#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found $path"
  else
    fail "missing $path"
  fi
}

require_literal() {
  local path="$1"
  local needle="$2"
  local label="$3"
  if grep -Fq -- "$needle" "$path"; then
    pass "$label"
  else
    fail "$label"
  fi
}

reject_pattern_in_file() {
  local path="$1"
  local pattern="$2"
  local label="$3"
  if rg -n --fixed-strings --quiet -- "$pattern" "$path"; then
    fail "$label"
  else
    pass "$label"
  fi
}

reject_pattern_in_paths() {
  local pattern="$1"
  local label="$2"
  shift 2
  if rg -n --fixed-strings --hidden -- "$pattern" "$@" >/dev/null; then
    fail "$label"
  else
    pass "$label"
  fi
}

for path in \
  "docs/skill-specs/README.md" \
  "docs/skill-specs/bb-code-review.md" \
  "docs/skill-specs/jira-commit.md" \
  "docs/skill-specs/worktree.md" \
  "docs/skill-qa-checklist.md"
do
  require_file "$path"
done

reject_pattern_in_paths ".Codex-plugin" "legacy .Codex-plugin paths removed" \
  AGENTS.md README.md .claude/CLAUDE.md
reject_pattern_in_paths "Codex plugin validate" "legacy Codex plugin validate command removed" \
  AGENTS.md README.md .claude/CLAUDE.md

for path in \
  "plugins/bb-code-review/skills/bb-review/SKILL.md" \
  "plugins/git-worktree/skills/worktree/SKILL.md" \
  "plugins/jira-commit/skills/jira-commit/SKILL.md" \
  ".codex/skills/bb-code-review/SKILL.md" \
  ".codex/skills/jira-commit/SKILL.md" \
  ".codex/skills/worktree/SKILL.md"
do
  require_literal "$path" "Use when" "$path frontmatter includes trigger-oriented description"
done

require_literal ".codex/skills/bb-code-review/SKILL.md" 'argument-hint: "<PR_URL> [--dry-run] [--threshold N]"' "Codex bb-code-review argument-hint includes threshold"
require_literal ".codex/skills/jira-commit/SKILL.md" 'argument-hint: "[JIRA编号（可选）]"' "Codex jira-commit argument-hint present"
require_literal ".codex/skills/worktree/SKILL.md" 'argument-hint: "[branch-name] [--stash] [--from <worktree>] [--base <branch>]"' "Codex worktree argument-hint present"

require_literal ".codex/skills/bb-code-review/SKILL.md" '$bb-code-review' "Codex bb-code-review uses $ command"
require_literal ".codex/skills/jira-commit/SKILL.md" '$jira-commit' "Codex jira-commit uses $ command"
require_literal ".codex/skills/worktree/SKILL.md" '$worktree' "Codex worktree uses $ command"

reject_pattern_in_file ".codex/skills/bb-code-review/SKILL.md" "/bb-code-review" "Codex bb-code-review no longer uses slash command"

for path in \
  "plugins/jira-commit/skills/jira-commit/SKILL.md" \
  ".codex/skills/jira-commit/SKILL.md" \
  "plugins/jira-commit/README.md"
do
  reject_pattern_in_file "$path" "允许无前缀提交" "$path forbids no-prefix fallback"
  reject_pattern_in_file "$path" "无 JIRA 时" "$path removes no-JIRA example"
done

require_literal "README.md" "| 工具/包名 | Claude Code 命令 | Codex CLI 命令 |" "README command mapping table present"
require_literal "AGENTS.md" "docs/skill-specs/" "AGENTS documents canonical skill specs"
require_literal ".claude/CLAUDE.md" "docs/skill-specs/" "CLAUDE.md documents canonical skill specs"

if [[ "$failures" -ne 0 ]]; then
  printf '\n%s check(s) failed.\n' "$failures" >&2
  exit 1
fi

printf '\nAll skill consistency checks passed.\n'
