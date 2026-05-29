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

## Logging

- Use the database engine's native logging primitives as the default. For PostgreSQL this means `RAISE LOG`, `RAISE NOTICE`, or `RAISE WARNING` in procedural code, with migration and application-layer logs handled by the migration runner rather than inventing a separate SQL logging framework.

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

## Project Setup (SQL) with `em`

Use `em` to standardise schema workflows. For SQL projects, `em run` must operate against a disposable local or development database. It must never default to production.

## 1. Dependency Installation

Install the core SQL linting, formatting, and schema validation utilities used by the repository:

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

## 3. `em` command mapping

| `em` command | SQL command | Notes |
| --- | --- | --- |
| `em run` | `atlas schema apply --env dev` or the repository migration command | Only target disposable or development infrastructure. |
| `em test` | `pg_prove`, `sqldef`, or migration smoke tests | Pick the test runner used by the repository. |
| `em check` | `sqlfluff lint --dialect postgres . && squawk .` | Match the real dialect in `.sqlfluff`. |
| `em doc` | `atlas schema inspect --env dev` | Save warnings and errors to `.agents/em/docs-output`. |

## 4. Example `em` command bodies

```bash
cmd_run() {
  ensure_em_dir
  atlas schema apply --env dev --auto-approve >"$RUN_LOG" 2>&1
}

cmd_test() {
  ensure_em_dir
  pg_prove tests 2>&1 | tee "$TEST_LOG"
}

cmd_check() {
  ensure_em_dir
  {
    sqlfluff lint --dialect postgres .
    squawk .
  } 2>&1 | tee "$CHECK_LOG"
}

cmd_doc() {
  ensure_em_dir
  atlas schema inspect --env dev >"$DOC_LOG" 2>&1
}
```

If the repository uses a different database engine or migration tool, keep the same `em` surface and swap the internal commands.

## 5. Hooks and CI

Hooks may run `sqlfluff fix` on staged files, but the project-level validation contract should stay `./em check` and `./em test`.
