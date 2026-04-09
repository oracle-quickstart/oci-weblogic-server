#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

echo "Validating .clinerules rule documents..."
[[ -f "${ROOT_DIR}/.clinerules/README.md" ]] || fail "Missing .clinerules/README.md"
[[ -f "${ROOT_DIR}/.clinerules/rules.md" ]] || fail "Missing .clinerules/rules.md"
grep -q "Jira-first execution" "${ROOT_DIR}/.clinerules/rules.md" || fail "rules.md missing Jira section"
grep -q "Validation" "${ROOT_DIR}/.clinerules/README.md" || fail "README.md missing validation section"
echo "[PASS] Rules documentation looks present and consistent."