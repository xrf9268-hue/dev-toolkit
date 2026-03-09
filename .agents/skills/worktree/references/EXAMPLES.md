# Worktree Examples

## Natural Language Triggers

- `给我建个 worktree 用来做 feature-auth`
- `我想并行做支付重构，别动当前分支，帮我开个隔离目录`
- `把当前没提交的改动迁到新的 checkout 继续做`
- `把 hotfix-123 那个 worktree 里的改动挪到 release-hotfix`

## Parameter Combinations

### Existing Branch

```text
branch-name: feature-auth
```

结果：若 `feature-auth` 未被其他 worktree 占用，则直接为该分支创建 worktree。

### Existing Branch Already Checked Out

```text
branch-name: feature-auth
```

结果：如果 `feature-auth` 已在当前或其他 worktree 中 checkout，不要重试同名分支；改为询问新的 `branch-name`，或用新分支名并以 `feature-auth` 作为 `--base` 创建派生分支。

### New Branch From Explicit Base

```text
branch-name: feature-new
--base develop
```

结果：若 `feature-new` 不存在，则基于 `develop` 创建新分支并创建 worktree。

### Migrate Current Changes

```text
branch-name: feature-auth
--stash
```

结果：当前工作区有改动时先 stash，再在新 worktree 应用本次 stash ref。

### Migrate From Another Worktree

```text
branch-name: release-hotfix
--from hotfix-123
```

结果：从 `hotfix-123` 对应的精确 worktree 解析来源，stash 来源改动后在新 worktree 应用。

### Remote-Only Branch

```text
branch-name: release-hotfix
```

结果：如果 `release-hotfix` 只存在于远端，先按 remote 选择规则解析唯一远端，再在新 worktree 中创建本地跟踪分支；多 remote 命中时停止并询问。

## Output Samples

### Success With Migration

```text
Worktree created successfully!

  Path:         ../.worktrees/my-project/release-hotfix/
  Branch:       release-hotfix
  Migrated:     applied (stash@{2})
  Local config: copied .env, docs/.local
  Dependencies: installing in background (pnpm)

Next steps:
  cd ../.worktrees/my-project/release-hotfix/
  继续你的编辑器、agent 或终端流程
```

### Success Without Migration

```text
Worktree created successfully!

  Path:         ../.worktrees/my-project/feature-auth/
  Branch:       feature-auth
  Migrated:     skipped (no local changes)
  Local config: skipped
  Dependencies: skipped

Next steps:
  cd ../.worktrees/my-project/feature-auth/
  继续你的编辑器、agent 或终端流程
```

### Base Branch Required

```text
⚠️ 无法确定新分支的基线分支。

请显式提供 --base <branch>，或先创建/同步默认分支。
```
