# GERP Dev Toolkit

GERP-UI 团队开发工具集，覆盖 [Claude Code](https://github.com/anthropics/claude-code) 与 [Codex CLI](https://github.com/openai/codex)。

## 工具列表

| 工具 | 功能 | 版本 |
|------|------|------|
| **gerp-commit** | 规范化 Git 提交工具，自动添加 JIRA 前缀 | 2.0.0 |
| **gerp-worktree** | Git worktree 自动化管理，支持配置同步和内容迁移 | 1.0.0 |

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
gerp-dev-toolkit/
├── .claude-plugin/
│   └── marketplace.json     # Marketplace 清单
├── plugins/
│   ├── gerp-commit/         # Claude Code 插件
│   └── gerp-worktree/       # Claude Code 插件
└── .codex/                  # Codex CLI Skills
    └── skills/
        ├── gerp-commit/
        └── worktree/
```

## Claude Code 安装

添加 marketplace 并安装插件：

```bash
/plugin marketplace add xrf9268-hue/gerp-dev-toolkit
/plugin install gerp-commit@gerp-dev-toolkit
/plugin install gerp-worktree@gerp-dev-toolkit
```

用户级安装（可选，仅在需要跨项目显式调用时使用）：

```bash
/plugin install gerp-commit@gerp-dev-toolkit --scope user
/plugin install gerp-worktree@gerp-dev-toolkit --scope user
```

> 建议只在 GERP 相关仓库使用自动触发，其他项目请显式调用。

### 本地验证

**重要**：验证命令必须在 Marketplace 根目录执行，即包含 `.claude-plugin/marketplace.json` 的目录。

```bash
# 切换到 Marketplace 根目录
cd /path/to/gerp-dev-toolkit

# 验证整个 Marketplace
claude plugin validate .

# 或验证单个插件
claude plugin validate ./plugins/gerp-commit
claude plugin validate ./plugins/gerp-worktree
```

## 插件文档

- `plugins/gerp-commit/README.md` - 规范化提交工具
- `plugins/gerp-worktree/README.md` - Worktree 管理工具

## Codex CLI

使用 `$skill-installer` 安装：

```
$skill-installer install https://github.com/xrf9268-hue/gerp-dev-toolkit/tree/main/.codex/skills/gerp-commit
$skill-installer install https://github.com/xrf9268-hue/gerp-dev-toolkit/tree/main/.codex/skills/worktree
```

安装后重启 Codex 生效。

**使用方式**：
- gerp-commit：`$gerp-commit`
- worktree：`$worktree feature-auth`
