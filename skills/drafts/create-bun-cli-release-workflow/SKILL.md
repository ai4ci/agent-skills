# Skill File: Bun CLI Auto-Build & Cross-Distribution Blueprint
> **Purpose**: A hardened workflow pattern for publishing high-performance TypeScript CLI applications simultaneously as native standalone executables (via GitHub Releases) and as a staged package to the npm registry.

---

## 🛠️ Core Strategy Architecture
1. **GitHub Releases** act as the hosting layer for massive, self-contained standalone binaries (~50MB-90MB each, containing the pre-baked Bun runtime).
2. **NPM Registry** hosts the clean TypeScript/JavaScript source engine via a standard package footprint.
3. **Local Tooling Checks** block breaking mutations by enforcing that the version number is hard-coded directly inside the source text at compilation time rather than resolved via runtime filesystem parsing (which crashes inside packed binaries).
4. **Targeted Deployment Filters** isolate automation execution exclusively to initial major or minor iterations (`*.0`), ensuring mid-flight patches bypass the production pipeline.

---

## 💻 1. The Production `package.json` Standard
Configure the package manifest to lock down automation hooks (`preversion`, `version`, `postversion`) ensuring local artifacts, source code data, and remote tags never drift out of sync.

```json
{
  "name": "your-cli-tool",
  "version": "1.0.0",
  "description": "High performance standalone CLI tool",
  "type": "module",
  "main": "./dist/index.js",
  "bin": {
    "your-cli-tool": "./dist/cli.js"
  },
  "engines": {
    "node": ">=22"
  },
  "files": [
    "dist/",
    "README.md",
    "LICENSE"
  ],
  "scripts": {
    "prebuild": "node scripts/stamp-version.cjs",
    "build": "tsc -p tsconfig.build.json && chmod +x dist/cli.js",
    "typecheck": "tsc --noEmit",
    "test": "node --test 'test/**/*.test.ts'",
    "build:binary": "npm run build && bun build ./src/cli.ts --compile --outfile ./bin/your-cli-tool",
    "preversion": "npm run typecheck && npm test",
    "version": "npm run build:binary && git add src/cli.ts",
    "postversion": "(git push origin main && git push origin main --tags) || echo '⚠️ Automatic push failed (credentials/sandbox block). Push manually using: git push origin main --tags'"
  }
}
```

---

## 📝 2. Source-Stamping Utility (`scripts/stamp-version.cjs`)
Because Bun executables cannot dynamically traverse path structures to locate a loose `package.json` on a host system at runtime, this script rewires a code literal (`const VERSION = "..."`) during local builds and tag creation.

```javascript
#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

const rootDir = process.cwd();
const pkgPath = path.join(rootDir, "package.json");
const cliPath = path.join(rootDir, "src", "cli.ts");

const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
const version = pkg.version;

let src = fs.readFileSync(cliPath, "utf8");

// Targets: const VERSION_NAME = "x.y.z"; 
const regex = /(VERSION_NAME\s*=\s*["'`])[^"'`]*(["'`])/;

if (regex.test(src)) {
  src = src.replace(regex, `$1${version}$2`);
  fs.writeFileSync(cliPath, src);
  console.log(`✅ Stamped version ${version} into src/cli.ts`);
} else {
  console.error("❌ Error: Target VERSION_NAME definition missing inside src/cli.ts");
  process.exit(1);
}
```

---

## 🚀 3. GitHub Actions Configuration (`.github/workflows/release.yml`)
This workflow includes advanced concurrency mitigation to abort out-of-date executions instantly on batch tag pushes, a POSIX RegEx interceptor to enforce minor/major releases, and package updates for custom staging protocols.

```yaml
name: Release CI

on:
  push:
    tags:
      - 'v*'

# --- CONCURRENCY LOCK ---
# Groups runs by the branch/ref. If multiple tags are pushed,
# older active jobs on the same branch are instantly cancelled.
concurrency:
  group:  github.workflow -{{ github.ref_name }}
  cancel-in-progress: true

jobs:
  # --- STAGE 1: COMPILE STANDALONE BINARIES & POST TO GITHUB ---
  build-and-release:
    name: Build Binaries & Release
    runs-on: ubuntu-latest
    # POSIX Regex matching initial minor/major version releases only (e.g. v1.2.0, v2.0.0)
    # Gracefully ignores patch versions (e.g. v1.2.3)
    if: \({{ matches(github.ref_name, '^v[0-9]+\.[0-9]+\.0\)') }}
    permissions:
      contents: write
    steps:
      - name: Checkout Source Code
        uses: actions/checkout@v7

      - name: Setup Bun Environment
        uses: oven-sh/setup-bun@v2
        with:
          bun-version: latest

      - name: Install Project Dependencies
        run: bun install --frozen-lockfile

      - name: Stamp Version Number into Source
        run: node scripts/stamp-version.cjs

      - name: Compile Native Binaries
        run: |
          mkdir -p dist-binary
          # Note: C++ Native bindings (.node files) will require fallback instructions documented 
          # for end-users running compiled options outside of node-driven environments.
          bun build ./src/cli.ts --compile --target=bun-linux-x64 --outfile ./dist-binary/your-cli-tool-linux-x64
          bun build ./src/cli.ts --compile --target=bun-darwin-arm64 --outfile ./dist-binary/your-cli-tool-darwin-arm64
          bun build ./src/cli.ts --compile --target=bun-darwin-x64 --outfile ./dist-binary/your-cli-tool-darwin-x64
          bun build ./src/cli.ts --compile --target=bun-windows-x64 --outfile ./dist-binary/your-cli-tool-windows-x64.exe

      - name: Generate Github Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: \${{ github.ref_name }}
          name: Release \${{ github.ref_name }}
          draft: false
          prerelease: false
          files: |
            dist-binary/your-cli-tool-linux-x64
            dist-binary/your-cli-tool-darwin-arm64
            dist-binary/your-cli-tool-darwin-x64
            dist-binary/your-cli-tool-windows-x64.exe
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}

  # --- STAGE 2: PUBLISH STANDARD BUILD TO NPM ---
  publish-npm:
    name: Stage for publication to npm
    needs: build-and-release
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source Code
        uses: actions/checkout@v7

      - name: Setup node
        uses: actions/setup-node@v7
        with:
          node-version: 22
          registry-url: https://registry.npmjs.org

      - name: Upgrade npm to latest (Requires npm >= 11.15.0)
        # Bypasses default out-of-date global binaries present on Linux runners
        run: npm install -g npm@latest

      - name: Install Project Dependencies
        run: npm ci

      - name: Run Build Script (TSC Compilation)
        run: npm run build

      - name: Stage the package
        run: npm stage publish
        env:
          NODE_AUTH_TOKEN: \${{ secrets.NPM_STAGE_TOKEN }}
```

---

## ⏳ 4. Standard Operational Release Commands
When ready to cut a new release target, fire the sequence directly from your terminal:

```bash
# Bumps minor version, executes typechecks, runs test matrix, builds binaries, stamps code, 
# creates a local Git commit, cuts a version tag, and pushes to remote repository.
npm version minor
```
