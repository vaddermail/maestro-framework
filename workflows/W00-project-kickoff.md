# W00 — Project Kickoff (F0)

> **Phase:** F0 · **Exit gate:** P0 · **Core agent:** the Orchestrator in person
> (`core/orchestrator.md`) — no product specialist works yet.

## Objective

Put the foundation in place: the framework installed in the project repository, the **project
memory** instantiated (`STATE.md`, `CLAUDE.md`, `FRAMEWORK-IMPROVEMENTS.md`, `product/` tree), the
**effort profile** calibrated and the **raw idea** recorded without editing. At the end of F0 the
project has somewhere to write everything decided from here on — and has decided nothing about the
product yet.

## Preconditions (entry gate)

There is no upstream gate (this is the first phase). All that is required:

- [ ] A project folder/repository, with `Maestro/` copied inside from the ZIP of a
      **release** (`START-HERE.md` §Part 1) — confirm the ZIP's SHA-256 against the one published
      in the release notes.
- [ ] Self-check of the installed copy **green**: `bash Maestro/_meta/verify.sh` — a corrupted or
      partial copy is caught here, not halfway through F5.
- [ ] An AI session with file access, at the project root.
- [ ] The user's idea in 2–10 sentences (even if vague — refining it is F1 work, not a
      prerequisite).
- [ ] Environment confirmed (the AI tool reads/writes files; if it is Claude Code, see
      `adapters/claude-code.md`). In sessions after the first, the startup protocol is that of
      `playbooks/developer-onboarding.md` §Session-start protocol — this workflow is only the
      foundation.
- [ ] If the repository already has code or the product is already in use: read §Adopting in a
      product that already exists before step 1 — it changes the order (inventory before
      calibration) and what the gate requires.

## Steps (agent → artifact)

| # | Who | Action | Artifact |
| --- | --- | --- | --- |
| 1 | Orchestrator | Read the framework in the order of `START-HERE.md` §2.1 (Manifesto → orchestrator → lifecycle → protocol → questions → memory → this workflow), plus `knowledge/permanent-rules.md` | — (read-only) |
| 2 | Orchestrator | Create `STATE.md` at the root from `templates/project/STATE.md.template` | `STATE.md` |
| 3 | Orchestrator | Create `CLAUDE.md` (or the tool's equivalent) from `templates/project/CLAUDE.md.template`, including the tiers→models mapping (`core/model-routing.md`) | `CLAUDE.md` |
| 4 | Orchestrator | Create `FRAMEWORK-IMPROVEMENTS.md` at the root (from `templates/project/FRAMEWORK-IMPROVEMENTS.md.template`) and the genesis dossier at `product/99-records/genesis.md` (from `templates/project/GENESIS.md.template`) — what the project teaches the framework, and the numbers that prove the promise; and `FORBIDDEN-TERMS` at the project root from `templates/project/FORBIDDEN-TERMS.template` (local list of client names/confidential terms; never sent) | `FRAMEWORK-IMPROVEMENTS.md`, `product/99-records/genesis.md`, `FORBIDDEN-TERMS` |
| 5 | Orchestrator | Create the `product/` tree per `core/artifact-protocol.md` (collapsed to the profile — see §Effort profiles) | `product/` |
| 6 | Orchestrator | Record in `STATE.md` §Situation header (dedicated fields, including "Raw idea" and "F0 → F1 inputs"): date, framework version (`_meta/VERSION.md`), **upstream framework repository** (org/repo or URL the copy came from — the destination of improvement reports and the source of syncs), AI tool, the **raw idea exactly as the user gave it** (unedited) and, in a product that already exists, the "Adoption" field | `STATE.md` |
| 6b | `agents/00-discovery/existing-system-analyst.md` | **Only if the repository already has code or the product is already in use:** inventory of what exists **before** the calibration batch — profile, horizon and thresholds are decided with it in view, not blind (§Adopting in a product that already exists) | `product/00-discovery/existing-system.md` |
| 7 | Orchestrator | Put the single calibration batch (§Decision points), pin the **effort profile**, and record the thresholds in `CLAUDE.md` §F0 calibration | `STATE.md`, `CLAUDE.md` |
| 8 | Orchestrator | Propose the first commit ("project foundation"), already with step 9's scaffold and step 10's gate inside — both run before this one — execute only if the user confirms (`START-HERE.md` §2.2) | — |
| 9 | Orchestrator | If the tool is Claude Code: `bash Maestro/adapters/claude-code/generate-scaffold.sh` generates `.claude/` (agents per phase, hooks, skills, settings) — version it with the foundation (`adapters/claude-code.md` §Executable scaffold) | `.claude/` |
| 10 | Orchestrator | Wire up the project gate: `MAESTRO_SEM_REDE=1 bash Maestro/_meta/verify-project.sh` at the close of every session, confirmed green; once CI exists (`workflows/W06-build.md` step 0.5, or already now in an adopted product), as a stage of it (`pipelines/ci-quality.md` §Stages). A gate that only runs by hand does not run | session close · CI |

Nothing here consumes upstream artifacts (there are none); everything is foundation writing. Step 7
depends on the user's answers — if they do not answer, the following steps stay blocked and the
pending item goes to `STATE.md` §Pending decisions (`core/orchestrator.md` §Recovery).

## Decision points

A **single** calibration batch to the user (format of `core/question-engine.md`,
`START-HERE.md` §2.3):

- **Size of the ambition** → picks the effort profile: prototype / internal product / commercial
  product / enterprise platform (`core/orchestrator.md` §Effort profiles). **User decision**
  (it sizes every gate that follows).
- **Horizon** (weeks / months / years) and **team** (user+AI only / small team / multiple
  teams) — they tune the depth and the Git discipline.
- **Hard constraints already known** — budget, deadlines, compliance (e.g. GDPR, regulated
  sector), mandatory integrations, strong technology preferences. Recorded as **input** for
  F1/F3, not as closed decisions yet.
- **Quality thresholds** — accept the profile defaults for code smells and technical debt
  (tables in `loops/L04-code-smells.md` and `loops/L08-technical-debt.md`) or set custom values;
  whatever is agreed is recorded in `CLAUDE.md` §F0 calibration.
- **Greenfield, or replacing/extending an external system?** — if the product replaces or extends
  a system in use **outside this repository** (shared spreadsheets, a discontinued product, an old
  internal app), F1 summons `agents/00-discovery/existing-system-analyst.md` (inventory of what is
  in use, data to migrate, integrations to preserve, cutover constraints). Recorded as an **input**
  for F1. When the code is already **in this** repository, it is not a question — it is
  observable, and the inventory already ran at step 6b.

- **One repository, or several?** — if the product is going to be born, or already lives, split
  across more than one repository (services with their own lifecycles, a gateway for third
  parties, an ecosystem), wire up `modules/multi-repository-product.md` from day 1: precedence
  table, typed items, mesh not star. Deciding late turns the owner into a courier between
  sessions.

Mandatory human approval: **the effort profile** (it affects the cost and depth of everything
else).

## Adopting in a product that already exists

Maestro is often adopted midway through: inherited code with no specification, or a product that
has been in production for years. The greenfield W00 applied as-is fails in two measured ways — it
calibrates blind (profile and thresholds pinned before anyone reads the code) and leaves the
project gate **red forever**, demanding a trail of phases the product never passed through; a
permanently red gate is a gate nobody runs.

| Case | Signal | What changes |
| --- | --- | --- |
| **Code exists, product not yet launched** | There is history in Git; there is no `product/` | Full F0, with step 6b before the calibration batch; F1 starts from the inventory instead of a blank sheet. "Adoption: on existing code (F0)." |
| **Product in production** | Real users, deploys, live data | Adopted **at the phase the product is in** (typically F9; evolutions through `workflows/W10-feature-evolution.md`). "Adoption: on a product in production, since F9 (yyyy-mm-dd)." |

Rules for the "product in production" case:

1. **The foundation is complete, not minimal** — `STATE.md`, `CLAUDE.md`,
   `FRAMEWORK-IMPROVEMENTS.md`, `FORBIDDEN-TERMS` and genesis from the point of adoption. Without
   the improvements file, the in-the-moment capture does not happen: an adopter with a "minimal
   bootstrap" ended up with ten days of lessons sitting only in `STATE.md` and in conversation, and
   had to recover them afterward.
2. **The phases before adoption are not reconstructed.** F1–F8 artifacts are not written
   retroactively for a product that never went through them. In place of that trail, the gate
   requires `product/00-discovery/existing-system.md` — the characterization of what exists:
   proven features, known risks, existing tests and how they run, deploy map.
3. **Gate records count from the point of adoption**, never before — the single exception in
   `core/quality-gates.md` §Gates and effort profiles.
4. **Stabilize before evolving** is the typical first piece of work: the test strategy is written
   in existing-system mode (`agents/10-quality/test-strategist.md` §Workflow, on invariants
   observed in the code), before any numbered specification exists.
5. `_meta/verify-project.sh` reads the "Adoption" field of `STATE.md` §Situation header and applies
   these rules. Without the field, it treats the project as greenfield — the right behavior when
   nobody declared otherwise.

## Loops it opens

No phase loop. F0 is a short, deterministic sequence. The only iterative mechanism is the
question engine of the calibration batch, which closes as soon as the profile is pinned.

## Exit gate (P0)

`core/quality-gates.md`:

- [ ] `STATE.md`, `CLAUDE.md`, `FRAMEWORK-IMPROVEMENTS.md`, `FORBIDDEN-TERMS` and the `product/`
      tree created at the root (outside `Maestro/`).
- [ ] Raw idea recorded without editing; framework version, **upstream framework repository** and
      AI tool noted.
- [ ] Effort profile **confirmed by the user** and recorded.
- [ ] Tiers→models mapping filled in in `CLAUDE.md`.
- [ ] `CLAUDE.md` §F0 calibration filled in (thresholds and cadences).
- [ ] Tool scaffold generated, when the adapter provides for it (step 9).
- [ ] `bash Maestro/_meta/verify-project.sh` green, and wired into CI once it exists
      (`workflows/W06-build.md` step 0.5) — until then, run at the close of every session (step 10).
- [ ] In a product that already exists: `product/00-discovery/existing-system.md` written before
      calibration and the "Adoption" field filled in (§Adopting in a product that already exists).
- [ ] P0 gate record written at `product/99-records/gates/P0-YYYY-MM-DD.md`
      (`templates/project/GATE.md.template`), with the items of this §Exit gate as criteria.

**Who approves:** the user (effort profile). **Who verifies:** the Orchestrator (existence and
format of the files). With P0 closed, `workflows/W01-discovery.md` starts.

## Effort profiles

The profile calibrated here **sizes every following phase** — but F0 itself is practically
constant:

| Profile | Effect on F0 |
| --- | --- |
| **Prototype** | `product/` tree collapsed (one file per phase, e.g. `product/00-discovery/dossier.md`); guardians marked as disabled in `CLAUDE.md` §F0 calibration. **Names and IDs** are kept so traceability is not lost if it grows (`core/artifact-protocol.md`). |
| **Internal product** | Full tree; guardians on the profile's cadences (`agents/13-guardians/README.md` §Cadences per profile), noted in `CLAUDE.md` §F0 calibration. |
| **Commercial product** | Full tree; guardians on the profile's cadences (`agents/13-guardians/README.md` §Cadences per profile); note of an adversarial audit before go-live and a mandatory pentest in `CLAUDE.md` §F0 calibration. |
| **Enterprise platform** | As commercial + a record, in `CLAUDE.md` §F0 calibration, that every structural decision requires an ADR and that the global review (`workflows/W12-global-review.md`) is periodic. |

Changing profile later is legitimate (record it in `STATE.md` and run the gates the new profile
requires — `core/orchestrator.md` §Effort profiles).

## Related

- `START-HERE.md` — the human+AI protocol this workflow is the detail of.
- `core/project-memory.md` — what `STATE.md` and file-based memory guarantee.
- `core/artifact-protocol.md` — the `product/` tree to create.
- `templates/project/STATE.md.template` · `templates/project/CLAUDE.md.template` ·
  `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` ·
  `templates/project/FORBIDDEN-TERMS.template` — the instantiables.
- `playbooks/developer-onboarding.md` — the startup protocol for the following sessions.
- `workflows/W01-discovery.md` — the phase that starts next.
- `adapters/claude-code.md` — session start and memory in the concrete tool.
