---
name: jira-commit
description: Use when the user wants to create a git commit for current changes, asks to commit a branch or workspace, or explicitly provides a JIRA issue key to include in the commit message.
---

# JIRA Commit

创建符合团队规范的 Git 提交；如能解析到 JIRA issue key，则附带 JIRA 前缀。

## 何时使用

- 用户明确要求提交当前改动
- 用户要求提交当前分支、工作区或暂存区改动
- 当前分支可解析 JIRA 编号，或用户显式提供了 JIRA 编号时，自动把它带入 commit message
- 不用于只生成 commit message 模板，也不用于 `git push`

## 环境变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `JIRA_PREFIXES` | JIRA 项目前缀，多个用逗号分隔；未设置时跳过分支名解析 | `PROJ1,PROJ2` |

## Git 上下文

- JIRA 前缀列表：`$JIRA_PREFIXES`（可为空）
- 当前分支：`git branch --show-current`
- 用户显式提供的 JIRA 编号
- 工作区状态：`git status --short`
- 暂存区变更：`git diff --staged --stat`
- 未暂存变更：`git diff --stat`
- 最近提交：`git log --oneline -5`

## 必要前置检查

1. 读取当前分支名：
   ```bash
   git branch --show-current
   ```
2. 解析 JIRA 编号，规则如下：
   - 用户通过参数显式指定时，优先使用参数
   - 否则仅在 `JIRA_PREFIXES` 非空时，从分支名提取，匹配 `($JIRA_PREFIXES)-[0-9]+`
   - 如果参数和分支名都无法提供有效 JIRA 编号，继续执行提交，但不要添加 JIRA 前缀
3. 如果工作区无变更，报告并结束，不执行 `git add` 或 `git commit`。

## 提交规范

1. **语言要求**：使用中文描述变更内容
2. **内容要求**：
   - 首行：简短描述做了什么（50字符以内）
   - 正文（可选）：详细说明原因、影响或技术细节
3. **JIRA 前缀**：
   - 解析到有效 JIRA 编号时，使用中文方括号包裹，如 `【PROJ-32921】`
   - 未解析到 JIRA 编号时，首行直接写中文摘要，不补占位前缀
4. **禁止内容**：
   - 不要使用 emoji
   - 不要使用英文 commit type 前缀（如 feat:, fix:, chore:）

## 执行步骤

1. 获取当前分支名并尝试解析 JIRA 编号
2. 检查工作区变更；如无变更，报告并结束
3. 分析暂存和未暂存变更内容
4. 将相关变更添加到暂存区（`git add`）
5. 生成符合规范的 commit message：
   - 有 JIRA 时使用 `【JIRA-123】摘要`
   - 无 JIRA 时直接使用 `摘要`
6. 展示暂存内容与提议的 message，等待用户确认
7. 用户确认后执行 `git commit`
8. 返回提交结果

## 提交格式示例

```text
【PROJ-32921】修复分页下拉菜单被水平滚动条遮挡问题

根因：表格容器设置了 z-index 创建了局部层叠上下文
修复：删除父级容器的 z-index 属性
```

```text
重写 worktree skill，收紧远端与迁移规则

补充 remote 选择策略，去掉主观的本地配置同步条件。
```

## 返回格式

**成功**：

```text
✅ 已提交: abc1234
【PROJ-32921】修复分页下拉菜单遮挡问题
```

```text
✅ 已提交: abc1234
重写 worktree skill，收紧远端与迁移规则
```

**失败**：

```text
❌ 提交失败: [错误原因]
```

**无变更**：

```text
ℹ️ 工作区无变更，无需提交
```
