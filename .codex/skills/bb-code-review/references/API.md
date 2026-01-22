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
http://bitbucket.rd.800best.com/projects/BESTSMART/repos/html/pull-requests/8393/overview
                                        ↓           ↓              ↓
                                     PROJECT      REPO           PR_ID
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

### 获取变更文件列表

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}/changes
```

参数：`start`, `limit`

### 获取 PR Diff

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}/diff
```

参数：`contextLines`, `srcPath`, `whitespace`

---

## 评论相关

### 获取 PR 评论

```
GET /projects/{project}/repos/{repo}/pull-requests/{pr_id}/comments
```

### 发布评论

```
POST /projects/{project}/repos/{repo}/pull-requests/{pr_id}/comments
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

**anchor.lineType**：`ADDED`, `REMOVED`, `CONTEXT`

---

## 错误处理

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 认证失败 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
