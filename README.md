# GERP Commit Plugin

GERP-UI 项目**专用**规范化提交插件，自动添加 JIRA 前缀，使用中文描述。

> **重要**：此插件专为 GERP-UI 项目设计，请勿安装到用户级目录，避免影响其他项目。

支持双平台：
- **Claude Code**：官方插件结构，支持 `--plugin-dir` 加载
- **OpenAI Codex**：使用 Skill（遵循官方最佳实践）

## 安装

### Claude Code

#### 方式一：项目级插件安装（推荐）

将插件克隆到 gerp-ui 项目的 `.claude-plugins/` 目录：

```bash
cd /path/to/gerp-ui
mkdir -p .claude-plugins
git clone <repo-url> .claude-plugins/gerp-commit
```

启动 Claude Code 时指定插件目录：

```bash
claude --plugin-dir .claude-plugins/gerp-commit
```

或在 `.claude/settings.json` 中配置：

```json
{
  "plugins": [".claude-plugins/gerp-commit"]
}
```

#### 方式二：用户级 Slash Command（可选，跨项目手动调用）

> 仅安装 Slash Command，手动触发 `/gerp-commit`

```bash
mkdir -p ~/.claude/commands
cp commands/gerp-commit.md ~/.claude/commands/
```

**触发方式**：
- `/gerp-commit` - 使用分支名中的 JIRA
- `/gerp-commit BGERP-12345` - 指定 JIRA 编号

**注意**：Slash Command 在主上下文运行，git 输出会保留在对话中。

#### 两种方式对比

| 特性 | 项目级插件 | 用户级 Slash Command |
|-----|-----------|---------------------|
| 安装位置 | `gerp-ui/.claude-plugins/` | `~/.claude/commands/` |
| 加载方式 | `--plugin-dir` | 自动加载 |
| 作用范围 | 仅 gerp-ui 项目 | 所有项目 |
| 包含组件 | Skill + Subagent + Command | 仅 Command |
| 上下文隔离 | ✅ `context: fork` | ❌ 主上下文 |
| 触发方式 | 自动激活 / `/gerp-commit` | `/gerp-commit` |

### OpenAI Codex CLI

```bash
# 项目级安装（推荐）
cd /path/to/gerp-ui
cp -r .codex/ .

# 用户级安装（可选，会影响所有项目）
# mkdir -p ~/.codex/skills
# cp -r .codex/skills/gerp-commit ~/.codex/skills/
```

**使用方式**：
- 显式调用：`$gerp-commit`
- 隐式触发：描述任务时自动匹配

## 插件架构

```
用户请求 ("帮我提交代码")
    ↓ 自动激活
Skill (context: fork) 创建隔离上下文
    ↓ 委派给
Subagent (model: haiku) 执行 git 操作
    ↓
返回结果 (仅 commit hash)
```

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

## 目录结构（官方插件规范）

```
gerp-commit/
├── .claude-plugin/
│   └── plugin.json                     # 插件元数据
├── agents/
│   └── gerp-commit.md                  # Subagent（业务逻辑）
├── commands/
│   └── gerp-commit.md                  # Slash Command
├── skills/
│   └── gerp-commit/
│       └── SKILL.md                    # Skill（入口 + 隔离）
├── .codex/
│   └── skills/
│       └── gerp-commit/
│           └── SKILL.md                # Codex Skill
└── README.md
```

## 平台差异

| 特性 | Claude Code (插件) | Claude Code (Command) | Codex |
|-----|--------------------|-----------------------|-------|
| 架构 | Skill + Subagent | Slash Command | Skill |
| 上下文隔离 | ✅ | ❌ | ❌ |
| 模型 | haiku | haiku | 全局配置 |
| 触发方式 | 自动 / 手动 | `/gerp-commit` | `$gerp-commit` |
| 作用范围 | 仅加载插件的项目 | 取决于安装位置 | 取决于安装位置 |

## 相关文档

- Claude Code：[Plugins 文档](https://docs.anthropic.com/en/docs/claude-code/plugins)
- Claude Code：[Attribution 设置](https://docs.anthropic.com/en/docs/claude-code/settings#attribution-settings)
- Codex：[Skills 文档](https://developers.openai.com/codex/skills)

## 贡献

欢迎提交 PR 改进插件或添加新功能。
