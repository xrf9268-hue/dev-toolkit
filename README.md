# GERP Commit Plugin

GERP-UI 项目规范化提交插件，自动添加 JIRA 前缀，使用中文描述。

支持双平台：
- **Claude Code**：Skill + Subagent（项目级）+ Slash Command（用户级）
- **OpenAI Codex**：使用 Skill（遵循官方最佳实践）

## 安装

### Claude Code

提供两种安装方式，可根据需求选择：

#### 方式一：项目级安装（推荐用于 gerp-ui）

> 自动触发，项目隔离，不影响其他项目

```bash
cd /path/to/gerp-ui
cp -r .claude/ .
```

**触发方式**：
- 自动激活："帮我提交代码"、"commit 一下"
- 显式调用：请求使用 gerp-commit

**架构**：
```
用户请求 → Skill (context: fork) → Subagent (haiku) → 返回结果
```

#### 方式二：用户级安装（可选，跨项目手动调用）

> 手动触发 `/gerp-commit`，适用于任何项目

```bash
mkdir -p ~/.claude/commands
cp .claude/commands/gerp-commit.md ~/.claude/commands/
```

**触发方式**：
- `/gerp-commit` - 使用分支名中的 JIRA
- `/gerp-commit BGERP-12345` - 指定 JIRA 编号

**注意**：Slash Command 在主上下文运行，git 输出会保留在对话中。

#### 两种方式对比

| 特性 | 项目级 (Skill + Subagent) | 用户级 (Slash Command) |
|-----|--------------------------|----------------------|
| 安装位置 | `gerp-ui/.claude/` | `~/.claude/commands/` |
| 作用范围 | 仅 gerp-ui 项目 | 所有项目 |
| 触发方式 | 自动激活 | 手动 `/gerp-commit` |
| 上下文隔离 | ✅ `context: fork` | ❌ 主上下文 |
| 参数传递 | 对话中说明 | `/gerp-commit BGERP-xxx` |
| 适用场景 | 日常开发 | 手动控制 |

### OpenAI Codex CLI

```bash
# 项目级安装（推荐）
cd /path/to/gerp-ui
cp -r .codex/ .

# 用户级安装（可选）
mkdir -p ~/.codex/skills
cp -r .codex/skills/gerp-commit ~/.codex/skills/
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
│   ├── agents/
│   │   └── gerp-commit.md              # Subagent（业务逻辑，项目级）
│   ├── commands/
│   │   └── gerp-commit.md              # Slash Command（用户级安装用）
│   └── skills/
│       └── gerp-commit/
│           └── SKILL.md                # Skill（入口 + 隔离，项目级）
├── .codex/
│   └── skills/
│       └── gerp-commit/
│           └── SKILL.md                # Codex Skill
└── README.md
```

## 平台差异

| 特性 | Claude Code (项目级) | Claude Code (用户级) | Codex |
|-----|---------------------|---------------------|-------|
| 架构 | Skill + Subagent | Slash Command | Skill |
| 上下文隔离 | ✅ | ❌ | ❌ |
| 模型 | haiku | haiku | 全局配置 |
| 触发方式 | 自动 | `/gerp-commit` | `$gerp-commit` |
| 作用范围 | 仅项目 | 所有项目 | 取决于安装位置 |

## 相关文档

- Claude Code：[Attribution 设置](https://docs.anthropic.com/en/docs/claude-code/settings#attribution-settings)（禁用自动添加的后缀）
- Codex：[Skills 文档](https://developers.openai.com/codex/skills)

## 贡献

欢迎提交 PR 改进插件或添加新功能。
