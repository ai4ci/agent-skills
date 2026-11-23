# Rust Development Environment

Setup Rust development environment with cargo and common tools.

## Decision Points

### 1. Installation Method

| Option | Pros | Cons | When to Use |
|--------|------|------|-------------|
| **rustup** (recommended) | Official, manages toolchains | User-specific install | Most development |
| **System packages** | Simple, system-wide | Older versions, less flexible | Containers, minimal needs |

### 2. Toolchain

- **stable** - Production use, recommended
- **beta** - Preview of upcoming features
- **nightly** - Cutting edge, some crates require it

### 3. Additional Components

- **clippy** - Linter
- **rustfmt** - Code formatter
- **rust-analyzer** - IDE support (LSP)
- **llvm-tools** - Coverage, profiling
- **miri** - Undefined behavior detection

### 4. Common Tools (cargo install)

- **cargo-watch** - Auto-rebuild on changes
- **cargo-edit** - Add/remove/upgrade deps from CLI
- **cargo-audit** - Security vulnerability checking
- **cargo-nextest** - Faster test runner
- **sccache** - Compilation cache

## Cloud-Init Setup

### Recommended Setup (rustup, system-wide)

```yaml
packages:
  - build-essential
  - curl
  - pkg-config
  - libssl-dev

runcmd:
  # Install rustup system-wide
  - |
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
      RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo \
      sh -s -- -y --default-toolchain stable --profile default
    
    # Make available system-wide
    ln -s /opt/cargo/bin/* /usr/local/bin/
  
  # Install common components
  - /opt/cargo/bin/rustup component add clippy rustfmt rust-analyzer
  
  # Install useful cargo tools
  - /opt/cargo/bin/cargo install cargo-watch cargo-edit
```

### User-Specific Installation

For per-user rustup installation:

```yaml
packages:
  - build-essential
  - curl
  - pkg-config
  - libssl-dev

runcmd:
  # Install rustup for user
  - su - USERNAME -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
  
  # Add components
  - su - USERNAME -c "~/.cargo/bin/rustup component add clippy rustfmt rust-analyzer"
```

### With Nightly Toolchain

```yaml
runcmd:
  # Install with both stable and nightly
  - |
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
      RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo \
      sh -s -- -y --default-toolchain stable
    
    ln -s /opt/cargo/bin/* /usr/local/bin/
  
  # Add nightly
  - rustup toolchain install nightly
  - rustup component add clippy rustfmt --toolchain nightly
```

### With sccache (Compilation Cache)

```yaml
runcmd:
  # ... rustup installation ...
  
  # Install sccache
  - cargo install sccache
  
  # Configure cargo to use sccache
  - |
    mkdir -p /etc/skel/.cargo
    cat > /etc/skel/.cargo/config.toml << 'EOF'
    [build]
    rustc-wrapper = "sccache"
    EOF
```

### Minimal System Packages (No rustup)

For simple containers where you don't need toolchain management:

```yaml
packages:
  - rustc
  - cargo
  - rust-clippy
  - rustfmt
```

## Singularity Setup

### Definition File Section

```singularity
%post
    apt-get install -y build-essential curl pkg-config libssl-dev
    
    # Install rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
      RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo \
      sh -s -- -y --default-toolchain stable --profile default
    
    # Link binaries
    ln -s /opt/cargo/bin/* /usr/local/bin/
    
    # Add components
    /opt/cargo/bin/rustup component add clippy rustfmt rust-analyzer

%environment
    export RUSTUP_HOME=/opt/rustup
    export CARGO_HOME=/opt/cargo
    export PATH="/opt/cargo/bin:$PATH"
```

## Project-Specific Setup

### Building a Cargo Project

```yaml
runcmd:
  # Build project (debug)
  - su - USERNAME -c "cd /home/USERNAME/project && cargo build"
  
  # Or release build
  - su - USERNAME -c "cd /home/USERNAME/project && cargo build --release"
  
  # Or just fetch dependencies
  - su - USERNAME -c "cd /home/USERNAME/project && cargo fetch"
```

### With Specific Toolchain

For projects requiring nightly:
```yaml
runcmd:
  - su - USERNAME -c "cd /home/USERNAME/project && rustup override set nightly"
  - su - USERNAME -c "cd /home/USERNAME/project && cargo build"
```

### Workspace Projects

```yaml
runcmd:
  # Build all workspace members
  - su - USERNAME -c "cd /home/USERNAME/project && cargo build --workspace"
```

## Common Native Dependencies

Many Rust crates need system libraries. Install these based on your dependencies:

```yaml
packages:
  # Common
  - build-essential
  - pkg-config
  - libssl-dev
  
  # For crates using OpenSSL
  - libssl-dev
  
  # For database clients
  - libpq-dev           # PostgreSQL (diesel, sqlx)
  - libsqlite3-dev      # SQLite
  - libmysqlclient-dev  # MySQL
  
  # For crypto crates
  - libclang-dev        # bindgen
  
  # For GUI/graphics
  - libgtk-3-dev
  - libwebkit2gtk-4.0-dev
```

## Verification

```yaml
runcmd:
  # ... installation commands ...
  
  # Verify
  - rustc --version
  - cargo --version
  - rustup show
  - clippy-driver --version
  - rustfmt --version
```

## Common Configurations

### CLI Tool Development

```yaml
runcmd:
  # ... rustup installation ...
  
  - rustup component add clippy rustfmt
  - cargo install cargo-edit cargo-watch
```

### Web Development (Actix/Axum)

```yaml
packages:
  - build-essential
  - pkg-config
  - libssl-dev
  - libpq-dev  # if using PostgreSQL

runcmd:
  # ... rustup installation ...
  
  - cargo install cargo-watch sqlx-cli
```

### WebAssembly Development

```yaml
runcmd:
  # ... rustup installation ...
  
  - rustup target add wasm32-unknown-unknown
  - cargo install wasm-pack trunk
```

### Embedded Development

```yaml
runcmd:
  # ... rustup installation ...
  
  # Add embedded targets
  - rustup target add thumbv7em-none-eabihf  # Cortex-M4F
  - rustup target add riscv32imac-unknown-none-elf  # RISC-V
  
  # Install embedded tools
  - cargo install cargo-embed cargo-flash probe-run
  
  # Install system tools
  - apt-get install -y gdb-multiarch openocd
```

## Environment Variables

```yaml
write_files:
  - path: /etc/profile.d/rust.sh
    content: |
      export RUSTUP_HOME=/opt/rustup
      export CARGO_HOME=/opt/cargo
      export PATH="/opt/cargo/bin:$PATH"
      
      # Optional: faster linking
      export RUSTFLAGS="-C link-arg=-fuse-ld=lld"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `rustc` not found | Check PATH includes cargo/bin |
| Linker errors | Install `build-essential` |
| OpenSSL errors | Install `pkg-config libssl-dev` |
| Slow compilation | Install and configure `sccache` |
| Permission denied | Use per-user install or fix /opt permissions |
| Nightly required | Run `rustup toolchain install nightly` |
| Target not installed | Run `rustup target add <target>` |
| cargo install fails | Check native dependencies for the crate |
