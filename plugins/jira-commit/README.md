# jira-commit

统一的 JIRA 规范化 Git 提交工具，支持多项目 JIRA 前缀配置。

## 功能

- 自动从分支名提取 JIRA 编号
- 支持手动指定 JIRA 编号
- 统一使用中文方括号格式 `【JIRA-ID】`
- 中文描述，符合团队规范

## 环境配置

通过环境变量配置支持的 JIRA 前缀：

```bash
# 配置 JIRA 项目前缀（多个用逗号分隔）
export JIRA_PREFIXES="PROJ1,PROJ2"
```

建议添加到 `~/.bashrc` 或 `~/.zshrc`：

```bash
echo 'export JIRA_PREFIXES="PROJ1,PROJ2"' >> ~/.zshrc
source ~/.zshrc
```

## 使用方法

```bash
# 自动提取分支中的 JIRA 编号
/jira-commit

# 手动指定 JIRA 编号
/jira-commit PROJ-12345
```

## 提交格式

统一格式：`【JIRA-ID】中文描述`

```
【PROJ-32921】修复分页下拉菜单被水平滚动条遮挡问题

根因：表格容器设置了 z-index 创建了局部层叠上下文
修复：删除父级容器的 z-index 属性
```

## 规范说明

- 使用中文方括号 `【】` 包裹 JIRA 编号
- 不使用 Angular commit type (feat, fix 等)
- 使用中文描述变更内容
