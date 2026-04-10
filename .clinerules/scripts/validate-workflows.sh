#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

fail() {
  echo "[FAIL] $*" >&2
  exit 1
}

echo "Validating .clinerules workflow artifacts..."
[[ -f "${ROOT_DIR}/.clinerules/workflows/jira-ticket-implementation.md" ]] || fail "Missing workflow markdown"
[[ -f "${ROOT_DIR}/.clinerules/workflows/jira-ticket-implementation.svg" ]] || fail "Missing workflow svg"
[[ -f "${ROOT_DIR}/.clinerules/workflows/jira-closure-workflow.md" ]] || fail "Missing post-merge workflow markdown"
[[ -f "${ROOT_DIR}/.clinerules/workflows/jira-closure-workflow.svg" ]] || fail "Missing post-merge workflow svg"
[[ -f "${ROOT_DIR}/.clinerules/skills/jenkins-build-skill.md" ]] || fail "Missing Jenkins skill"
[[ -f "${ROOT_DIR}/.clinerules/skills/jira-management-skill.md" ]] || fail "Missing Jira skill"
[[ -f "${ROOT_DIR}/.clinerules/skills/oci-operations-skill.md" ]] || fail "Missing OCI skill"
[[ -f "${ROOT_DIR}/.clinerules/skills/code-quality-skill.md" ]] || fail "Missing code quality skill"
grep -q "Workflow Steps" "${ROOT_DIR}/.clinerules/workflows/jira-ticket-implementation.md" || fail "Workflow doc missing Workflow Steps section"
grep -q "<svg" "${ROOT_DIR}/.clinerules/workflows/jira-ticket-implementation.svg" || fail "Workflow SVG invalid"
grep -q "Workflow Steps" "${ROOT_DIR}/.clinerules/workflows/jira-closure-workflow.md" || fail "Jira closure workflow doc missing Workflow Steps section"
grep -q "<svg" "${ROOT_DIR}/.clinerules/workflows/jira-closure-workflow.svg" || fail "Jira closure workflow SVG invalid"
echo "[PASS] Workflow and skill artifacts look present and consistent."