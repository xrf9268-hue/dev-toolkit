# Worktree Workflow Reference

本文件补充主 skill 的详细决策规则：分支解析、路径约定、本地配置同步和输出摘要。

## Primary Use Cases

1. 为现有分支或新分支创建隔离 worktree
2. 用 `--stash` 把当前工作区未提交改动迁到新 worktree
3. 用 `--from <worktree>` 把其他 worktree 的未提交改动迁到新 worktree

## 1. Input Resolution

- `branch-name` 是第一个位置参数
- `--stash` 与 `--from <worktree>` 互斥；同时出现时立即报错并停止
- `--base <branch>` 只在目标分支尚不存在时生效
- 未提供 `branch-name` 时，先执行：

```bash
git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | head -n 10
```

然后让用户在“已有分支”与“新分支名”之间做选择。

## 2. Repository Context

先读取仓库上下文：

```bash
git rev-parse --show-toplevel
git rev-parse --git-common-dir
git remote
```

- `--show-toplevel` 给出当前 worktree 对应的仓库根目录
- `--git-common-dir` 用于定位 shared git dir，并反推主仓库位置
- `git remote` 用于判断是否能从远端 HEAD 推断默认基线

## 3. Target Path

路径固定为：

```text
../.worktrees/<project>/<safe-branch>/
```

决策规则：

- `<project>` 取仓库根目录 basename
- `<safe-branch>` 为目标分支名，将 `/` 替换为 `-`
- 如果目标路径已存在，先检查它是否已经注册为 worktree；已注册则报告现有路径，未注册则停止并提示用户处理目录冲突

## 4. Branch and Base Resolution

### Existing Branch

- 本地目标分支已存在且未被任何 worktree 占用：直接 `git worktree add <path> <branch>`
- 本地目标分支已存在但已在当前或其他 worktree 中 checkout：
  - 立即停止，不要重试同名分支
  - 明确说明 Git 不允许同一分支同时附着到多个 worktree
  - 让用户二选一：
    - 提供新的 `branch-name`
    - 如果目的是从该分支当前状态继续派生工作，用新分支名并将该已有分支作为 `--base`
- 仅远端分支存在：先按下面的 remote 选择规则解析远端，再在新 worktree 中创建本地跟踪分支

### New Branch

仅当目标分支不存在时才创建新分支。基线优先级如下：

1. 显式 `--base <branch>`
2. 本地默认分支：优先 `main`，其次 `master`
3. 远端 HEAD：
   - 按下面的 remote 选择规则解析默认 remote
   - 再读取该 remote 的 HEAD branch

如果以上都无法解析，立即报告：

```text
⚠️ 无法确定新分支的基线分支。

请显式提供 --base <branch>，或先创建/同步默认分支。
```

不要假设 `origin/main` 一定存在。

### Remote Selection Policy

当需要从远端解析“默认基线”或“仅远端存在的目标分支”时，统一使用以下规则：

1. 如果 `origin` 存在，且目标分支或默认 HEAD 可从 `origin` 唯一解析，优先使用 `origin`
2. 如果没有 `origin`，且仓库只有一个 remote，使用该 remote
3. 如果目标分支只在一个 remote 上存在，使用该 remote
4. 如果多个 remote 都匹配，立即停止并让用户显式指定 remote 或 `--base`

不要在多 remote 场景下自行猜测远端。

## 5. Worktree Creation

创建顺序：

1. 先完成分支与迁移准备
2. 再执行 `git worktree add`
3. 创建成功后才进入迁移应用、本地配置同步和依赖安装

需要显式报告的失败场景：

- 分支已被其他 worktree 占用
- 目标路径冲突
- 目标基线不存在
- 远端跟踪分支不可解析
- 多 remote 下目标远端不唯一

## 6. Local Configuration Sync

同步目标是“本地环境文件”，不是仓库内容复制。

允许同步的项目：

- `.env`
- `.env.local`
- `docs/.local`
- 仓库文档明确标记为 local-only、且不应视为 tracked source 的其他目录

处理规则：

- 仅在源文件存在时复制
- 目标文件已存在时默认跳过，并在摘要中说明
- 不要把 `AGENTS.md`、`.agents/`、源码目录、锁文件或其他 tracked 内容写成必须复制项

## 7. Dependency Installation

安装是保留的自动化步骤，但必须带条件和状态输出。

检测顺序：

1. `pnpm-lock.yaml` -> `pnpm install`
2. `yarn.lock` -> `yarn install`
3. `bun.lockb` 或 `bun.lock` -> `bun install`
4. `package-lock.json` -> `npm install`

状态规则：

- 命中锁文件且命令可用：后台启动安装，摘要写 `installing in background (<tool>)`
- 命中锁文件但命令不可用：摘要写 `skipped (missing <tool>)`
- 无锁文件：摘要写 `skipped`

## 8. Summary Output

摘要至少包含：

- `Path`
- `Branch`
- `Migrated`
- `Local config`
- `Dependencies`

状态文案要区分：

- `applied`
- `skipped`
- `failed`

不要自动打开编辑器、agent 或终端；只给出 `cd <path>` 作为 next step。
