# GERP Commit Plugin

GERP-UI 项目**专用**规范化提交插件，自动添加 JIRA 前缀，使用中文描述。

> **重要**：此插件专为 GERP-UI 项目设计，非 GERP 仓库请显式调用，避免误触发。

支持平台：
- **Claude Code**：仅保留 Skill（已合并 Slash Command）

## 安装

### Claude Code

#### 方式一：项目级插件安装（推荐）

将 marketplace 仓库克隆到 gerp-ui 项目的 `.claude-plugins/` 目录：

```bash
cd /path/to/gerp-ui
mkdir -p .claude-plugins
git clone <repo-url> .claude-plugins/gerp-dev-toolkit
```

启动 Claude Code 时指定插件目录：

```bash
claude --plugin-dir .claude-plugins/gerp-dev-toolkit/plugins/gerp-commit
```

或在 `.claude/settings.json` 中配置：

```json
{
  "plugins": [".claude-plugins/gerp-dev-toolkit/plugins/gerp-commit"]
}
```

> 插件仓库本身不需要 `.claude/` 目录；`.claude` 仅用于使用者项目的配置。

#### 方式二：通过 Marketplace 安装（团队分发）

仓库已内置 marketplace 文件：`.claude-plugin/marketplace.json`。

添加 marketplace 并安装插件：

```bash
/plugin marketplace add xrf9268-hue/claude-code-command
/plugin install gerp-commit@gerp-dev-toolkit
```

本地验证（推荐发布前执行，需在 marketplace 根目录执行）：

```bash
claude plugin validate .
```

### Claude Code 使用

- 直接描述提交需求即可自动触发，如“帮我提交代码”
- 可指定 JIRA，如“用 BGERP-12345 提交”

## 插件架构

```
用户请求 ("帮我提交代码")
    ↓ 自动激活
Skill (context: fork) 创建隔离上下文
    ↓
执行 git 操作并创建提交
    ↓
返回结果 (commit hash)
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
gerp-dev-toolkit/
├── .claude-plugin/
│   └── marketplace.json                 # Marketplace 清单
└── plugins/
    └── gerp-commit/
        ├── .claude-plugin/
        │   └── plugin.json              # 插件元数据
        ├── skills/
        │   └── gerp-commit/
        │       └── SKILL.md             # Claude Code Skill
        └── README.md
```

## 相关文档

- Claude Code：[Plugins 文档](https://docs.anthropic.com/en/docs/claude-code/plugins)
- Claude Code：[Attribution 设置](https://docs.anthropic.com/en/docs/claude-code/settings#attribution-settings)

## 贡献

欢迎提交 PR 改进插件或添加新功能。
