---
name: worktree
description: Create a git worktree with synced configs, content migration (--stash, --from), and background dependency installation. Use when user wants parallel development environment or needs to work on multiple branches simultaneously.
metadata:
  short-description: Git worktree with config sync and content migration
---

# Git Worktree Skill

You are an expert DevOps assistant. Create a parallel development environment with optional content migration.

## Usage

```
$worktree [branch-name] [--stash] [--from <worktree>]
```

## Quick Start

1. **Parse arguments**: branch name, `--stash`, `--from <worktree>`
2. **Analyze context**: Find main repo via `git rev-parse --git-common-dir`
3. **Resolve branch**: Use provided name or prompt user to select
4. **Migrate content**: If `--stash` or `--from` specified (see [MIGRATION.md](references/MIGRATION.md))
5. **Create worktree** at `../.worktrees/<project>/<branch>/`
6. **Sync configs**: Copy `.claude/`, `.codex/`, `.env`, `.vscode/`, etc.
7. **Install deps**: Background install with detected package manager
8. **Copy launch command** to clipboard

## Arguments

| Argument | Description |
|----------|-------------|
| `branch-name` | Target branch (positional) |
| `--stash` | Migrate current uncommitted changes to new worktree |
| `--from <worktree>` | Migrate changes from specified worktree |

## Directory Structure

```
parent/
├── project/                    # Main repo
└── .worktrees/
    └── project/                # Grouped by project
        ├── feature-auth/       # Worktree 1
        └── hotfix-123/         # Worktree 2
```

## Detailed Documentation

- Complete workflow steps: [references/WORKFLOW.md](references/WORKFLOW.md)
- Content migration guide: [references/MIGRATION.md](references/MIGRATION.md)
- Usage examples: [references/EXAMPLES.md](references/EXAMPLES.md)

## Output

Provide a clear summary (do NOT auto-open editor):

```
Worktree created successfully!

  Path:     ../.worktrees/<project>/<branch>/
  Branch:   <branch-name>
  Configs:  .claude/, .codex/, .env, .vscode/, ...
  Migrated: [if applicable]
  Dependencies: Installing in background (<pkg-mgr>)

Quick start (copied to clipboard):
  cd <path> && codex
```
