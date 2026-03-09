# Usage Examples

## Basic Usage

### Create worktree for existing branch

```
branch-name: feature-auth
```

Creates a worktree at `../.worktrees/<project>/feature-auth/`

### Create worktree for new branch

```
branch-name: my-new-feature
```

If branch doesn't exist, creates it from latest main/master.

### Create new branch from specific base

```
branch-name: my-new-feature
--base develop
```

Creates new branch from `develop` instead of main/master.

### Interactive branch selection

```
branch-name: [ask user]
```

Shows recent branches and prompts for selection.

---

## With Content Migration

### Move current changes to new worktree

```
branch-name: feature-auth
--stash
```

1. Stashes current uncommitted changes
2. Creates worktree
3. Applies stash in new worktree

### Move changes from another worktree

```
branch-name: feature-auth
--from hotfix-123
```

1. Stashes changes from `hotfix-123` worktree
2. Creates `feature-auth` worktree
3. Applies stash in new worktree

---

## With Base Branch

### Create feature from develop branch

```
branch-name: feature-new
--base develop
```

Creates `feature-new` branch based on latest `origin/develop`.

### Create hotfix from release branch

```
branch-name: hotfix-123
--base release/v2.0
```

Creates `hotfix-123` branch based on `origin/release/v2.0`.

---

## Natural Language Triggers

The skill also responds to natural language:

- "Create a parallel branch for feature work"
- "I need a new worktree for testing"
- "Switch to a new branch but keep my changes"
- "Set up a parallel development environment"

---

## Output Example

```
Worktree created successfully!

  Path:     ../.worktrees/my-project/feature-auth/
  Branch:   feature-auth
  Configs:  .agents/, AGENTS.md, .env, .vscode/

  Migrated: Changes applied from current worktree
            Original stash preserved for safety

  Dependencies: Installing in background (pnpm)

Next steps:
  1. Enter the new worktree path
  2. Continue with your preferred agent, editor, or terminal workflow
```
