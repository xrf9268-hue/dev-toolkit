---
name: bb-review
description: Use when the user wants to review a Bitbucket pull request, shares a Bitbucket PR URL, asks for a review preview, or wants to publish review comments to Bitbucket.
context: fork
agent: general-purpose
model: sonnet
disable-model-invocation: true
argument-hint: "<PR_URL> [--dry-run] [--threshold N]"
allowed-tools:
  - Bash(curl:*)
  - Bash(git:*)
  - Bash(jq:*)
  - Read
  - Glob
  - Grep
  - Task
---

# Bitbucket PR Review

审查 Bitbucket Pull Request，输出预览结果或直接发布评论。

## 命令映射

| Surface | Command |
|---------|---------|
| Claude Code | `/bb-review <PR_URL> [--dry-run] [--threshold N]` |
| Codex CLI | `$bb-code-review <PR_URL> [--dry-run] [--threshold N]` |

## 何时使用

- 用户提供 Bitbucket PR URL
- 用户要求审查 Bitbucket PR、预览评论，或按阈值过滤结果
- 不用于解释 Bitbucket API 文档，也不用于审查本地未提交改动

## 环境变量

| 变量 | 说明 | 必需 |
|------|------|------|
| `BITBUCKET_HOST` | Bitbucket Server 地址 | 是 |
| `BITBUCKET_USER` | 用户名 | 是 |
| `BITBUCKET_PASSWORD` | 密码（LDAP 密码，Basic Auth 认证） | 是 |
| `BITBUCKET_SSH_HOST` | SSH 克隆地址（如 `ssh://git@$BITBUCKET_HOST:7999`） | 否 |

本 Skill 使用 Basic Auth 访问 REST API，使用 SSH 克隆仓库以收集上下文。

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `<PR_URL>` | Bitbucket PR 的完整 URL | 必需 |
| `--dry-run` | 预览模式，不发布评论 | `false` |
| `--threshold N` | 置信度阈值（0-100） | `80` |

## 输入解析

- PR URL 来自 `$ARGUMENTS`
- 解析正则：`/projects/([^/]+)/repos/([^/]+)/pull-requests/(\d+)`
- 提取结果：`PROJECT`、`REPO`、`PR_ID`

## 必要前置检查

开始任何审查动作前，必须按顺序执行：

1. 校验 PR URL 格式：
   ```bash
   echo "$PR_URL" | grep -oE '/projects/([^/]+)/repos/([^/]+)/pull-requests/([0-9]+)'
   ```
2. 检查环境变量：
   ```bash
   [ -n "$BITBUCKET_USER" ] || echo "❌ 缺少 BITBUCKET_USER"
   [ -n "$BITBUCKET_PASSWORD" ] || echo "❌ 缺少 BITBUCKET_PASSWORD"
   [ -n "$BITBUCKET_HOST" ] || echo "❌ 缺少 BITBUCKET_HOST"
   ```
3. 验证认证：
   ```bash
   curl -s -o /dev/null -w "%{http_code}" \
     -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
     "https://$BITBUCKET_HOST/rest/api/1.0/projects"
   ```
4. 检查 PR 状态必须为 `OPEN`。

任一步骤失败都必须报告错误并终止。

## 审查流程

1. 从 URL 提取 `PROJECT`、`REPO`、`PR_ID`。
2. 通过 SSH 克隆仓库到临时目录，并收集 `CLAUDE.md`、`.claude/` 等项目规范上下文。
3. 获取 PR 元数据、变更文件、diff，以及必要的评论历史和活动记录。
4. 按以下 5 个固定维度审查代码：

| 审查维度 | 关注点 |
|----------|--------|
| 规范合规 | `CLAUDE.md` 规则、命名约定、文件结构 |
| Bug 扫描 | 空指针、边界条件、资源泄漏、并发问题 |
| 历史上下文 | 相关提交、模式变化、回归风险 |
| 评论历史 | 避免重复评论、跟进未解决问题 |
| 代码风格 | 缩进、空格、命名、注释 |

5. 每个问题必须输出以下统一结构：

```json
{
  "file": "path/to/file.ts",
  "line": 42,
  "severity": "warning|error|info",
  "message": "问题描述",
  "suggestion": "修复建议",
  "confidence": 85
}
```

6. 默认只保留 `confidence >= 80` 的问题；用户指定 `--threshold N` 时按新阈值过滤。
7. `--dry-run` 仅展示预览；去掉 `--dry-run` 才允许发布行级评论。

## API 参考

详见 [references/API.md](references/API.md)。

## 返回格式

**成功**：

```text
✅ PR 审查完成

发现问题: 5 个
- 2 个错误
- 3 个警告

已发布评论: 5 条
PR URL: https://$BITBUCKET_HOST/projects/PROJECT/repos/REPO/pull-requests/123
```

**预览模式**：

```text
🔍 预览模式 - 不发布评论

发现问题: 5 个
[问题列表...]

重新运行并去掉 `--dry-run` 可发布评论：
- Claude Code: `/bb-review <PR_URL>`
- Codex CLI: `$bb-code-review <PR_URL>`
```

**无问题**：

```text
✅ PR 审查完成，未发现问题
```

**失败**：

```text
❌ 审查失败: [错误原因]
```
