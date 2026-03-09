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

require_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    pass "found $path"
  else
    fail "missing $path"
  fi
}

reject_path() {
  local path="$1"
  local label="$2"
  if [[ -e "$path" ]]; then
    fail "$label"
  else
    pass "$label"
  fi
}

reject_pattern_in_paths() {
  local pattern="$1"
  local label="$2"
  shift 2
  if rg -n --fixed-strings --hidden --glob '!/.git' -- "$pattern" "$@" >/dev/null; then
    fail "$label"
  else
    pass "$label"
  fi
}

run_check() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

for path in \
  "AGENTS.md" \
  "README.md" \
  "docs/references/README.md" \
  "docs/skill-qa-checklist.md" \
  "docs/skill-specs/README.md"
do
  require_file "$path"
done

require_dir ".agents/skills"

for path in \
  ".agents/skills/bb-code-review/SKILL.md" \
  ".agents/skills/jira-commit/SKILL.md" \
  ".agents/skills/worktree/SKILL.md"
do
  require_file "$path"
done

reject_path "plugins" "plugins directory removed"
reject_path ".codex" ".codex directory removed"
reject_path ".claude-plugin" ".claude-plugin directory removed"
reject_path "config/skill-targets.json" "target manifest removed"
reject_path "config/skill-targets.schema.json" "target manifest schema removed"
reject_path "scripts/render_skills.py" "renderer removed"
reject_path ".claude/CLAUDE.md" "repo CLAUDE.md removed"

run_check "canonical skill packages validate" python3 - <<'PY'
import re
import sys
from pathlib import Path

root = Path(".").resolve()
skill_root = root / ".agents" / "skills"
skills = sorted(path for path in skill_root.iterdir() if path.is_dir())

errors: list[str] = []

if not skills:
    errors.append("no skill packages found under .agents/skills")

for skill_dir in skills:
    skill_path = skill_dir / "SKILL.md"
    if not skill_path.is_file():
        errors.append(f"missing SKILL.md: {skill_path.relative_to(root)}")
        continue

    text = skill_path.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n\n?(.*)$", text, re.S)
    if not match:
        errors.append(f"invalid frontmatter: {skill_path.relative_to(root)}")
        continue

    frontmatter_text, body = match.groups()
    meta: dict[str, str] = {}
    for line in frontmatter_text.splitlines():
        if not line.strip():
            continue
        key, sep, value = line.partition(":")
        if not sep:
            errors.append(f"invalid frontmatter line in {skill_path.relative_to(root)}: {line}")
            continue
        meta[key.strip()] = value.strip().strip('"')

    expected_keys = {"name", "description"}
    if set(meta) != expected_keys:
        errors.append(
            f"{skill_path.relative_to(root)} frontmatter keys must be exactly "
            f"{sorted(expected_keys)}, found {sorted(meta)}"
        )
        continue

    if meta["name"] != skill_dir.name:
        errors.append(f"{skill_path.relative_to(root)} name must equal directory name")

    if not meta["description"].startswith("Use when"):
        errors.append(f"{skill_path.relative_to(root)} description must start with 'Use when'")

    for link in re.findall(r"\]\(([^)]+)\)", body):
        if link.startswith(("http://", "https://", "#")):
            continue
        local_target = link.split("#", 1)[0]
        if not local_target:
            continue
        target = (skill_dir / local_target).resolve()
        try:
            target.relative_to(skill_dir.resolve())
        except ValueError:
            errors.append(f"{skill_path.relative_to(root)} references file outside skill package: {link}")
            continue
        if not target.exists():
            errors.append(f"{skill_path.relative_to(root)} references missing file: {link}")

if errors:
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    raise SystemExit(1)
PY

run_check "README documents breaking change" rg -n --fixed-strings "本仓库已移除这些直接使用方式" README.md

reject_pattern_in_paths ".codex/" "no active .codex references remain in current architecture docs or skills" \
  AGENTS.md docs/skill-specs/README.md .agents
reject_pattern_in_paths ".claude-plugin/" "no active .claude-plugin references remain in current architecture docs or skills" \
  AGENTS.md docs/skill-specs/README.md .agents
reject_pattern_in_paths "plugins/" "no active plugins references remain in current architecture docs or skills" \
  AGENTS.md docs/skill-specs/README.md .agents
reject_pattern_in_paths "claude plugin " "no active Claude plugin commands remain outside migration notes" \
  AGENTS.md docs/skill-specs/README.md docs/references/README.md docs/skill-qa-checklist.md .agents
reject_pattern_in_paths ".claude/CLAUDE.md" "no repo CLAUDE.md references remain in active docs or skills" \
  AGENTS.md docs/skill-specs/README.md .agents
reject_pattern_in_paths ".claude/" "worktree and review skills no longer depend on .claude/" \
  .agents/skills/bb-code-review/SKILL.md \
  .agents/skills/worktree/SKILL.md \
  .agents/skills/worktree/references/EXAMPLES.md \
  .agents/skills/worktree/references/WORKFLOW.md
reject_pattern_in_paths "CLAUDE.md" "review skill no longer depends on CLAUDE.md" \
  .agents/skills/bb-code-review/SKILL.md
reject_pattern_in_paths ".codex/" "worktree skill no longer depends on .codex/" \
  .agents/skills/worktree/SKILL.md \
  .agents/skills/worktree/references/EXAMPLES.md \
  .agents/skills/worktree/references/WORKFLOW.md

if [[ "$failures" -ne 0 ]]; then
  printf '\n%s check(s) failed.\n' "$failures" >&2
  exit 1
fi

printf '\nAll skill consistency checks passed.\n'
