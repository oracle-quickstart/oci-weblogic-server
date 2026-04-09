# Cline Workflow: Jira Closure

Use this workflow after a pull request has been merged and the remaining work is to close the loop in Jira, Slack, git, and any release or follow-up tracking.

## Workflow Steps

The detailed execution flow is organized into the numbered sections below.

## 1. Inputs and preconditions

### Required inputs
- merged PR URL or PR number
- Jira ticket key or Jira URL

### Optional inputs
- parent ticket key or list of subtasks
- Slack channel name
- topic branch name
- rollout, release-note, or backport instructions

### Default behavior
- derive the topic branch from the merged PR when it is not provided
- reuse the previously requested Slack channel when one is already known; otherwise ask once before posting
- apply the repository MCP retry policy from `.clinerules/rules.md` for Jira, PR, and Slack operations

---

## 2. Confirm the PR is merged

1. Verify that the PR is merged before doing any closeout work.
2. Capture:
    - merge commit or squash commit reference
    - base branch
    - merged topic branch
    - final CI or validation status
3. If the PR is not merged, stop the closeout workflow and ask the user how to proceed.

---

## 3. Review merged scope and follow-up obligations

Before closing tickets, review the merged change for any remaining obligations, such as:
- unresolved reviewer comments that need a follow-up ticket
- release-note or documentation updates still pending
- backport or rollout tasks
- manual verification items still open

If more work remains, create or update follow-up Jira issues instead of silently closing the work.

---

## 4. Update Jira subtasks

- transition implementation, validation/test, and docs / PR follow-up subtasks to the appropriate done or resolved state
- for Story or Epic work, verify that the mandatory subtasks created earlier are either complete or replaced by explicit follow-up tickets
- do not close a subtask if real work is still outstanding and untracked

---

## 5. Update the parent Jira ticket

- move the parent issue to the correct done, resolved, or delivered state once the required subtasks are complete
- keep release, backport, or rollout follow-ups linked when they remain open
- preserve any meaningful implementation summary in the parent issue history

---

## 6. Add a final Jira closeout comment

Add a Jira comment that includes:
- merged PR URL
- merge commit or branch information
- base branch
- test or verification summary
- any follow-up tickets, rollout notes, or known next steps

Suggested Jira comment:

```text
PR merged: <PR-URL>
Merge commit: <MERGE-COMMIT>
Base branch: <BASE-BRANCH>
Verification: <short summary>
Follow-up: <ticket links or none>
```

---

## 7. Notify Slack

Post a short closeout update to the requested Slack channel after Jira is updated.

Suggested Slack message:

```text
<TICKET-KEY> merged and closed out
PR: <PR-URL>
Base branch: <BASE-BRANCH>
Verification: <short summary>
Follow-up: <ticket links or none>
Jira: <JIRA-URL>
```

If no Slack channel is known and a message is required, ask once before posting.

---

## 8. Clean up local and remote branches

After merge confirmation, clean up the topic branch locally and remotely when appropriate.

Typical commands:

```bash
git checkout <base-branch>
git pull --ff-only origin <base-branch>
git branch -d <topic-branch>
git push origin --delete <topic-branch>
git fetch origin --prune
```

If the branch must be retained for a release or backport reason, document that choice in Jira or Slack instead of deleting it silently.

---

## 9. Final repository and release closeout

- update any remaining release notes, runbooks, or tracking docs that were intentionally deferred until merge
- ensure follow-up work is captured in Jira rather than left as tribal knowledge
- confirm there are no accidental local leftovers related to the completed branch

---

## 10. Done checklist

A merged PR closeout is complete when all the following are done:
- merged PR status was confirmed
- outstanding follow-ups were reviewed and tracked
- Jira subtasks were updated
- parent Jira ticket was updated
- final Jira closeout comment was added
- Slack notification was sent when requested
- local and remote branch cleanup was handled or explicitly deferred
- release-note, rollout, or follow-up obligations were recorded