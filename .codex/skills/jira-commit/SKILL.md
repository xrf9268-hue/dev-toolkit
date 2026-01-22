---
name: jira-commit
description: |
  创建规范化的 git 提交，自动从分支名提取 JIRA 前缀，支持用户指定编号。

  触发场景：
  - 用户明确请求提交代码（"帮我提交""commit一下""创建提交"）
  - 用户显式调用 /jira-commit 或 jira-commit <JIRA编号>

  支持的 JIRA 前缀通过环境变量 JIRA_PREFIXES 配置，非标准分支请显式调用并指定 JIRA 编号。
disable-model-invocation: true
argument-hint: "[JIRA编号（可选）]"
---

## 环境变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `JIRA_PREFIXES` | JIRA 项目前缀，多个用逗号分隔 | `PROJ1,PROJ2` |

## Git 上下文

- JIRA 前缀列表: !`echo "${JIRA_PREFIXES:-JIRA}"`
- 当前分支: !`git branch --show-current`
- 分支中的 JIRA: !`git branch --show-current | grep -oE "(${JIRA_PREFIXES//,/|})-[0-9]+" || echo ''`
- 用户指定 JIRA: $ARGUMENTS
- 工作区状态: !`git status --short`
- 暂存区变更: !`git diff --staged --stat`
- 未暂存变更: !`git diff --stat`
- 最近提交: !`git log --oneline -5`

## 执行前置检查

**重要**：在开始任何 git 操作前，必须先执行以下检查：

1. 检查当前分支名：
   ```bash
   git branch --show-current
   ```

2. 验证执行条件：
   - ✅ **继续执行**：分支名包含 JIRA 前缀（匹配 `$JIRA_PREFIXES` 中的任一前缀），或用户通过参数指定了 JIRA 编号
   - ❌ **立即终止**：分支名不包含有效 JIRA 前缀且用户未指定 JIRA 编号

3. 如果不满足条件，输出以下提示并**终止**：
   ```
   ⚠️ 未检测到 JIRA 分支，且未指定 JIRA 编号。

   若确需提交，请显式指定：/jira-commit <JIRA编号>
   ```
   **不执行任何 git add、commit 等操作**。

## JIRA 前缀确定规则

1. 如果用户通过参数指定了 JIRA（如 `jira-commit PROJ-12345`），优先使用用户指定的
2. 否则从分支名中自动提取（匹配 `($JIRA_PREFIXES)-[0-9]+`）
3. 如果都没有，则允许无前缀提交

## 提交规范

1. **JIRA 前缀**：使用中文方括号包裹，如 `【PROJ-32921】`
2. **语言要求**：使用中文描述变更内容
3. **内容要求**：
   - 首行：简短描述做了什么（50字符以内）
   - 正文（可选）：详细说明原因、影响或技术细节
4. **禁止内容**：
   - 不要使用 emoji
   - 不要使用英文 commit type 前缀（如 feat:, fix:, chore:）

## 执行步骤

1. 获取当前分支名并提取 JIRA 前缀
2. 检查工作区变更；如无变更，报告并结束
3. 分析暂存和未暂存变更内容
4. 将相关变更添加到暂存区（`git add`）
5. 生成符合规范的 commit message
6. 展示暂存内容与提议的 message，等待用户确认
7. 用户确认后执行 `git commit`
8. 返回提交结果

## 提交格式示例

```
【PROJ-32921】修复分页下拉菜单被水平滚动条遮挡问题

根因：表格容器设置了 z-index 创建了局部层叠上下文
修复：删除父级容器的 z-index 属性
```

无 JIRA 时：
```
修复分页下拉菜单被水平滚动条遮挡问题
```

## 返回格式

**成功**：
```
✅ 已提交: abc1234
【PROJ-32921】修复分页下拉菜单遮挡问题
```

**失败**：
```
❌ 提交失败: [错误原因]
```

**无变更**：
```
ℹ️ 工作区无变更，无需提交
```
