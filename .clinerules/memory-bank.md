# Memory Bank: OCI WebLogic Server Repository

## Purpose
This file captures high-signal project context, conventions, and reminders for recurring work in the `oci-weblogic-server` repository.

## Repository Snapshot
- Repository: `oracle-quickstart/oci-weblogic-server`
- Primary domain: OCI Terraform stack for WebLogic Server
- Main implementation area: `terraform/` (root modules + reusable modules)
- Supporting areas:
  - `builds/` for bundle/build scripts
  - `solutions/` for topology examples and tfvars guidance
  - `utils/` for helper scripts
  - `.clinerules/` for workflow/rules/skills documentation

## Working Norms
- Jira-first execution for ticketed work.
- Follow `.clinerules/workflows/jira-ticket-implementation.md` for delivery work.
- Follow `.clinerules/workflows/jira-closure-workflow.md` after PR merge closeout.
- Branching defaults:
  - use `master` if present, otherwise `main`
  - ask for release branch if backport/release train is mentioned
- Keep commits ticket-linked: `<TICKET-KEY> - <short summary>`.

## File and Change Hygiene
- Preserve local style/conventions in each directory.
- For new files, mirror header/licensing format from nearby comparable files.
- Avoid unrelated refactors in ticket-scoped changes.
- Update tests/validation/docs when behavior changes.

## Validation Expectations
- Prefer smallest meaningful validation set per change:
  - targeted script checks
  - Terraform validation/plan where relevant
  - related module checks
- Record commands and outcomes for PR notes.
- If a validation step is skipped, explicitly state why.

## PR and Closeout Expectations
- PR should include:
  - summary of changes
  - Jira link
  - testing performed
  - risks/notes/follow-ups when needed
- After PR creation:
  - comment on Jira with PR link and testing summary
  - notify requested Slack channel (when applicable)
- After merge (if requested):
  - transition Jira to done/resolved states
  - add final closure comment
  - clean local/remote branches with merge confirmation

## MCP/Automation Reliability Notes
- Treat Jira/PR/Slack MCP failures as retryable when transient.
- Retry up to 3 times with short backoff before escalating.
- Keep dependent MCP actions serialized.
- Do not claim side effects succeeded unless confirmed.

## Quick Pointers
- Rules: `.clinerules/rules.md`
- Ticket implementation workflow: `.clinerules/workflows/jira-ticket-implementation.md`
- Closure workflow: `.clinerules/workflows/jira-closure-workflow.md`
- Workflow diagrams:
  - `.clinerules/workflows/jira-ticket-implementation.svg`
  - `.clinerules/workflows/jira-closure-workflow.svg`