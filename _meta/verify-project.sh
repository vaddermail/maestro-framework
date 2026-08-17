#!/usr/bin/env bash
# _meta/verify-project.sh — the PROJECT gate ("Gates, not gut feelings", applied to execution).
# verify.sh validates the framework; this one validates whether a project is FOLLOWING it:
# foundation in place, artifacts present for the phases STATE.md declares closed, fresh memory,
# genesis up to date, copy intact. Run from the project root (or from anywhere — it repositions
# itself):
#   bash Maestro/_meta/verify-project.sh
# Exits with 1 on failures. Warnings do not block, but stay visible. Natural hook: end of each
# session (START-HERE.md §2.5) and the project CI (pipelines/ci-quality.md).
set -uo pipefail
cd "$(dirname "$0")/../.."

falhas=0; avisos=0
falha() { printf '✗ %s\n' "$*"; falhas=$((falhas + 1)); }
aviso() { printf '! %s\n' "$*"; avisos=$((avisos + 1)); }
ok() { printf '✓ %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 0. Is this the root of a Maestro project?
# ---------------------------------------------------------------------------
if [ ! -f STATE.md ] || [ ! -d Maestro ]; then
  printf '✗ project root not found (expected STATE.md and Maestro/ in %s)\n' "$(pwd)"
  printf '  Run from the project: bash Maestro/_meta/verify-project.sh\n'
  exit 1
fi

# ---------------------------------------------------------------------------
# 1. F0 foundation: the files W00 creates exist
# ---------------------------------------------------------------------------
fund_ko=0
for f in STATE.md FRAMEWORK-IMPROVEMENTS.md product; do
  [ -e "$f" ] || { falha "MISSING FOUNDATION: $f (workflows/W00-project-kickoff.md)"; fund_ko=1; }
done
[ -f CLAUDE.md ] || aviso "no CLAUDE.md at the root (or the tool's equivalent — adapters/)"
[ "$fund_ko" -eq 0 ] && ok "F0 foundation in place"

# ---------------------------------------------------------------------------
# 2. STATE.md declares the essentials: phase, framework version, upstream repository
# ---------------------------------------------------------------------------
fase=$(grep -iE 'fase atual|current phase' STATE.md | grep -oE 'F[0-9]' | head -1 || true)
if [ -z "$fase" ]; then
  falha "STATE.md does not declare the current phase (F0–F9)"
  fase=F0
else
  ok "declared phase: $fase"
fi
grep -qiE 'versão da framework' STATE.md && ok "framework version recorded" \
  || falha "STATE.md missing the copied framework version (precondition for syncing)"
grep -qiE 'repositório da framework-mãe|framework-mãe|upstream framework repository' STATE.md \
  && ok "upstream repository recorded" \
  || aviso "STATE.md missing the upstream repository (the destination of improvement reports)"

# ---------------------------------------------------------------------------
# 3. Artifacts per closed phase: if the current phase is FN, the earlier ones left a trace
#    (the prototype profile collapses folders into a single dossier — any content accepted)
# ---------------------------------------------------------------------------
tem_conteudo() { [ -d "$1" ] && [ -n "$(find "$1" -type f -name '*.md' 2>/dev/null | head -1)" ]; }
n=${fase#F}
art_ko=0
verifica_fase() { # $1=minimum current-phase number  $2=folder  $3=description
  [ "$n" -ge "$1" ] || return 0
  tem_conteudo "$2" || { falha "NO TRACE of $3 ($2/) with current phase $fase"; art_ko=1; }
}
verifica_fase 2 product/00-discovery "F1 Discovery"
verifica_fase 3 product/01-requirements "F2 Requirements"
verifica_fase 4 product/02-architecture "F3 Architecture"
verifica_fase 5 product/03-experience "F4 Experience"
verifica_fase 6 product/04-specification "F5 Specification"
verifica_fase 8 product/05-security "F7 Quality & Security"
[ "$n" -ge 4 ] && { tem_conteudo product/02-architecture/decisions \
  || aviso "no ADRs in product/02-architecture/decisions/ with the architecture closed"; }
[ "$art_ko" -eq 0 ] && ok "closed-phase artifacts left a trace"

# ---------------------------------------------------------------------------
# 4. Fresh memory: the last STATE.md update is not fossilized
# ---------------------------------------------------------------------------
ult=$(grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' STATE.md | sort -r | head -1 || true)
if [ -n "$ult" ] && command -v date >/dev/null; then
  dias=$(( ( $(date +%s) - $(date -d "$ult" +%s 2>/dev/null || echo 0) ) / 86400 ))
  if [ "$dias" -gt 45 ]; then
    aviso "STATE.md with no dates for $dias days (last: $ult) — memory fossilizing?"
  else
    ok "memory alive (most recent date in STATE: $ult)"
  fi
fi

# ---------------------------------------------------------------------------
# 5. Improvement loop: submissions accompany the heavy phase closures
# ---------------------------------------------------------------------------
if [ -f FRAMEWORK-IMPROVEMENTS.md ]; then
  if [ "$n" -ge 8 ] && ! grep -qE '#[0-9]+' FRAMEWORK-IMPROVEMENTS.md; then
    aviso "phase $fase with no submission in §Report log (the checklist says to submit at the F7/P6b close)"
  else
    ok "improvement loop consistent with the phase"
  fi
fi

# ---------------------------------------------------------------------------
# 6. Genesis dossier: one line per closed phase (the measurement of the promise)
# ---------------------------------------------------------------------------
if [ -f product/99-records/genesis.md ]; then
  linhas=$(grep -cE '^\| F[0-9] ' product/99-records/genesis.md || true)
  if [ "$n" -ge 2 ] && [ "${linhas:-0}" -eq 0 ]; then
    aviso "genesis.md with no closed-phase lines (templates/project/GENESIS.md.template)"
  else
    ok "genesis dossier tracks the phases ($linhas line(s))"
  fi
else
  [ "$n" -ge 1 ] && aviso "no product/99-records/genesis.md — the ecosystem curve stays blind to this project"
fi

# ---------------------------------------------------------------------------
# 7. Framework copy integrity (when it came from a release with a manifest)
# ---------------------------------------------------------------------------
if [ -f Maestro/_meta/SHA256SUMS ]; then
  if bash Maestro/_meta/verify.sh --integridade >/dev/null 2>&1; then
    ok "framework copy intact (identical to the origin release)"
  else
    falha "framework copy DIVERGES from the release (bash Maestro/_meta/verify.sh --integridade)"
  fi
else
  aviso "copy without an integrity manifest (before 2.5.0, or an upstream clone)"
fi

# ---------------------------------------------------------------------------
printf '\n'
if [ "$falhas" -gt 0 ]; then
  printf '✗ Project OFF the process: %d failure(s), %d warning(s).\n' "$falhas" "$avisos"
  exit 1
fi
printf '✓ Project following the process (%d warning(s)).\n' "$avisos"
