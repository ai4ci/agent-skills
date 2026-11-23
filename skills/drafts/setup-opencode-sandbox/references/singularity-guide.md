# Singularity Container Guide

Build Singularity containers for running opencode on HPC systems. This guide covers the decision points and building blocks - assemble them based on your specific requirements.

## Decision Points

### 1. Base Image

| Option | When to Use |
|--------|-------------|
| `ubuntu:24.04` | Standard development, most cases |
| `ubuntu:22.04` | Compatibility with older systems |
| `nvidia/cuda:12.4-devel-ubuntu24.04` | GPU workloads, CUDA development |
| `nvidia/cuda:12.4-runtime-ubuntu24.04` | GPU inference only (smaller) |
| `rocm/dev-ubuntu-24.04` | AMD GPU workloads |

### 2. Build Method

| Method | Pros | Cons | When to Use |
|--------|------|------|-------------|
| `sudo singularity build` | Full control | Needs root | Local dev machine |
| `singularity build --fakeroot` | No root needed | May have limitations | User systems with fakeroot |
| `singularity build --remote` | No local root | Needs Sylabs account | HPC without build privileges |
| Convert from Docker | Leverage existing Dockerfiles | Extra step | Existing Docker workflow |

### 3. Config Transfer Method

| Method | When to Use |
|--------|-------------|
| **Bind mounts at runtime** (recommended) | Keep config outside container, easy updates |
| **Embed via %files** | Self-contained image, config rarely changes |
| **Overlay filesystem** | Need persistent changes within container |

## Definition File Structure

A Singularity `.def` file has these sections:

```singularity
Bootstrap: docker
From: ubuntu:24.04

%labels
    # Metadata

%post
    # Build-time commands (install packages, configure)

%environment
    # Runtime environment variables

%files
    # Copy files from host at build time

%runscript
    # Default command when running container

%startscript
    # Command for `singularity instance start`

%help
    # Documentation shown by `singularity run-help`
```

## Building Blocks

### Header (Required)

```singularity
Bootstrap: docker
From: ubuntu:24.04
```

Or with CUDA:
```singularity
Bootstrap: docker
From: nvidia/cuda:12.4-devel-ubuntu24.04
```

### Labels (Recommended)

```singularity
%labels
    Author your-name
    Version 1.0
    Description OpenCode sandbox for HPC
```

### Base System Packages

```singularity
%post
    apt-get update && apt-get install -y \
        git \
        curl \
        wget \
        build-essential \
        ca-certificates \
        jq \
        unzip \
        openssh-client \
        vim
    
    # Cleanup to reduce image size
    apt-get clean
    rm -rf /var/lib/apt/lists/*
```

### OpenCode Installation

```singularity
%post
    # Install opencode
    curl -fsSL https://opencode.ai/install | sh
    
    # Make available system-wide
    cp /root/.local/bin/opencode /usr/local/bin/ 2>/dev/null || true
```

### Development Environments

Add these to `%post` based on requirements. See the individual `*-dev.md` guides for detailed options.

**Python (uv):**
```singularity
    # Python via uv
    curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
    uv python install 3.12
```

**Node.js (bun):**
```singularity
    # Node.js via bun
    curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash
```

**R (r2u):**
```singularity
    # R with r2u binary packages
    apt-get install -y gnupg
    gpg --homedir /tmp --no-default-keyring \
        --keyring /usr/share/keyrings/r2u.gpg \
        --keyserver keyserver.ubuntu.com \
        --recv-keys A1489FE2AB99A21A 67C2D66C4B1D4339 51716619E084DAB9
    
    cat > /etc/apt/sources.list.d/r2u.sources << 'EOF'
Types: deb
URIs: https://r2u.stat.illinois.edu/ubuntu
Suites: noble
Components: main
Arch: amd64
Signed-By: /usr/share/keyrings/r2u.gpg
EOF
    
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y r-base-core
    apt-get install -y r-cran-tidyverse
```

**Java:**
```singularity
    apt-get install -y openjdk-21-jdk maven
```

**Rust:**
```singularity
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
      RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo \
      sh -s -- -y --default-toolchain stable
    ln -s /opt/cargo/bin/* /usr/local/bin/
```

**Go:**
```singularity
    GO_VERSION="1.22.2"
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    ln -s /usr/local/go/bin/* /usr/local/bin/
```

### Environment Variables

```singularity
%environment
    export PATH=/usr/local/bin:/usr/local/go/bin:$PATH
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
    export HOME=/root
    
    # For Rust (if installed)
    export RUSTUP_HOME=/opt/rustup
    export CARGO_HOME=/opt/cargo
```

### Entry Points

**Run opencode by default:**
```singularity
%runscript
    cd "${WORKSPACE:-/workspace}"
    exec opencode "$@"
```

**Interactive shell as default:**
```singularity
%runscript
    cd "${WORKSPACE:-/workspace}"
    exec /bin/bash
```

**For Singularity instances:**
```singularity
%startscript
    cd "${WORKSPACE:-/workspace}"
    opencode
```

### Help Documentation

```singularity
%help
    OpenCode Sandbox Container
    
    Usage:
      singularity run --bind /path/to/project:/workspace container.sif
      singularity shell --bind /path/to/project:/workspace container.sif
      singularity exec container.sif <command>
    
    Required bind mounts:
      /path/to/project:/workspace     Your project directory
    
    Optional bind mounts:
      ~/.config/opencode:/root/.config/opencode:ro    OpenCode config
      ~/.local/share/opencode:/root/.local/share/opencode    Auth tokens
    
    GPU support:
      singularity run --nv ...    (NVIDIA)
      singularity run --rocm ...  (AMD)
```

### Workspace Directory

```singularity
%post
    mkdir -p /workspace
    chmod 777 /workspace
```

## Validation

### Check Definition Syntax

Before building, validate the definition file:

```bash
# Basic syntax check (looks for common issues)
singularity inspect --deffile mycontainer.def 2>&1 || echo "Check definition file"

# Dry-run parse (if available in your version)
singularity build --sandbox /tmp/test-build mycontainer.def --no-build 2>&1 | head -20
```

### Test Build in Sandbox Mode

Build as writable sandbox first for faster iteration:

```bash
# Build sandbox (faster, allows testing)
sudo singularity build --sandbox /tmp/sandbox-test mycontainer.def

# Test it
singularity shell /tmp/sandbox-test

# Once working, build final .sif
sudo singularity build mycontainer.sif /tmp/sandbox-test

# Cleanup
rm -rf /tmp/sandbox-test
```

### Post-Build Verification

```bash
# Check container runs
singularity run mycontainer.sif --help

# Verify installed tools
singularity exec mycontainer.sif which opencode
singularity exec mycontainer.sif python3 --version 2>/dev/null || true
singularity exec mycontainer.sif node --version 2>/dev/null || true
singularity exec mycontainer.sif R --version 2>/dev/null || true

# Check environment
singularity exec mycontainer.sif env | grep -E '^(PATH|HOME|LANG)'
```

## Building

### Standard Build (with root)

```bash
sudo singularity build mycontainer.sif mycontainer.def
```

### Fakeroot Build (unprivileged)

```bash
singularity build --fakeroot mycontainer.sif mycontainer.def
```

### Remote Build (Sylabs Cloud)

```bash
# Login first (one-time)
singularity remote login

# Build remotely
singularity build --remote mycontainer.sif mycontainer.def
```

### From Docker Image

```bash
# Direct pull and convert
singularity build mycontainer.sif docker://ubuntu:24.04

# From local Docker daemon
docker build -t myimage .
singularity build mycontainer.sif docker-daemon://myimage:latest
```

## Running

### Basic Usage

```bash
# Interactive shell
singularity shell mycontainer.sif

# Run default command
singularity run mycontainer.sif

# Execute specific command
singularity exec mycontainer.sif opencode --help
```

### With Bind Mounts

```bash
# Project directory
singularity run --bind /path/to/project:/workspace mycontainer.sif

# With opencode config
singularity run \
    --bind $HOME/project:/workspace \
    --bind $HOME/.config/opencode:/root/.config/opencode:ro \
    --bind $HOME/.local/share/opencode:/root/.local/share/opencode \
    mycontainer.sif
```

### GPU Support

```bash
# NVIDIA GPU
singularity run --nv --bind /path/to/project:/workspace mycontainer.sif

# AMD GPU
singularity run --rocm --bind /path/to/project:/workspace mycontainer.sif
```

### Clean Environment

```bash
# Isolate from host environment
singularity run --cleanenv --bind /path/to/project:/workspace mycontainer.sif
```

## HPC Job Scripts

### Slurm Example

```bash
#!/bin/bash
#SBATCH --job-name=opencode
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --gres=gpu:1

module load singularity  # if needed on your HPC

singularity exec --nv \
    --bind $HOME/project:/workspace \
    --bind $HOME/.config/opencode:/root/.config/opencode:ro \
    --bind $HOME/.local/share/opencode:/root/.local/share/opencode \
    $HOME/containers/opencode.sif \
    opencode
```

### PBS Example

```bash
#!/bin/bash
#PBS -N opencode
#PBS -l nodes=1:ppn=4
#PBS -l mem=16gb
#PBS -l walltime=04:00:00

cd $PBS_O_WORKDIR

singularity exec \
    --bind $HOME/project:/workspace \
    $HOME/containers/opencode.sif \
    opencode
```

## Overlay Filesystems

For persistent changes within the container:

```bash
# Create overlay image
singularity overlay create --size 1024 overlay.img

# Use with container
singularity run --overlay overlay.img mycontainer.sif

# Changes persist in overlay.img
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails with permission denied | Use `sudo` or `--fakeroot` |
| Fakeroot not working | Check `/etc/subuid` and `/etc/subgid` have entries for your user |
| Container can't find files | Check bind mount paths; use absolute paths |
| GPU not detected | Ensure `--nv` flag and nvidia drivers on host |
| Network issues in build | Check proxy settings; some HPC systems need `--network none` |
| "File not found" for bound paths | The mount point must exist in container |
| Slow filesystem performance | Use `--bind` not `--overlay` for large datasets |

## Best Practices

1. **Keep images small** - Remove apt caches, use multi-stage builds
2. **Use bind mounts for data** - Don't embed large datasets in image
3. **Test locally first** - Build and test before transferring to HPC
4. **Document in %help** - Future you will thank present you
5. **Version your definitions** - Keep .def files in git
6. **Use specific base image tags** - `ubuntu:24.04` not `ubuntu:latest`
