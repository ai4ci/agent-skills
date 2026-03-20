#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="scripts/extract_documentation.R"

run_extract_documentation() {
  (
    cd "$SKILL_DIR"
    Rscript "$SCRIPT" "$@"
  )
}

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== Testing extract_documentation.R with package: tools ==="

# Capture output to a temp file
OUTPUT_FILE=$(mktemp /tmp/test_extract_output_XXXXXX.txt)
trap 'rm -f "$OUTPUT_FILE"' EXIT

run_extract_documentation --package tools 2>/dev/null > "$OUTPUT_FILE"
EXIT_CODE=$?

check_contains() {
  local label="$1"
  local pattern="$2"
  if grep -qF "$pattern" "$OUTPUT_FILE"; then
    pass "$label"
  else
    fail "$label — pattern not found: '$pattern'"
  fi
}

# 1. Exit code
if [[ $EXIT_CODE -eq 0 ]]; then
  pass "Script exits with code 0"
else
  fail "Script exits with code 0 (got $EXIT_CODE)"
fi

# 2. DESCRIPTION section header
check_contains "DESCRIPTION section header present" "DESCRIPTION: tools"

# 3. Package title from DESCRIPTION
check_contains "Package title in DESCRIPTION" "Tools for Package Development"

# 4. Manual section for Rd2txt (core tools function)
check_contains "Manual section for Rd2txt" "Manual: Rd2txt"

# 5. Manual section for fileutils (file utility functions)
check_contains "Manual section for fileutils" "Manual: fileutils"

# 6. Manual section for toTitleCase
check_contains "Manual section for toTitleCase" "Manual: toTitleCase"

# 7. file_ext usage appears in function reference body
check_contains "file_ext usage in function docs" "file_ext(x)"

# 8. Rd2txt function signature in body
check_contains "Rd2txt function signature in body" "Rd2txt(Rd"

# 9. Section separators are present
check_contains "Section separator lines present" "============================================="

# 10. --output flag writes to a file
TMP_FILE=$(mktemp /tmp/test_extract_XXXXXX.txt)
run_extract_documentation --package tools --output "$TMP_FILE" 2>/dev/null
if [[ -s "$TMP_FILE" ]]; then
  pass "--output flag writes non-empty file"
else
  fail "--output flag writes non-empty file"
fi
if grep -qF "DESCRIPTION: tools" "$TMP_FILE"; then
  pass "--output file contains expected content"
else
  fail "--output file contains expected content"
fi
rm -f "$TMP_FILE"

# 11. Missing --package argument exits non-zero
if ! run_extract_documentation 2>/dev/null; then
  pass "Missing --package exits non-zero"
else
  fail "Missing --package exits non-zero"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
