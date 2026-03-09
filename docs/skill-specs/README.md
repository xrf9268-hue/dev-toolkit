# Skill Canonical Specs

这些文档是仓库内 Skill 契约的单一来源。

维护规则：

1. 先更新 `docs/skill-specs/*.md`
2. 再同步对应的 Claude Code 插件 Skill、Codex Skill 和插件 README
3. 最后运行：
   - `bash scripts/check-skill-consistency.sh`
   - `claude plugin validate .`

外部参考资料位于 `docs/references/`。

每份 spec 都应覆盖：

- 命令映射
- 触发场景与非触发场景
- 参数与环境变量
- 关键行为约束
- 需要同步的派生文件
