# bb-code-review Canonical Spec

## Canonical Description

`Use when the user wants to review a Bitbucket pull request, shares a Bitbucket PR URL, asks for a review preview, or wants to publish review comments to Bitbucket.`

## Command Mapping

| Surface | Command |
|---------|---------|
| Claude Code | `/bb-review <PR_URL> [--dry-run] [--threshold N]` |
| Codex CLI | `$bb-code-review <PR_URL> [--dry-run] [--threshold N]` |

## Trigger Cues

- 用户提供 Bitbucket PR URL
- 用户要求审查 Bitbucket PR
- 用户要求预览评论或按阈值过滤结果

## Should Not Trigger

- 解释 Bitbucket API 文档
- 审查本地未提交改动
- 总结 PR 描述而不做代码审查

## Parameters

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `<PR_URL>` | Bitbucket PR 完整 URL | 必需 |
| `--dry-run` | 只预览，不发布评论 | `false` |
| `--threshold N` | 置信度阈值 | `80` |

## Environment Variables

- `BITBUCKET_HOST`
- `BITBUCKET_USER`
- `BITBUCKET_PASSWORD`
- `BITBUCKET_SSH_HOST`（可选）

## Behavior Contract

1. 开始前必须校验 URL、环境变量、认证状态和 PR 状态。
2. 必须收集 PR 元数据、变更文件、diff，以及必要的仓库规范上下文。
3. 审查维度固定为：规范合规、Bug 扫描、历史上下文、评论历史、代码风格。
4. 所有问题都必须输出统一结构：`file`、`line`、`severity`、`message`、`suggestion`、`confidence`。
5. 默认只保留 `confidence >= 80` 的问题。
6. `--dry-run` 只预览，去掉 `--dry-run` 才允许发布评论。

## Derived Files

- `plugins/bb-code-review/skills/bb-review/SKILL.md`
- `.codex/skills/bb-code-review/SKILL.md`
- `plugins/bb-code-review/README.md`
- `README.md`
