# Change Effort Profile

How to move a project from one effort profile to another mid-cycle — the ecosystem's most likely
case is the **prototype that validated and continues** as an internal or commercial product; the
same procedure serves any step-up (internal → commercial → enterprise platform). The rule lives in
`core/orchestrator.md` §Effort profiles ("the gates the new profile requires and the old one waived
are run") and in `workflows/W00-project-kickoff.md` §Effort profiles; this playbook is the checklist
the rule assumes. Executed by the Orchestrator, with the user owning the decision. Changing profile
is not "change one line in STATE": it is openly inheriting the process debt the old profile
authorized — and paying it off in phase order.

## Preconditions

- User decision recorded — it is scope and money (`core/orchestrator.md` §Human approval): the new
  profile chosen from the table in `core/orchestrator.md` §Effort profiles, with the reason (e.g.
  "the prototype validated the idea with 12 real users; moving to internal product").
- `STATE.md` §Situation header with the **old** profile legible and the current phase correct —
  without it there is no way to know which gates already passed, nor at what depth.
- `product/99-records/genesis.md` exists (step 5 writes to it).
- No slice left mid-flight without a record in `STATE.md` §In progress — whatever is mid-flight
  either finishes under the old profile or gets recorded as interrupted; it never stays invisible.

## Steps

1. **Record the new profile in both sources.** In `STATE.md` §Situation header: the new profile,
   with "since YYYY-MM-DD; before: {old profile}"; a line in `STATE.md` §Done with the decision and
   the reason. In `CLAUDE.md` §F0 calibration: the profile, the new profile's L04/L08 thresholds, and
   the guardian cadences that now apply. *Verified* by reading both files: they state the same
   profile and the same date. *If it fails*: do not proceed — two sources of truth that diverge are
   pitfall 7 of `knowledge/ai-pitfalls.md`.
2. **Apply the table "what the old profile waived → what becomes due".** One line per item; each
   line gets one of three states: **already done** (with the evidence), **due** (goes into step 4)
   or **not applicable** (with the reason why). The table is written for the prototype → product
   case; for a step-up between higher profiles, read the new profile's column in each row's source
   file.

   | What the old profile waived | What becomes due | Source file |
   | --- | --- | --- |
   | Collapsed `product/` tree (one file per phase) | **Nothing gets split**: names and IDs stay the same and each file only splits when it grows — traceability is already in place | `core/artifact-protocol.md` §The project's `product/` tree; `workflows/W00-project-kickoff.md` §Effort profiles |
   | F1: minimal personas and cases; costs in order of magnitude | Real personas of known users; risks with a named owner; KPIs with a measured baseline (commercial) | `workflows/W01-discovery.md` §Effort profiles |
   | F2: NFRs only those that block decisions; ACs only on risk flows | NFRs quantified with the system's owner; L01 formally closed; ACs on every MVP FR (commercial) | `workflows/W02-requirements.md` §Effort profiles; `loops/L01-ambiguous-requirements.md` |
   | F3: hosting deferred; short ADR; panel sketched by the Orchestrator | **Hosting decision** (ADR with validated costs on commercial); ADRs for the structural decisions; stack with an update policy (commercial) | `workflows/W03-architecture.md` §Effort profiles |
   | F4: performance budgets waived; basic accessibility | Performance budgets per route type; WCAG AA on the critical flows; budgeted web performance (commercial) | `checklists/definition-of-done.md` §F4; `workflows/W04-experience.md` §Effort profiles |
   | F5: spec reviewed by the Orchestrator itself + user OK | **Minimal panel** (architecture + security + UX) consolidated by `agents/12-reviewers/review-consolidator.md`; formal threat model (STRIDE) (commercial and above) | `workflows/W05-specification.md` §Exit gate (P5); `workflows/W05-specification.md` §Effort profiles; `checklists/definition-of-done.md` §F5 |
   | F6: P6 review by the Orchestrator itself; tests only on risk logic; bigger slices | Panel review on the critical flows; real DB parity per slice and AI consumption recorded (commercial and above); slices already delivered **do not get redone** — they go into step 3's snapshot | `workflows/W06-build.md` §Effort profiles |
   | F7: minimal panel; no formal pentest | Light pentest + scans (internal); full panel, full pentest and **adversarial audit** (commercial); ASVS level 2+ and independent verification of every conclusion (enterprise) | `workflows/W07-quality-and-security.md` §Effort profiles; `playbooks/adversarial-audit.md` |
   | F8: no real production, or a documented manual deploy | Delivery pipeline; backups with a tested restore; monitoring and alerts (internal); blue-green/canary, automatic rollback, SLOs, on-call (commercial); DR exercised (enterprise) | `workflows/W08-launch.md` §Effort profiles |
   | L04 and L08 loops disarmed | **Arm** with the new profile's thresholds, recorded in `CLAUDE.md` §F0 calibration; the debt accumulated in the prototype goes into `STATE.md` §Debt, with the interest estimated | `loops/L04-code-smells.md` §Progress metric; `loops/L08-technical-debt.md` §Exit condition (success) |
   | Guardians disabled | **Activate** per the single table, at the new profile's cadence; each guardian's first cycle runs right away, not "at the next cadence" | `agents/13-guardians/README.md` §Cadences per profile |

   *Verified*: no line without a state. *If it fails*: a line without a state is exactly the silent
   process debt the rule forbids — close the table before continuing.
3. **Snapshot the process debt with `workflows/W12-global-review.md`**, with the narrow scope it
   asks for: "what the old profile waived". The panel reviews what exists (dossiers, ADRs, spec,
   code, tests) through the **new** profile's eyes; the consolidated report in
   `product/99-records/reviews/` states what is missing in substance, by phase — the table from step
   2 states what is missing in process. *Verified*: consolidated report with a verdict and findings
   by phase. *If it fails* (panel with no artifact to review): the gap is itself a due item — record
   it and move on.
4. **Run the outstanding gates in phase order.** P1 → P2 → … up to the current phase, each with its
   gate record at `product/99-records/gates/Pn-YYYY-MM-DD.md`
   (`templates/project/GATE.md.template`), verified by whoever did not produce it and approved by
   the user where the matrix requires it (`core/quality-gates.md` §The lifecycle gates), and the
   summary in `STATE.md` §Done. The collapsed `product/` tree **does not get split** — names and IDs
   stay the same (`core/artifact-protocol.md`) and each file only splits when it grows. The build
   does not stop, but **no new slice closes P6 under the new profile while P5 has not been redone** —
   P5 is the gate that unlocks code, and it is the panel-reviewed spec that protects everything that
   comes after. *Verified*: every due gate has a record with Result "passed" (or a user waiver
   recorded in it). *If it fails*: the phase reopens in `STATE.md` — going back is normal
   (`core/lifecycle.md` §Lifecycle rules); moving forward without a gate is not.
5. **Note it in the genesis record and signal curation.** A line in `product/99-records/genesis.md`
   §Phases (in the last closed phase, Notes column — the phase in progress only gets a line when it
   closes): "profile {old} → {new} on YYYY-MM-DD; gates redone: …; AI cost of the change: …". What
   the prototype should have done from the start — and would have come out cheaper — gets recorded
   in `FRAMEWORK-IMPROVEMENTS.md` §Friction and omissions: it is the signal curation reads to tune
   what the prototype profile waives. *Verified*: both lines exist.

## Rollback

Widening a profile back (e.g. internal product → prototype, or turning off guardians the change
activated) requires **user-accepted risk** — "never loosen it without user-accepted risk"
(`agents/13-guardians/README.md` §Cadences per profile) — and gets recorded as a decision: a short
ADR (`templates/project/ADR-DECISION.md.template`) or a line in `STATE.md` §Done with the risk
assumed spelled out, plus updating both sources from step 1. Gate records already written **do not
get erased** — they are history; guardians get explicitly disabled in `CLAUDE.md` and loops get
disarmed with the debt staying recorded, not disappearing. A change interrupted partway through
step 4 can stop where it is: the gates already redone stay redone; the ones still missing get listed
in `STATE.md` §Up next with the note "due under the {new} profile, suspended on YYYY-MM-DD".

## Related

- `core/orchestrator.md` §Effort profiles — the rule this playbook operationalizes.
- `workflows/W00-project-kickoff.md` §Effort profiles — the original F0 calibration.
- `agents/13-guardians/README.md` §Cadences per profile — the single source of what activates.
- `loops/L04-code-smells.md` · `loops/L08-technical-debt.md` — the loops that arm with the new
  thresholds.
- `workflows/W12-global-review.md` — step 3's snapshot.
- `templates/project/GATE.md.template` — the record of each redone gate.
- `checklists/definition-of-done.md` — the *(waivable in: prototype)* markings that stop applying.
- `core/artifact-protocol.md` — why the collapsed tree does not get split.
