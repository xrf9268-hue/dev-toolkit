# bb-code-review

Bitbucket PR 代码审查插件，支持多 Agent 并行审查和自动评论。

## 功能

- 解析 Bitbucket PR URL，自动提取项目、仓库、PR 信息
- 5 个并行 Agent 审查代码变更
- 置信度评分过滤低质量问题
- 自动发布行级评论到 Bitbucket

## 环境配置

### 认证方式

本插件使用两种认证方式：
- **API 认证**: Basic Auth（用户名 + 密码）
- **Git 克隆**: SSH（需要配置 SSH Key）

### 配置 SSH Key

1. 生成 SSH Key（如果没有）：
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   ```

2. 将公钥添加到 Bitbucket：
   - 登录 Bitbucket Server
   - 点击头像 → **Manage account** → **SSH keys**
   - 点击 **Add key**，粘贴 `~/.ssh/id_ed25519.pub` 内容

3. 测试连接：
   ```bash
   ssh -T git@$BITBUCKET_HOST -p 7999
   ```

### 设置环境变量

```bash
# 必需
export BITBUCKET_HOST="your-bitbucket-server.example.com"
export BITBUCKET_USER="your-username"
export BITBUCKET_PASSWORD="your-password"

# 可选（如果 SSH 端口不是默认 7999）
export BITBUCKET_SSH_HOST="ssh://git@your-bitbucket-server.example.com:7999"
```

建议将环境变量添加到 `~/.bashrc` 或 `~/.zshrc`：

```bash
echo 'export BITBUCKET_HOST="your-bitbucket-server.example.com"' >> ~/.zshrc
echo 'export BITBUCKET_USER="your-username"' >> ~/.zshrc
echo 'export BITBUCKET_PASSWORD="your-password"' >> ~/.zshrc
source ~/.zshrc
```

**注意**: 密码存储在环境变量中有一定安全风险，请确保你的机器安全。

## 使用方法

### Claude Code

```bash
# 基本用法
/bb-review https://$BITBUCKET_HOST/projects/PROJECT/repos/REPO/pull-requests/123

# 预览模式（不发布评论）
/bb-review https://$BITBUCKET_HOST/projects/PROJECT/repos/REPO/pull-requests/123 --dry-run

# 调整置信度阈值
/bb-review https://$BITBUCKET_HOST/projects/PROJECT/repos/REPO/pull-requests/123 --threshold 90
```

### Codex CLI

```bash
/bb-code-review https://$BITBUCKET_HOST/projects/PROJECT/repos/REPO/pull-requests/123
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
PR URL: https://$BITBUCKET_HOST/projects/PROJECT/repos/REPO/pull-requests/123
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

检查用户名和密码是否正确：

```bash
curl -s -o /dev/null -w "%{http_code}" \
  -u "$BITBUCKET_USER:$BITBUCKET_PASSWORD" \
  "https://$BITBUCKET_HOST/rest/api/1.0/projects"
```

### SSH 克隆失败

1. 确认 SSH Key 已添加到 Bitbucket
2. 测试 SSH 连接：
   ```bash
   ssh -T git@$BITBUCKET_HOST -p 7999
   ```
3. 检查 SSH agent 是否运行：
   ```bash
   ssh-add -l
   ```

### PR 不存在 (404)

检查 URL 格式是否正确：
```
https://$BITBUCKET_HOST/projects/{PROJECT}/repos/{REPO}/pull-requests/{PR_ID}
```

## 许可证

MIT
