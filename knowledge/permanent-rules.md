# Permanent Working Rules

Rules that hold in **any** project run by the framework, from a weekend prototype to an
enterprise platform. Distilled from several real projects. Agents reference this file instead
of repeating the principles; the Orchestrator enforces them.

## 1. Owner's mindset + critical filter

Do not just execute the literal request. Before implementing **any** request, assess whether it
creates future problems, collides with other features/data/roadmap, or whether a better path
exists — and **state the risks BEFORE proceeding**, not after.

- **Why:** the requester may lack technical training and not see the downstream effect; an
  agent that only obeys transfers the cost of the mistake to the future.
- **How to apply:** explain trade-offs in plain language; at the end of each block, a short
  report (what changed, why, risks/follow-ups). When there is information to act, **act and
  recommend** — do not inventory endless alternatives (that is indecision disguised as rigor).

## 2. Absolute honesty — zero tolerance

Content that reaches the user tolerates no invention; results are reported faithfully.

- **Why:** an invented number or an unproven "it works" costs more than an admitted gap — it
  destroys trust in everything else.
- **How to apply:** when in doubt about a fact, **do not write it** rather than degrade. Tests
  fail → say so with the real output. Never declare "it works" without evidence (see §live
  proof in `knowledge/proven-patterns.md`). AI enrichment must be *grounded* and reversible,
  with provenance (which source, when).

## 3. Reversible by default

All development has a reversal path — not just the obvious cases.

- **Why:** a rollback that demands heroic manual restoration is, in practice, a one-way path;
  and what cannot be undone cannot be risked.
- **How to apply:**
  - **Reversible, expand-contract DB migrations:** additive first (new column/table), migrate
    data and code, and **only then** drop the old — never drop/rename what is in use in the
    same step (`playbooks/expand-contract-db-migration.md`). Every migration with a *down* or
    a documented reversal plan.
  - **Risky changes behind a flag/kill-switch** (`modules/feature-flags.md`), switchable off
    without a new deploy.
  - **Prefer additive over destructive** (§4). Backup/rollback state before irreversible
    operations (drop, purge, deploy).
  - **AI-touched data** with provenance + undo (§2).

## 4. Destructive or mass changes

Before mass deleting/merging/overwriting: **plan + list, reason per item**, and execute only
after human validation. **Additive** features proceed without prior validation.

- **Why:** an accidental mass delete is the most expensive and least reversible error category;
  the cost of listing first is tiny next to the cost of restoring later.
- **How to apply:** deletes/updates **always by exact ID**, never by substring search. Before
  deleting/overwriting a target, **look at it**; if it contradicts how it was described, raise
  the question instead of proceeding (`MANIFESTO.md` §8).

## 5. Secrets out of version control

Secrets (keys, passwords, tokens, API keys) **never** enter Git nor logs/output.

- **Why:** a committed secret is a compromised secret — history is public and eternal;
  rotating in a hurry is always worse than never having exposed it.
- **How to apply:** live in a dedicated store or gitignored folder; reference **by file
  path**, never paste values into chat/artifacts; inject at runtime. Deploy with a backup
  first, a rollback state, and a hard block against the wrong infra. Detail:
  `playbooks/secrets-management.md`.

## 6. Stable versions by default

Use the latest **stable** version of each technology (LTS runtime, GA framework major, stable
lib releases). Avoid alpha/beta/RC/nightly and freshly released majors, except for justified,
recorded need.

- **Why:** bleeding edge is paid for in bugs, breaking changes and missing documentation — a
  recurring cost for a usually illusory gain.
- **How to apply:** **pin** the version (lockfile / `engines` / `.nvmrc`) so everyone shares
  the same one; **update deliberately** (changelog + tests — `playbooks/dependency-updates.md`),
  never by drift. Innovate where the product differentiates, not in the base infrastructure.

## 7. Testing, verification and audit with maximum coverage

Every request — even low-impact — followed by verification that includes the **related**
components, not only the one touched.

- **Why:** most regressions appear one step away from the change, where nobody looked.
- **How to apply:** tests focused on the **risk logic** (business rules, reversibility,
  conflicts, authorization), with fakes/mocks for external I/O; real **live proof** at the
  end; lint and tests locally before integrating — **frontend and backend run separately**,
  run both. Periodically, extensive **adversarial** audits, verifying every conclusion
  independently (`playbooks/adversarial-audit.md`).

## 8. Collaborative Git discipline

Always work on a dedicated branch, never directly on the integration branch. Small, clear
commits. Integrate only via PR/merge with the work tested and green. Before editing a file,
check for others' work in progress; at risk of conflict, flag it instead of overwriting. Do
not commit/push unless asked, but propose it when there is finished, green work.

- **Why:** a broken integration branch blocks the whole team; shared memory only works if
  nobody silently overwrites someone else's work.
- **How to apply:** pull before starting, branch, verify, green PR, tell your colleague.

## Related

- `MANIFESTO.md` — the higher-level principles these rules operationalize.
- `knowledge/origin-lessons.md` — the concrete cases that originated them.
- `knowledge/ai-pitfalls.md` — the failures these rules prevent.
- `core/quality-gates.md` — where compliance is verified.
