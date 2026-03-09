# Skill QA Checklist

用于人工检查 `.agents/skills/` 的触发描述和正文行为是否一致。

## bb-code-review

Should trigger:

- `审查这个 Bitbucket PR：https://$BITBUCKET_HOST/projects/FOO/repos/bar/pull-requests/123`
- `先 dry run 预览一下这个 Bitbucket PR 的评论`
- `用 90 阈值 review 这个 Bitbucket PR`

Should not trigger:

- `解释 Bitbucket pull request diff API`
- `帮我 review 当前工作区还没提交的改动`
- `总结一下这个 PR 描述，不要做代码审查`

## jira-commit

Should trigger:

- `帮我提交这些改动`
- `用 PROJ-12345 创建一个 commit`
- `commit 一下这个分支上的修改`
- `直接提交吧，不要带 JIRA`

Should not trigger:

- `帮我把刚才的提交推到远程`
- `解释一下团队的 commit 规范`
- `给我生成一个 commit message 模板，不要真的提交`

## worktree

Should trigger:

- `给我建个 worktree 用来做 feature-auth`
- `把当前未提交改动迁到一个新的 worktree`
- `我需要一个并行开发环境，基于 develop 开新分支`
- `别切当前分支，帮我开个隔离目录继续做支付重构`
- `把 hotfix-123 那个 worktree 里的未提交改动迁到新的 release-hotfix`
- `我想并行做两个需求，给我准备一个新的独立工作区`

Should not trigger:

- `解释一下 git worktree 是什么`
- `切换到 develop 分支`
- `帮我删除旧的 worktree`
- `列出当前有哪些 worktree`
