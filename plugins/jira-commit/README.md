# jira-commit

统一的 JIRA 规范化 Git 提交工具，支持 GERP 和 BESTSMART 项目。

## 功能

- 自动从分支名提取 JIRA 编号（支持 `BGERP-XXXXX` 和 `BESTSMART-XXXXX`）
- 支持手动指定 JIRA 编号
- 统一使用中文方括号格式 `【JIRA-ID】`
- 中文描述，符合团队规范

## 使用方法

```bash
# 自动提取分支中的 JIRA 编号
/jira-commit

# 手动指定 JIRA 编号
/jira-commit BGERP-12345
/jira-commit BESTSMART-11967
```

## 提交格式

统一格式：`【JIRA-ID】中文描述`

```
【BGERP-32921】修复分页下拉菜单被水平滚动条遮挡问题

根因：表格容器设置了 z-index 创建了局部层叠上下文
修复：删除父级容器的 z-index 属性
```

```
【BESTSMART-11967】新增百世快运和韵达快运支持

为满足新的物流对接需求，增加了两个新的物流渠道适配器。
```

## 支持的项目

| 项目 | JIRA 前缀 | 提交示例 |
|------|-----------|----------|
| GERP | `BGERP-XXXXX` | `【BGERP-32921】修复分页问题` |
| BESTSMART | `BESTSMART-XXXXX` | `【BESTSMART-11967】修复分页问题` |

## 规范说明

- 使用中文方括号 `【】` 包裹 JIRA 编号
- 不使用 Angular commit type (feat, fix 等)
- 使用中文描述变更内容
