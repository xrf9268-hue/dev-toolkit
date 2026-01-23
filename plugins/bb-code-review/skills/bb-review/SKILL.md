---
name: bb-code-review
description: |
  审查 Bitbucket Pull Request，使用多 Agent 并行分析代码变更。

  触发场景：
  - 用户提供 Bitbucket PR URL
  - 用户显式调用 /bb-review <PR_URL>
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

## 环境变量

| 变量 | 说明 | 必需 |
|------|------|------|
| `BITBUCKET_HOST` | Bitbucket Server 地址 | 是 |
| `BITBUCKET_USER` | 用户名 | 是 |
| `BITBUCKET_PASSWORD` | 密码（LDAP 密码，Basic Auth 认证） | 是 |
| `BITBUCKET_SSH_HOST` | SSH 克隆地址（如 ssh://git@$BITBUCKET_HOST:7999） | 否 |

**注意**：本插件使用 Basic Auth 进行 API 认证，使用 SSH 进行仓库克隆。

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--dry-run` | 预览模式，不发布评论 | false |
| `--threshold N` | 置信度阈值（0-100） | 80 |

## 输入解析

- PR URL: $ARGUMENTS
- 解析正则: `/projects/([^/]+)/repos/([^/]+)/pull-requests/(\d+)`
- 提取: PROJECT, REPO, PR_ID

## 执行前置检查

**重要**：在开始任何操作前，必须先执行以下检查：

1. 验证 PR URL 格式：
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

如果检查失败，输出错误信息并**终止**。

## 审查流程（8 步）

### Step 1: 解析 URL 并验证认证

从 URL 提取 PROJECT、REPO、PR_ID：

```bash
# 解析 URL（使用 sed 以兼容 macOS）
PR_URL="$1"
PROJECT=$(echo "$PR_URL" | sed -n 's|.*/projects/\([^/]*\)/.*|\1|p')
REPO=$(echo "$PR_URL" | sed -n 's|.*/repos/\([^/]*\)/.*|\1|p')
PR_ID=$(echo "$PR_URL" | sed -n 's|.*/pull-requests/\([0-9]*\).*|\1|p')

echo "PROJECT: $PROJECT, REPO: $REPO, PR_ID: $PR_ID"
```

### Step 2: 检查 PR 状态

确认 PR 处于 OPEN 状态：

```bash
curl -s -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects/$PROJECT/repos/$REPO/pull-requests/$PR_ID" \
  | jq -r '.state'
```

如果状态不是 `OPEN`，报告并终止。

### Step 3: 收集相关 CLAUDE.md 文件

查找仓库中的 CLAUDE.md 以获取项目规范：

```bash
# 使用 SSH 克隆到临时目录（需要配置 SSH key）
# SSH 地址格式: ssh://git@$BITBUCKET_HOST:7999/$PROJECT/$REPO.git
SSH_HOST="${BITBUCKET_SSH_HOST:-ssh://git@$BITBUCKET_HOST:7999}"
git clone --depth 1 "$SSH_HOST/$PROJECT/$REPO.git" /tmp/repo
find /tmp/repo -name "CLAUDE.md" -o -name ".claude" -type d
```

### Step 4: 获取 PR diff 和变更文件

```bash
# 获取变更文件列表
curl -s -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects/$PROJECT/repos/$REPO/pull-requests/$PR_ID/changes?limit=1000" \
  | jq -r '.values[].path.toString'

# 获取 diff
curl -s -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects/$PROJECT/repos/$REPO/pull-requests/$PR_ID/diff"
```

### Step 5: 并行 Agent 审查

使用 Task 工具启动 5 个并行 Agent：

| Agent | 职责 | 关注点 |
|-------|------|--------|
| **规范合规** | 检查代码是否符合项目规范 | CLAUDE.md 规则、命名约定、文件结构 |
| **Bug 扫描** | 识别潜在缺陷 | 空指针、边界条件、资源泄漏、并发问题 |
| **历史上下文** | 分析 git 历史 | 相关提交、模式变化、回归风险 |
| **评论历史** | 检查已有评论 | 避免重复评论、跟进未解决问题 |
| **代码风格** | 统一代码风格 | 缩进、空格、命名、注释 |

每个 Agent 返回：
```json
{
  "issues": [
    {
      "file": "path/to/file.ts",
      "line": 42,
      "severity": "warning|error|info",
      "message": "问题描述",
      "suggestion": "修复建议",
      "confidence": 85
    }
  ]
}
```

### Step 6: 置信度评分

每个问题评分标准（0-100）：

| 分数区间 | 含义 |
|----------|------|
| 90-100 | 确定性问题，必须修复 |
| 80-89 | 高可能性问题，建议修复 |
| 60-79 | 可能问题，需人工确认 |
| < 60 | 低置信度，可能误报 |

### Step 7: 过滤低分问题

只保留置信度 ≥ 阈值（默认 80）的问题：

```javascript
issues.filter(issue => issue.confidence >= threshold)
```

### Step 8: 发布评论到 Bitbucket

如果不是 `--dry-run` 模式，发布评论：

```bash
# 发布行级评论
curl -X POST \
  -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  -H "Content-Type: application/json" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects/$PROJECT/repos/$REPO/pull-requests/$PR_ID/comments" \
  -d '{
    "text": "问题描述\n\n建议修复方案",
    "anchor": {
      "path": "path/to/file.ts",
      "line": 42,
      "lineType": "ADDED"
    }
  }'
```

## API 参考

详见 [references/API.md](references/API.md)

## 返回格式

**成功**：
```
✅ PR 审查完成

发现问题: 5 个
- 2 个错误
- 3 个警告

已发布评论: 5 条
PR URL: https://$BITBUCKET_HOST/projects/PROJECT/repos/REPO/pull-requests/123
```

**预览模式**：
```
🔍 预览模式 - 不发布评论

发现问题: 5 个
[问题列表...]

使用 /bb-review <URL> 发布评论
```

**无问题**：
```
✅ PR 审查完成，未发现问题
```

**失败**：
```
❌ 审查失败: [错误原因]
```
