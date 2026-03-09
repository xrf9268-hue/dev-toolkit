---
name: worktree
description: Use when the user wants a git worktree for parallel branch work, asks for an isolated development workspace, wants to move current or other worktree uncommitted changes into a new branch workspace, or wants to keep the current checkout untouched while starting related work.
---

# Git Worktree

创建并初始化用于并行开发的 Git worktree；必要时迁移未提交改动。

## Overview

核心原则：先确定目标分支与迁移来源，再创建 worktree，最后执行条件化初始化。

## When to Use

- 用户明确要求创建 git worktree
- 用户说“开个并行开发环境”“新开隔离目录做功能”“不要切当前分支但继续开发”
- 用户要把当前目录或其他 worktree 的未提交改动迁到新 worktree
- 不用于删除 worktree、列出现有 worktree、切换分支，或仅解释 git worktree 概念

## Important

- 默认目标路径是 `../.worktrees/<project>/<safe-branch>/`，其中分支名里的 `/` 要转换成 `-`
- `branch-name` 缺失时，先列最近分支，再让用户选择已有分支或输入新分支
- `--stash` 与 `--from <worktree>` 互斥；同一次请求只能选择一种迁移来源
- 自动化保留，但只同步可观测的本地环境文件和仓库文档明确标记为 local-only 的目录，不要把 tracked 仓库内容当成必须复制项
- 不自动打开编辑器、agent 或终端；只返回路径、状态摘要和 next steps

## Inputs

| Argument | Meaning |
|----------|---------|
| `branch-name` | 目标分支名；可省略，省略时先询问 |
| `--stash` | 把当前工作区未提交改动迁到新 worktree |
| `--from <worktree>` | 把其他 worktree 的未提交改动迁到新 worktree |
| `--base <branch>` | 新分支的基线分支；仅在目标分支尚不存在时使用 |

## Workflow

1. 解析 `branch-name`、`--stash`、`--from`、`--base`。
2. 用 `git rev-parse --show-toplevel` 和 `git rev-parse --git-common-dir` 确认主仓库、项目名和当前 worktree 上下文。
3. 决定目标分支：
   - 显式提供 `branch-name` 时直接使用
   - 未提供时列出最近本地分支并询问
4. 如需迁移改动，先按 [references/MIGRATION.md](references/MIGRATION.md) 准备来源、校验状态并记录本次 stash ref。
5. 创建 worktree：
   - 目标分支已存在且未被任何 worktree 占用时直接添加
   - 目标分支已存在但已在当前或其他 worktree 中 checkout 时，不要重试同名分支；让用户改用新分支名，或基于该分支创建派生分支
   - 目标分支不存在时，按 `--base` > 本地默认分支 > 远端 HEAD 解析基线；无法解析时报告并停止
6. 只有在拿到本次 stash ref 时才迁移改动；应用失败时保留 stash 并明确报告冲突。
7. 条件化同步本地配置：仅复制存在的 `.env`、`.env.local`、`docs/.local`，以及仓库文档明确标记为 local-only 的其他目录。
8. 检测 `pnpm` / `yarn` / `bun` / `npm` 锁文件；命中时后台安装依赖，否则在摘要里标记 skipped。
9. 输出路径、分支、迁移状态、配置同步状态、依赖安装状态和 next steps。

详细规则见 [references/WORKFLOW.md](references/WORKFLOW.md)。

## Common Issues

### `--from` 指向的 worktree 不存在

列出现有 worktree，让用户改用精确路径或目录名；不要模糊匹配。

### 新分支没有可用基线

如果没有 `--base`，且无法从本地默认分支或远端 HEAD 推断基线，立即报告并停止，不要假设 `origin/main`。

### 目标分支已被其他 worktree 占用

Git 不允许同一分支同时附着到多个 worktree。此时不要直接重试同名分支；让用户提供新的 `branch-name`，或者用新分支名并以该分支作为 `--base` 创建派生分支。

### stash 应用冲突

报告冲突发生在新 worktree，保留原始 stash，让用户在新 worktree 手动解决后再决定是否清理 stash。

### 没有可识别的依赖管理器

创建 worktree 仍然算成功，但要在摘要中明确写出 `Dependencies: skipped`。

## Examples

- `给我建个 worktree 用来做 feature-auth`
- `别切当前分支，帮我开个新目录继续做支付重构`
- `把 hotfix-123 那个 worktree 里的未提交改动迁到新的 release-hotfix worktree`

更多参数组合和输出样例见 [references/EXAMPLES.md](references/EXAMPLES.md)。

## Output

```text
Worktree created successfully!

  Path:         ../.worktrees/<project>/<safe-branch>/
  Branch:       <branch-name>
  Migrated:     applied | skipped | failed
  Local config: copied .env, docs/.local | skipped
  Dependencies: installing in background (pnpm) | skipped

Next steps:
  cd <path>
  继续你的编辑器、agent 或终端流程
```
