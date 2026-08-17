# Loops — intelligent persistence

A **loop** is a convergence process: it repeats an action while an undesirable condition persists,
until that condition disappears **or** a safeguard decides it is not converging and escalates to
the user. Where a workflow (`workflows/README.md`) is a sequence that ends when the last step runs,
a loop ends when the **state of the world** reaches the target — or when it proves it never will.

Loops exist because most software problems are not solved in one step: ambiguous requirements breed
more questions, one fixed test reveals another failing, one handled CVE uncovers the next one. The
framework does not leave this to session improvisation: each recurring problem type has a loop with
explicit entry, exit and **anti-stubbornness** rules — because an AI agent left to insist is as
likely to converge as to enter an endless cycle "fixing" the same thing (see
`knowledge/ai-pitfalls.md`).

## Anatomy of a loop (fixed sections)

Every `Lnn` follows the same structure, so the Orchestrator can jump from one to another without
relearning the format:

| Section | What it answers | Rule |
| --- | --- | --- |
| **Identification** | Name, when it runs, which agent(s) execute the action, suggested model | Table at the top |
| **Progress metric** | The measurable number the loop drives down | Must be **countable and comparable** across iterations — not a "feeling of improvement" |
| **Entry condition** | What opens the loop | A verifiable fact (`there are N items in state X`), not an intention |
| **Action (the body of the iteration)** | What is done **once** per iteration | One small, reversible step; delegates to the agent that owns the problem |
| **Exit condition (success)** | When the loop closes because it resolved | Metric at zero (or ≤ the agreed threshold), verified by someone who did not produce the fix |
| **Anti-infinite-loop safeguard** | When the loop stops **without** resolving | Rule of 3 (below) + hard caps; escalates to the user with a diagnosis |
| **STATE.md record** | The trail left behind | The loop's ledger line, updated every iteration |
| **Related** | Where the reader goes next | 3–8 paths that exist in `_meta/INVENTORY.md` |

## The anti-infinite-loop safeguard (the "rule of 3")

No loop runs indefinitely. The base safeguard, mandatory in **all** loops:

> **3 consecutive iterations without progress → stop the loop, record the diagnosis and escalate to
> the user with options.** "Without progress" = the loop's progress metric did not strictly
> decrease between iterations.

This operationalizes the line in `core/orchestrator.md` §Recovery and exceptions ("loop that does
not converge → stop"). Each loop specializes the rule with three complementary defenses:

1. **Stagnation** — the metric does not decrease for 3 consecutive iterations (the base case above).
2. **Oscillation** — the metric goes down and comes back up to the same value (e.g. fixing A breaks
   B, fixing B breaks A). Detected by a state *fingerprint*: if an already-seen state repeats, it
   is a cycle, not progress — stop immediately, do not wait for the 3rd iteration.
3. **Hard cap** — an absolute maximum number of iterations per loop (set in each `Lnn`),
   regardless of whether there is progress, for the pathological case of infinitesimal "progress".

When a safeguard fires, the Orchestrator **neither insists nor invents** (`knowledge/ai-pitfalls.md`
#3, #20): it writes in `STATE.md` → "Decisões pendentes" what it tried, why it did not converge and
what options exist (change approach, accept residual risk, cut scope), and returns the decision to
whoever can make it. A run aborted by a safeguard **is not a loop failure** — it is the loop doing
its job.

## The `Lnn` convention and the STATE.md ledger

- Loops numbered `Lnn-name.md` (`_meta/STYLE-GUIDE.md` §6). Numbering does not imply execution
  order: loops fire by **condition**, not by sequence.
- Each active loop has **one ledger line** in `STATE.md` ("Em curso" section), updated every
  iteration, in the format:

  ```
  L02 · failing tests · metric 12→7→7 · iter 3 (cap 6) · last progress: iter 2 · status: AT RISK
  ```

  It records: the metric across iterations (so the trend is visible), the current iteration and the
  cap, when progress last happened, and the status (`in progress` / `at risk` / `stopped —
  escalated to the user` / `closed`). On closing, it collapses into one line in "Registo histórico"
  (`core/project-memory.md` §Memory hygiene). This guarantees the next session resumes a loop
  midway **without re-asking**.

## Who opens, who runs, who closes

- **Opens:** the Orchestrator, when a workflow dictates it (e.g. `W02` opens `L01`) or when an
  agent/guardian reports the entry condition. Operation loops (L03/L05/L06/L07/L08) also fire by
  cadence or event in F9 (`workflows/W09-continuous-operation.md`).
- **Runs:** the agent that owns the problem executes each iteration's action (named in each `Lnn`'s
  Identification); the Orchestrator coordinates, measures the metric and applies the safeguard. The
  model is chosen per task (`core/model-routing.md`): the **action** can be Economy; the **decision
  to accept risk or stop** demands judgment (Top).
- **Closes:** the gate (`core/quality-gates.md`) or the guardian, with **independent verification**
  — whoever produced the fix never declares the loop closed (`knowledge/ai-pitfalls.md` #20).

## Cross-cutting principles (do not repeat, reference)

- **Fix the cause, never the symptom or the detector.** The failing test is not deleted and the
  threshold is not raised so the smell passes — that is gaming the metric. Per-loop detail (L02,
  L04).
- **Every iteration is reversible** (`knowledge/permanent-rules.md` §3): a loop step that cannot be
  undone requires human approval before running.
- **Priority by severity/risk**, not by detection order (L03, L07): what hurts most is solved
  first.
- **Metric honesty** (`knowledge/permanent-rules.md` §2): the metric is reported at its real value;
  a loop declared closed has to prove it (metric verified, not asserted).

## The framework's loops

| Loop | Condition it chases | Agent/owner | Typical phase |
| --- | --- | --- | --- |
| `loops/L01-ambiguous-requirements.md` | Ambiguous/contradictory/missing requirements | `agents/01-requirements/ambiguity-hunter.md` | F2 (and wherever ambiguity appears) |
| `loops/L02-failing-tests.md` | Failing tests | `agents/10-quality/` | F6 (continuous) |
| `loops/L03-security-issues.md` | Open security findings | `agents/09-security/security-coordinator.md` | F7, F9 |
| `loops/L04-code-smells.md` | Code smells above the threshold | `agents/13-guardians/quality-guardian.md` | F6, F9 |
| `loops/L05-inconsistencies.md` | Docs↔code↔data divergence | Agent that owns the source of truth | Continuous |
| `loops/L06-outdated-documentation.md` | Documentation out of sync | `agents/13-guardians/documentation-guardian.md` | F9 (and after every change) |
| `loops/L07-cves.md` | CVEs to triage | `agents/13-guardians/security-guardian.md` | F9 (cadence + event) |
| `loops/L08-technical-debt.md` | Recorded technical debt | Orchestrator + relevant agent | F9 (planned) |

## Related

- `core/orchestrator.md` — who opens/coordinates/closes the loops (§Recovery and exceptions: the
  origin of the rule of 3).
- `workflows/README.md` — the processes that open loops within the phases.
- `core/quality-gates.md` — what a loop must satisfy to close.
- `core/project-memory.md` — where each loop's ledger lives (`STATE.md`).
- `knowledge/ai-pitfalls.md` — the stubbornness and self-validation the loops stop.
- `core/model-routing.md` — which model executes the action vs. decides to stop.
