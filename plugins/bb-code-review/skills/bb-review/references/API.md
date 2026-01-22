# Bitbucket REST API 参考

本文档提供 Bitbucket Server REST API 的使用说明。

## 认证方式

### Bearer Token（推荐）

```bash
curl -H "Authorization: Bearer $BITBUCKET_TOKEN" \
  "https://$BITBUCKET_HOST/rest/api/1.0/..."
```

### Basic Auth

```bash
curl -u "$BITBUCKET_USER:$BITBUCKET_TOKEN" \
  "https://$BITBUCKET_HOST/rest/api/1.0/..."
```

## API 端点

### 基础 URL

```
https://{BITBUCKET_HOST}/rest/api/1.0
```

### URL 解析

从 PR URL 提取参数：

```
https://$BITBUCKET_HOST/projects/PROJECT/repos/REPO/pull-requests/123/overview
                                    ↓        ↓              ↓
                                 PROJECT    REPO          PR_ID
```

正则表达式：
```regex
/projects/([^/]+)/repos/([^/]+)/pull-requests/(\d+)
```

---

## Pull Request 相关

### 获取 PR 详情

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}
```

**响应示例**：
```json
{
  "id": 8393,
  "version": 0,
  "title": "feat: 新增功能",
  "description": "详细描述",
  "state": "OPEN",
  "open": true,
  "closed": false,
  "createdDate": 1705123456000,
  "updatedDate": 1705123456000,
  "fromRef": {
    "id": "refs/heads/feature/BESTSMART-12345",
    "displayId": "feature/BESTSMART-12345",
    "latestCommit": "abc123..."
  },
  "toRef": {
    "id": "refs/heads/develop",
    "displayId": "develop",
    "latestCommit": "def456..."
  },
  "locked": false,
  "author": {
    "user": {
      "name": "username",
      "displayName": "User Name"
    }
  },
  "reviewers": [...],
  "participants": [...]
}
```

### 获取变更文件列表

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}/changes
```

**参数**：
| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `start` | int | 起始位置 | 0 |
| `limit` | int | 返回数量 | 25 |

**响应示例**：
```json
{
  "values": [
    {
      "contentId": "abc123",
      "fromContentId": "def456",
      "path": {
        "parent": "src/components",
        "name": "Button.tsx",
        "toString": "src/components/Button.tsx"
      },
      "type": "MODIFY",
      "nodeType": "FILE",
      "percentUnchanged": 85
    }
  ],
  "size": 10,
  "isLastPage": true
}
```

**变更类型 (type)**：
- `ADD` - 新增文件
- `MODIFY` - 修改文件
- `DELETE` - 删除文件
- `MOVE` - 移动/重命名文件
- `COPY` - 复制文件

### 获取 PR Diff

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}/diff
```

**参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| `contextLines` | int | 上下文行数 |
| `srcPath` | string | 过滤特定文件 |
| `whitespace` | string | 空白处理：`ignore-all`, `ignore-change` |

**响应示例**：
```json
{
  "diffs": [
    {
      "source": {
        "parent": "src",
        "name": "file.ts",
        "toString": "src/file.ts"
      },
      "destination": {
        "parent": "src",
        "name": "file.ts",
        "toString": "src/file.ts"
      },
      "hunks": [
        {
          "sourceLine": 10,
          "sourceSpan": 5,
          "destinationLine": 10,
          "destinationSpan": 7,
          "segments": [
            {
              "type": "CONTEXT",
              "lines": [
                { "source": 10, "destination": 10, "line": "const a = 1;" }
              ]
            },
            {
              "type": "REMOVED",
              "lines": [
                { "source": 11, "destination": 11, "line": "const b = 2;" }
              ]
            },
            {
              "type": "ADDED",
              "lines": [
                { "source": 11, "destination": 11, "line": "const b = 3;" },
                { "source": 11, "destination": 12, "line": "const c = 4;" }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

---

## 评论相关

### 获取 PR 评论

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}/comments
```

### 获取 PR 活动（包含评论）

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}/activities
```

**参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| `fromType` | string | 过滤类型：`COMMENT`, `ACTIVITY` |

### 发布评论

```
POST /projects/{project}/repos/{repo}/pull-requests/{pr_id}/comments
```

**请求体 - 通用评论**：
```json
{
  "text": "评论内容"
}
```

**请求体 - 行级评论**：
```json
{
  "text": "评论内容",
  "anchor": {
    "path": "src/components/Button.tsx",
    "line": 42,
    "lineType": "ADDED"
  }
}
```

**anchor 参数**：
| 字段 | 类型 | 说明 |
|------|------|------|
| `path` | string | 文件路径 |
| `line` | int | 行号 |
| `lineType` | string | 行类型：`ADDED`, `REMOVED`, `CONTEXT` |
| `fileType` | string | 文件类型：`FROM`, `TO` |

**响应示例**：
```json
{
  "id": 12345,
  "version": 0,
  "text": "评论内容",
  "author": {
    "user": {
      "name": "username",
      "displayName": "User Name"
    }
  },
  "createdDate": 1705123456000,
  "updatedDate": 1705123456000,
  "comments": [],
  "anchor": {
    "path": "src/components/Button.tsx",
    "line": 42,
    "lineType": "ADDED"
  }
}
```

### 回复评论

```
POST /projects/{project}/repos/{repo}/pull-requests/{pr_id}/comments/{comment_id}/comments
```

**请求体**：
```json
{
  "text": "回复内容"
}
```

### 更新评论

```
PUT /projects/{project}/repos/{repo}/pull-requests/{pr_id}/comments/{comment_id}
```

**请求体**：
```json
{
  "version": 0,
  "text": "更新后的内容"
}
```

### 删除评论

```
DELETE /projects/{project}/repos/{repo}/pull-requests/{pr_id}/comments/{comment_id}?version={version}
```

---

## 提交相关

### 获取 PR 提交列表

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}/commits
```

### 获取提交详情

```
GET /projects/{project}/repos/{repo}/commits/{commitId}
```

### 获取提交 Diff

```
GET /projects/{project}/repos/{repo}/commits/{commitId}/diff
```

---

## 分支相关

### 获取分支列表

```
GET /projects/{project}/repos/{repo}/branches
```

### 获取默认分支

```
GET /projects/{project}/repos/{repo}/default-branch
```

---

## 仓库相关

### 获取仓库信息

```
GET /projects/{project}/repos/{repo}
```

### 获取文件内容

```
GET /projects/{project}/repos/{repo}/raw/{path}?at={ref}
```

### 浏览目录

```
GET /projects/{project}/repos/{repo}/browse/{path}?at={ref}
```

---

## 分页

所有列表 API 支持分页：

| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `start` | int | 起始位置 | 0 |
| `limit` | int | 返回数量 | 25 |

**响应分页字段**：
```json
{
  "values": [...],
  "size": 25,
  "limit": 25,
  "start": 0,
  "isLastPage": false,
  "nextPageStart": 25
}
```

---

## 错误处理

**常见 HTTP 状态码**：

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 认证失败 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 409 | 版本冲突 |

**错误响应示例**：
```json
{
  "errors": [
    {
      "context": null,
      "message": "The specified user does not exist.",
      "exceptionName": "com.atlassian.bitbucket.user.NoSuchUserException"
    }
  ]
}
```

---

## 使用示例

### 完整审查流程

```bash
#!/bin/bash
set -e

# 配置（从环境变量读取）
# export BITBUCKET_HOST="your-bitbucket-server.example.com"
# export BITBUCKET_USER="your-username"
# export BITBUCKET_PASSWORD="your-password"
PROJECT="PROJECT"
REPO="REPO"
PR_ID="123"

# 1. 获取 PR 信息
pr_info=$(curl -s -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects/$PROJECT/repos/$REPO/pull-requests/$PR_ID")

echo "PR Title: $(echo $pr_info | jq -r '.title')"
echo "PR State: $(echo $pr_info | jq -r '.state')"

# 2. 获取变更文件
changes=$(curl -s -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects/$PROJECT/repos/$REPO/pull-requests/$PR_ID/changes?limit=1000")

echo "Changed files:"
echo $changes | jq -r '.values[].path.toString'

# 3. 获取 diff
diff=$(curl -s -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects/$PROJECT/repos/$REPO/pull-requests/$PR_ID/diff")

# 4. 发布评论
curl -X POST \
  -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  -H "Content-Type: application/json" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects/$PROJECT/repos/$REPO/pull-requests/$PR_ID/comments" \
  -d '{
    "text": "Code review completed by AI assistant.",
    "anchor": {
      "path": "src/App.tsx",
      "line": 10,
      "lineType": "ADDED"
    }
  }'
```
