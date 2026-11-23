# R Development Environment

Setup R development environment with fast binary package installation. The recommended approach uses **r2u** - a repository providing pre-built binary R packages for Ubuntu.

## Decision Points

### 1. Package Installation Method

| Option | Pros | Cons | When to Use |
|--------|------|------|-------------|
| **r2u + bspm** (recommended) | Instant installs, no compilation | Ubuntu-only, limited package selection | Ubuntu VMs, most data science |
| **CRAN source** | All packages available | Slow compilation, needs build deps | Cutting edge packages |
| **Posit Package Manager** | Binaries for many platforms | Requires config | Non-Ubuntu Linux |
| **conda-forge** | Cross-platform binaries | Environment management overhead | Complex native deps |

### 2. R Version

- **Latest (4.4.x)** - Current features, recommended
- **4.3.x** - Previous stable
- **MRAN snapshot** - Reproducibility (deprecated)

### 3. Package Sets

Common meta-packages:
- **tidyverse** - Data manipulation and visualization
- **Bioconductor** - Bioinformatics packages
- **data.table** - High-performance data manipulation
- **shiny** - Web applications
- **targets** - Pipeline management

## Cloud-Init Setup

**Important**: Heredocs in cloud-init runcmd are tricky because unindented content can break YAML parsing. The examples below use `printf` or properly escaped approaches that work reliably.

### Recommended Setup (r2u + bspm)

This provides instant binary package installation:

```yaml
packages:
  - gnupg

runcmd:
  # Add r2u and CRAN repositories
  - |
    gpg --homedir /tmp --no-default-keyring \
        --keyring /usr/share/keyrings/r2u.gpg \
        --keyserver keyserver.ubuntu.com \
        --recv-keys A1489FE2AB99A21A 67C2D66C4B1D4339 51716619E084DAB9
  - |
    printf '%s\n' \
      'Types: deb' \
      'URIs: https://r2u.stat.illinois.edu/ubuntu' \
      'Suites: noble' \
      'Components: main' \
      'Arch: amd64' \
      'Signed-By: /usr/share/keyrings/r2u.gpg' \
      > /etc/apt/sources.list.d/r2u.sources
  - |
    printf '%s\n' \
      'Types: deb' \
      'URIs: https://cloud.r-project.org/bin/linux/ubuntu' \
      'Suites: noble-cran40/' \
      'Components:' \
      'Arch: amd64' \
      'Signed-By: /usr/share/keyrings/r2u.gpg' \
      > /etc/apt/sources.list.d/cran.sources
  - apt-get update -qq
  - DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends r-base-core
  - Rscript -e 'install.packages("bspm")'
  - |
    printf '%s\n' \
      'suppressMessages(bspm::enable())' \
      'options(bspm.version.check=FALSE)' \
      >> /etc/R/Rprofile.site
  - apt-get install -y r-cran-tidyverse
```

**Copy-paste ready version** (for runcmd.yml file):

```yaml
  - |
    gpg --homedir /tmp --no-default-keyring \
        --keyring /usr/share/keyrings/r2u.gpg \
        --keyserver keyserver.ubuntu.com \
        --recv-keys A1489FE2AB99A21A 67C2D66C4B1D4339 51716619E084DAB9
  - |
    printf '%s\n' \
      'Types: deb' \
      'URIs: https://r2u.stat.illinois.edu/ubuntu' \
      'Suites: noble' \
      'Components: main' \
      'Arch: amd64' \
      'Signed-By: /usr/share/keyrings/r2u.gpg' \
      > /etc/apt/sources.list.d/r2u.sources
  - |
    printf '%s\n' \
      'Types: deb' \
      'URIs: https://cloud.r-project.org/bin/linux/ubuntu' \
      'Suites: noble-cran40/' \
      'Components:' \
      'Arch: amd64' \
      'Signed-By: /usr/share/keyrings/r2u.gpg' \
      > /etc/apt/sources.list.d/cran.sources
  - apt-get update -qq
  - DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends r-base-core
  - Rscript -e 'install.packages("bspm")'
  - |
    printf '%s\n' \
      'suppressMessages(bspm::enable())' \
      'options(bspm.version.check=FALSE)' \
      >> /etc/R/Rprofile.site
  - apt-get install -y r-cran-tidyverse
```

### Minimal R Setup (no r2u)

For simpler setups without binary packages:

```yaml
runcmd:
  # Add CRAN repository
  - |
    gpg --homedir /tmp --no-default-keyring \
        --keyring /usr/share/keyrings/cran.gpg \
        --keyserver keyserver.ubuntu.com \
        --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    
    echo "deb [signed-by=/usr/share/keyrings/cran.gpg] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
        > /etc/apt/sources.list.d/cran.list
    
    apt-get update -qq
  
  # Install R
  - DEBIAN_FRONTEND=noninteractive apt-get install -y r-base
```

### With Bioconductor

Add after base R installation:

```yaml
runcmd:
  # ... base R installation ...
  
  # Install BiocManager
  - Rscript -e 'install.packages("BiocManager")'
  
  # Install Bioconductor packages
  - Rscript -e 'BiocManager::install(c("DESeq2", "edgeR"), ask=FALSE)'
```

### With RStudio Server

```yaml
packages:
  - gdebi-core

runcmd:
  # ... R installation ...
  
  # Install RStudio Server
  - |
    wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.04.0-735-amd64.deb
    gdebi -n rstudio-server-2024.04.0-735-amd64.deb
    rm rstudio-server-*.deb
```

## Singularity Setup

### Definition File Section

Heredocs work normally in Singularity %post sections (not YAML), but content should still be unindented:

```singularity
%post
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
    
    cat > /etc/apt/sources.list.d/cran.sources << 'EOF'
Types: deb
URIs: https://cloud.r-project.org/bin/linux/ubuntu
Suites: noble-cran40/
Components:
Arch: amd64
Signed-By: /usr/share/keyrings/r2u.gpg
EOF
    
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends r-base-core
    
    Rscript -e 'install.packages("bspm")'
    cat >> /etc/R/Rprofile.site << 'EOF'
suppressMessages(bspm::enable())
options(bspm.version.check=FALSE)
EOF
    
    apt-get install -y r-cran-tidyverse r-cran-data.table

%environment
    export LC_ALL=C.UTF-8
```

## Project-Specific Setup

### Installing from renv.lock

```yaml
runcmd:
  # Install renv
  - Rscript -e 'install.packages("renv")'
  
  # Restore project dependencies (as user)
  - su - USERNAME -c "cd /home/USERNAME/project && Rscript -e 'renv::restore()'"
```

### Installing Specific Packages

```yaml
runcmd:
  # Via apt (r2u binaries, fast)
  - apt-get install -y r-cran-dplyr r-cran-ggplot2 r-cran-shiny
  
  # Or via Rscript (from CRAN)
  - Rscript -e 'install.packages(c("dplyr", "ggplot2", "shiny"))'
```

## Verification

```yaml
runcmd:
  # ... installation commands ...
  
  # Verify
  - R --version
  - Rscript -e 'sessionInfo()'
  - Rscript -e 'library(tidyverse); packageVersion("tidyverse")'
```

## Common Configurations

### Data Science Setup

```yaml
runcmd:
  # ... r2u setup ...
  
  - apt-get install -y \
      r-cran-tidyverse \
      r-cran-data.table \
      r-cran-arrow \
      r-cran-duckdb \
      r-cran-targets
```

### Statistical Analysis

```yaml
runcmd:
  # ... r2u setup ...
  
  - apt-get install -y \
      r-cran-tidyverse \
      r-cran-lme4 \
      r-cran-brms \
      r-cran-emmeans \
      r-cran-performance
```

### Bioinformatics Setup

```yaml
runcmd:
  # ... r2u setup ...
  
  - apt-get install -y r-cran-tidyverse r-cran-biocmanager
  - Rscript -e 'BiocManager::install(c("DESeq2", "edgeR", "clusterProfiler"), ask=FALSE)'
```

### Package Development

```yaml
runcmd:
  # ... r2u setup ...
  
  - apt-get install -y \
      r-cran-devtools \
      r-cran-testthat \
      r-cran-roxygen2 \
      r-cran-pkgdown \
      r-cran-usethis
```

## Notes on r2u

- **Ubuntu only**: r2u provides binaries only for Ubuntu (22.04, 24.04)
- **x86_64 and arm64**: Both architectures supported
- **Noble = 24.04**: Update `Suites: noble` for other Ubuntu versions
- **bspm bridge**: The bspm package makes `install.packages()` use apt automatically
- **Package availability**: Not all CRAN packages are in r2u; bspm falls back to source compilation

## Troubleshooting

| Issue | Solution |
|-------|----------|
| GPG key errors | Re-run gpg --recv-keys command |
| Package not found in r2u | Install from CRAN: `Rscript -e 'install.packages("pkg")'` |
| Compilation fails | Install build deps: `apt-get install build-essential r-base-dev` |
| System library missing | Install dev package: `apt-get install libcurl4-openssl-dev` etc. |
| bspm not working | Check `/etc/R/Rprofile.site` contains enable command |
| Locale warnings | Set `LC_ALL=C.UTF-8` in environment |
