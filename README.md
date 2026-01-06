# GERP Commit Plugin

GERP-UI 项目规范化提交命令插件，自动添加 JIRA 前缀，使用中文描述。

## 安装

### 方式一：作为插件安装（推荐）

```bash
cd ~/.claude/plugins
git clone <repo-url> gerp-commit
```

或在 Claude Code 中执行：
```
/plugin install <repo-url>
```

### 方式二：仅安装命令

```bash
cp commands/*.md ~/.claude/commands/
```

## 可用命令

### `/gerp-commit`

创建规范化的 git 提交。

**使用方式：**

```bash
# 自动从分支名提取 JIRA 前缀
/gerp-commit

# 手动指定 JIRA 编号
/gerp-commit BGERP-12345
```

**功能特性：**

- 自动从分支名提取 `BGERP-XXXXX` 前缀
- 支持参数覆盖自动提取的 JIRA
- 无 JIRA 时允许无前缀提交
- 使用中文方括号 `【BGERP-XXXXX】`
- 中文描述提交内容
- 禁止添加 Claude Code 生成后缀

**提交格式示例：**

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
├── .claude-plugin/
│   └── plugin.json      # 插件元数据
├── commands/
│   └── gerp-commit.md   # 提交命令
└── README.md
```

## 贡献

欢迎提交 PR 改进命令或添加新命令。
