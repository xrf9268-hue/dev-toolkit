# git-worktree

Git worktree 自动化管理工具，支持配置同步、内容迁移和后台依赖安装。

## 功能特性

- **统一目录结构**：所有 worktree 存储在 `../.worktrees/<project>/` 目录下
- **配置自动同步**：复制 `.env`、`.vscode/`、`.claude/` 等关键配置文件
- **内容迁移**：通过 `--stash` 或 `--from` 在 worktree 之间传输未提交的更改
- **后台依赖安装**：自动检测包管理器（pnpm/yarn/npm/bun）并后台安装依赖
- **剪贴板集成**：复制快速启动命令供立即使用

## 使用方式

```bash
# 基本使用
/worktree feature-auth

# 携带当前未提交更改
/worktree feature-auth --stash

# 从其他 worktree 迁移更改
/worktree feature-auth --from main
```

## 目录结构

```
parent/
├── project/                    # 主仓库
└── .worktrees/
    └── project/                # 按项目分组
        ├── feature-auth/       # Worktree 1
        ├── hotfix-123/         # Worktree 2
        └── ...
```

## 同步的配置文件

| 文件/目录 | 说明 |
|-----------|------|
| `.claude/` | Claude Code 配置 |
| `.codex/` | Codex CLI 配置 |
| `.env` | 环境变量 |
| `.env.local` | 本地环境变量 |
| `.vscode/` | VSCode 配置 |
| `.cursorrules` | Cursor 规则 |
| `.windsurfrules` | Windsurf 规则 |
| `AGENTS.md` | Agent 配置 |

## 输出示例

```
Worktree created successfully!

  Path:     ../.worktrees/my-project/feature-auth/
  Branch:   feature-auth
  Configs:  .claude/, .env, .vscode/, ...
  Migrated: Changes applied from current
  Dependencies: Installing in background (pnpm)

Quick start (copied to clipboard):
  cd ../.worktrees/my-project/feature-auth && claude
```

## 安装

```bash
/install git-worktree@xrf9268-hue/dev-toolkit
```

## 详细文档

- 完整工作流程：[references/WORKFLOW.md](skills/worktree/references/WORKFLOW.md)
- 内容迁移指南：[references/MIGRATION.md](skills/worktree/references/MIGRATION.md)
- 使用示例：[references/EXAMPLES.md](skills/worktree/references/EXAMPLES.md)
