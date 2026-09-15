#!/usr/bin/env bash
# _meta/verify-project.sh — the PROJECT gate ("Gates, not gut feelings", applied to execution).
# verify.sh validates the framework; this one validates whether a project is FOLLOWING it:
# foundation in place, artifacts present for the phases STATE.md declares closed, gate records,
# specification approved before code, questions recorded, fresh memory with evidence, genesis up
# to date, copy intact and on the upstream version. Run from the project root (or from anywhere —
# it repositions itself):
#   bash Maestro/_meta/verify-project.sh
# Exits with 1 on failures. Warnings do not block, but stay visible. Natural hook: end of each
# session (START-HERE.md §2.5, the Stop hook in adapters/claude-code/) and the project CI
# (pipelines/ci-quality.md). No network, except check 8 (only with git and timeout; never fails;
# never asks for credentials; skipped when MAESTRO_SEM_REDE=1 — that is how the Stop hook runs it).
set -uo pipefail
cd "$(dirname "$0")/../.."

falhas=0; avisos=0
falha() { printf '✗ %s\n' "$*"; falhas=$((falhas + 1)); }
# A check that evaluated nothing does NOT print ✓. Saying "not verified" is honest;
# printing green over what was never looked at is the failure mode an audit found here
# — and it is worse than having no gate at all.
nao_verificado() { printf -- '— NOT VERIFIED: %s\n' "$*"; }
aviso() { printf '! %s\n' "$*"; avisos=$((avisos + 1)); }
ok() { printf '✓ %s\n' "$*"; }
hoje=$(date +%F 2>/dev/null || echo 9999-12-31)

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
[ -f CLAUDE.md ] && grep -q '{{' CLAUDE.md && aviso "CLAUDE.md still has unfilled {{...}} placeholders (templates/README.md §How to instantiate a template — progressive sections keep the reminder line, never {{}})"
[ -f FORBIDDEN-TERMS ] || aviso "no FORBIDDEN-TERMS at the root (the local list _meta/scan-report.sh reads before any report upstream — templates/project/FORBIDDEN-TERMS.template)"
[ "$fund_ko" -eq 0 ] && ok "F0 foundation in place"

# ---------------------------------------------------------------------------
# 2. STATE.md declares the essentials: phase, framework version, upstream repository
#    The phase is read from a line WITHOUT a placeholder: a STATE.md copied from the template
#    and never edited said "{{F0–F9, see …}}" and the gate read F0 and printed green over an
#    empty product/.
# ---------------------------------------------------------------------------
fase=$(grep -iE 'fase atual|current phase' STATE.md | grep -v '{{' | grep -oE '(^|[^A-Za-z0-9])F[0-9]([^0-9]|$)' | grep -oE 'F[0-9]' | head -1 || true)
if [ -z "$fase" ]; then
  falha "STATE.md does not declare the current phase (F0–F9) — or it is still the unfilled template"
  fase_ok=0; fase='?'; n=-1
else
  fase_ok=1; n=${fase#F}
  ok "declared phase: $fase"
fi
v_estado=$(grep -iE 'versão da framework|framework version' STATE.md | grep -v '{{' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
if [ -n "$v_estado" ]; then
  ok "framework version recorded ($v_estado)"
  v_copia=$(grep -oE 'Current version: [0-9.]+' Maestro/_meta/VERSION.md 2>/dev/null | grep -oE '[0-9.]+$' | head -1 || true)
  if [ -n "$v_copia" ] && [ "$v_estado" != "$v_copia" ]; then
    aviso "STATE.md says framework $v_estado but the copy in Maestro/ is $v_copia — update the number in the three live files (playbooks/sync-framework.md step 7)"
  fi
else
  falha "STATE.md missing the copied framework version as X.Y.Z (precondition for syncing) — or it is still the template placeholder"
fi
if grep -qiE 'upstream framework repository|framework-m[ãa]e' STATE.md || [ -f Maestro/_meta/ORIGIN ]; then
  ok "upstream repository recorded"
else
  aviso "STATE.md missing the upstream repository (the destination of improvement reports; in a release copy it comes in Maestro/_meta/ORIGIN)"
fi
# Sections of the live files that arrived in later MINORs: a project synced without adding them
# has 24 specs writing into a §Debt that does not exist.
grep -qE '^## .*Debt' STATE.md || aviso "STATE.md missing the Debt section (template ≥1.1.0 — playbooks/sync-framework.md step 6b)"
[ -f FRAMEWORK-IMPROVEMENTS.md ] && ! grep -qE '^## .*Candidate confirmation' FRAMEWORK-IMPROVEMENTS.md \
  && aviso "FRAMEWORK-IMPROVEMENTS.md missing the Candidate confirmation section (template ≥1.0.0 — playbooks/sync-framework.md step 6b)"

# ---------------------------------------------------------------------------
# 3. Artifacts per closed phase: if the current phase is FN, the earlier ones left a trace
#    (the prototype profile collapses folders into a single dossier — any content accepted)
# ---------------------------------------------------------------------------
tem_conteudo() { [ -d "$1" ] && [ -n "$(find "$1" -type f -name '*.md' 2>/dev/null | head -1)" ]; }
art_ko=0
verifica_fase() { # $1=minimum current-phase number  $2=folder  $3=description
  [ "$fase_ok" -eq 1 ] || return 0
  [ "$n" -ge "$1" ] || return 0
  tem_conteudo "$2" || { falha "NO TRACE of $3 ($2/) with current phase $fase"; art_ko=1; }
}
verifica_fase 2 product/00-discovery "F1 Discovery"
verifica_fase 3 product/01-requirements "F2 Requirements"
verifica_fase 4 product/02-architecture "F3 Architecture"
verifica_fase 5 product/03-experience "F4 Experience"
verifica_fase 6 product/04-specification "F5 Specification"
verifica_fase 6 product/06-tests "F6 Tests (hard precondition of the build — W06)"
verifica_fase 8 product/05-security "F7 Quality & Security"
verifica_fase 9 product/07-operations "F8 Operations"
[ "$n" -ge 4 ] && { tem_conteudo product/02-architecture/decisions \
  || aviso "no ADRs in product/02-architecture/decisions/ with the architecture closed"; }
if [ "$fase_ok" -eq 0 ]; then
  nao_verificado "artifacts per phase — the current phase in STATE.md is unreadable"
elif [ "$n" -lt 2 ]; then
  nao_verificado "artifacts per phase — no phase closed yet (current phase $fase)"
elif [ "$art_ko" -eq 0 ]; then
  ok "closed-phase artifacts left a trace"
fi

# ---------------------------------------------------------------------------
# 3b. Gate records: every closed gate left its record (who verified, who approved, evidence,
#     waivers). In this release it is a WARNING — projects in flight started before the
#     artifact existed; promoting it to a failure is the owner's call (_meta/VERSION.md).
# ---------------------------------------------------------------------------
if [ "$fase_ok" -eq 1 ] && [ "$n" -ge 1 ]; then
  reg_ko=0; k=0
  perfil=$(grep -iE 'perfil de esforço|effort profile' STATE.md | head -1 | tr 'A-Z' 'a-z' || true)
  while [ "$k" -lt "$n" ]; do
    # The per-slice P6 is dispensable in a prototype (templates/project/GATE.md.template)
    if [ "$k" -eq 6 ] && printf '%s' "$perfil" | grep -qE 'prot'; then k=$((k + 1)); continue; fi
    if ! ls product/99-records/gates/P${k}-*.md >/dev/null 2>&1; then
      aviso "NO RECORD OF GATE P$k with current phase $fase (templates/project/GATE.md.template → product/99-records/gates/)"; reg_ko=1
    fi
    k=$((k + 1))
  done
  [ "$n" -ge 7 ] && ! ls product/99-records/gates/P6b-*.md >/dev/null 2>&1 \
    && { aviso "NO RECORD OF GATE P6b (build closure) with current phase $fase"; reg_ko=1; }
  for r in product/99-records/gates/P*.md; do
    [ -f "$r" ] || continue
    grep -q '{{' "$r" && { aviso "unfilled gate record (placeholders {{...}}): $r"; reg_ko=1; }
    # only the Waivers section counts (the criteria table header also says "waived")
    derr=$(awk '/^## .*Waiver/{p=1;next} /^## /{p=0} p' "$r" | grep -viE 'none|^\| *Crit|^\| *---|^[[:space:]]*$' || true)
    [ -n "$derr" ] && ! printf '%s' "$derr" | grep -qi 'risk' && { aviso "waiver without an accepted risk in $r"; reg_ko=1; }
  done
  if [ "$n" -ge 9 ] && ls product/99-records/gates/P8-*.md >/dev/null 2>&1 \
     && ! grep -hiE 'approved by' product/99-records/gates/P8-*.md | grep -qvE '\{\{|not required'; then
    aviso "P8 (production) without a recorded human approval — this is the promise that 'production belongs to the human' (START-HERE.md)"; reg_ko=1
  fi
  [ "$reg_ko" -eq 0 ] && ok "gate records present for P0–P$((n - 1))"
elif [ "$fase_ok" -eq 0 ]; then
  nao_verificado "gate records — the phase is unreadable"
fi

# ---------------------------------------------------------------------------
# 3c. Never code before an approved specification (START-HERE.md §What must never happen)
# ---------------------------------------------------------------------------
if [ "$fase_ok" -eq 1 ]; then
  if [ "$n" -ge 6 ]; then
    if grep -rlE '\*\*State:\*\* *approved' product/04-specification >/dev/null 2>&1; then
      ok "specification with approved artifact(s) — P5 passed"
    else
      aviso "NO APPROVED SPECIFICATION: no artifact in product/04-specification/ with a 'State: approved' header and current phase $fase (core/artifact-protocol.md §Standard artifact header)"
    fi
  else
    m=$(find . -maxdepth 3 \( -name package.json -o -name pyproject.toml -o -name go.mod -o -name Cargo.toml -o -name pom.xml -o -name build.gradle -o -name '*.csproj' -o -name composer.json -o -name Gemfile -o -name mix.exs \) \
        ! -path './Maestro/*' ! -path './product/*' ! -path '*/node_modules/*' ! -path './.git/*' 2>/dev/null | head -1)
    [ -n "$m" ] && aviso "code manifest ($m) with current phase $fase — code before P5? (legitimate only for slice 0 of a starter; START-HERE.md §What must never happen)"
  fi
fi

# ---------------------------------------------------------------------------
# 3d. Ask, do not assume: the question history exists and provisional assumptions are
#     confirmed at the next gate (core/question-engine.md)
# ---------------------------------------------------------------------------
if [ "$fase_ok" -eq 1 ] && [ "$n" -ge 2 ]; then
  qa=product/01-requirements/questions-and-answers.md
  if [ -f "$qa" ]; then
    prov=$(grep -c 'assumed-by-default' "$qa" 2>/dev/null || true)
    [ "${prov:-0}" -gt 0 ] && aviso "$prov provisional assumption(s) in $qa still unconfirmed — they are confirmed at the next gate (core/question-engine.md §When something is assumed by default)"
    ok "question-and-answer history present"
  elif [ "$n" -ge 3 ]; then
    aviso "NO question-and-answer HISTORY ($qa) with current phase $fase — either nothing was asked, or the answers stayed in the conversation (MANIFESTO.md §3)"
  fi
  sem_revisitar=$(awk '/^## .*on behalf of the absent owner/{p=1;next} /^## /{p=0} p && /^- \*\*/ && !/Revisit if/' STATE.md | grep -vc '{{' || true)
  [ "${sem_revisitar:-0}" -gt 0 ] && aviso "$sem_revisitar decision(s) made on behalf of the absent owner without 'Revisit if:' (STATE.md §Decisions made on behalf of the absent owner)"
fi

# ---------------------------------------------------------------------------
# 4. Fresh memory: the last STATE.md update is not fossilized
#    (future dates — deadlines, roadmap — do not count as an update)
# ---------------------------------------------------------------------------
ult=$(grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' STATE.md | awk -v h="$hoje" '$0 <= h' | sort -r | head -1 || true)
if [ -n "$ult" ] && command -v date >/dev/null; then
  seg=$(date -d "$ult" +%s 2>/dev/null || date -j -f %Y-%m-%d "$ult" +%s 2>/dev/null || echo 0)
  dias=$(( ( $(date +%s) - seg ) / 86400 ))
  if [ "$seg" -eq 0 ]; then
    nao_verificado "fresh memory — the date $ult is not interpretable by this \`date\`"
  elif [ "$dias" -gt 45 ]; then
    aviso "STATE.md with no dates for $dias days (last: $ult) — memory fossilizing?"
  else
    ok "memory alive (most recent date in STATE: $ult)"
  fi
fi
# Evidence: "tested" without output is not evidence (knowledge/proven-patterns.md §Live proof)
sem_ev=$(awk '/^## .*Done/{p=1;next} /^## /{p=0} p && /^- \*\*/ && !/Evidence:/' STATE.md | grep -vc '{{' || true)
[ "${sem_ev:-0}" -gt 0 ] && aviso "$sem_ev block(s) in STATE.md §Done without 'Evidence:' (minimum format: knowledge/proven-patterns.md §Live proof)"

# ---------------------------------------------------------------------------
# 5. Improvement loop: submissions accompany the heavy phase closures
#    (the checklist says to submit at the F6/P6b close — so with current phase F7 there
#    should already be a submission)
# ---------------------------------------------------------------------------
if [ -f FRAMEWORK-IMPROVEMENTS.md ]; then
  if [ "$fase_ok" -eq 0 ]; then
    nao_verificado "improvement loop — depends on the phase, and the phase is unreadable"
  elif [ "$n" -ge 7 ] && ! grep -qE '#[0-9]+' FRAMEWORK-IMPROVEMENTS.md; then
    aviso "phase $fase with no submission in §Report log (the checklist says to submit at the F6/P6b close — playbooks/report-framework-improvements.md)"
  else
    ok "improvement loop consistent with the phase"
  fi
fi

# ---------------------------------------------------------------------------
# 6. Genesis dossier: one line per closed phase (the measurement of the promise)
# ---------------------------------------------------------------------------
if [ -f product/99-records/genesis.md ]; then
  # An unedited template row still carries {{...}}: counting it made the very instrument
  # that measures the framework's promise go green over placeholders.
  linhas=$(grep -E '^\| F[0-9] ' product/99-records/genesis.md | grep -vc '{{' || true)
  porpreencher=$(grep -cE '^\| F[0-9] .*{{' product/99-records/genesis.md || true)
  if [ "${porpreencher:-0}" -gt 0 ]; then
    aviso "genesis.md with $porpreencher unfilled row(s) (template placeholders {{...}})"
  fi
  if [ "${linhas:-0}" -eq 0 ]; then
    if [ "$fase_ok" -eq 0 ]; then
      nao_verificado "genesis dossier — depends on the phase, and the phase is unreadable"
    elif [ "$n" -ge 2 ]; then
      aviso "genesis.md with no filled closed-phase row (templates/project/GENESIS.md.template)"
    else
      nao_verificado "genesis dossier — no closed phase to measure yet"
    fi
  else
    ok "genesis dossier tracks the phases ($linhas filled row(s))"
  fi
else
  [ "$n" -ge 1 ] && aviso "no product/99-records/genesis.md — the ecosystem curve stays blind to this project"
fi

# ---------------------------------------------------------------------------
# 7. Framework copy integrity (when it came from a release with a manifest)
# ---------------------------------------------------------------------------
if [ -f Maestro/_meta/SHA256SUMS ]; then
  bash Maestro/_meta/verify.sh --integrity >/dev/null 2>&1; rc=$?
  case $rc in
    0) ok "framework copy intact (identical to the origin release)" ;;
    2) nao_verificado "copy integrity — no sha256sum/shasum on PATH (install coreutils)" ;;
    *) falha "framework copy DIVERGES from the release (bash Maestro/_meta/verify.sh --integrity — if everything fails on a Windows machine it is CRLF conversion: restore with git checkout -- Maestro/)" ;;
  esac
else
  [ -f Maestro/_meta/FORBIDDEN-TERMS ] && aviso "the copy came from a clone of the upstream repository, not from a release (upstream-only files present) — replace it with the release ZIP: playbooks/sync-framework.md"
  aviso "copy without an integrity manifest (a working clone, not a release ZIP)"
fi

# ---------------------------------------------------------------------------
# 8. Upstream version: "deliberate" must not decay into "never" — a warning when a newer
#    release exists. Warning, never a failure; without network, git or origin → NOT VERIFIED.
# ---------------------------------------------------------------------------
repo=$(sed -n 's/^repository=//p' Maestro/_meta/ORIGIN 2>/dev/null | head -1)
[ -n "$repo" ] || repo=$(grep -iE 'upstream framework repository|framework-m[ãa]e' STATE.md | grep -oE '[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | head -1 || true)
v_copia=$(grep -oE 'Current version: [0-9.]+' Maestro/_meta/VERSION.md 2>/dev/null | grep -oE '[0-9.]+$' | head -1 || true)
if [ "${MAESTRO_SEM_REDE:-0}" = 1 ]; then
  nao_verificado "upstream version — no network in this context (MAESTRO_SEM_REDE=1; run the gate by hand to see)"
elif printf '%s' "$repo" | grep -qE '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$' && command -v git >/dev/null 2>&1 && command -v timeout >/dev/null 2>&1; then
  # never ask for credentials: against a private upstream with no cached credential, git asked
  # "Username" in a third party's terminal, or opened the credential-manager dialog
  ult_tag=$(GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=/bin/true timeout 5 git -c credential.helper= ls-remote --tags "https://github.com/$repo.git" 2>/dev/null | sed 's#.*refs/tags/##' | grep -E '^v[0-9]' | grep -v '\^{}' | sort -V | tail -1 || true)
  if [ -z "$ult_tag" ]; then
    nao_verificado "upstream version — no access to $repo (network/credentials)"
  elif [ -n "$v_copia" ] && [ "${ult_tag#v}" != "$v_copia" ]; then
    aviso "upstream framework at $ult_tag, copy at $v_copia — sync deliberately: playbooks/sync-framework.md"
  else
    ok "copy on the latest upstream version ($ult_tag)"
  fi
else
  nao_verificado "upstream version — origin unknown or no git/timeout (Maestro/_meta/ORIGIN or org/repo in STATE.md)"
fi

# ---------------------------------------------------------------------------
printf '\n'
if [ "$falhas" -gt 0 ]; then
  printf '✗ Project OFF the process: %d failure(s), %d warning(s).\n' "$falhas" "$avisos"
  exit 1
fi
printf '✓ Project following the process (%d warning(s)).\n' "$avisos"
