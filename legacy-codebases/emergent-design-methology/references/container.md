
To build a zero-overhead, multi-language validation sandbox for an agent, a multi-stage Docker build is the cleanest approach. This method compiles heavy binaries (like Rust-based tools) in temporary build stages and copies only the final, lightweight executables into a slim Ubuntu target image.

## The Multi-Stage Agent Sandbox Blueprint

```dockerfile
# syntax=docker/dockerfile:1
# ==============================================================================
# STAGE 1: Compile and Fetch Binaries (Rust & Standalone Tools)
# ==============================================================================
FROM ubuntu:24.04 AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates unzip git build-essential cargo libssl-dev pkg-config

WORKDIR /build

# 1. Compile Panache (For Rmd/qmd layout handling)
RUN cargo install panache --locked --root /build/out/

# 2. Fetch Posit Air (High-speed R formatter)
RUN curl -LsSf github.com | sh -s -- --to /build/out/bin

# 3. Fetch Apache Maven Daemon (mvnd)
RUN curl -L -o mvnd.tar.gz apache.org \
    && tar -xvf mvnd.tar.gz \
    && mkdir -p /build/out/mvnd \
    && mv maven-mvnd-1.0.2-linux-amd64/* /build/out/mvnd/

# 4. Fetch PMD Static Analyzer
RUN curl -L -o pmd.zip github.com \
    && unzip pmd.zip \
    && mv pmd-bin-7.0.0 /build/out/pmd

# 5. Fetch Google Java Format jar
RUN mkdir -p /build/out/java-format \
    && curl -L -o /build/out/java-format/google-java-format.jar \
       github.com

# 6. Fetch Atlas DB Inspector
RUN curl -sSf https://atlasgo.sh | sh -s -- --to /build/out/bin

# ==============================================================================
# STAGE 2: Final Production Sandbox Environment
# ==============================================================================
FROM ubuntu:24.04

# Define environmental non-interactive constraints
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/local/bin:/opt/mvnd/bin:${PATH}"

# Install native Runtimes, Package Managers, and Core CLI tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-venv \
    openjdk-17-jdk-headless \
    r-base-core \
    shellcheck \
    shfmt \
    && rm -rf /var/lib/apt/lists/*

# 1. Copy Compiled & Prefetched Binaries from Builder stage
COPY --from=builder /build/out/bin/ /usr/local/bin/
COPY --from=builder /build/out/mvnd/ /opt/mvnd/
COPY --from=builder /build/out/pmd/ /opt/pmd/
COPY --from=builder /build/out/java-format/ /opt/java-format/

# Create a symlink to ensure PMD can be executed directly as a command
RUN ln -s /opt/pmd/bin/pmd /usr/local/bin/pmd

# 2. Install Python Tools using uv (Ruff, mypy, pytest)
RUN curl -LsSf astral.sh | sh \
    && uv tool install ruff \
    && uv tool install mypy \
    && uv tool install pytest

# 3. Install Global Node/NPM ecosystem utilities (Biome, Squawk, Bats)
RUN npm install -g @biomejs/biome typescript vitest squawk-cli bats

# 4. Install SQLFluff via generic python layers
RUN pip install --no-cache-dir --break-system-packages sqlfluff

# 5. Pre-seed baseline packages for headless R environments
RUN Rscript -e "install.packages(c('renv', 'lintr', 'testthat'), repos='r-project.org')"

# Set fallback operational sandbox path
WORKDIR /workspace
CMD ["/bin/bash"]
```


