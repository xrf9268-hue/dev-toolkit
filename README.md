# GERP Dev Toolkit

GERP-UI 团队开发工具集，覆盖 [Claude Code](https://github.com/anthropics/claude-code) 与 [Codex CLI](https://github.com/openai/codex)。

## 工具列表

- **gerp-commit**: 规范化 Git 提交工具，自动添加 JIRA 前缀

## 支持平台

- **Claude Code**：插件形式，通过 marketplace 安装
- **Codex CLI**：Skill 形式，通过 `.codex/` 安装

## 平台差异

| 特性 | Claude Code | Codex CLI |
|-----|-------------|-----------|
| 形态 | Plugin + Skill | Skill |
| 上下文隔离 | ✅ `context: fork` | ❌ |
| 触发方式 | 自动 / 手动 | `$gerp-commit` |
| 安装位置 | `plugins/gerp-commit/` | `.codex/` |

## 目录结构

```
gerp-dev-toolkit/
├── .claude-plugin/
│   └── marketplace.json     # Marketplace 清单
├── plugins/
│   └── gerp-commit/          # Claude Code 插件
└── .codex/                   # Codex CLI Skill
```

## Claude Code 安装

添加 marketplace 并安装插件：

```bash
/plugin marketplace add xrf9268-hue/gerp-dev-toolkit
/plugin install gerp-commit@gerp-dev-toolkit
```

用户级安装（可选，仅在需要跨项目显式调用时使用）：

```bash
/plugin install gerp-commit@gerp-dev-toolkit --scope user
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
```

## 插件文档

- `plugins/gerp-commit/README.md`

## Codex CLI

Codex Skill 位于 `.codex/`，安装方式：

```bash
# 项目级安装（推荐）
cd /path/to/gerp-ui
cp -r /path/to/gerp-dev-toolkit/.codex/ .

# 用户级安装（可选，会影响所有项目）
# mkdir -p ~/.codex/skills
# cp -r /path/to/gerp-dev-toolkit/.codex/skills/gerp-commit ~/.codex/skills/
```

**使用方式**：
- 显式调用：`$gerp-commit`
- 隐式触发：描述任务时自动匹配
