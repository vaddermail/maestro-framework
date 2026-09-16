#!/usr/bin/env bash
# _meta/test-project-gate.sh — exercises _meta/verify-project.sh against synthetic projects,
# to prove the gate knows how to say YES and how to say NO.
#
# Why: a gate that is never exercised is a promise. An audit found verify-project.sh printing
# three ✓ over things it had never evaluated (an unreadable phase falling back to F0) and
# accepting a genesis.md that was the unedited template — with CI green from start to finish,
# because CI only ran the FRAMEWORK gate, never the PROJECT gate.
#
# Usage:
#   bash _meta/test-project-gate.sh [path-to-the-framework-copy]
#     without an argument: uses the tree this script lives in (a working clone)
#     with an argument: uses that copy — this is how release.yml runs it INSIDE the extracted
#     ZIP, which is the only tree that proves anything about what projects receive.
#
# Exits 1 if any case does not behave as expected. Cases: conforming, deviant, unreadable phase,
# unfilled genesis, first day, unfilled STATE, edited copy, CRLF, draft spec, no Q&A/gate records,
# future date, P8 without human approval, scripts with CRLF, adoption (F9, mid-way, from scratch,
# inconsistent, without a phase), memory ceiling, pending decisions (age, no date, batch).

# Line-ending guard: a copy with CRLF (Windows) failed with cryptic errors and the gate never ran.
# The `#` at the end of the next line makes it immune to the very \r it detects.
case "$(head -c 4000 "$0")" in *$'\r'*) printf '✗ %s has CRLF line endings — restore with git checkout (the copy .gitattributes prevents the conversion) or: sed -i "s/\\r$//" %s\n' "$0" "$0"; exit 2 ;; esac #
set -uo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK="${1:-$(cd "$AQUI/.." && pwd)}"
BASE="$(mktemp -d)"
trap 'rm -rf "$BASE"' EXIT

falhas=0
falha() { printf '✗ %s\n' "$*"; falhas=$((falhas + 1)); }
ok() { printf '✓ %s\n' "$*"; }

# Builds a synthetic project: $1 = name, $2 = declared phase, $3 = "conforming"|"deviant"
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
| Framework version | $(grep -oE 'Current version: [0-9.]+' "$FRAMEWORK/_meta/VERSION.md" | grep -oE '[0-9.]+$') |
| Upstream framework repository | (fixture — no org/repo; no network) |

## Historical log
- $(date +%F) — project-gate fixture.
EOF
  : > "$raiz/FRAMEWORK-IMPROVEMENTS.md"
  : > "$raiz/CLAUDE.md"

  if [ "$tipo" = "conforming" ]; then
    # Phase F3 closed ⇒ the gate requires a trace of F1 and F2, and nothing else.
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
    # Question history (MANIFESTO §2) and records of the closed gates (P0–P2), no placeholders.
    cat > "$raiz/product/01-requirements/questions-and-answers.md" <<'EOF'
# Questions and answers

## Q-001 · Effort profile  [phase F0]
**Answer:** internal product. Status: answered.
EOF
    mkdir -p "$raiz/product/99-records/gates"
    for k in 0 1 2; do
      printf '# Gate P%s — fixture — 2026-01-1%s\n\n> **Result:** passed\n> **Verified by:** fixture-reviewer\n> **Approved by (human):** user, 2026-01-1%s\n' "$k" "$k" "$k" \
        > "$raiz/product/99-records/gates/P${k}-2026-01-1${k}.md"
    done
  fi
  printf '%s' "$raiz"
}

corre() { ( cd "$1" && bash Maestro/_meta/verify-project.sh 2>&1 ); }

printf 'Project gate under test: %s/_meta/verify-project.sh\n\n' "$FRAMEWORK"

# ---------------------------------------------------------------------------
# Case 1 — a project that FOLLOWS the process: the gate must approve.
# ---------------------------------------------------------------------------
r=$(constroi conforming "F3 — Architecture" conforming)
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -eq 0 ]; then
  ok "conforming project: approved (exit 0)"
else
  falha "conforming project REJECTED (exit $codigo) — the gate fails whoever follows the process:"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 2 — a project declaring an advanced phase with no trace at all: must fail.
# ---------------------------------------------------------------------------
r=$(constroi deviant "F8 — Launch" deviant)
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'NO TRACE'; then
  ok "deviant project: rejected for the missing trace (exit $codigo)"
else
  falha "deviant project APPROVED, or rejected for another reason (exit $codigo) — blind gate:"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 3 — unreadable phase: the gate must NOT print ✓ over what it did not evaluate.
# ---------------------------------------------------------------------------
r=$(constroi unreadable "Launch (pre-production)" deviant)
saida=$(corre "$r"); codigo=$?
if printf '%s' "$saida" | grep -q 'closed-phase artifacts left a trace'; then
  falha "unreadable phase: the gate printed ✓ over artifacts it never evaluated (fail-open)"
elif printf '%s' "$saida" | grep -q 'NOT VERIFIED'; then
  ok "unreadable phase: the gate says NOT VERIFIED instead of inventing green"
else
  falha "unreadable phase: unexpected behaviour (exit $codigo)"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 4 — a genesis that is the unedited template: placeholders do not count as measurement.
# ---------------------------------------------------------------------------
r=$(constroi placeholders "F3 — Architecture" deviant)
mkdir -p "$r/product/00-discovery" "$r/product/01-requirements"
echo '# x' > "$r/product/00-discovery/context.md"
echo '# y' > "$r/product/01-requirements/functional.md"
cp "$FRAMEWORK/templates/project/GENESIS.md.template" "$r/product/99-records/genesis.md"
saida=$(corre "$r"); codigo=$?
if printf '%s' "$saida" | grep -qE 'genesis dossier tracks the phases \([1-9]'; then
  falha "genesis: the gate counted rows of the unedited template as measured phases"
elif printf '%s' "$saida" | grep -q 'unfilled row'; then
  ok "genesis: {{...}} placeholders flagged, not counted as measurement"
else
  falha "genesis: unexpected behaviour (exit $codigo)"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 5 — first day: F0 just instantiated (genesis still the template) must PASS.
# ---------------------------------------------------------------------------
r=$(constroi first-day "F0 — Kickoff" deviant)
cp "$FRAMEWORK/templates/project/GENESIS.md.template" "$r/product/99-records/genesis.md"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -eq 0 ] && ! printf '%s' "$saida" | grep -q 'NO TRACE'; then
  ok "first day (F0): approved without requiring a trace of phases that have not closed"
else
  falha "first day (F0): rejected (exit $codigo) — a project that just started must pass:"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 6 — a STATE.md that is the unfilled template: "{{F0–F9, …}}" is not "F0".
# ---------------------------------------------------------------------------
r=$(constroi unfilled "F0" deviant)
cp "$FRAMEWORK/templates/project/STATE.md.template" "$r/STATE.md"
saida=$(corre "$r"); codigo=$?
if printf '%s' "$saida" | grep -q 'declared phase: F0'; then
  falha "unfilled STATE: the gate read the placeholder {{F0–F9…}} as phase F0"
elif printf '%s' "$saida" | grep -q 'does not declare the current phase' && ! printf '%s' "$saida" | grep -qi 'adoption'; then
  ok "unfilled STATE: placeholders count neither as a declared phase nor as an adoption"
else
  falha "unfilled STATE: unexpected behaviour (exit $codigo)"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 7 — a locally edited framework copy: only provable with a manifest (release ZIP).
# ---------------------------------------------------------------------------
r=$(constroi edited "F3 — Architecture" conforming)
if [ -f "$r/Maestro/_meta/SHA256SUMS" ]; then
  printf '\n' >> "$r/Maestro/core/orchestrator.md"
  saida=$(corre "$r"); codigo=$?
  if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'DIVERGES'; then
    ok "edited copy: rejected on integrity (exit $codigo)"
  else
    falha "edited copy: not caught (exit $codigo)"
    printf '%s\n' "$saida" | sed 's/^/    /'
  fi
  # Case 7b — CRLF line endings (Windows with autocrlf): must flag it and say it is CRLF.
  r=$(constroi crlf "F3 — Architecture" conforming)
  sed 's/$/\r/' "$r/Maestro/core/orchestrator.md" > "$r/crlf.tmp" && mv "$r/crlf.tmp" "$r/Maestro/core/orchestrator.md"
  saida=$(corre "$r"); codigo=$?
  if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'CRLF'; then
    ok "copy with CRLF: rejected, and the reason names the line-ending conversion"
  else
    falha "copy with CRLF: not flagged, or flagged without an explanation (exit $codigo)"
    printf '%s\n' "$saida" | sed 's/^/    /'
  fi
else
  printf -- '— cases 7/7b (edited copy, CRLF): NOT APPLICABLE without a manifest (they run from the ZIP in release.yml)\n'
fi

# ---------------------------------------------------------------------------
# Case 8 — F6 with the specification still in draft: code before an approved spec must be flagged.
# ---------------------------------------------------------------------------
r=$(constroi draft-spec "F6 — Build" conforming)
mkdir -p "$r/product/02-architecture/decisions" "$r/product/03-experience" "$r/product/04-specification" "$r/product/06-tests"
echo '# ADR' > "$r/product/02-architecture/decisions/ADR-001-x.md"; echo '# UX' > "$r/product/03-experience/flows.md"
printf '# Spec\n\n> **State:** draft\n' > "$r/product/04-specification/module.md"; echo '# Tests' > "$r/product/06-tests/strategy.md"
saida=$(corre "$r")
if printf '%s' "$saida" | grep -q 'NO APPROVED SPECIFICATION'; then
  ok "draft spec in F6: flagged"
  sed 's/draft/approved/' "$r/product/04-specification/module.md" > "$r/spec.tmp" && mv "$r/spec.tmp" "$r/product/04-specification/module.md"
  saida=$(corre "$r")
  if printf '%s' "$saida" | grep -q 'NO APPROVED SPECIFICATION'; then
    falha "approved spec in F6: still flagged"
  else
    ok "approved spec in F6: accepted"
  fi
else
  falha "draft spec in F6: passed without a warning"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 9 — F3 with no question history and no gate records: both warnings must appear;
#          in the conforming project (which has them) neither may appear.
# ---------------------------------------------------------------------------
r=$(constroi no-qa "F3 — Architecture" deviant)
mkdir -p "$r/product/00-discovery" "$r/product/01-requirements"
echo '# x' > "$r/product/00-discovery/context.md"; echo '# y' > "$r/product/01-requirements/functional.md"
saida=$(corre "$r")
if printf '%s' "$saida" | grep -q 'NO question-and-answer HISTORY' && printf '%s' "$saida" | grep -q 'NO RECORD OF GATE P2'; then
  ok "F3 with no Q&A and no gate records: both flagged"
else
  falha "F3 with no Q&A and no gate records: warning(s) missing"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi
r=$(constroi conforming-2 "F3 — Architecture" conforming)
saida=$(corre "$r")
if printf '%s' "$saida" | grep -qE 'NO question-and-answer HISTORY|NO RECORD OF GATE'; then
  falha "conforming project: flagged for Q&A or gates it does have"
  printf '%s\n' "$saida" | sed 's/^/    /'
else
  ok "conforming project: Q&A and gate records recognized"
fi

# ---------------------------------------------------------------------------
# Case 10 — a future date in STATE.md (a deadline, a roadmap) is not an updated memory.
# ---------------------------------------------------------------------------
r=$(constroi future "F3 — Architecture" conforming)
printf -- '- 2099-12-31 — target launch date.\n' >> "$r/STATE.md"
saida=$(corre "$r")
if printf '%s' "$saida" | grep -q '2099'; then
  falha "future date: the gate took a future deadline for a memory update"
else
  ok "future date: ignored when computing live memory"
fi

# ---------------------------------------------------------------------------
# Case 11 — F9 with P8 and no recorded human approval: the "production belongs to the human"
#           promise has a gate.
# ---------------------------------------------------------------------------
r=$(constroi p8 "F9 — Operations" conforming)
for d in 02-architecture/decisions 03-experience 04-specification 05-security 06-tests 07-operations; do mkdir -p "$r/product/$d"; echo '# x' > "$r/product/$d/x.md"; done
printf '# Spec\n\n> **State:** approved\n' > "$r/product/04-specification/module.md"
for k in 3 4 5 6 7; do printf '# Gate P%s\n\n> **Result:** passed\n> **Verified by:** r\n> **Approved by (human):** user, 2026-02-0%s\n' "$k" "$k" > "$r/product/99-records/gates/P${k}-2026-02-0${k}.md"; done
printf '# Gate P6b\n\n> **Result:** passed\n> **Verified by:** r\n> **Approved by (human):** user, 2026-02-08\n' > "$r/product/99-records/gates/P6b-2026-02-08.md"
printf '# Gate P8\n\n> **Result:** passed\n> **Verified by:** r\n> **Approved by (human):** {{name, date}}\n' > "$r/product/99-records/gates/P8-2026-02-09.md"
saida=$(corre "$r")
if printf '%s' "$saida" | grep -q 'without a recorded human approval'; then
  ok "P8 without human approval: flagged"
else
  falha "P8 without human approval: passed silently"
  printf '%s\n' "$saida" | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 12 — scripts with CRLF line endings (Windows checkout): none of the seven may die with
#           cryptic errors or print green — they stop with exit 2 and say it is CRLF and how to restore.
#           (An adopting project saw the gate die on «set: pipefail» and never ran it again.)
# ---------------------------------------------------------------------------
r=$(constroi crlf-scripts "F3 — Architecture" conforming)
crlf_ko=0
for sc in _meta/verify.sh _meta/verify-project.sh _meta/test-project-gate.sh _meta/generate-contracts.sh _meta/scan-report.sh adapters/claude-code/generate-scaffold.sh adapters/claude-code/test-hooks.sh; do
  [ -f "$r/Maestro/$sc" ] || { crlf_ko=1; printf '    (missing %s in the copy)\n' "$sc"; continue; }
  sed 's/$/\r/' "$r/Maestro/$sc" > "$r/crlf.tmp" && mv "$r/crlf.tmp" "$r/Maestro/$sc"
  saida=$( cd "$r" && bash "Maestro/$sc" 2>&1 ); codigo=$?
  [ "$codigo" -eq 2 ] && printf '%s' "$saida" | grep -q 'CRLF' || { crlf_ko=1; printf '    %s: exit %s — %s\n' "$sc" "$codigo" "$(printf '%s' "$saida" | head -1 | cut -c1-90)"; }
done
if [ "$crlf_ko" -eq 0 ]; then
  ok "scripts with CRLF: all seven stop with exit 2 and name the cause"
else
  falha "scripts with CRLF: one died with a cryptic error or printed green (above)"
fi

# ---------------------------------------------------------------------------
# Case 13 — adoption in a product that already exists (workflows/W00-project-kickoff.md §Adopting).
#   13a product in production adopted at F9: earlier phases leave no trace and no records, and the
#       gate must not fail for that (permanently red = a gate nobody runs).
#   13b without the existing-system dossier → fails and names it.
#   13c adoption mid-way (since F5, current phase F7): demands traces and records from F5 on, only.
#   13d «from scratch (new product, no existing system)» is NOT an adoption — and the code-before-P5
#       warning still appears (the false detection used to switch it off silently).
#   13e adoption declared ahead of the current phase → inconsistent, fails.
#   13f adoption in production without saying the phase → fails and asks for the phase.
#   13g adoption on existing code (F0) at F3: the code predates Maestro — no code-before-P5 warning.
#   13h adoption since F6 with phase F7: demands F6 and does not say every closed phase is earlier.
# ---------------------------------------------------------------------------
r=$(constroi adoption-f9 "F9 — Operations" deviant)
printf '| **Adoption** | on a product in production, since F9 (2026-09-01) |\n' >> "$r/STATE.md"
mkdir -p "$r/product/00-discovery"
printf '# Existing system\n\nProven features, risks, existing tests, deploy map.\n' > "$r/product/00-discovery/existing-system.md"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -eq 0 ] && ! printf '%s' "$saida" | grep -qE 'NO TRACE|NO RECORD OF GATE P[0-8]|NO APPROVED SPECIFICATION' && printf '%s' "$saida" | grep -q 'since F9'; then
  ok "13a adoption at F9: approved without demanding traces or records of the phases before the adoption"
else
  falha "13a adoption at F9: rejected or flagged for phases the product never had (exit $codigo)"
  printf '%s\n' "$saida" | grep -E '^(✗|!)' | sed 's/^/    /' | head -8
fi
: > "$r/product/00-discovery/existing-system.md"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'ADOPTION WITHOUT DOSSIER'; then
  ok "13b adoption without the existing-system dossier (empty file): rejected and the reason names it"
else
  falha "13b adoption without dossier: passed, or rejected without naming it (exit $codigo)"
fi

r=$(constroi adoption-mid "F7 — Quality" deviant)
printf '| **Adoption** | on existing code, since F5 (2026-08-01) |\n' >> "$r/STATE.md"
mkdir -p "$r/product/00-discovery" "$r/product/99-records/gates"
printf '# Existing system\n' > "$r/product/00-discovery/existing-system.md"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'NO TRACE of F5' && printf '%s' "$saida" | grep -q 'NO TRACE of F6' \
   && ! printf '%s' "$saida" | grep -qE 'NO TRACE of F[1-4]' \
   && printf '%s' "$saida" | grep -q 'NO RECORD OF GATE P5' && printf '%s' "$saida" | grep -q 'NO RECORD OF GATE P6b' \
   && ! printf '%s' "$saida" | grep -qE 'NO RECORD OF GATE P[0-4] ' && ! printf '%s' "$saida" | grep -q 'earlier than the adoption'; then
  ok "13c adoption mid-way (F5, phase F7): demands F5 onwards and nothing before"
else
  falha "13c adoption mid-way: wrong demands (exit $codigo)"
  printf '%s\n' "$saida" | grep -E '^(✗|!|—)' | sed 's/^/    /' | head -12
fi

r=$(constroi from-scratch "F3 — Architecture" conforming)
printf '| **Adoption** | from scratch (new product, no existing system) |\n' >> "$r/STATE.md"
printf '{"name":"x"}\n' > "$r/package.json"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -eq 0 ] && ! printf '%s' "$saida" | grep -qi 'adoption' && printf '%s' "$saida" | grep -q 'code manifest'; then
  ok "13d «from scratch (new product…)» is not an adoption, and the code-before-P5 warning still appears"
else
  falha "13d «from scratch» read as an adoption, or code warning switched off (exit $codigo)"
  printf '%s\n' "$saida" | grep -E '^(✗|!|✓ adoption)' | sed 's/^/    /' | head -6
fi

r=$(constroi adoption-f0 "F3 — Architecture" conforming)
printf '| **Adoption** | on existing code (F0) |\n' >> "$r/STATE.md"
mkdir -p "$r/product/00-discovery"; printf '# Existing system\n' > "$r/product/00-discovery/existing-system.md"
printf '{"name":"x"}\n' > "$r/package.json"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -eq 0 ] && printf '%s' "$saida" | grep -q 'since F0' && ! printf '%s' "$saida" | grep -q 'code manifest'; then
  ok "13g adoption on existing code (F0) at F3: the code predates Maestro by definition — no code-before-P5 warning"
else
  falha "13g adoption F0: undue code warning, or rejection (exit $codigo)"
  printf '%s\n' "$saida" | grep -E '^(✗|!)' | sed 's/^/    /' | head -5
fi

r=$(constroi adoption-f6 "F7 — Quality" deviant)
printf '| **Adoption** | on existing code, since F6 (2026-08-01) |\n' >> "$r/STATE.md"
mkdir -p "$r/product/00-discovery"; printf '# Existing system\n' > "$r/product/00-discovery/existing-system.md"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'NO TRACE of F6' && ! printf '%s' "$saida" | grep -q 'earlier than the adoption'; then
  ok "13h adoption since F6 with phase F7: demands F6 and does not say every closed phase is earlier"
else
  falha "13h adoption F6/F7: off-by-one at the adoption boundary (exit $codigo)"
  printf '%s\n' "$saida" | grep -E '^(✗|—)' | sed 's/^/    /' | head -5
fi

r=$(constroi adoption-ahead "F8 — Launch" deviant)
printf '| **Adoption** | on a product in production, since F9 |\n' >> "$r/STATE.md"
mkdir -p "$r/product/00-discovery"; printf '# x\n' > "$r/product/00-discovery/existing-system.md"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'ADOPTION INCONSISTENT'; then
  ok "13e adoption declared ahead of the current phase: fails as inconsistent"
else
  falha "13e adoption ahead of the phase: accepted — the gate becomes bypassable (exit $codigo)"
fi

r=$(constroi adoption-no-phase "F9 — Operations" deviant)
printf '| **Adoption** | on a product in production (2026-09-01) |\n' >> "$r/STATE.md"
saida=$(corre "$r"); codigo=$?
if [ "$codigo" -ne 0 ] && printf '%s' "$saida" | grep -q 'ADOPTION WITHOUT PHASE'; then
  ok "13f adoption in production without a phase: fails and asks for the phase"
else
  falha "13f adoption without phase: passed silently as F0 (exit $codigo)"
fi

# ---------------------------------------------------------------------------
# Case 14 — living memory with no ceiling: above 60 KB, or a line above 3 000 characters, warns;
#           below both limits (58 KB, 2 990 characters) it does not — the thresholds are the
#           documented ones, not others.
# ---------------------------------------------------------------------------
enche() { # $1 = file, $2 = target KB: appends 100-character lines until past the target
  while [ $(( $(wc -c < "$1") / 1024 )) -lt "$2" ]; do printf '%0100d\n' 0 | tr 0 y >> "$1"; done
}
r=$(constroi memory-below "F3 — Architecture" conforming)
{ printf '| Note | '; head -c 2979 /dev/zero | tr '\0' 'x'; printf ' |\n'; } >> "$r/STATE.md"   # 2 990 characters
enche "$r/STATE.md" 58
saida=$(corre "$r")
maxl=$(awk '{ if (length($0) > m) m = length($0) } END { print m }' "$r/STATE.md")
if [ "$maxl" -eq 2990 ] && ! printf '%s' "$saida" | grep -q 'compact' && ! printf '%s' "$saida" | grep -q 'characters on a single line'; then
  ok "14a memory below the thresholds (58 KB, 2 990 characters): no warning"
else
  falha "14a memory below the thresholds flagged — threshold differs from the documented one (line $maxl)"
  printf '%s\n' "$saida" | grep -E '^!' | grep -E 'KB|characters' | sed 's/^/    /'
fi
r=$(constroi memory-large "F3 — Architecture" conforming)
{ printf '| Last update | '; head -c 2987 /dev/zero | tr '\0' 'x'; printf ' |\n'; } >> "$r/STATE.md"   # 3 005 characters
enche "$r/STATE.md" 61
saida=$(corre "$r")
kb=$(( $(wc -c < "$r/STATE.md") / 1024 ))
if printf '%s' "$saida" | grep -q "is $kb KB" && printf '%s' "$saida" | grep -q 'has 3005 characters on a single line'; then
  ok "14b memory above the thresholds ($kb KB, 3 005 characters): size and accumulated cell flagged"
else
  falha "14b memory above the thresholds: not flagged, or measured wrongly ($kb KB)"
  printf '%s\n' "$saida" | grep -E '^!' | grep -E 'KB|characters' | sed 's/^/    /'
fi

# ---------------------------------------------------------------------------
# Case 15 — pending decisions: two open for 60 days and one from today → «2 for more than 30 days»
#           (an inverted comparison would count 1); one without a date → warns that it cannot be
#           measured; a heading of another section that mentions «pending decisions» does not count;
#           16 open → triage in a batch.
# ---------------------------------------------------------------------------
r=$(constroi pending "F3 — Architecture" conforming)
velha=$(date -d '60 days ago' +%F 2>/dev/null || date -v-60d +%F)
printf '\n## 5. Pending decisions\n\n- **Q-001** (opened on %s) — split the repositories? Blocks: nothing.\n- **Q-002** (opened on %s) — another old one.\n- **Q-003** (opened on %s) — a recent question.\n- **Q-004** — no opening date.\n\n## 9. Historical log — pending decisions resolved\n\n- **Q-000** (opened on %s) — already resolved, does not count.\n' "$velha" "$velha" "$(date +%F)" "$velha" >> "$r/STATE.md"
saida=$(corre "$r")
if printf '%s' "$saida" | grep -q '2 pending decision(s) open for more than 30 days' && printf '%s' "$saida" | grep -q '1 pending decision(s) without «opened on'; then
  ok "15a pending decisions: 2 aged counted (not 1, not 3), 1 without a date flagged, neighbouring section ignored"
else
  falha "15a pending decisions: wrong count"
  printf '%s\n' "$saida" | grep -E '^!' | sed 's/^/    /' | head -5
fi
r=$(constroi pending-batch "F3 — Architecture" conforming)
{ printf '\n## 5. Pending decisions\n\n'; for i in $(seq 1 16); do printf -- '- **Q-%03d** (opened on %s) — question %s.\n' "$i" "$(date +%F)" "$i"; done; } >> "$r/STATE.md"
saida=$(corre "$r")
if printf '%s' "$saida" | grep -q '16 pending decisions open'; then
  ok "15b 16 pending decisions open: batch triage requested"
else
  falha "15b 16 pending: not flagged"
fi

printf '\n'
if [ "$falhas" -gt 0 ]; then
  printf '✗ The project gate FAILED its own test: %d case(s).\n' "$falhas"
  exit 1
fi
printf '✓ Project gate exercised: it approves whoever follows, fails whoever deviates, and does not invent green.\n'
