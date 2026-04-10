# JIRA Ticket to Branch, PR, and Cleanup Workflow

## Goal
Deliver Jira-driven changes consistently, from requirements capture to PR creation and final Jira updates.

## Inputs and defaults

### Required inputs
- Jira ticket key or Jira URL

### Optional inputs
- Parent ticket key (if the supplied issue is a parent/epic/story that needs subtasks)
- Base branch: <BASE-BRANCH> (default: main or master)
- Repo root: <REPO-PATH>
- Preferred topic branch prefix: <PREFIX> (default: jira/)
- Assignee: <JIRA-ASSIGNEE> (default: me)

### Default behavior
- If the target branch is not specified, assume the repository default branch:
  - use `master` if it exists
  - otherwise use `main`
- If the ticket explicitly references a release train or backport, ask which release branch to use instead of guessing.

For this repository, `master` exists and release branches follow patterns like `release-wlsoci26.1.1`.

Rules:
- Always read the Jira ticket first.
- If Jira or Slack MCP calls fail, retry 2x with backoff before asking me.
- Use copyright header template where new files are created.
- Do not push changes until tests/validation steps (if any) are completed or explicitly skipped.

## Workflow steps

### 1) Jira Intake
- Fetch the Jira issue through the Jira MCP server.
- Capture:
  - summary
  - description
  - acceptance criteria
  - linked issues / subtasks
  - fix version / release hints
  - comments that clarify scope

### 2) Enumerate code changes
Before editing code, review the repository to identify impacted files, behaviors, tests, docs, and build assets.

Create a concise change inventory that includes:
- files or modules likely to change
- why each area is impacted
- required tests or validations
- any docs, release notes, or generated artifacts that should move with the change

If the ticket scope is broad, split the inventory into logical implementation units.

### 3) Create or align Jira subtasks
Create Jira subtasks under the parent ticket when the work can be cleanly separated, for example:
- implementation
- test coverage / validation
- documentation or release-note updates
- release/backport follow-up

Subtask guidance:
- use action-oriented titles
- copy the parent ticket link into each subtask
- add the planned file/module scope to each subtask description
- do not create duplicates if matching subtasks already exist
- assign ticket to <JIRA-ASSIGNEE> (default: me).
- move ticket status to "In Progress".

Suggested subtask naming:
- `<TICKET-KEY>: implement code changes`
- `<TICKET-KEY>: validate and test`
- `<TICKET-KEY>: docs / PR follow-up`

### 4) Create the topic branch
- Sync the chosen base branch.
- Create a topic branch from the selected base branch.
- Use the repository naming convention.

Recommended branch format:
- `<owner>/<ticket-key-lowercase>`

Examples:
- `pgnanesh/jcs-15221`

Typical commands:
```bash
git fetch origin --prune
git checkout main
git pull --ff-only origin main
git checkout -b <owner>/<ticket-key-lowercase>
```

For release work, replace `main` with the selected release branch.

### 5) Implement the ticket
Implementation expectations:
- follow the enumerated scope
- keep changes traceable to the Jira ticket or subtask
- update tests, scripts, docs, or configs as required
- keep diffs focused; avoid unrelated cleanup unless it is required for correctness

#### Copyright / license rule
When creating new files, copy the header pattern from the closest matching file type in the repository.

Examples used in this repository include:

Shell / Python / YAML style
```
#
# Copyright (c) 2026, Oracle and/or its affiliates. All rights reserved.
#
```

UPL-style files when the surrounding area uses it
```
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
```

Always mirror the neighboring file convention instead of forcing a single header onto every file type.

### 6) Validate before commit
Run the smallest meaningful validation set for the change, such as:
- targeted script validation
- unit/integration tests
- build or lint commands
- repo-specific smoke checks

Capture the exact commands and high-level results for later PR notes.
If a validation step is skipped, explicitly record why.

### 7) Commit and push the Jira branch
Before committing:
- review `git diff`
- confirm no accidental files are included
- ensure ticket-linked messages and docs are accurate

Recommended commit format:
`<TICKET-KEY> - <short summary>`

Example:
`JCS-15221 - Add the intial proto files to the repository`

Typical commands:
```bash
git status --short
git add <files>
git commit -m "<TICKET-KEY> - <short summary>"
git push -u origin <topic-branch>
```

### 8) Create the pull request
Create the PR from the topic branch to the chosen base branch.

Base branch selection rule:
- user-provided branch wins
- otherwise, use `master` if present
- otherwise, use `main`
- if the ticket indicates a release backport, ask which release branch to target

Required PR body:
```
## Summary
- change 1
- change 2

## Jira
- https://jira.oraclecorp.com/jira/browse/<TICKET-KEY>

## Testing
- `command 1`
- `command 2`

## Risks / Notes
- none
```

PR title recommendation:
`<TICKET-KEY>: <concise change summary>`

### 9) Update Jira with the PR link
After the PR is created:
- add the PR URL to the parent ticket or the implementation subtask
- add a short note summarizing what changed
- include testing summary or CI status if available

Suggested Jira comment:
```
PR created: <PR-URL>
Branch: <topic-branch>
Base branch: <base-branch>
Testing: <short test summary>
```