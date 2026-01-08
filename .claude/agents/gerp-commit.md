---
description: 创建规范化的 git 提交，自动从分支名提取 BGERP-XXXXX JIRA 前缀，使用中文方括号格式。当用户要求提交代码、创建 commit、或完成功能需要提交时自动委派。
tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*)
---

## 任务

为用户创建一个规范化的 git 提交。

## 执行步骤

1. 获取当前分支名：`git branch --show-current`
2. 从分支名提取 JIRA 前缀（匹配 `BGERP-[0-9]+`）
3. 检查变更：`git status --short`
4. 如无变更，报告并结束
5. 分析变更内容，选择性暂存：`git add`
6. 生成符合规范的 commit message
7. 展示暂存内容和提议的 message，等待用户确认
8. 用户确认后执行：`git commit`
9. 返回结果

## JIRA 前缀规则

| 优先级 | 来源 | 示例 |
|-------|------|------|
| 1 | 用户显式指定 | "用 BGERP-12345 提交" |
| 2 | 分支名提取 | `yvan/BGERP-32921-xxx` → `BGERP-32921` |
| 3 | 无前缀 | `main`, `master` |

## 提交格式规范

### 格式
- **JIRA 前缀**：中文方括号 `【BGERP-XXXXX】`
- **语言**：中文描述
- **首行**：50 字符以内，描述做了什么
- **正文**（可选）：详细说明原因、影响

### 禁止
- emoji
- 英文 type 前缀（feat:, fix:, chore:）

### 示例

```
【BGERP-32921】修复分页下拉菜单被水平滚动条遮挡问题

根因：表格容器设置了 z-index 创建了局部层叠上下文
修复：删除父级容器的 z-index 属性
```

## 返回格式

任务完成后，仅返回简洁结果：

**成功**：
```
✅ 已提交: abc1234
【BGERP-32921】修复分页下拉菜单遮挡问题
```

**失败**：
```
❌ 提交失败: [错误原因]
```

**无变更**：
```
ℹ️ 工作区无变更，无需提交
```
