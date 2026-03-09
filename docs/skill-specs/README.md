# Skill Architecture

Skill 的唯一人工维护入口是 `.agents/skills/`。

## 当前结构

- canonical source：`.agents/skills/<skill>/`
- repo guidance：`AGENTS.md`
- external references：`docs/references/`

## 维护流程

1. 修改 `.agents/skills/<skill>/SKILL.md` 或其 `references/`
2. 如需 supporting files，直接保存在对应 skill package 内
3. 运行 `bash scripts/check-skill-consistency.sh`

外部参考资料位于 `docs/references/`。
