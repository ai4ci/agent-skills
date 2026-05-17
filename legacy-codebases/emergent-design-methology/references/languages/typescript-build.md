This is the preferred set of tools to support agentic typescript code generation. Modern typescript packages may use `npm/npx` or `bun/bunx`, select as appropriate for the project, in a green field project choose `bun`.
## Validation tools:
### Syntax & Formatting Validation
- `ESLint` and `Prettier` - Mature and enables documentation arguments are checked.
- `Biome` (`npx @biomejs/biome check` or `bunx @biomejs/biome check`): Faster than traditional combination of ESLint and Prettier, with structured outputs, but cannot monitor documentation, a good one off quick check option.
### Strict Type-Checking
- [tsc](https://www.typescriptlang.org/docs/handbook/compiler-options.html) (`npx tsc --noEmit`/`bunx tsc --noEmit`): 
### Testing & Assertion
- Node projects use `vitest` (`npx vitest run --reporter=json`)
- Bun projects use bun itself  (`bunx test`) 
### Dependency & Vulnerability Scans
- In built audit (`npm audit` / `bun audit`)
- Unneeded dependencies  `bunx knip --fix` followed by `bun install` (or npm equivalent)
### Code coverage
- Bun native coverage (`bun test --coverage --coverage-reporter="lcov" --coverage-dir="/tmp/coverage"`)
- NPM projects native coverage (via `vitest`) (`npm vitest run --coverage`):
### Documentation consistency
- `TypeDoc` & `eslint-plugin-jsdoc`: requires configuration and to be run within the project, and requires project setup as below
### Code duplication
- [jscpd](https://github.com/kucherenko/jscpd) : `bunx jscpd /path/to/source` or `bunx jscpd --pattern "src/**/*.ts"`
### Profiling
- see [[typescript-profiling]].

---
## Project Setup with `em`

Use `em` as the stable build interface and let it delegate to the repository's existing package manager. If the project already uses `npm`, keep using `npm`. For a greenfield TypeScript project, prefer `bun`.
### 1. Dependency Installation

Install the normal TypeScript tooling in the project and call it from `em`:

```bash
bun add --dev eslint @eslint/js typescript typescript-eslint eslint-config-prettier eslint-plugin-jsdoc prettier typedoc typedoc-plugin-markdown
```

Or for npm-based projects:

```bash
npm install --save-dev eslint @eslint/js typescript typescript-eslint eslint-config-prettier eslint-plugin-jsdoc prettier typedoc typedoc-plugin-markdown
```

### 2. Configuration Files

#### `typedoc.json`

This file instructs TypeDoc to look only at your source entry point, output clean Markdown files (`.md`) to your `./docs` folder, and bypass test errors using `skipErrorChecking`.

```json
{
  "$schema": "https://typedoc.org",
  "entryPoints": ["./src/index.ts"],
  "out": "./docs",
  "cleanOutputDir": true,
  "excludeInternal": true,
  "plugin": ["typedoc-plugin-markdown"],
  "skipErrorChecking": true,
  "compilerOptions": {
    "skipLibCheck": true,
    "exclude": [
      "tests/**/*",
      "**/*.test.ts",
      "**/*.spec.ts"
    ]
  }
}
```

#### `eslint.config.mjs`

This file configures ESLint to check your code logic, parse TypeScript, validate that your `@param` declarations exactly match your function signatures, and dynamically read `.prettierignore` so you maintain one unified ignore file.

```javascript
// @ts-check

import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import eslintConfigPrettier from 'eslint-config-prettier';
import jsdoc from 'eslint-plugin-jsdoc';
import { readFileSync } from 'node:fs';

// Dynamically sync and parse Prettier ignores for ESLint
const prettierIgnores = readFileSync('.prettierignore', 'utf8')
  .split(/\r?\n/)
  .map((line) => line.trim())
  .filter((line) => line && !line.startsWith('#'));

export default tseslint.config(
  {
    ignores: prettierIgnores,
  },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  
  // Standard JSDoc/TSDoc recommended configurations
  jsdoc.configs['flat/recommended-typescript'],

  {
    rules: {
      '@typescript-eslint/no-explicit-any': 'warn', 
      // Strict parameter rules ensuring documentation never falls out of sync
      'jsdoc/require-param': 'error',
      'jsdoc/check-param-names': 'error',
      'jsdoc/require-returns': 'error',
    },
  },
  eslintConfigPrettier,
);
```

#### `.prettierrc`

Defines your project's strict code formatting styles.

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 80
}
```

#### `.prettierignore`

A single source of truth for folder exclusions. Both Prettier and ESLint use this list, with the configuration above.

```text
node_modules/
dist/
bun.lockb
package-lock.json
docs/
tests/
```

### 3. `package.json` scripts

Keep the detailed commands in `package.json`. `em` should call these scripts rather than duplicating flags in multiple places. Prettier requires a double dash (`--`) before the file path when invoked through package scripts.

```json
"scripts": {
  "lint": "eslint",
  "format": "prettier --write -- ",
  "format:check": "prettier --check --",
  "docs:generate": "typedoc",
  "test": "vitest run",
  "typecheck": "tsc --noEmit",
  "start": "node dist/index.js"
},
"knip": {
  "ignoreDependencies": [
    "typedoc-plugin-markdown"
  ]
}
```

### 4. `em` command mapping

| `em` command | Bun project | npm project | Notes |
| --- | --- | --- | --- |
| `em run` | `bun run start` | `npm run start` | Prefer an existing `start` script. If the repository uses `dev`, document that choice in `em`. |
| `em test` | `bun test` or `bun run test` | `npm test` | Run the full automated test suite. |
| `em check` | `bun run typecheck && bun run lint . && bunx knip` | `npm run typecheck && npm run lint -- . && npx knip` | Add `format:check` if formatting is a gate. |
| `em doc` | `bun run docs:generate` | `npm run docs:generate` | Send warnings and errors to `.agents/em/docs-output`. |

### 5. Example `em` command bodies

```bash
pkg_exec() {
  if [ -f bun.lockb ]; then
    echo "bun"
  else
    echo "npm"
  fi
}

cmd_test() {
  ensure_em_dir
  local pkg
  pkg="$(pkg_exec)"
  if [ "$pkg" = "bun" ]; then
    bun test 2>&1 | tee "$TEST_LOG"
  else
    npm test 2>&1 | tee "$TEST_LOG"
  fi
}

cmd_check() {
  ensure_em_dir
  local pkg
  pkg="$(pkg_exec)"
  if [ "$pkg" = "bun" ]; then
    {
      bun run typecheck
      bun run lint .
      bunx knip
    } 2>&1 | tee "$CHECK_LOG"
  else
    {
      npm run typecheck
      npm run lint -- .
      npx knip
    } 2>&1 | tee "$CHECK_LOG"
  fi
}

cmd_doc() {
  ensure_em_dir
  local pkg
  pkg="$(pkg_exec)"
  if [ "$pkg" = "bun" ]; then
    bun run docs:generate >"$DOC_LOG" 2>&1
  else
    npm run docs:generate >"$DOC_LOG" 2>&1
  fi
}
```

### 6. Hooks and CI

Hooks may still format staged files directly, but project-level validation in hooks and CI should call `./em check` and `./em test`. That keeps local, agent, and CI behaviour aligned.