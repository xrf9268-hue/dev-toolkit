# AGENTS.md

This file provides repository-wide guidance for agents working with code in this repository.

## 项目概述

Dev Toolkit 是一个标准唯一 Skill 仓库，只维护 `.agents/skills/` 下的 canonical skill package。

## 常用命令

```bash
# Skill 契约静态检查
bash scripts/check-skill-consistency.sh

# 查看 canonical skills
find .agents/skills -maxdepth 2 -name SKILL.md | sort
```

## 架构

### Canonical Skill Packages

本仓库只保留标准 skill source：

- **Canonical source**: `.agents/skills/<skill>/`
- **Repo guidance**: `AGENTS.md`
- **External references**: `docs/references/`

### 关键配置

**SKILL.md frontmatter**:
- 仅保留可移植字段：`name`、`description`
- `name` 必须与 `.agents/skills/<skill>/` 目录名一致
- `description` 必须以 `Use when` 开头

### Skill 单一来源

每个工具的正文、引用文档和触发描述只维护在 `.agents/skills/`。

变更流程：

1. 修改 `.agents/skills/<skill>/`
2. 如需 supporting files，直接放在对应 skill package 内
3. 运行 `bash scripts/check-skill-consistency.sh`

根目录 `AGENTS.md` 是仓库唯一的仓库级 agent 指南。

### 敏感信息处理

**禁止硬编码敏感信息**：所有敏感信息（域名、用户名、密码、Token、API Key 等）必须通过环境变量配置，不得写入代码或文档中。

示例：
- ✅ `$BITBUCKET_HOST`、`$JIRA_TOKEN`
- ❌ `bitbucket.example.com`、`your-actual-token`

### 文件对应关系

| Skill | Canonical Path |
|------|----------------|
| jira-commit | `.agents/skills/jira-commit/SKILL.md` |
| worktree | `.agents/skills/worktree/SKILL.md` |
| bb-code-review | `.agents/skills/bb-code-review/SKILL.md` |
