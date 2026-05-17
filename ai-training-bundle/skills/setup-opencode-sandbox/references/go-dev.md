# Go Development Environment

Setup Go development environment.

## Decision Points

### 1. Installation Method

| Option | Pros | Cons | When to Use |
|--------|------|------|-------------|
| **Official tarball** (recommended) | Latest version, official | Manual updates | Most development |
| **System packages** | Simple apt install | Older versions | Quick setup, version not critical |
| **go install from existing Go** | Easy version switching | Needs Go already | Adding versions |

### 2. Go Version

- **1.22.x** - Current stable, recommended
- **1.21.x** - Previous stable
- **tip** - Development branch (not recommended)

### 3. Additional Tools

- **golangci-lint** - Comprehensive linter
- **gopls** - Official language server (IDE support)
- **delve** - Debugger
- **air** - Live reload for development
- **staticcheck** - Advanced static analysis

## Cloud-Init Setup

### Recommended Setup (Official Tarball)

```yaml
packages:
  - curl
  - git
  - build-essential

runcmd:
  # Install Go
  - |
    GO_VERSION="1.22.2"
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
  
  # Set up environment
  - |
    cat > /etc/profile.d/golang.sh << 'EOF'
    export PATH="/usr/local/go/bin:$PATH"
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
    EOF
  
  # Install common tools (as user, after PATH is set)
  - su - USERNAME -c "source /etc/profile.d/golang.sh && go install golang.org/x/tools/gopls@latest"
  - su - USERNAME -c "source /etc/profile.d/golang.sh && go install github.com/go-delve/delve/cmd/dlv@latest"
```

### With golangci-lint

```yaml
runcmd:
  # ... Go installation ...
  
  # Install golangci-lint
  - curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.57.2
```

### System Packages (Simpler, Older Version)

For quick setup where exact version doesn't matter:

```yaml
packages:
  - golang-go
  - golang-golang-x-tools

runcmd:
  # golangci-lint
  - curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.57.2
```

### ARM64 Installation

```yaml
runcmd:
  - |
    GO_VERSION="1.22.2"
    ARCH=$(uname -m)
    case $ARCH in
      x86_64) GOARCH="amd64" ;;
      aarch64) GOARCH="arm64" ;;
      *) echo "Unsupported architecture"; exit 1 ;;
    esac
    
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz" -o /tmp/go.tar.gz
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
```

## Singularity Setup

### Definition File Section

```singularity
%post
    GO_VERSION="1.22.2"
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    
    # Install tools
    export PATH="/usr/local/go/bin:$PATH"
    export GOPATH="/opt/go"
    go install golang.org/x/tools/gopls@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

%environment
    export PATH="/usr/local/go/bin:$PATH"
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:/opt/go/bin:$PATH"
```

## Project-Specific Setup

### Download Dependencies

```yaml
runcmd:
  # Download module dependencies
  - su - USERNAME -c "cd /home/USERNAME/project && go mod download"
```

### Build Project

```yaml
runcmd:
  # Build
  - su - USERNAME -c "cd /home/USERNAME/project && go build ./..."
  
  # Or build specific binary
  - su - USERNAME -c "cd /home/USERNAME/project && go build -o /home/USERNAME/go/bin/myapp ./cmd/myapp"
```

### Vendor Dependencies

If project uses vendoring:
```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && go mod vendor"
```

## Private Modules

For projects using private Go modules:

```yaml
runcmd:
  # Configure GOPRIVATE
  - su - USERNAME -c "go env -w GOPRIVATE=github.com/myorg/*"
  
  # Configure git to use SSH for private repos
  - su - USERNAME -c "git config --global url.git@github.com:.insteadOf https://github.com/"
```

Or with GitHub token:
```yaml
write_files:
  - path: /home/USERNAME/.netrc
    owner: USERNAME:USERNAME
    permissions: '0600'
    content: |
      machine github.com
      login USERNAME
      password GITHUB_TOKEN

runcmd:
  - su - USERNAME -c "go env -w GOPRIVATE=github.com/myorg/*"
```

## Verification

```yaml
runcmd:
  # ... installation commands ...
  
  # Verify
  - go version
  - go env GOPATH GOROOT
  - which gopls || true
  - golangci-lint --version || true
```

## Common Configurations

### CLI Tool Development

```yaml
runcmd:
  # ... Go installation ...
  
  - su - USERNAME -c "source /etc/profile.d/golang.sh && go install golang.org/x/tools/gopls@latest"
  - su - USERNAME -c "source /etc/profile.d/golang.sh && go install github.com/go-delve/delve/cmd/dlv@latest"
  - curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin
```

### Web Development

```yaml
runcmd:
  # ... Go installation ...
  
  # Install air for live reload
  - su - USERNAME -c "source /etc/profile.d/golang.sh && go install github.com/cosmtrek/air@latest"
  
  # Install templ for templates (if using)
  - su - USERNAME -c "source /etc/profile.d/golang.sh && go install github.com/a-h/templ/cmd/templ@latest"
```

### Microservices / gRPC

```yaml
packages:
  - protobuf-compiler

runcmd:
  # ... Go installation ...
  
  # Install protoc plugins
  - su - USERNAME -c "source /etc/profile.d/golang.sh && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
  - su - USERNAME -c "source /etc/profile.d/golang.sh && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
```

### Cross-Compilation Setup

```yaml
runcmd:
  # ... Go installation ...
  
  # Go supports cross-compilation natively, just set GOOS/GOARCH
  # Example: build for Windows
  - su - USERNAME -c "cd /home/USERNAME/project && GOOS=windows GOARCH=amd64 go build -o myapp.exe"
  
  # Example: build for ARM Linux
  - su - USERNAME -c "cd /home/USERNAME/project && GOOS=linux GOARCH=arm64 go build -o myapp-arm64"
```

## Environment Variables

```yaml
write_files:
  - path: /etc/profile.d/golang.sh
    content: |
      export PATH="/usr/local/go/bin:$PATH"
      export GOPATH="$HOME/go"
      export PATH="$GOPATH/bin:$PATH"
      
      # Optional: module proxy for faster downloads
      export GOPROXY="https://proxy.golang.org,direct"
      
      # Optional: private module patterns
      # export GOPRIVATE="github.com/myorg/*"
```

## CGO and Native Dependencies

For projects using CGO (calling C code):

```yaml
packages:
  - build-essential
  - gcc
  - g++
  
  # Common C library dependencies
  - libsqlite3-dev    # SQLite
  - librdkafka-dev    # Kafka client
  - librocksdb-dev    # RocksDB

runcmd:
  # Ensure CGO is enabled (it's on by default when gcc is available)
  - go env -w CGO_ENABLED=1
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `go` not found | Check PATH includes `/usr/local/go/bin` |
| Module download fails | Check network, GOPROXY, GOPRIVATE settings |
| CGO: gcc not found | Install `build-essential` |
| Private repo fails | Configure .netrc or SSH keys |
| gopls slow/missing | Ensure installed: `go install golang.org/x/tools/gopls@latest` |
| Permission denied in GOPATH | Check directory ownership, run as user not root |
| Wrong Go version | Remove system Go, use official tarball |
