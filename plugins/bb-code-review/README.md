# bb-code-review

Bitbucket PR 代码审查插件，支持多 Agent 并行审查和自动评论。

## 功能

- 解析 Bitbucket PR URL，自动提取项目、仓库、PR 信息
- 5 个并行 Agent 审查代码变更
- 置信度评分过滤低质量问题
- 自动发布行级评论到 Bitbucket

## 环境配置

### 获取 Personal Access Token

1. 登录 Bitbucket Server
2. 点击右上角头像 → **Manage account**
3. 选择 **Personal access tokens**
4. 点击 **Create a token**
5. 设置权限：
   - **Repository**: Read, Write
   - **Pull Request**: Read, Write
6. 复制生成的 Token

### 设置环境变量

```bash
# 必需
export BITBUCKET_HOST="bitbucket.rd.800best.com"
export BITBUCKET_TOKEN="your-personal-access-token"

# 可选（Basic Auth 时使用）
export BITBUCKET_USER="your-username"
```

建议将环境变量添加到 `~/.bashrc` 或 `~/.zshrc`：

```bash
echo 'export BITBUCKET_HOST="bitbucket.rd.800best.com"' >> ~/.zshrc
echo 'export BITBUCKET_TOKEN="your-token"' >> ~/.zshrc
source ~/.zshrc
```

## 使用方法

### Claude Code

```bash
# 基本用法
/bb-review http://bitbucket.rd.800best.com/projects/BESTSMART/repos/html/pull-requests/8393

# 预览模式（不发布评论）
/bb-review http://bitbucket.rd.800best.com/projects/BESTSMART/repos/html/pull-requests/8393 --dry-run

# 调整置信度阈值
/bb-review http://bitbucket.rd.800best.com/projects/BESTSMART/repos/html/pull-requests/8393 --threshold 90
```

### Codex CLI

```bash
/bb-code-review http://bitbucket.rd.800best.com/projects/BESTSMART/repos/html/pull-requests/8393
```

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `<PR_URL>` | Bitbucket PR 的完整 URL | 必需 |
| `--dry-run` | 预览模式，只显示问题不发布评论 | false |
| `--threshold N` | 置信度阈值（0-100），低于此分数的问题将被过滤 | 80 |

## 审查维度

插件使用 5 个并行 Agent 从不同维度审查代码：

| Agent | 职责 |
|-------|------|
| 规范合规 | 检查是否符合 CLAUDE.md 定义的项目规范 |
| Bug 扫描 | 识别潜在缺陷（空指针、边界条件、资源泄漏） |
| 历史上下文 | 分析 git 历史，评估回归风险 |
| 评论历史 | 检查已有评论，避免重复 |
| 代码风格 | 统一代码风格和命名规范 |

## 置信度评分

每个发现的问题都会有 0-100 的置信度评分：

| 分数 | 含义 |
|------|------|
| 90-100 | 确定性问题，必须修复 |
| 80-89 | 高可能性问题，建议修复 |
| 60-79 | 可能问题，需人工确认 |
| < 60 | 低置信度，可能误报 |

默认只显示 ≥ 80 分的问题，可通过 `--threshold` 调整。

## 输出示例

### 发现问题

```
✅ PR 审查完成

发现问题: 5 个
- 2 个错误
- 3 个警告

已发布评论: 5 条
PR URL: http://bitbucket.rd.800best.com/projects/BESTSMART/repos/html/pull-requests/8393
```

### 预览模式

```
🔍 预览模式 - 不发布评论

发现问题: 3 个

1. [ERROR] src/utils/api.ts:42
   未处理的 Promise 异常
   建议: 添加 try-catch 或 .catch() 处理
   置信度: 95

2. [WARNING] src/components/List.tsx:128
   循环中使用索引作为 key
   建议: 使用唯一标识符作为 key
   置信度: 88

使用 /bb-review <URL> 发布评论
```

### 无问题

```
✅ PR 审查完成，未发现问题
```

## 故障排除

### 认证失败 (401)

检查 Token 是否正确设置：

```bash
echo $BITBUCKET_TOKEN
curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $BITBUCKET_TOKEN" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects"
```

### 权限不足 (403)

确保 Token 具有以下权限：
- Repository: Read, Write
- Pull Request: Read, Write

### PR 不存在 (404)

检查 URL 格式是否正确：
```
http://bitbucket.rd.800best.com/projects/{PROJECT}/repos/{REPO}/pull-requests/{PR_ID}
```

## 许可证

MIT
