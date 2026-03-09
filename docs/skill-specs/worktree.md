# worktree Canonical Spec

## Canonical Description

`Use when the user wants a git worktree for a parallel branch workspace, an isolated development environment, or to move uncommitted changes into a new worktree.`

## Command Mapping

| Surface | Command |
|---------|---------|
| Claude Code | `/worktree [branch-name] [--stash] [--from <worktree>] [--base <branch>]` |
| Codex CLI | `$worktree [branch-name] [--stash] [--from <worktree>] [--base <branch>]` |

## Trigger Cues

- 用户要求创建 git worktree
- 用户需要并行开发环境或隔离分支工作区
- 用户希望把未提交改动迁移到新 worktree

## Should Not Trigger

- 仅解释 git worktree 原理
- 只切换当前分支
- 删除或清理已有 worktree

## Parameters

| 参数 | 说明 |
|------|------|
| `[branch-name]` | 目标分支名 |
| `--stash` | 迁移当前未提交改动 |
| `--from <worktree>` | 从指定 worktree 迁移未提交改动 |
| `--base <branch>` | 为新分支指定基线分支 |

## Behavior Contract

1. 目标路径固定为 `../.worktrees/<project>/<branch>/`。
2. 创建前必须识别主仓库根目录、公共 git dir、项目名和目标分支。
3. 支持 `--stash` 与 `--from` 两种迁移模式。
4. 必须同步共享配置：`.claude/`、`.codex/`、`.env`、`.env.local`、`.vscode/`、`AGENTS.md` 等存在的文件。
5. 必须检测包管理器并后台安装依赖。
6. 不自动打开编辑器，只返回摘要和快速启动命令。

## Derived Files

- `plugins/git-worktree/skills/worktree/SKILL.md`
- `.codex/skills/worktree/SKILL.md`
- `plugins/git-worktree/README.md`
- `README.md`
