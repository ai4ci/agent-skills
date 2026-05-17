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
## Project Setup:

Here is the complete summary of all dependencies and configuration files required to enable strict TypeScript linting, synchronized documentation validation, Prettier formatting, and Markdown documentation generation using `bun` or `npm`.
### 1. Dependency Installation

Install all necessary dev dependencies for your linting, formatting, and documentation ecosystem:

```bash
bun add --dev eslint @eslint/js typescript typescript-eslint eslint-config-prettier eslint-plugin-jsdoc prettier typedoc typedoc-plugin-markdown
```

OR 

```
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

### 3. Integrated bun / npm Scripts (`package.json`)

Add these commands to the `"scripts"` field in your `package.json` to make running tasks direct and streamlined (and stop `knip` removing references by name). Prettier requires a double dash (--) before the file path when invoked through package scripts

```json
"scripts": {
  "lint": "eslint",
  "format": "prettier --write -- ",
  "format:check": "prettier --check --",
  "docs:generate": "typedoc"
},
"knip": {
  "ignoreDependencies": [
    "typedoc-plugin-markdown"
  ]
}
```

### 4. Running the Ecosystem Commands

- `bun run lint <file or directory>` — Validates TS rules and guarantees doc-block comments match functions.
- `bun run format <file or directory>` — Automatically formats files (skipping the `docs/` folder).
- `bun run format:check <file or directory>
- `bun run docs:generate` — Compiles safe Markdown API pages without tripping over tests.

or npm equivalents

---
## Git Workflow Integration

### 1. Install Lefthook

Add Lefthook to your project development dependencies using Bun:

```bash
bun add --dev lefthook
```

### 2. Create the Configuration File

Create a file named **`lefthook.yml`** in your project's root folder. This file instructs Git to isolate and scan _only_ the specific TypeScript files you have changed (staged) right before a commit is allowed to complete:

```yaml
pre-commit:
  commands:
    # Task 1: Check and fix code formatting
    format:
      glob: "*.ts"
      run: bun run format {staged_files} && git add {staged_files}

    # Task 2: Validate code logic and check documentation sync
    lint:
      glob: "*.ts"
      run: bun run lint {staged_files}
```

### 3. Activate the Hooks

Run the initialization command to write Lefthook's execution scripts into your native hidden `.git/hooks/` directory:

```bash
bunx lefthook install
```


---