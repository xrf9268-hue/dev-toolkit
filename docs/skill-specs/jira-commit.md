# jira-commit Canonical Spec

## Canonical Description

`Use when the user wants to create a git commit for work tracked by a JIRA issue key, or explicitly provides a JIRA issue key for the commit.`

## Command Mapping

| Surface | Command |
|---------|---------|
| Claude Code | `/jira-commit [JIRA编号]` |
| Codex CLI | `$jira-commit [JIRA编号]` |

## Trigger Cues

- 用户明确要求提交当前改动
- 当前分支包含 JIRA issue key
- 用户显式提供 JIRA 编号

## Should Not Trigger

- 仅解释 commit message 规范
- 只做 `git push`
- 分支和参数都没有 JIRA 编号的直接提交请求

## Parameters

| 参数 | 说明 |
|------|------|
| `[JIRA编号]` | 显式指定 JIRA issue key，优先级高于分支名 |

## Environment Variables

- `JIRA_PREFIXES`

## Behavior Contract

1. 必须先从显式参数或当前分支解析 JIRA issue key。
2. 参数优先于分支名。
3. 如果无法得到 JIRA issue key，必须终止，不允许无前缀提交。
4. 只有存在实际工作区改动时才继续。
5. 提交标题格式固定为 `【JIRA-ID】中文描述`，正文可选。
6. 不允许 `feat:`、`fix:` 等英文 commit type 前缀，也不允许 emoji。
7. 执行 `git commit` 前必须展示暂存摘要和提议 message，并等待用户确认。

## Derived Files

- `plugins/jira-commit/skills/jira-commit/SKILL.md`
- `.codex/skills/jira-commit/SKILL.md`
- `plugins/jira-commit/README.md`
- `README.md`
