# Bundling OpenCode Configuration

This guide walks through bundling opencode configuration files for transfer to a sandbox environment. The bundle is a base64-encoded tar.gz that gets embedded in cloud-init's `write_files` section.

## What Gets Bundled

Typically you'll want to bundle:

| Path | Purpose | Required? |
|------|---------|-----------|
| `~/.config/opencode/` | Main config directory | Yes |
| `~/.local/share/opencode/auth.json` | Authentication tokens | Yes (for GitHub/API access) |
| `~/.local/bin/` | Custom binaries | Optional |

## Decision Points

Before bundling, consider these questions:

### 1. Which opencode.json to use?

**Option A: Use existing local config**
```bash
# Your current config
cat ~/.config/opencode/opencode.json
```

**Option B: Create a custom config for the sandbox**
```bash
# Create a minimal sandbox-specific config
cat > /tmp/opencode-sandbox-config/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcpServers": {
    // Only include servers that make sense in sandbox
  }
}
EOF
```

**Option C: Modify existing config**
```bash
# Copy and modify
cp ~/.config/opencode/opencode.json /tmp/opencode-sandbox-config/
# Edit to remove/add plugins as needed
```

### 2. Which MCP servers/plugins to include?

Consider excluding plugins that:
- Require local resources not available in sandbox
- Have security implications (filesystem access outside project)
- Need credentials you don't want in the sandbox

Consider including plugins that:
- Are essential for your workflow
- Work in isolated environments
- Have credentials that can be scoped appropriately

### 3. What about skills?

Skills in `~/.config/opencode/skills/` or `.opencode/skills/` may also need adjustment:
- Some skills may reference local paths
- Consider which skills are relevant for the sandbox use case

### 4. Authentication tokens

`~/.local/share/opencode/auth.json` contains API tokens. Options:
- **Include it**: Full functionality, but tokens are in the sandbox
- **Exclude it**: User must authenticate fresh in sandbox
- **Create limited version**: New tokens with minimal scopes

## Bundling Process

### Step 1: Create a staging directory

```bash
BUNDLE_DIR=$(mktemp -d)
echo "Staging in: $BUNDLE_DIR"
```

### Step 2: Copy opencode config

**Using existing config:**
```bash
mkdir -p "$BUNDLE_DIR/.config/opencode"

# Copy main config (respecting .gitignore if present)
if [[ -f ~/.config/opencode/.gitignore ]]; then
    # Use git to list non-ignored files
    (cd ~/.config/opencode && git ls-files --cached --others --exclude-standard 2>/dev/null) | \
    while read -r file; do
        mkdir -p "$BUNDLE_DIR/.config/opencode/$(dirname "$file")"
        cp ~/.config/opencode/"$file" "$BUNDLE_DIR/.config/opencode/$file"
    done
else
    # Copy everything except logs/temp files
    rsync -a --exclude='*.log' --exclude='*.tmp' --exclude='.git' \
        ~/.config/opencode/ "$BUNDLE_DIR/.config/opencode/"
fi
```

**Using custom config:**
```bash
mkdir -p "$BUNDLE_DIR/.config/opencode"
cp /path/to/custom/opencode.json "$BUNDLE_DIR/.config/opencode/"
# Copy any other needed files (skills, etc.)
```

### Step 3: Handle authentication

**Include existing auth:**
```bash
mkdir -p "$BUNDLE_DIR/.local/share/opencode"
cp ~/.local/share/opencode/auth.json "$BUNDLE_DIR/.local/share/opencode/"
```

**Skip auth (user will authenticate in sandbox):**
```bash
# Don't copy auth.json - skip this step
```

**Create auth with specific tokens:**
```bash
mkdir -p "$BUNDLE_DIR/.local/share/opencode"
cat > "$BUNDLE_DIR/.local/share/opencode/auth.json" << 'EOF'
{
  "github": {
    "token": "ghp_xxxxxxxxxxxx"
  }
}
EOF
```

### Step 4: Add extra directories (optional)

```bash
# Example: include custom binaries
mkdir -p "$BUNDLE_DIR/.local/bin"
cp ~/.local/bin/my-tool "$BUNDLE_DIR/.local/bin/"
```

### Step 5: Create the bundle

```bash
# Create base64-encoded tar.gz
tar -czf - -C "$BUNDLE_DIR" . | base64 -w0 > /tmp/opencode-bundle.b64

# Verify it worked
echo "Bundle size: $(wc -c < /tmp/opencode-bundle.b64) bytes"

# Preview contents
base64 -d < /tmp/opencode-bundle.b64 | tar -tzf -
```

### Step 6: Clean up staging directory

```bash
rm -rf "$BUNDLE_DIR"
```

## Complete Example: Custom Minimal Config

Here's a complete example creating a minimal sandbox config:

```bash
#!/usr/bin/env bash
set -euo pipefail

BUNDLE_DIR=$(mktemp -d)
trap 'rm -rf "$BUNDLE_DIR"' EXIT

# Create minimal opencode.json
mkdir -p "$BUNDLE_DIR/.config/opencode"
cat > "$BUNDLE_DIR/.config/opencode/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcpServers": {}
}
EOF

# Copy auth if it exists
if [[ -f ~/.local/share/opencode/auth.json ]]; then
    mkdir -p "$BUNDLE_DIR/.local/share/opencode"
    cp ~/.local/share/opencode/auth.json "$BUNDLE_DIR/.local/share/opencode/"
fi

# Create bundle
tar -czf - -C "$BUNDLE_DIR" . | base64 -w0 > /tmp/opencode-bundle.b64
echo "Created: /tmp/opencode-bundle.b64"
```

## Complete Example: Full Config with Modifications

```bash
#!/usr/bin/env bash
set -euo pipefail

BUNDLE_DIR=$(mktemp -d)
trap 'rm -rf "$BUNDLE_DIR"' EXIT

# Copy full config
mkdir -p "$BUNDLE_DIR/.config/opencode"
rsync -a --exclude='*.log' --exclude='*.tmp' --exclude='.git' \
    ~/.config/opencode/ "$BUNDLE_DIR/.config/opencode/"

# Modify: remove specific MCP server
# (using jq to remove a server that won't work in sandbox)
if command -v jq &>/dev/null; then
    jq 'del(.mcpServers["local-only-server"])' \
        "$BUNDLE_DIR/.config/opencode/opencode.json" > /tmp/modified.json
    mv /tmp/modified.json "$BUNDLE_DIR/.config/opencode/opencode.json"
fi

# Copy auth
mkdir -p "$BUNDLE_DIR/.local/share/opencode"
cp ~/.local/share/opencode/auth.json "$BUNDLE_DIR/.local/share/opencode/"

# Create bundle
tar -czf - -C "$BUNDLE_DIR" . | base64 -w0 > /tmp/opencode-bundle.b64
echo "Created: /tmp/opencode-bundle.b64"
```

## Using the Bundle

The bundle is used in cloud-init's `write_files` section. The `generate-cloud-init.sh` script handles this automatically when you provide `--bundle-file`:

```bash
./scripts/generate-cloud-init.sh \
  --bundle-file /tmp/opencode-bundle.b64 \
  ...other options...
```

This embeds the bundle in the cloud-init YAML and extracts it during provisioning.

## Verifying Bundle Contents

Before using, verify what's in your bundle:

```bash
# List files
base64 -d < /tmp/opencode-bundle.b64 | tar -tzf -

# Extract and inspect (to temp dir)
INSPECT_DIR=$(mktemp -d)
base64 -d < /tmp/opencode-bundle.b64 | tar -xzf - -C "$INSPECT_DIR"
find "$INSPECT_DIR" -type f
cat "$INSPECT_DIR/.config/opencode/opencode.json"
rm -rf "$INSPECT_DIR"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bundle too large for cloud-init | cloud-init has ~16KB limit for user-data; split into multiple files or use external storage |
| Permissions wrong after extraction | Add `chmod` commands in cloud-init's `runcmd` section |
| Config not found in sandbox | Check extraction path; should be relative to user's $HOME |
| Auth not working | Verify auth.json was included and tokens are valid |
