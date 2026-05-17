# Cloud-Init Configuration Guide

This reference covers cloud-init configuration for setting up opencode sandboxes on VMs.

## Overview

Cloud-init is the industry standard for cross-platform cloud instance initialization. It runs during initial boot and configures:
- Users and SSH keys
- Package installation
- File creation
- Script execution

## Key Modules Used

### write_files

Write arbitrary files to disk. Supports base64 encoding for binary content:

```yaml
write_files:
  - path: /home/sandbox/.config/opencode/config.yaml
    owner: sandbox:sandbox
    permissions: '0600'
    encoding: base64
    content: <base64-encoded-content>
```

For transferring directory trees, use base64-encoded tar:

```yaml
write_files:
  - path: /tmp/opencode-bundle.tar.gz
    encoding: base64
    content: <base64-encoded-tar-gz>

runcmd:
  - tar -xzf /tmp/opencode-bundle.tar.gz -C /home/sandbox
  - chown -R sandbox:sandbox /home/sandbox/.config/opencode
  - rm /tmp/opencode-bundle.tar.gz
```

### users

Create users with SSH keys and sudo access:

```yaml
users:
  - name: sandbox
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAA...
```

### packages

Install packages during boot:

```yaml
package_update: true
package_upgrade: true
packages:
  - git
  - curl
  - build-essential
```

### runcmd

Run commands after boot (runs once):

```yaml
runcmd:
  - curl -LsSf https://astral.sh/uv/install.sh | sh
  - su - sandbox -c "git clone https://github.com/user/project /home/sandbox/project"
```

## Dev Environment Snippets

### Python with uv

```yaml
runcmd:
  - curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
```

### Node.js with bun

```yaml
runcmd:
  - curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash
```

### R with r2u (fast binary packages)

```yaml
runcmd:
  - |
    apt-get update -qq
    apt-get install -y --no-install-recommends ca-certificates gnupg
    gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/r2u.gpg \
        --keyserver keyserver.ubuntu.com --recv-keys A1489FE2AB99A21A 67C2D66C4B1D4339 51716619E084DAB9
    cat > /etc/apt/sources.list.d/r2u.sources <<EOF
    Types: deb
    URIs: https://r2u.stat.illinois.edu/ubuntu
    Suites: noble
    Components: main
    Arch: amd64, arm64
    Signed-By: /usr/share/keyrings/r2u.gpg
    EOF
    cat > /etc/apt/sources.list.d/cran.sources <<EOF
    Types: deb
    URIs: https://cloud.r-project.org/bin/linux/ubuntu
    Suites: noble-cran40/
    Components:
    Arch: amd64, arm64
    Signed-By: /usr/share/keyrings/r2u.gpg
    EOF
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends r-base-core
    Rscript -e 'install.packages(c("tidyverse", "bspm"))'
```

### Java with Maven

```yaml
packages:
  - openjdk-21-jdk
  - maven
```

## GitHub Token Configuration

Set up `gh` CLI with token:

```yaml
write_files:
  - path: /home/sandbox/.config/gh/hosts.yml
    owner: sandbox:sandbox
    permissions: '0600'
    content: |
      github.com:
        oauth_token: ${GITHUB_TOKEN}
        user: ${GITHUB_USER}
        git_protocol: https
```

## Complete Template Structure

```yaml
#cloud-config
users:
  - name: ${USERNAME}
    groups: sudo
    shell: /bin/bash
    sudo: ${SUDO_CONFIG}
    ssh_authorized_keys:
      - ${SSH_PUBLIC_KEY}

package_update: true
packages:
  - git
  - curl
  - build-essential
  - jq

write_files:
  - path: /tmp/opencode-bundle.tar.gz
    encoding: base64
    content: ${OPENCODE_BUNDLE_BASE64}
  
  - path: /home/${USERNAME}/.config/gh/hosts.yml
    owner: ${USERNAME}:${USERNAME}
    permissions: '0600'
    content: |
      github.com:
        oauth_token: ${GITHUB_TOKEN}
        user: ${GITHUB_USER}
        git_protocol: https

  - path: /home/${USERNAME}/.gitconfig
    owner: ${USERNAME}:${USERNAME}
    permissions: '0644'
    content: |
      [user]
        name = ${GIT_NAME}
        email = ${GIT_EMAIL}

runcmd:
  # Extract opencode config bundle
  - tar -xzf /tmp/opencode-bundle.tar.gz -C /home/${USERNAME}
  - chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config/opencode
  - chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local/share/opencode
  - rm /tmp/opencode-bundle.tar.gz
  
  # Install dev tools (conditional based on selection)
  ${DEV_TOOLS_INSTALL}
  
  # Clone the project
  - su - ${USERNAME} -c "git clone ${GITHUB_PROJECT} /home/${USERNAME}/project"
  
  # Install opencode
  - curl -fsSL https://opencode.ai/install | sh
  
  # Signal completion
  - touch /var/lib/cloud/instance/opencode-ready
```

## VirtualBox-Specific Notes

For VirtualBox, cloud-init data is provided via a seed ISO (NoCloud datasource):

```bash
# Create seed ISO with cloud-localds
cloud-localds --network-config network-config.yml seed.iso user-data.yml meta-data.yml
```

The meta-data file:
```yaml
instance-id: opencode-sandbox-001
local-hostname: ${HOSTNAME}
```

## Oracle Cloud-Specific Notes

OCI instances receive cloud-init via the metadata service. Use `--user-data-file`:

```bash
oci compute instance launch \
  --availability-domain "${AD}" \
  --compartment-id "${COMPARTMENT_ID}" \
  --shape "${SHAPE}" \
  --subnet-id "${SUBNET_ID}" \
  --image-id "${IMAGE_ID}" \
  --ssh-authorized-keys-file ~/.ssh/id_rsa.pub \
  --user-data-file user-data.yml \
  --display-name "opencode-sandbox" \
  --wait-for-state RUNNING
```

## Waiting for Cloud-Init Completion

```bash
# Wait for cloud-init to complete
ssh user@host 'cloud-init status --wait'

# Or check specific file
ssh user@host 'while [ ! -f /var/lib/cloud/instance/opencode-ready ]; do sleep 5; done'
```
