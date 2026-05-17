# Node.js Development Environment

Setup Node.js development environment. The recommended approach uses **bun** - an all-in-one JavaScript runtime, bundler, and package manager.

## Decision Points

### 1. Runtime / Package Manager

| Option | Pros | Cons | When to Use |
|--------|------|------|-------------|
| **bun** (recommended) | Extremely fast, all-in-one (runtime, pm, bundler, test) | Newer, some Node.js API gaps | Most projects, especially new ones |
| **Node.js + npm** | Universal compatibility | Slower | Projects requiring full Node.js compatibility |
| **Node.js + pnpm** | Fast, disk efficient | Extra setup | Monorepos, disk-constrained environments |
| **Node.js + yarn** | Workspaces, plug'n'play | Complexity | Existing yarn projects |

### 2. Node.js Version (if using Node.js)

- **22.x** - Current (latest features)
- **20.x** - LTS (recommended for stability)
- **18.x** - Previous LTS (legacy projects)

### 3. Additional Tools

Consider pre-installing:
- **TypeScript** - Type checking
- **tsx** - TypeScript execution
- **prettier** - Code formatting
- **eslint** - Linting

## Cloud-Init Setup

### Minimal Setup (bun only)

```yaml
packages:
  - curl
  - unzip

runcmd:
  # Install bun system-wide
  - curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash
```

### With Global Tools

```yaml
runcmd:
  # Install bun
  - curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash
  
  # Install global tools
  - bun install -g typescript
  - bun install -g tsx
  - bun install -g prettier
```

### Alternative: Node.js + npm (Official)

Using NodeSource repository for latest versions:

```yaml
runcmd:
  # Install Node.js 20.x LTS
  - curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  - apt-get install -y nodejs
  
  # Update npm
  - npm install -g npm@latest
  
  # Install common tools
  - npm install -g typescript tsx prettier eslint
```

### Alternative: Node.js + pnpm

```yaml
runcmd:
  # Install Node.js
  - curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  - apt-get install -y nodejs
  
  # Install pnpm
  - npm install -g pnpm
  
  # Or via corepack (built into Node.js)
  - corepack enable
  - corepack prepare pnpm@latest --activate
```

### Alternative: nvm (Multiple Versions)

For environments needing multiple Node.js versions:

```yaml
runcmd:
  # Install nvm for the user
  - su - USERNAME -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
  
  # Install and use Node.js (as user)
  - su - USERNAME -c "source ~/.nvm/nvm.sh && nvm install 20 && nvm use 20"
```

## Singularity Setup

### Definition File Section (bun)

```singularity
%post
    # Install bun
    curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash

%environment
    export PATH="/usr/local/bin:$PATH"
```

### Definition File Section (Node.js)

```singularity
%post
    # Install Node.js 20.x
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    
    # Install global tools
    npm install -g typescript tsx

%environment
    export PATH="/usr/local/bin:$PATH"
```

## Project-Specific Setup

### For package.json projects (bun)

After cloning the project:
```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && bun install"
```

### For package.json projects (npm)

```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && npm ci"
```

Use `npm ci` instead of `npm install` for reproducible installs from lockfile.

### For pnpm projects

```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && pnpm install --frozen-lockfile"
```

## Verification

Add these to verify the setup:

```yaml
runcmd:
  # ... installation commands ...
  
  # Verify bun
  - bun --version
  
  # Or verify Node.js
  - node --version
  - npm --version
```

## Common Configurations

### TypeScript Development

```yaml
runcmd:
  - curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash
  - bun install -g typescript
  - bun install -g tsx
  - bun install -g @types/node
```

### Full-Stack Web Development

```yaml
runcmd:
  - curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash
  - bun install -g typescript
  - bun install -g prettier
  - bun install -g eslint
```

### CLI Tool Development

```yaml
runcmd:
  - curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash
  - bun install -g typescript
  - bun install -g tsx
  - bun install -g pkg  # for building executables
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `bun` not found | Ensure `/usr/local/bin` is in PATH |
| Permission denied | Run install as root, run project commands as user |
| Native module build fails | Install build deps: `apt-get install build-essential python3` |
| SSL/certificate errors | Install: `apt-get install ca-certificates` |
| bun compatibility issues | Fall back to Node.js for full compatibility |
| Lockfile conflicts | Delete lockfile and regenerate, or use appropriate install flag |
