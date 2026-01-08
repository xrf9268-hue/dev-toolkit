---
name: gerp-commit
description: 创建规范化的 git 提交，自动从分支名提取 BGERP-XXXXX JIRA 前缀。当用户要求提交代码、创建 commit、gerp-commit 时触发。
context: fork
agent: gerp-commit
---

## 触发场景

- "帮我提交代码"
- "commit 一下"
- "创建一个提交"
- "用 BGERP-12345 提交"

## 说明

此 Skill 会在隔离的上下文中调用 `gerp-commit` Subagent，确保 git diff/status 等输出不会污染主对话。
