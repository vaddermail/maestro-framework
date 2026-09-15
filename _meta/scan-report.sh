#!/usr/bin/env bash
# _meta/scan-report.sh — the mechanical sweep that playbooks/report-framework-improvements.md
# (step 2) and playbooks/framework-curation.md (step 2) require before the only irreversible step
# of the loop: publishing a report as an issue. It looks for secret and personal-data patterns
# and, optionally, a list of forbidden terms (one regex per line, `#` comments — the same format
# as the upstream _meta/FORBIDDEN-TERMS; in a project it is instantiated from
# templates/project/FORBIDDEN-TERMS.template and is NEVER sent).
#
# Usage:
#   bash Maestro/_meta/scan-report.sh <file | -> [terms-list]
# Exits 0 when clean; 1 with hits — prints file:line and the NAME of the pattern, never the value.
set -uo pipefail
alvo="${1:-}"; lista="${2:-}"
[ -n "$alvo" ] || { printf 'Usage: scan-report.sh <file | -> [terms-list]\n'; exit 2; }
if [ "$alvo" = "-" ]; then tmp=$(mktemp); cat > "$tmp"; alvo="$tmp"; nome="(stdin)"; else nome="$alvo"; fi
[ -f "$alvo" ] || { printf '✗ file not found: %s\n' "$alvo"; exit 2; }

hits=0
# Exclusions: variable placeholders and domains reserved for examples are not leaks.
excl='\$\{|\{\{|example\.(com|org|net)|exemplo\.(pt|com)|\.invalid\b|\.example\b'
procura() { # $1 = pattern name  $2 = regex  $3 = 'i' (case-insensitive) or 'c' (case-sensitive)
  local flag='-i'; [ "${3:-i}" = c ] && flag=''
  while IFS= read -r l; do
    [ -n "$l" ] || continue
    printf '✗ %s — %s:%s\n' "$1" "$nome" "${l%%:*}"; hits=$((hits + 1))
  done < <(grep -na $flag -E -e "$2" "$alvo" | grep -viE -e "$excl" | cut -d: -f1)
}
# Binary file: grep without -a only warned on stderr and the sweep reported "clean".
if grep -qI . "$alvo" 2>/dev/null; then :; else
  printf '✗ binary or empty file — not scannable: %s\n' "$nome"; [ -n "${tmp:-}" ] && rm -f "$tmp"; exit 1
fi
procura 'API key / token'                '(sk|rk)_(live|test)_[A-Za-z0-9]{8,}|sk-(proj|ant)-[A-Za-z0-9_-]{16,}|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|glpat-[A-Za-z0-9_-]{16,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,}|npm_[A-Za-z0-9]{30,}|dckr_pat_[A-Za-z0-9_-]{16,}|hooks\.slack\.com/services/' c
procura 'private key'                    '-----BEGIN [A-Z ]*PRIVATE KEY'
procura 'JWT'                            'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.' c
procura 'credential in a URL'            '://[^/[:space:]:]+:[^@[:space:]]+@'
procura 'secret in the clear'            '(password|passwd|palavra-passe|senha|api[_-]?key|client[_-]?secret|secret[_-]?key|access[_-]?token|auth[_-]?token|AWS_SECRET_ACCESS_KEY)[[:space:]]*[:=][[:space:]]*[^[:space:]{$]{8,}'
procura 'e-mail'                         '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
procura 'IBAN'                           '\b[A-Z]{2}[0-9]{2}[0-9A-Z ]{11,30}\b' c
procura 'national ID / tax number'       '\b(NIF|NIB|NISS|SSN|VAT|taxpayer)\b.{0,8}[0-9]{9,21}'
procura 'phone number'                   '(\+[0-9]{1,3}|00[0-9]{1,3})[[:space:]]?[0-9]{3}[[:space:]]?[0-9]{3}[[:space:]]?[0-9]{3}'
procura 'private IP'                     '\b(10\.[0-9]{1,3}|192\.168|172\.(1[6-9]|2[0-9]|3[01]))\.[0-9]{1,3}\.[0-9]{1,3}\b(/[0-9]+)?' c
if [ -n "$lista" ]; then
  if [ -f "$lista" ]; then
    i=0
    while IFS= read -r termo; do
      i=$((i + 1)); case "$termo" in '' | \#*) continue ;; esac
      procura "forbidden term no. $i in the list" "$termo"
    done < "$lista"
  else
    printf '! terms list not found: %s (sweeping secrets/PII only)\n' "$lista"
  fi
fi
[ -n "${tmp:-}" ] && rm -f "$tmp"
if [ "$hits" -gt 0 ]; then
  printf '✗ sweep: %d hit(s) — edit before sending (playbooks/report-framework-improvements.md §Rollback).\n' "$hits"
  exit 1
fi
printf '✓ sweep clean: no secret patterns, no personal data%s.\n' "$([ -n "$lista" ] && printf ', no forbidden terms')"
