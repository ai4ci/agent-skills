---
name: setup-opencode-sandbox
description: 'Use when setting up a sandboxed VM or container for opencode AI agent. Triggers: "create sandbox", "setup VM for opencode", "provision development environment", "create isolated environment for AI agent", "setup opencode on VirtualBox/Oracle Cloud/Singularity/HPC". Creates fully configured environments with SSH access to running opencode instance.'
license: MIT
---

# Setup OpenCode Sandbox

Provision sandboxed environments for running the opencode AI coding agent with full development toolchains. Supports local VirtualBox VMs, Oracle Cloud instances, and Singularity containers for HPC.

## Available Resources

**Scripts:**
- [scripts/generate-cloud-init.sh](scripts/generate-cloud-init.sh) - Generate cloud-init user-data YAML from parameters
- [scripts/create-vbox-vm.sh](scripts/create-vbox-vm.sh) - Create and launch VirtualBox VM with cloud-init

**Guides:**
- [references/bundle-config.md](references/bundle-config.md) - Bundling opencode configuration (custom configs, plugin selection)
- [references/python-dev.md](references/python-dev.md) - Python setup with uv, conda, version management
- [references/nodejs-dev.md](references/nodejs-dev.md) - Node.js setup with bun, npm, nvm
- [references/r-dev.md](references/r-dev.md) - R setup with r2u fast binary packages
- [references/java-dev.md](references/java-dev.md) - Java setup with OpenJDK, Maven, Gradle
- [references/rust-dev.md](references/rust-dev.md) - Rust setup with rustup, cargo
- [references/go-dev.md](references/go-dev.md) - Go development setup

## When to Use This Skill

Use this skill when the user wants to:
- Create a sandboxed VM for running opencode
- Set up an isolated development environment for AI agents
- Provision a cloud instance for opencode
- Create a Singularity container for HPC opencode usage
- Migrate a development setup to a new machine

Do NOT use this skill for:
- Installing opencode on the local machine directly
- Configuring opencode settings without sandboxing
- General VM administration unrelated to opencode

## Prerequisites

### Required Tools (varies by target)

**For VirtualBox VMs:**
- VirtualBox with `VBoxManage` CLI
- `qemu-img` (from qemu-utils package)
- `cloud-localds` (from cloud-image-utils package)

**For Oracle Cloud:**
- OCI CLI (`oci`) configured with credentials
- Existing VCN, subnet, and compartment

**For Singularity:**
- Singularity/Apptainer installed
- Root access OR fakeroot capability for building

### Required Information (gather interactively)

1. **Username** - User account to create in sandbox
2. **SSH public key** - For passwordless SSH access
3. **Target platform** - VirtualBox, Oracle Cloud, or Singularity
4. **GitHub project URL** - Repository to clone (optional)
5. **GitHub token** - For `gh` CLI access (optional)
6. **Dev environments** - Select from available guides (Python, Node.js, R, Java, Rust, Go)

## Workflow

### Step 1: Gather User Requirements

Interactively collect the necessary information. Use the question tool to prompt for:

```
1. Target platform: [VirtualBox VM, Oracle Cloud, HPC Singularity]
2. Username for the sandbox
3. SSH public key (list available keys from ~/.ssh/*.pub)
4. GitHub token (guide user to create one if needed)
5. Development environments to install (multi-select, see references/*-dev.md):
   - Python (uv)
   - Node.js (bun)
   - R (r2u + tidyverse)
   - Java (OpenJDK 21 + Maven)
   - Rust
   - Go
6. Enable passwordless sudo? [yes/no]
7. VM sizing (for VM targets): CPUs, Memory, Disk
```

For SSH key selection, list files:
```bash
ls -1 ~/.ssh/*.pub 2>/dev/null
```

For git config defaults:
```bash
git config --global user.name
git config --global user.email
```

### Step 2: Bundle OpenCode Configuration

Follow [references/bundle-config.md](references/bundle-config.md) to create a config bundle. Key decisions:

1. **Which opencode.json?** - Use existing local config, create a custom one, or modify existing
2. **Which plugins/MCP servers?** - Consider what makes sense in the sandbox context
3. **Include auth.json?** - Balance functionality vs. credential exposure.

The guide provides complete examples for:
- Minimal sandbox config
- Full config with selective modifications
- Custom plugin configurations

Output: a base64-encoded tar.gz file (e.g., `/tmp/opencode-bundle.b64`) for cloud-init.

### Step 3: Prepare Development Environment Snippets

Based on the selected development environments, create snippet files using the reference guides:

#### Create packages.txt

List additional apt packages needed (one per line):
```bash
# Example packages.txt for Python + R
gnupg
pkg-config
libssl-dev
```

#### Create runcmd.yml

Assemble runcmd entries from the relevant guides. Each guide (e.g., `references/python-dev.md`) provides cloud-init `runcmd` snippets.

```yaml
# Example runcmd.yml for Python (uv) + Node.js (bun)
  - curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
  - curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash
```

See the individual guides for detailed options:
- Python: version selection, uv vs conda, project setup
- R: r2u setup, package selection, Bioconductor
- Java: JDK version, Maven vs Gradle, GraalVM
- etc.

### Step 4: Generate Configuration

#### For VirtualBox or Oracle Cloud:

Generate cloud-init user-data using the snippet files:

```bash
./scripts/generate-cloud-init.sh \
  --username sandbox \
  --ssh-key "$(cat ~/.ssh/id_rsa.pub)" \
  --github-project https://github.com/user/repo \
  --github-token "$GITHUB_TOKEN" \
  --github-user "$GITHUB_USER" \
  --bundle-file /tmp/opencode-bundle.b64 \
  --packages-file packages.txt \
  --runcmd-file runcmd.yml \
  --passwordless-sudo \
  --output user-data.yml
```

#### For Singularity:

Copy the skeleton template and customize by adding snippets from the dev environment guides:

```bash
cp templates/opencode-sandbox.def ./opencode-sandbox.def
# Edit to add %post commands from the relevant *-dev.md guides
```

See [references/singularity-guide.md](references/singularity-guide.md) for detailed building blocks.

### Step 5: Validate Configuration

Before provisioning, validate the generated configuration to catch syntax errors.

#### Validate cloud-init YAML

```bash
# Use cloud-init's schema validator (recommended)
cloud-init schema --config-file user-data.yml

# Should output: "Valid schema user-data.yml"
# Ignore warnings about system config permissions - only the final line matters
```

If cloud-init is not installed locally:
```bash
# Fallback: check YAML syntax with Python
python3 -c "import yaml; yaml.safe_load(open('user-data.yml'))" && echo "YAML syntax OK"

# Manual inspection of critical sections
grep -E "^(users|packages|runcmd|write_files):" user-data.yml && echo "Key sections present"
```

#### Validate Singularity definition

```bash
# Check for basic structure
grep -E "^(Bootstrap|From|%post|%environment|%runscript):" opencode-sandbox.def && echo "Key sections present"

# Test build in sandbox mode (faster iteration)
sudo singularity build --sandbox /tmp/test-sandbox opencode-sandbox.def

# Verify tools in sandbox
singularity exec /tmp/test-sandbox which opencode
singularity exec /tmp/test-sandbox opencode --version

# Clean up test sandbox
rm -rf /tmp/test-sandbox
```

If validation fails, fix the issues before proceeding to provisioning.

### Step 6: Provision the Environment

#### VirtualBox VM:

Using the input from the user around VM size and name do something like:

```bash
./scripts/create-vbox-vm.sh \
  --name opencode-sandbox \
  --user-data user-data.yml \
  --cpus 4 \
  --memory 8192 \
  --disk 40960 \
  --ip 192.168.56.10
```

#### Oracle Cloud:

Using input from user (CRITICAL to get the correct ssh key)

```bash
# Get required IDs
COMPARTMENT_ID=$(oci iam compartment list --query "data[0].id" --raw-output)
SUBNET_ID=$(oci network subnet list -c "$COMPARTMENT_ID" --query "data[0].id" --raw-output)
AD=$(oci iam availability-domain list -c "$COMPARTMENT_ID" --query "data[0].name" --raw-output)
IMAGE_ID=$(oci compute image list -c "$COMPARTMENT_ID" \
  --operating-system "Canonical Ubuntu" \
  --operating-system-version "24.04" \
  --query "data[0].id" --raw-output)

# Launch instance
oci compute instance launch \
  --compartment-id "$COMPARTMENT_ID" \
  --availability-domain "$AD" \
  --shape "VM.Standard.A1.Flex" \
  --shape-config '{"ocpus": 4, "memoryInGBs": 24}' \
  --subnet-id "$SUBNET_ID" \
  --image-id "$IMAGE_ID" \
  --ssh-authorized-keys-file ~/.ssh/id_rsa.pub \
  --user-data-file user-data.yml \
  --display-name "opencode-sandbox" \
  --assign-public-ip true \
  --wait-for-state RUNNING
```

#### Singularity on HPC:

Build the final image (after validation passed):
```bash
sudo singularity build opencode-sandbox.sif opencode-sandbox.def
# Or with fakeroot:
singularity build --fakeroot opencode-sandbox.sif opencode-sandbox.def
```

Transfer to HPC:
```bash
scp opencode-sandbox.sif user@hpc:/path/to/containers/
```

Then on the HPC system:
```bash
singularity run \
  --bind $HOME/project:/workspace \
  --bind $HOME/.config/opencode:/root/.config/opencode \
  --bind $HOME/.local/share/opencode:/root/.local/share/opencode \
  opencode-sandbox.sif
```

### Step 7: Wait for Setup and Connect

#### For VMs (VirtualBox/Oracle):

Wait for cloud-init to complete:
```bash
ssh -o StrictHostKeyChecking=no user@HOST 'cloud-init status --wait'
```

Or check for the ready marker:
```bash
ssh user@HOST 'while [ ! -f /var/lib/cloud/instance/opencode-ready ]; do sleep 5; done'
```

Then connect and start opencode:
```bash
ssh user@HOST
cd project
opencode
```

#### For Singularity:

Run interactively:
```bash
singularity shell --bind $HOME/project:/workspace opencode-sandbox.sif
cd /workspace
opencode
```

### Step 8: Provide Connection Details

After successful setup, provide the user with:

1. **SSH command** to connect to the sandbox
2. **Location** of the cloned project
3. **How to start opencode** in the project
4. **How to stop/delete** the sandbox when done

## Guidance

### GitHub Token Scopes

When guiding user to create a GitHub token, recommend these scopes:
- `repo` - Full repository access
- `read:org` - Read org membership (for private repos)
- `workflow` - Update GitHub Actions workflows

Create at: https://github.com/settings/tokens/new

Or use `gh auth token` if `gh` is already configured locally.

### Security Considerations

- **Passwordless sudo**: Only enable for trusted, isolated environments
- **GitHub tokens**: Tokens are stored in plaintext in the VM; use fine-grained tokens with minimal scopes
- **OpenCode auth tokens**: `auth.json` contains API credentials; consider excluding from bundle or using scoped tokens
- **Network isolation**: VirtualBox host-only networking limits exposure; Oracle Cloud instances are publicly accessible

### File Transfer Architecture

Files are transferred via cloud-init's `write_files` with base64-encoded tar:

```
Local Machine                    Sandbox VM
─────────────────────────────────────────────
~/.config/opencode/    ──┐
                         ├─ tar.gz ─ base64 ─ cloud-init ─ untar ─► ~/.config/opencode/
~/.local/share/opencode/ ┘                                         ~/.local/share/opencode/
```

This approach:
- Works across all platforms (VirtualBox, OCI)
- Requires no separate file transfer step
- Is extensible to additional directories

### Extending File Transfers

To transfer additional directories, see [references/bundle-config.md](references/bundle-config.md) - the bundling guide covers adding extra directories like `~/.local/bin`.

## Validation

After setup completes, verify:

- [ ] SSH connection works without password
- [ ] User has correct sudo permissions
- [ ] opencode binary is available (`which opencode`)
- [ ] opencode config is present (`ls ~/.config/opencode`)
- [ ] Git project is cloned (if specified)
- [ ] `gh auth status` works (if token provided)
- [ ] Dev environments are installed (`uv --version`, `bun --version`, etc.)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| cloud-init never completes | Check `/var/log/cloud-init-output.log` on the VM |
| SSH connection refused | Wait longer; check firewall rules; verify IP address |
| VirtualBox network not working | Ensure host-only adapter exists: `VBoxManage hostonlyif create` |
| OCI instance not reachable | Check security list allows SSH (port 22) |
| Singularity build fails | Try with `--fakeroot` or build on system with root access |
| opencode not found | Check if install script ran; try manual install |
| GitHub clone fails | Verify token has `repo` scope; check URL is correct |

### Checking Cloud-Init Logs

```bash
# Full output log
ssh user@HOST 'cat /var/log/cloud-init-output.log'

# Cloud-init status
ssh user@HOST 'cloud-init status --long'

# Specific module failures
ssh user@HOST 'cat /var/log/cloud-init.log | grep -i error'
```

### Cleaning Up

**VirtualBox:**
```bash
VBoxManage controlvm VM_NAME poweroff
VBoxManage unregistervm VM_NAME --delete
```

**Oracle Cloud:**
```bash
oci compute instance terminate --instance-id INSTANCE_OCID --force
```

## References

- [Cloud-init documentation](https://cloudinit.readthedocs.io/)
- [OCI CLI reference](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/)
- [Singularity definition files](https://docs.sylabs.io/guides/latest/user-guide/definition_files.html)
- [references/bundle-config.md](references/bundle-config.md) - Bundling opencode configuration
- [references/cloud-init-guide.md](references/cloud-init-guide.md) - Detailed cloud-init configuration
- [references/singularity-guide.md](references/singularity-guide.md) - Singularity container guide

### Development Environment Guides

- [references/python-dev.md](references/python-dev.md) - Python with uv, conda, version management
- [references/nodejs-dev.md](references/nodejs-dev.md) - Node.js with bun, npm, nvm
- [references/r-dev.md](references/r-dev.md) - R with r2u binary packages
- [references/java-dev.md](references/java-dev.md) - Java with OpenJDK, Maven, Gradle
- [references/rust-dev.md](references/rust-dev.md) - Rust with rustup, cargo
- [references/go-dev.md](references/go-dev.md) - Go development
