---
description: 创建规范化的 git 提交（自动添加 JIRA 前缀，中文描述）
model: claude-haiku-4-5-20251001
argument-hint: [JIRA编号（可选，如 BGERP-12345）]
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*)
---

## Git 上下文

- 当前分支: !`git branch --show-current`
- 分支中的 JIRA: !`git branch --show-current | grep -oE 'BGERP-[0-9]+' || echo ''`
- 用户指定 JIRA: $ARGUMENTS
- 工作区状态: !`git status --short`
- 暂存区变更: !`git diff --staged --stat`
- 未暂存变更: !`git diff --stat`
- 最近提交: !`git log --oneline -5`

## JIRA 前缀确定规则

1. 如果用户通过参数指定了 JIRA（如 `/gerp-commit BGERP-12345`），优先使用用户指定的
2. 否则从分支名中自动提取（匹配 `BGERP-[0-9]+`）
3. 如果都没有，则允许无前缀提交

## 提交规范

1. **JIRA 前缀**：使用中文方括号包裹，如 `【BGERP-32921】`
2. **语言要求**：使用中文描述变更内容
3. **内容要求**：
   - 首行：简短描述做了什么（50字符以内）
   - 正文（可选）：详细说明原因、影响或技术细节
4. **禁止内容**：
   - 不要添加 "Generated with Claude Code" 或 "Co-Authored-By: Claude" 等后缀
   - 不要使用 emoji
   - 不要使用英文 commit type 前缀（如 feat:, fix:, chore:）

## 提交格式示例

有 JIRA 时：
```
【BGERP-32921】修复分页下拉菜单被水平滚动条遮挡问题

根因：表格容器设置了 z-index 创建了局部层叠上下文
修复：删除父级容器的 z-index 属性
```

无 JIRA 时：
```
修复分页下拉菜单被水平滚动条遮挡问题
```

## 任务

根据上述 Git 上下文和提交规范，执行以下操作：

1. 确定 JIRA 前缀（优先用户参数 > 分支提取 > 无前缀）
2. 分析所有暂存和未暂存的变更内容
3. 将相关变更添加到暂存区（git add）
4. 使用规范格式创建提交（git commit）

只调用必要的 git 工具完成提交，不要输出其他文本。
