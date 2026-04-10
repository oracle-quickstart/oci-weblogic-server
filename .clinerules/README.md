# Cline Rules, Workflows, and Skills

This directory contains repository-specific guidance for working in the
`oci-weblogic-server` codebase with Cline.

## Structure

```text
.clinerules/
├── README.md
├── memory-bank.md
├── rules.md
├── workflows/
│   ├── jira-ticket-implementation.md
│   ├── jira-to-pr-workflow.svg
│   ├── jira-closure-workflow.md
│   └── jira-closure-workflow.svg
├── skills/
│   ├── code-quality-skill.md
│   ├── jenkins-build-skill.md
│   ├── jira-management-skill.md
│   └── oci-operations-skill.md
├── scripts/
│   ├── validate-rules.sh
│   └── validate-workflows.sh
└── templates/
    ├── new-skill-template.md
    └── new-workflow-template.md
```

## What lives here

- `rules.md`: the repository rules Cline should follow.
- `workflows/`: documented execution flows for recurring work.
- `skills/`: focused capability documents for recurring engineering tasks.
- `scripts/`: lightweight validation helpers for this directory.
- `templates/`: starter documents for future additions.

## Primary workflows

The default workflow for ticketed work is documented in
`workflows/jira-ticket-implementation.md` and visualized in the sibling SVG.

Post-merge cleanup and delivery closeout work is documented in
`workflows/jira-clousre-workflow.md` and visualized in its sibling SVG.

## Stretch goals covered

- README documenting the structure and usage
- examples embedded in workflow and skill documents
- validation scripts for rules/workflows
- templates for future workflow and skill additions

## Usage notes

1. Read `rules.md` before starting repository work.
2. Use the jira-ticket-implementation workflow for Jira-driven changes through PR creation.
3. Use the jira closure workflow after a PR is merged to finish Jira, Slack, and branch cleanup steps.
4. Reuse the skill documents when operating Jenkins, Jira, OCI, or code quality tasks.
5. Run the validation scripts after editing `.clinerules` content.

## Validation

```bash
./.clinerules/scripts/validate-rules.sh
./.clinerules/scripts/validate-workflows.sh
```

## Viewing hidden folders in IntelliJ

Because `.clinerules` starts with a dot, it may be hidden depending on IDE
filters. In IntelliJ, make sure hidden files are visible in the Project tool
window if you do not immediately see it.