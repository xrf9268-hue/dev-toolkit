# GERP Commit Plugin

GERP-UI 项目规范化提交插件，自动添加 JIRA 前缀，使用中文描述。

支持双平台：
- **Claude Code**：使用 Subagent（独立上下文，避免污染主对话）
- **OpenAI Codex**：使用 Skill（遵循官方最佳实践）

## 安装

### Claude Code

将 `.claude/agents/` 目录复制到你的项目或用户目录：

```bash
# 项目级安装（仅当前项目可用）
cp -r .claude/agents/ /path/to/your/project/.claude/agents/

# 用户级安装（所有项目可用）
mkdir -p ~/.claude/agents
cp .claude/agents/gerp-commit.md ~/.claude/agents/
```

**使用方式**：
- **自动触发**：描述任务时自动委派（如 "帮我提交代码"、"commit 一下"）
- **显式调用**：请求使用 gerp-commit agent

**优势**：
- 上下文隔离：git diff/status 等操作不会污染主对话
- 仅返回结果：主对话只收到 commit hash 和简述

### OpenAI Codex CLI

```bash
# 用户级安装（所有项目可用）
mkdir -p ~/.codex/skills
cp -r .codex/skills/gerp-commit ~/.codex/skills/

# 项目级安装
cp -r .codex/ /path/to/your/project/
```

**使用方式**：
- 显式调用：`$gerp-commit`
- 隐式触发：描述任务时自动匹配

## 功能特性

- 自动从分支名提取 `BGERP-XXXXX` 前缀
- 支持参数覆盖自动提取的 JIRA
- 无 JIRA 时允许无前缀提交
- 使用中文方括号 `【BGERP-XXXXX】`
- 中文描述提交内容

## 提交格式

```
【BGERP-32921】修复分页下拉菜单被水平滚动条遮挡问题

根因：表格容器设置了 z-index 创建了局部层叠上下文
修复：删除父级容器的 z-index 属性
```

## 分支命名规则

| 分支示例 | JIRA 提取 |
|---------|----------|
| `yvan/BGERP-32921-售后看板和统计页面` | `BGERP-32921` |
| `feature/BGERP-12345-xxx` | `BGERP-12345` |
| `main` / `master` | 无前缀 |

## 目录结构

```
gerp-commit/
├── .claude/
│   └── agents/
│       └── gerp-commit.md          # Claude Code Subagent
├── .codex/
│   └── skills/
│       └── gerp-commit/
│           └── SKILL.md            # Codex Skill
├── .claude-plugin/
│   └── plugin.json                 # Claude Code 插件元数据
└── README.md
```

## 平台差异

| 特性 | Claude Code (Subagent) | Codex (Skill) |
|-----|------------------------|---------------|
| 上下文隔离 | ✅ 独立上下文 | ❌ 共享主上下文 |
| 触发方式 | 自动委派 / 显式 | `$gerp-commit` / 隐式 |
| 返回结果 | 仅 commit hash | 完整执行过程 |

## 相关文档

- Claude Code：[Attribution 设置](https://docs.anthropic.com/en/docs/claude-code/settings#attribution-settings)（禁用自动添加的后缀）
- Codex：[Skills 文档](https://developers.openai.com/codex/skills)

## 贡献

欢迎提交 PR 改进插件或添加新功能。
