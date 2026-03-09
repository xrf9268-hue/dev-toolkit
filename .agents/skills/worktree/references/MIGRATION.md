# Worktree Migration Reference

本文件定义 `--stash` 与 `--from <worktree>` 的迁移规则。

## Shared Rules

- `--stash` 与 `--from <worktree>` 互斥
- 迁移前先检查来源工作区是否有未提交改动：

```bash
git status --porcelain
```

- 迁移时要包含 untracked files
- 必须记录“本次创建的 stash ref”，后续只能用这个 ref 应用改动
- 绝不能假设最新条目一定是 `stash@{0}`

## Option A: `--stash`

适用场景：

- 当前目录有 work-in-progress
- 用户想把当前改动整体迁到新 worktree

推荐步骤：

1. 检查当前工作区是否有改动
2. 无改动时标记 `Migrated: skipped (no local changes)`，继续创建 worktree
3. 有改动时执行带唯一消息的 stash：

```bash
STASH_MSG="worktree-migrate-$(date +%Y%m%d-%H%M%S)"
git stash push -u -m "$STASH_MSG"
```

4. 通过消息精确捕获本次 stash ref：

```bash
git stash list --format='%gd %gs'
```

只接受与 `STASH_MSG` 精确匹配的条目。

## Option B: `--from <worktree>`

适用场景：

- 另一个 worktree 中有 work-in-progress
- 用户想把那份改动迁到新的目标分支

worktree 解析规则：

1. 用 `git worktree list --porcelain` 枚举现有 worktree
2. `--from` 只接受以下两种精确标识：
   - worktree 的完整路径
   - worktree 目录 basename 的精确匹配
3. 找不到或命中多个候选时，立即停止并列出现有 worktree 列表

来源校验：

- 先对来源 worktree 执行 `git -C <source> status --porcelain`
- 无改动时标记 `Migrated: skipped (no source changes)`，继续创建 worktree
- 有改动时在来源 worktree 中执行带唯一消息的 `git stash push -u -m "$STASH_MSG"`

## Applying the Stash

创建新 worktree 后：

```bash
git -C "$NEW_PATH" stash apply "$STASH_REF"
```

状态规则：

- 应用成功：`Migrated: applied (<stash-ref>)`
- 无需迁移：`Migrated: skipped (...)`
- 应用冲突：`Migrated: failed (conflicts while applying <stash-ref>)`

## Safety Notes

- stash 默认保留，不自动 `drop`
- 发生冲突时，明确告知冲突发生在新 worktree，并保留原始 stash 供用户复查
- 用户确认改动已经安全迁移前，不要建议自动清理 stash
