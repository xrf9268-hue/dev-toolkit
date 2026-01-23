# Dev Toolkit

开发工具集，覆盖 [Claude Code](https://github.com/anthropics/claude-code) 与 [Codex CLI](https://github.com/openai/codex)。

## 工具列表

| 工具 | 功能 |
|------|------|
| **jira-commit** | 规范化 Git 提交工具，自动添加 JIRA 前缀 |
| **git-worktree** | Git worktree 自动化管理，支持配置同步和内容迁移 |
| **bb-code-review** | Bitbucket PR 代码审查，支持多 Agent 并行审查 |

## 支持平台

- **Claude Code**：插件形式，通过 marketplace 安装
- **Codex CLI**：Skill 形式，通过 `.codex/` 安装

## 平台差异

| 特性 | Claude Code | Codex CLI |
|-----|-------------|-----------|
| 形态 | Plugin + Skill | Skill |
| 上下文隔离 | `context: fork` | - |
| 触发方式 | 自动 / 手动 | `$<skill-name>` |
| 安装位置 | `plugins/<name>/` | `.codex/skills/<name>/` |

## 目录结构

```
dev-toolkit/
├── .claude-plugin/
│   └── marketplace.json     # Marketplace 清单
├── plugins/
│   ├── jira-commit/         # Claude Code 插件
│   ├── git-worktree/        # Claude Code 插件
│   └── bb-code-review/      # Claude Code 插件
└── .codex/                  # Codex CLI Skills
    └── skills/
        ├── jira-commit/
        ├── worktree/
        └── bb-code-review/
```

## Claude Code 安装

### 远程安装

添加 marketplace 并安装插件：

```bash
/plugin marketplace add xrf9268-hue/dev-toolkit
/plugin install jira-commit@dev-toolkit
/plugin install git-worktree@dev-toolkit
/plugin install bb-code-review@dev-toolkit
```

### 本地安装

从本地路径安装（适用于开发调试或离线环境）：

```bash
# 在 marketplace 根目录执行
/plugin marketplace add ./

# 或指定完整路径
/plugin marketplace add /path/to/dev-toolkit

# 安装插件
/plugin install jira-commit@dev-toolkit
/plugin install git-worktree@dev-toolkit
/plugin install bb-code-review@dev-toolkit
```

> 建议只在相关仓库使用自动触发，其他项目请显式调用。

### 本地验证

**重要**：验证命令必须在 Marketplace 根目录执行，即包含 `.claude-plugin/marketplace.json` 的目录。

```bash
# 切换到 Marketplace 根目录
cd /path/to/dev-toolkit

# 验证整个 Marketplace
claude plugin validate .

# 或验证单个插件
claude plugin validate ./plugins/jira-commit
claude plugin validate ./plugins/git-worktree
claude plugin validate ./plugins/bb-code-review
```

## 插件文档

- `plugins/jira-commit/README.md` - 规范化提交工具
- `plugins/git-worktree/README.md` - Worktree 管理工具
- `plugins/bb-code-review/README.md` - Bitbucket PR 代码审查工具

## Codex CLI

使用 `$skill-installer` 安装：

```
$skill-installer install https://github.com/xrf9268-hue/dev-toolkit/tree/main/.codex/skills/jira-commit
$skill-installer install https://github.com/xrf9268-hue/dev-toolkit/tree/main/.codex/skills/worktree
$skill-installer install https://github.com/xrf9268-hue/dev-toolkit/tree/main/.codex/skills/bb-code-review
```

安装后重启 Codex 生效。

**使用方式**：
- jira-commit：`$jira-commit`
- worktree：`$worktree feature-auth`
- bb-code-review：`$bb-code-review`
