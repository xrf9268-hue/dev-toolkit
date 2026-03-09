# Skill Repository Migration

## 目标

将仓库从“多客户端发布仓”收敛为“标准唯一 Skill 源仓”。

## 迁移结果

- `jira-commit` canonical source：`.agents/skills/jira-commit/`
- `worktree` canonical source：`.agents/skills/worktree/`
- `bb-code-review` canonical source：`.agents/skills/bb-code-review/`

## 已移除的发布面

- `plugins/`
- `.codex/`
- `.claude-plugin/`
- 仓库内的 `.claude/CLAUDE.md`

## Breaking Change

本仓库不再直接支持：

- Claude plugin marketplace 安装
- Claude plugin validate
- Codex `.codex/skills/...` 安装 URL

如果后续需要面向 Claude、Codex、Gemini 等客户端发布，应在其他仓库、release artifact 或独立发布流程中维护适配产物，而不是回到本仓库重新引入这些目录。
