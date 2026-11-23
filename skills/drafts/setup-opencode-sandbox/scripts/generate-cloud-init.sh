#!/usr/bin/env bash
# Generate cloud-init user-data YAML for opencode sandbox
# Usage: generate-cloud-init.sh --username NAME --ssh-key "KEY" [OPTIONS]
#
# Required:
#   --username NAME       Username to create
#   --ssh-key "KEY"       SSH public key content
#
# Optional:
#   --hostname NAME       Hostname (default: opencode-sandbox)
#   --github-token TOKEN  GitHub personal access token
#   --github-user USER    GitHub username
#   --git-name NAME       Git user.name
#   --git-email EMAIL     Git user.email
#   --passwordless-sudo   Enable passwordless sudo
#   --bundle-file FILE    Base64-encoded config bundle
#   --packages-file FILE  File with additional packages (one per line)
#   --runcmd-file FILE    File with additional runcmd entries (YAML list items)
#   --output FILE         Output file (default: stdout)

set -euo pipefail

# Defaults
HOSTNAME="opencode-sandbox"
USERNAME=""
SSH_KEY=""
GITHUB_TOKEN=""
GITHUB_USER=""
GIT_NAME=""
GIT_EMAIL=""
PASSWORDLESS_SUDO="false"
BUNDLE_FILE=""
PACKAGES_FILE=""
RUNCMD_FILE=""
OUTPUT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --username) USERNAME="$2"; shift 2 ;;
        --hostname) HOSTNAME="$2"; shift 2 ;;
        --ssh-key) SSH_KEY="$2"; shift 2 ;;
        --github-token) GITHUB_TOKEN="$2"; shift 2 ;;
        --github-user) GITHUB_USER="$2"; shift 2 ;;
        --git-name) GIT_NAME="$2"; shift 2 ;;
        --git-email) GIT_EMAIL="$2"; shift 2 ;;
        --passwordless-sudo) PASSWORDLESS_SUDO="true"; shift ;;
        --bundle-file) BUNDLE_FILE="$2"; shift 2 ;;
        --packages-file) PACKAGES_FILE="$2"; shift 2 ;;
        --runcmd-file) RUNCMD_FILE="$2"; shift 2 ;;
        -o|--output) OUTPUT="$2"; shift 2 ;;
        -h|--help)
            cat <<EOF
Generate cloud-init user-data for opencode sandbox.

Usage: $(basename "$0") --username NAME --ssh-key "KEY" [OPTIONS]

Required:
  --username NAME       Username to create in sandbox
  --ssh-key "KEY"       SSH public key (content, not file path)

Optional:
  --hostname NAME       VM hostname (default: opencode-sandbox)
  --github-token TOKEN  GitHub PAT for gh CLI
  --github-user USER    GitHub username
  --git-name NAME       Git user.name (default: from local git config)
  --git-email EMAIL     Git user.email (default: from local git config)
  --passwordless-sudo   Enable passwordless sudo for user
  --bundle-file FILE    File containing base64-encoded config bundle
  --packages-file FILE  File with additional apt packages (one per line)
  --runcmd-file FILE    File with additional runcmd entries (YAML format)
  -o, --output FILE     Output file (default: stdout)

The --packages-file should contain package names, one per line:
  python3
  python3-pip
  nodejs

The --runcmd-file should contain YAML runcmd list items:
  - curl -LsSf https://astral.sh/uv/install.sh | sh
  - apt-get install -y r-base

See references/*-dev.md guides for dev environment snippets.

Example:
  $(basename "$0") --username sandbox --ssh-key "\$(cat ~/.ssh/id_rsa.pub)" \\
    --packages-file packages.txt --runcmd-file runcmd.yml \\
    --passwordless-sudo
EOF
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

# Validate required args
if [[ -z "$USERNAME" ]]; then
    echo "Error: --username is required" >&2
    exit 1
fi
if [[ -z "$SSH_KEY" ]]; then
    echo "Error: --ssh-key is required" >&2
    exit 1
fi

# Get git config defaults if not provided
if [[ -z "$GIT_NAME" ]] && command -v git &>/dev/null; then
    GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
fi
if [[ -z "$GIT_EMAIL" ]] && command -v git &>/dev/null; then
    GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
fi

# Determine sudo config
if [[ "$PASSWORDLESS_SUDO" == "true" ]]; then
    SUDO_LINE="ALL=(ALL) NOPASSWD:ALL"
else
    SUDO_LINE="ALL=(ALL:ALL) ALL"
fi

# Read additional packages if provided
EXTRA_PACKAGES=""
if [[ -n "$PACKAGES_FILE" ]] && [[ -f "$PACKAGES_FILE" ]]; then
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        # Skip empty lines and comments
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
        EXTRA_PACKAGES+="  - ${pkg}
"
    done < "$PACKAGES_FILE"
fi

# Read additional runcmd entries if provided
EXTRA_RUNCMD=""
if [[ -n "$RUNCMD_FILE" ]] && [[ -f "$RUNCMD_FILE" ]]; then
    EXTRA_RUNCMD=$(cat "$RUNCMD_FILE")
fi

# Read bundle if provided
BUNDLE_CONTENT=""
if [[ -n "$BUNDLE_FILE" ]] && [[ -f "$BUNDLE_FILE" ]]; then
    BUNDLE_CONTENT=$(cat "$BUNDLE_FILE")
fi

# Generate YAML
generate_yaml() {
cat <<EOF
#cloud-config
hostname: ${HOSTNAME}

users:
  - name: ${USERNAME}
    groups: sudo
    shell: /bin/bash
    sudo: ${SUDO_LINE}
    ssh_authorized_keys:
      - ${SSH_KEY}

package_update: true
package_upgrade: false
packages:
  - git
  - curl
  - wget
  - build-essential
  - ca-certificates
  - jq
  - unzip
  - openssh-client
EOF

# Add extra packages if provided
if [[ -n "$EXTRA_PACKAGES" ]]; then
    printf "%s" "$EXTRA_PACKAGES"
fi

# Add write_files section if we have content
if [[ -n "$BUNDLE_CONTENT" ]] || [[ -n "$GITHUB_TOKEN" ]] || [[ -n "$GIT_NAME" ]]; then
    echo ""
    echo "write_files:"
    
    # Bundle file
    if [[ -n "$BUNDLE_CONTENT" ]]; then
        cat <<EOF
  - path: /tmp/opencode-bundle.tar.gz
    encoding: base64
    content: ${BUNDLE_CONTENT}
EOF
    fi
    
    # GitHub CLI config
    if [[ -n "$GITHUB_TOKEN" ]] && [[ -n "$GITHUB_USER" ]]; then
        cat <<EOF
  - path: /home/${USERNAME}/.config/gh/hosts.yml
    owner: ${USERNAME}:${USERNAME}
    permissions: '0600'
    content: |
      github.com:
        oauth_token: ${GITHUB_TOKEN}
        user: ${GITHUB_USER}
        git_protocol: https
EOF
    fi
    
    # Git config
    if [[ -n "$GIT_NAME" ]] || [[ -n "$GIT_EMAIL" ]]; then
        cat <<EOF
  - path: /home/${USERNAME}/.gitconfig
    owner: ${USERNAME}:${USERNAME}
    permissions: '0644'
    content: |
      [user]
EOF
        [[ -n "$GIT_NAME" ]] && echo "        name = ${GIT_NAME}"
        [[ -n "$GIT_EMAIL" ]] && echo "        email = ${GIT_EMAIL}"
    fi
fi

# runcmd section
echo ""
echo "runcmd:"

# Extract bundle if present
if [[ -n "$BUNDLE_CONTENT" ]]; then
    cat <<EOF
  - mkdir -p /home/${USERNAME}/.config /home/${USERNAME}/.local/share
  - tar -xzf /tmp/opencode-bundle.tar.gz -C /home/${USERNAME}
  - chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config
  - chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local
  - rm /tmp/opencode-bundle.tar.gz
EOF
fi

# Custom runcmd entries (dev environments, etc.)
if [[ -n "$EXTRA_RUNCMD" ]]; then
    echo "$EXTRA_RUNCMD"
fi

# Install opencode
cat <<EOF
  - curl -fsSL https://opencode.ai/install | sh
  - cp /root/.local/bin/opencode /usr/local/bin/ || true
EOF

# Signal completion
cat <<EOF
  - touch /var/lib/cloud/instance/opencode-ready
  - echo "OpenCode sandbox setup complete" | tee /var/log/opencode-setup.log
EOF
}

# Output
if [[ -n "$OUTPUT" ]]; then
    generate_yaml > "$OUTPUT"
    echo "Cloud-init config written to $OUTPUT" >&2
else
    generate_yaml
fi
