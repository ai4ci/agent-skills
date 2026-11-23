# Python Development Environment

Setup Python development environment with modern tooling. The recommended approach uses **uv** - a fast Python package and project manager written in Rust.

## Decision Points

### 1. Package Manager

| Option | Pros | Cons | When to Use |
|--------|------|------|-------------|
| **uv** (recommended) | Extremely fast, manages Python versions, replaces pip/venv/pyenv | Newer tool | Most projects, especially new ones |
| **pip + venv** | Standard, universal | Slower, no Python version management | Legacy compatibility |
| **conda/mamba** | Data science packages, non-Python deps | Heavy, slower | Scientific computing, complex native deps |

### 2. Python Version

- **3.12** - Current stable, recommended for most projects
- **3.11** - Previous stable, wide compatibility
- **3.10** - Older stable, some legacy projects require it
- **Multiple versions** - uv can manage multiple versions

### 3. Additional Packages

Consider pre-installing common tools:
- **ruff** - Fast linter and formatter
- **pytest** - Testing framework
- **ipython** - Enhanced interactive shell
- Project-specific dependencies from `requirements.txt` or `pyproject.toml`

## Cloud-Init Setup

### Minimal Setup (uv only)

Add to `packages` section:
```yaml
packages:
  - curl
```

Add to `runcmd` section:
```yaml
runcmd:
  # Install uv system-wide
  - curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
```

### With Python Pre-installed

```yaml
runcmd:
  # Install uv
  - curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
  
  # Install specific Python version via uv
  - uv python install 3.12
  
  # Install global tools
  - uv tool install ruff
  - uv tool install pytest
```

### With Project Dependencies

```yaml
runcmd:
  # Install uv
  - curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
  
  # Install Python and sync project (run as user, in project dir)
  - su - USERNAME -c "cd /home/USERNAME/project && uv sync"
```

### Alternative: pip + venv (Standard)

If you need the standard Python toolchain:

```yaml
packages:
  - python3
  - python3-pip
  - python3-venv

runcmd:
  # Upgrade pip
  - python3 -m pip install --upgrade pip
  
  # Create project venv and install deps (as user)
  - su - USERNAME -c "cd /home/USERNAME/project && python3 -m venv .venv && .venv/bin/pip install -r requirements.txt"
```

### Alternative: Conda/Mamba

For scientific computing with complex native dependencies:

```yaml
runcmd:
  # Install miniforge (includes mamba)
  - curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
  - bash Miniforge3-*.sh -b -p /opt/miniforge3
  - rm Miniforge3-*.sh
  - ln -s /opt/miniforge3/bin/mamba /usr/local/bin/mamba
  - ln -s /opt/miniforge3/bin/conda /usr/local/bin/conda
  
  # Initialize for user
  - su - USERNAME -c "/opt/miniforge3/bin/conda init bash"
```

## Singularity Setup

### Definition File Section

```singularity
%post
    # Install uv
    curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
    
    # Install Python
    uv python install 3.12
    
    # Install common tools
    uv tool install ruff
    uv tool install pytest
    uv tool install ipython

%environment
    export PATH="/usr/local/bin:$PATH"
```

### With Conda (for scientific workloads)

```singularity
%post
    # Install miniforge
    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
    bash Miniforge3-Linux-x86_64.sh -b -p /opt/miniforge3
    rm Miniforge3-Linux-x86_64.sh
    
    # Create environment
    /opt/miniforge3/bin/mamba create -n dev python=3.12 numpy pandas scikit-learn -y

%environment
    export PATH="/opt/miniforge3/bin:$PATH"
    . /opt/miniforge3/etc/profile.d/conda.sh
    conda activate dev
```

## Project-Specific Setup

### For pyproject.toml projects (uv)

After cloning the project:
```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && uv sync"
```

This creates a `.venv` and installs all dependencies including dev dependencies.

### For requirements.txt projects

```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && uv venv && uv pip install -r requirements.txt"
```

### Installing Editable Package

```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && uv pip install -e ."
```

## Verification

Add these to verify the setup:

```yaml
runcmd:
  # ... installation commands ...
  
  # Verify
  - uv --version
  - uv python list
  - which python3
```

## Common Configurations

### Data Science Setup

```yaml
runcmd:
  - curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
  - uv python install 3.12
  - uv tool install jupyter
  - uv tool install ipython
```

### Web Development Setup

```yaml
runcmd:
  - curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
  - uv python install 3.12
  - uv tool install ruff
  - uv tool install pytest
  - uv tool install httpie
```

### CLI Tool Development

```yaml
runcmd:
  - curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
  - uv python install 3.12
  - uv tool install ruff
  - uv tool install pytest
  - uv tool install build
  - uv tool install twine
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `uv` not found | Ensure `/usr/local/bin` is in PATH |
| Permission denied | Run install as root, run project commands as user |
| Python version not found | Run `uv python install X.Y` first |
| Package build fails | Install build deps: `apt-get install build-essential python3-dev` |
| SSL errors | Install: `apt-get install ca-certificates` |
