#!/usr/bin/env bash
# _meta/test-project-gate.sh — exercises _meta/verify-project.sh against synthetic projects,
# to prove the gate knows how to say YES and how to say NO.
#
# Why: a gate that is never exercised is a promise. An audit found verify-project.sh printing
# three ✓ over things it had never evaluated (an unreadable phase falling back to F0) and
# accepting a genesis.md that was the unedited template — with CI green from start to finish,
# because CI only ever ran the FRAMEWORK gate, never the PROJECT gate.
#
# Usage:
#   bash _meta/test-project-gate.sh [path-to-framework-copy]
#     with no argument: uses the tree this script lives in (a working clone)
#     with an argument: uses that copy — this is how release.yml runs it INSIDE the extracted
#     ZIP, the only tree that proves anything about what projects actually receive.
#
# Exits 1 if any case does not behave as expected.

set -uo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK="${1:-$(cd "$AQUI/.." && pwd)}"
BASE="$(mktemp -d)"
trap 'rm -rf "$BASE"' EXIT

falhas=0
falha() { printf '✗ %s\n' "$*"; falhas=$((falhas + 1)); }
ok() { printf '✓ %s\n' "$*"; }

# Builds a synthetic project: $1 = name, $2 = declared phase, $3 = "compliant"|"deviant"
constroi() {
  local raiz="$BASE/$1" fase="$2" tipo="$3"
  mkdir -p "$raiz/product/99-records"
  # The framework copy the project uses is the one under test.
  mkdir -p "$raiz/Maestro"
  ( cd "$FRAMEWORK" && tar --exclude=.git --exclude=.github -cf - . ) | ( cd "$raiz/Maestro" && tar -xf - )

  cat > "$raiz/STATE.md" <<EOF
# STATE — synthetic project ($tipo)

| Field | Value |
| --- | --- |
| Current phase | $fase |
| Framework version | (fixture) |
| Upstream framework repository | (fixture) |

## Historical log
- $(date +%F) — project-gate fixture.
EOF
  : > "$raiz/FRAMEWORK-IMPROVEMENTS.md"
  : > "$raiz/CLAUDE.md"

  if [ "$tipo" = "compliant" ]; then
    # Phase F3 closed ⇒ the gate demands a trace of F1 and F2, and nothing else.
    mkdir -p "$raiz/product/00-discovery" "$raiz/product/01-requirements"
    echo '# Discovery' > "$raiz/product/00-discovery/context.md"
    echo '# Requirements' > "$raiz/product/01-requirements/functional.md"
    # Genesis with one REAL row (no placeholders): this is what the gate must tell apart.
    cat > "$raiz/product/99-records/genesis.md" <<'EOF'
# Genesis

| Phase | Date | Sessions | AI cost | Rework | Blockers | Gate | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| F1 | 2026-01-15 | 3 | 4.20 € | 1 | none | passed | fixture |
EOF
  fi
  printf '%s' "$raiz"
}

corre() { ( cd "$1" && bash Maestro/_meta/verify-project.sh 2>&1 ); }

printf 'Project gate under test: %s/_meta/verify-project.sh\n\n' "$FRAMEWORK"

# ---------------------------------------------------------------------------
# Case 1 — a project that FOLLOWS the process: the gate must approve.
# ---------------------------------------------------------------------------
r=$(constroi compliant "F3 — Architecture" compliant)
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -eq 0 ]; then
  ok "compliant project: approved (exit 0)"
else
  falha "compliant project REJECTED (exit $codigo) — the gate fails those who follow the process:"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 2 — a project declaring an advanced phase with no trace at all: must fail.
# ---------------------------------------------------------------------------
r=$(constroi deviant "F8 — Launch" deviant)
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'NO TRACE'; then
  ok "deviant project: rejected for missing traces (exit $codigo)"
else
  falha "deviant project APPROVED, or rejected for another reason (exit $codigo) — blind gate:"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 3 — unreadable phase: the gate must NOT print ✓ over what it never evaluated.
# ---------------------------------------------------------------------------
r=$(constroi unreadable "Launch (pre-production)" deviant)
saida=$(corre "$r"); codigo=$?
if printf '%s' "$saida" | grep -q 'closed-phase artifacts left a trace'; then
  falha "unreadable phase: the gate printed ✓ over artifacts it never evaluated (fail-open)"
elif printf '%s' "$saida" | grep -q 'NOT VERIFIED'; then
  ok "unreadable phase: the gate says NOT VERIFIED instead of inventing green"
else
  falha "unreadable phase: unexpected behavior (exit $codigo)"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 4 — genesis that is the unedited template: placeholders are not measurements.
# ---------------------------------------------------------------------------
r=$(constroi placeholders "F3 — Architecture" deviant)
mkdir -p "$r/product/00-discovery" "$r/product/01-requirements"
echo '# x' > "$r/product/00-discovery/context.md"
echo '# y' > "$r/product/01-requirements/functional.md"
cp "$FRAMEWORK/templates/project/GENESIS.md.template" "$r/product/99-records/genesis.md"
saida=$(corre "$r"); codigo=$?
if printf '%s' "$saida" | grep -qE 'genesis dossier tracks the phases \([1-9]'; then
  falha "genesis: the gate counted unedited template rows as measured phases"
elif printf '%s' "$saida" | grep -q 'unfilled row'; then
  ok "genesis: {{...}} placeholders flagged, not counted as measurement"
else
  falha "genesis: unexpected behavior (exit $codigo)"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

printf '\n'
if [ "$falhas" -gt 0 ]; then
  printf '✗ The project gate FAILED its own test: %d case(s).\n' "$falhas"
  exit 1
fi
printf '✓ Project gate exercised: approves those who follow, fails those who deviate, invents no green.\n'
