---
name: gerp-commit
description: 创建规范化的 git 提交，自动从分支名提取 BGERP-XXXXX JIRA 前缀，使用中文方括号格式和中文描述。当用户要求创建 commit、提交代码时触发。
---

## 执行步骤

1. `git branch --show-current` 获取分支，提取 JIRA（匹配 `BGERP-[0-9]+`）
2. `git status --short` 检查变更（无变更则停止）
3. `git diff` 分析变更内容
4. 选择性 `git add` 暂存相关文件
5. 生成 commit message，展示给用户确认
6. `git commit` 创建提交

## JIRA 前缀

- 用户指定 > 分支提取 > 无前缀
- 格式：中文方括号 `【BGERP-XXXXX】`

## 提交规范

- 首行：中文，50 字符内
- 正文（可选）：详细说明
- 禁止：emoji、英文 type 前缀

## 示例

```
【BGERP-32921】修复分页下拉菜单被水平滚动条遮挡问题
```
