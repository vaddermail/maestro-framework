#!/usr/bin/env bash
# adapters/claude-code/hooks/artifact-guard.sh — Maestro's PreToolUse hook (matcher Edit|Write|MultiEdit).
# It reads tool_input.file_path from stdin and decides:
#   under Maestro/                    → deny  (the framework copy is read-only; the friction is logged
#                                              in FRAMEWORK-IMPROVEMENTS.md §4 and goes upstream)
#   under product/ outside the        → ask   (the canonical tree is core/artifact-protocol.md;
#   canonical tree (1st segment)                the human confirms or corrects the path)
#   everything else                   → no output (allow)
# It is the real net for Maestro/ — the argument patterns of permissions are fragile; a hook is not.
# Unreadable stdin or no file_path → exit 0 with no output. Declared fail-open: a broken hook never
# blocks the work — the backstops are `verify.sh --integrity` and the project gate.
# Claude Code contract assumed (valid as of 2026-09): stdin JSON {"tool_name","tool_input":{"file_path"}};
# decision on stdout {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":…}}.
set -u
entrada=""; [ -t 0 ] || entrada=$(cat 2>/dev/null || true)
caminho=$(printf '%s' "$entrada" | tr -d '\n' | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -n "$caminho" ] || exit 0

# Normalize: backslashes (JSON escapes them doubled) → /, root with no trailing slash, root prefix stripped
caminho=$(printf '%s' "$caminho" | sed 's/\\\\/\\/g' | tr '\\' '/')
raiz="${CLAUDE_PROJECT_DIR:-$(pwd)}"; raiz="${raiz%/}"
rel="$caminho"
case "$rel" in "$raiz"/*) rel="${rel#"$raiz"/}" ;; esac
rel="${rel#./}"

decide() { # $1 = allow|deny|ask, $2 = reason (no double quotes)
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$1" "$2"
}

case "$rel" in
  Maestro/* | */Maestro/*)
    decide deny "Maestro/ is the read-only copy of the framework: it is never edited in the project (Maestro/playbooks/sync-framework.md; syncing replaces the copy through the shell, not through Edit). Log the friction in FRAMEWORK-IMPROVEMENTS.md §4 Friction and omissions — the fix goes upstream through the report circuit."
    ;;
  product/*)
    resto="${rel#product/}"
    case "$resto" in
      */*)
        seg="${resto%%/*}"
        case "$seg" in
          00-discovery | 01-requirements | 02-architecture | 03-experience | 04-specification | 05-security | 06-tests | 07-operations | 08-documentation | 99-records) ;;
          *) decide ask "product/$seg/ is outside the canonical tree (Maestro/core/artifact-protocol.md §The project's product/ tree: 00-discovery … 08-documentation, 99-records). An artifact outside the tree is an edge of the graph that no agent resolves — confirm the path or use the canonical folder." ;;
        esac
        ;;
    esac
    ;;
esac
exit 0
