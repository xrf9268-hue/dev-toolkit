---
name: worktree
description: Use when the user wants a git worktree for a parallel branch workspace, an isolated development environment, or to move uncommitted changes into a new worktree.
---

# Git Worktree

创建带配置同步、内容迁移和后台依赖安装的 Git worktree。

## 何时使用

- 用户要求创建 git worktree
- 用户需要并行开发环境或隔离分支工作区
- 用户希望把未提交改动迁移到新的 worktree
- 不用于删除 worktree 或仅解释 git worktree 概念

## 参数

| Argument | Description |
|----------|-------------|
| `branch-name` | Target branch (positional) |
| `--stash` | Migrate current uncommitted changes to new worktree |
| `--from <worktree>` | Migrate changes from specified worktree |
| `--base <branch>` | Base branch to create new branch from (default: `main` / `master`) |

## 目录结构

```text
parent/
├── project/                    # Main repo
└── .worktrees/
    └── project/                # Grouped by project
        ├── feature-auth/       # Worktree 1
        └── hotfix-123/         # Worktree 2
```

新 worktree 的目标路径固定为 `../.worktrees/<project>/<branch>/`。

## 工作流程

1. 解析输入参数，提取 `branch-name`、`--stash`、`--from`、`--base`。
2. 通过 `git rev-parse --show-toplevel` 和 `git rev-parse --git-common-dir` 定位主仓库和项目名。
3. 决定目标分支：优先使用显式参数，否则提示用户选择或输入新分支。
4. 如果指定 `--stash` 或 `--from`，先执行内容迁移准备。
5. 在 `../.worktrees/<project>/<branch>/` 创建 worktree。
6. 同步共享配置：`.agents/`、`AGENTS.md`、`.env`、`.env.local`、`.vscode/` 等存在的文件；若仓库中存在其他 agent 配置目录，可按需一并同步。
7. 检测包管理器（`pnpm` / `yarn` / `npm` / `bun`），后台安装依赖。
8. 展示进入新 worktree 的路径和后续建议动作，但**不要自动打开编辑器或 agent**。

## 详细文档

- Complete workflow steps: [references/WORKFLOW.md](references/WORKFLOW.md)
- Content migration guide: [references/MIGRATION.md](references/MIGRATION.md)
- Usage examples: [references/EXAMPLES.md](references/EXAMPLES.md)

## 输出

```text
Worktree created successfully!

  Path:     ../.worktrees/<project>/<branch>/
  Branch:   <branch-name>
  Configs:  .agents/, AGENTS.md, .env, .vscode/, ...
  Migrated: [if applicable]
  Dependencies: Installing in background (<pkg-mgr>)

Next steps:
  cd <path>
  启动你需要的 agent、编辑器或终端流程
```
