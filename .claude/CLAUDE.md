# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Dev Toolkit 是一个多平台开发工具集，为 Claude Code 和 Codex CLI 提供插件/技能支持。

## 常用命令

```bash
# 验证整个 Marketplace（需在根目录执行）
claude plugin validate .

# 验证单个插件
claude plugin validate ./plugins/jira-commit
claude plugin validate ./plugins/git-worktree
```

## 架构

### 双平台结构

本仓库同时支持 Claude Code 和 Codex CLI，两套实现独立维护：

- **Claude Code**: `plugins/<name>/.claude-plugin/plugin.json` + `plugins/<name>/skills/<skill>/SKILL.md`
- **Codex CLI**: `.codex/skills/<name>/SKILL.md`

### 版本号管理

**单一来源原则**: 版本号仅在 `plugin.json` 中定义，`marketplace.json` 不重复配置。

### 关键配置

**plugin.json 必需字段**:
- `skills`: 必须显式配置 `"./skills"` 才能让 slash command 正确显示

**SKILL.md frontmatter**:
- `disable-model-invocation: true`: 仅用户手动调用，不自动触发
- `context: fork`: 上下文隔离执行

### 敏感信息处理

**禁止硬编码敏感信息**：所有敏感信息（域名、用户名、密码、Token、API Key 等）必须通过环境变量配置，不得写入代码或文档中。

示例：
- ✅ `$BITBUCKET_HOST`、`$JIRA_TOKEN`
- ❌ `bitbucket.example.com`、`your-actual-token`

### 文件对应关系

| 插件 | plugin.json | skill 文件 |
|------|-------------|-----------|
| jira-commit | `plugins/jira-commit/.claude-plugin/plugin.json` | `plugins/jira-commit/skills/jira-commit/SKILL.md` |
| git-worktree | `plugins/git-worktree/.claude-plugin/plugin.json` | `plugins/git-worktree/skills/worktree/SKILL.md` |
| bb-code-review | `plugins/bb-code-review/.claude-plugin/plugin.json` | `plugins/bb-code-review/skills/bb-review/SKILL.md` |
