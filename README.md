# Dev Toolkit

标准唯一 Skill 仓库，按 Agent Skills 风格维护可复用的 skill package。

## 仓库定位

这个仓库只保留 canonical skill source：

- `.agents/skills/bb-code-review/`
- `.agents/skills/jira-commit/`
- `.agents/skills/worktree/`

面向特定客户端的发布，应在其他仓库、release artifact 或独立发布流程中完成。

## Skills

| Skill | 用途 |
|------|------|
| `bb-code-review` | 审查 Bitbucket Pull Request，输出预览结果或发布评论 |
| `jira-commit` | 生成符合团队规范的提交；如能解析到 JIRA issue key 则自动附带前缀 |
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
- 仓库文档和目录结构保持 canonical-only

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
