# WebLogic for OCI Cline Project Rules

## Primary Jira-to-PR workflow
- For Jira-driven work, use `.clinerules/workflows/jira-ticket-implementation.md` as the default execution playbook.
- Jira-first execution: read the Jira ticket before implementation and use the ticket details to drive planning, scope, testing, and PR updates.
- Start by reading the Jira ticket with the appropriate MCP server. If Jira access is unavailable, ask the user for the ticket contents or the missing connection details.
- Review the ticket and the relevant code before making changes, then enumerate the intended code, test, and documentation changes.
- If the work naturally breaks into multiple deliverables, create or update Jira subtasks under the parent ticket before implementation.
- Reference `.clinerules/memory-bank.md` for project context, architecture decisions, and key knowledge before starting work.

## Branching and git rules
- Ask for the target base branch when the user mentions a release branch or when the target branch is ambiguous.
- If no base branch is provided, default to `master` when it exists, otherwise use `main`.
- Follow the repository branch naming convention. Prefer `<owner>/<ticket-key-lowercase>` unless the user asks for a different convention.
- Keep commits scoped and ticket-linked. Default commit message format: `<TICKET-KEY> - <short summary>`.

## Implementation and file hygiene
- Preserve existing file style and nearby conventions.
- For every new source/config/script file, add the same Oracle copyright and license header style used by the nearest comparable file in the repository.
- Do not remove or rewrite existing copyright/license text unless the task explicitly requires it.
- Add or update tests when the ticket changes behavior, validation, or build logic.

## Pull request rules
- Create the PR against the selected base branch using the diff between the topic branch and that base branch.
- PR descriptions must include:
    - Summary of changes
    - Jira link
    - Testing performed
    - Risks, rollout notes, or follow-ups when relevant
- After PR creation, add the PR link back to the Jira task/subtask and notify the requested Slack channel.

## MCP reliability rules
- Treat Jira, Git/PR, and Slack MCP calls as retryable when failures look transient.
- Retry transient MCP failures up to 3 times with short backoff before asking the user for help.
- Use MCP operations one at a time, record the failure clearly, and do not silently skip required updates.

## Optional completion workflow
- When the user asks to finish the full lifecycle, verify the PR status, close or transition the Jira ticket/subtasks, and clean up local/remote topic branches after merge confirmation or explicit approval.