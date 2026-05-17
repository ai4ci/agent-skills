Here is your SQL validation framework, refactored to align with the exact layout, structure, and visual style used across your previous language specifications.

---

## Validation tools (SQL):

## Syntax & Formatting Validation

- SQLFluff (`sqlfluff lint --dialect postgres --format json . > sql-errors.json`): The definitive industry-standard linter and formatter for SQL. It supports dozens of specific database dialects (PostgreSQL, Snowflake, BigQuery, T-SQL) and exports precise line-and-column error maps as structured JSON records for automated AI correction.
- Sleek / sql-formatter (`npx sql-formatter -l postgres -w`): High-performance standalone formatters. They execute instantly on massive data files, standardizing basic visual layouts, keyword capitalization, and trailing commas without the processing overhead of a deep logic linter.

## Deep Namespace & Syntax Checking

- Squawk (`squawk --reporter=json . > sql-safety-report.json`): A specialized static analysis linter focused strictly on PostgreSQL. It identifies structural database anti-patterns and high-risk migration flaws (e.g., executing un-isolated table blocks or adding `NOT NULL` constraints without defaults) and emits machine-readable JSON alerts.

## Direct Schema Validation (No Database Engine Execution)

- Atlas (`atlas schema lint --env dev --format '{{ json . }}'`): A modern database schema management engine. It allows automated agents to perform dry-run query validations and schema audits locally using an isolated dev-database runner, flagging syntax anomalies and data-loss risks.

## Testing & Assertion

- pgTAP / tSQLt (`pg_prove --reporter TAP::Formatter::JUnit tests/`): Database-native unit testing frameworks. They run assertion procedures directly inside the database engine to validate views, constraints, or stored procedures, and stream results out via standard JUnit XML or TAP protocols.

## Dependency & Vulnerability Scans

- SQLFluff (Security Rules) (Embedded): Out-of-the-box rule sets analyze syntax branches to actively flag SQL injection vulnerabilities, raw string concatenations, and implicit type-coercion hazards.

## Code coverage

- plsqlcov / pgCodeCritique: Procedural code coverage tools. They hook directly into the database runtime to instrument and track execution paths across stored procedures, functions, and database triggers during unit test suites.

## Documentation consistency

- SchemaSpy / dbdocs (`java -jar schemaspy.jar -t postgresql -o ./doc-output`): Schema documentation extractors. They scrape raw database metadata and embedded inline remarks (e.g., `COMMENT ON COLUMN`), validating database health by highlighting structural tables that lack semantic descriptions.

## Code duplication

- jscpd (`bunx jscpd "src/**/*.sql"`): Identifies repeated multi-line structural query blocks or duplicate subqueries across migrations and script directories.

## Profiling

- Explain Plan Analysis (`EXPLAIN (ANALYZE, FORMAT JSON) SELECT...`): Database-native statement optimization. Executes query targets on live testing layers, returning nested JSON execution paths and exact node cost valuations for agent parsing.

---

## Project Setup (SQL):

Here is the complete summary of the environment installation instructions and standard configurations required to manage multi-dialect SQL validation pipelines.

## 1. Dependency Installation

Install your core SQL linting, formatting, and schema validation utilities using Python's `uv` and Node's `bun` package infrastructure:

```bash
# Install Python-backed linting infrastructure via uv
uv tool install sqlfluff

# Install standalone formatters and tools via bun
bun add --dev sql-formatter

# Install the native Atlas schema binary (macOS/Linux)
curl -sSf https://atlasgo.sh | sh
```

---

## 2. Configuration Files

## `.sqlfluff`

Place this configuration at the root of your project workspace to govern global linting rules and layout constraints across your code models:

```ini
[sqlfluff]
# Set the baseline target engine dialect
dialect = postgres
templater = raw
max_line_length = 80

[sqlfluff:indentation]
tab_space_size = 2
indent_unit = space

[sqlfluff:rules:capitalisation.keywords]
# Enforce consistent uppercase syntax across standard commands
capitalisation_policy = upper

[sqlfluff:rules:layout.commas]
# Enforce a uniform trailing comma alignment
line_position = trailing
```

## `atlas.hcl`

Configure your Atlas environment block to isolate structural testing from your production data layers:

```hcl
env "dev" {
  src = "file://migrations"
  # Isolated dev engine URL used strictly for headless schema validation
  dev = "docker://postgres/15/dev"
  
  migration {
    dir = "file://migrations"
  }
}
```

---

## 3. Integrated Scripts (`package.json` proxy layer)

Map standard multi-dialect checking routines into your core `package.json` configurations to supply your orchestration agents with a uniform execution wrapper:

```json
"scripts": {
  "lint": "sqlfluff lint --dialect postgres --format json . > sql-lint-report.json",
  "format": "sqlfluff fix --dialect postgres --force .",
  "format:check": "sql-formatter -l postgres -c .prettierignore --check",
  "docs:generate": "atlas schema inspect --env dev > schema.md"
}
```

---

## 4. Running the Ecosystem Commands

- `bun run lint` — Runs deep multi-file dialect audits and logs code structure errors into a JSON output.
- `bun run format` — Automatically refactors all database files, fixing capitalization issues and structural indents.
- `bun run format:check` — Scans SQL queries and returns a non-zero exit status if layout patterns are violated.
- `bun run docs:generate` — Headlessly inspects schema code matrices to export a unified markdown description.

---

## Git Workflow Integration (SQL expansion)

Incorporate multi-dialect SQL rules into your primary `lefthook.yml` validation sequence to stop broken schemas or high-risk queries from landing in your version history:

```yaml
pre-commit:
  commands:
    # Task 1: Check and auto-correct SQL structural formatting syntax via SQLFluff
    format-sql:
      glob: "*.sql"
      run: sqlfluff fix --dialect postgres --force {staged_files} && git add {staged_files}

    # Task 2: Validate queries against dialect profiles and run Squawk safety evaluations
    lint-sql:
      glob: "*.sql"
      run: sqlfluff lint --dialect postgres {staged_files} && squawk {staged_files}
```

