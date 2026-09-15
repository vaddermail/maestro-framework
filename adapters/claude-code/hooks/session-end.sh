#!/usr/bin/env bash
# adapters/claude-code/hooks/session-end.sh — Maestro's Stop hook: the mechanical net of the closing
# protocol (START-HERE.md §2.5), the most skipped step because it is read only once, in F0.
# Stop fires at the end of EVERY response of the main session — not "at the end of the session"; hence:
#   stop_hook_active = true      → exit 0 (it already blocked once; never loops)
#   no changes to commit         → silent exit 0 (reading, conversation, intermediate answer)
#   changes outside STATE.md     → block «Session touched N files without updating STATE.md — …»
#   and STATE.md is not among them
#   otherwise                    → run bash Maestro/_meta/verify-project.sh (no network:
#                                  MAESTRO_SEM_REDE=1); if it fails, block once with the ✗ lines
# With no git or no STATE.md nothing is evaluated (exit 0). Claude Code contract assumed (valid as of
# 2026-09): stdin JSON with "stop_hook_active"; block on stdout {"decision":"block","reason":…}.
set -u
entrada=""; [ -t 0 ] || entrada=$(cat 2>/dev/null || true)
printf '%s' "$entrada" | tr -d '\n' | grep -qE '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>/dev/null || exit 0

bloqueia() { # $1 = reason on one line
  m=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"decision":"block","reason":"%s"}\n' "$m"
  exit 0
}

git rev-parse --git-dir >/dev/null 2>&1 || exit 0
alterados=$(git status --porcelain 2>/dev/null | sed 's/^...//; s/.* -> //')
[ -n "$alterados" ] || exit 0
n=$(printf '%s\n' "$alterados" | grep -vcE '(^|/)STATE\.md$')
estado_tocado=0
printf '%s\n' "$alterados" | grep -qE '(^|/)STATE\.md$' && estado_tocado=1

if [ "$n" -gt 0 ] && [ "$estado_tocado" -eq 0 ]; then
  bloqueia "Session touched $n file(s) without updating STATE.md — Maestro/START-HERE.md §2.5: done (with evidence) / in progress / up next / pending decisions / lessons; then bash Maestro/_meta/verify-project.sh"
fi

if [ -f STATE.md ] && [ -f Maestro/_meta/verify-project.sh ]; then
  export MAESTRO_SEM_REDE=1
  saida=$(bash Maestro/_meta/verify-project.sh 2>&1); rc=$?
  if [ "$rc" -ne 0 ]; then
    falhas=$(printf '%s\n' "$saida" | grep '^✗' | head -6 | tr '\n' '|' | sed 's/|$//; s/|/ | /g')
    bloqueia "Project gate FAILED (bash Maestro/_meta/verify-project.sh): $falhas — fix it, or record the derogation in STATE.md, before finishing"
  fi
fi
exit 0
