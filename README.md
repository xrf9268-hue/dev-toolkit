# Dev Toolkit

标准唯一 Skill 仓库，按 Agent Skills 风格维护可复用的 skill package。

## 仓库定位

这个仓库只保留 canonical skill source：

- `.agents/skills/bb-code-review/`
- `.agents/skills/jira-commit/`
- `.agents/skills/worktree/`

这里不再直接提供 Claude plugin、Claude marketplace 或 Codex skill 安装面。后续如果需要面向特定客户端发布，应在其他仓库、release artifact 或独立发布流程中完成。

## Skills

| Skill | 用途 |
|------|------|
| `bb-code-review` | 审查 Bitbucket Pull Request，输出预览结果或发布评论 |
| `jira-commit` | 生成符合团队规范且带有效 JIRA issue key 的提交 |
| `worktree` | 创建带配置同步、内容迁移和后台依赖安装的 Git worktree |

## 维护方式

```bash
# 编辑 skill 本体或 supporting files
$EDITOR .agents/skills/<skill>/SKILL.md

# 校验 canonical skill package
bash scripts/check-skill-consistency.sh
```

校验脚本会检查：

- `SKILL.md` frontmatter 只包含 `name` 和 `description`
- `name` 与 skill 目录名一致
- `description` 以 `Use when` 开头
- skill package 内的相对链接都存在，且不会越出 package
- 仓库中不存在旧的 `plugins/`、`.codex/`、`.claude-plugin/` 发布面引用

## Breaking Change

本仓库已移除这些直接使用方式：

- `claude plugin marketplace add ...`
- `claude plugin install ...`
- `claude plugin validate ...`
- 通过 `/.codex/skills/...` 的安装 URL

如果你之前把这个仓库当作 Claude 或 Codex 的安装源使用，需要改为消费单独的客户端适配产物，而不是直接依赖本仓库。

## 目录结构

```text
dev-toolkit/
├── .agents/
│   └── skills/
│       ├── bb-code-review/
│       ├── jira-commit/
│       └── worktree/
├── docs/
│   ├── references/
│   ├── skill-qa-checklist.md
│   └── skill-specs/
├── AGENTS.md
└── scripts/
    └── check-skill-consistency.sh
```

## 文档索引

- `AGENTS.md`
- `docs/skill-specs/README.md`
- `docs/skill-qa-checklist.md`
- `docs/references/README.md`
