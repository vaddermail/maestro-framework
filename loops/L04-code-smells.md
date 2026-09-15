# L04 — Code Smells

> Loop `L04` of the Maestro framework — persists while code smells above the agreed threshold
> exist, improving structure **without changing behavior**. Follows the anatomy in
> `loops/README.md`.

Duplication, complexity and coupling do not break the system today — they make every change more
expensive tomorrow. This loop exists so that readability debt is paid off in small, verifiable
slices, never in one "big refactor" nobody can review or revert as a block.

## Identification

| Field | Value |
| --- | --- |
| **When it runs** | F6 (per slice, on closing); F9 (guardian's cadence) |
| **Agent that executes the action** | `agents/13-guardians/quality-guardian.md` detects and measures; the code owner (`agents/04-frontend/` or `agents/05-backend/`) applies the refactor; a reviewer (`agents/12-reviewers/`) confirms behavior did not change |
| **Suggested model** | Economy for mechanical refactors (extract function, rename); Standard for restructurings with behavior risk (`core/model-routing.md`) |

## Progress metric

Number of violations above the threshold defined for the project's effort profile (duplication %,
cyclomatic complexity, function/module size, coupling) — total count reported by the guardian,
comparable cycle to cycle.

Default thresholds (in the F0 calibration the user accepts them or sets others — the agreed value
is recorded in the project's `CLAUDE.md`, §F0 Calibration; `workflows/W00-project-kickoff.md`
§Decision points):

| Profile | Duplication | Complexity per function | Function size |
| --- | --- | --- | --- |
| Prototype | — (loop disarmed) | — | — |
| Internal product | ≤5% | ≤15 | ≤80 lines |
| Commercial product | ≤3% | ≤10 | ≤60 lines |
| Enterprise platform | ≤2% | ≤10 | ≤50 lines |

## Entry condition

`agents/13-guardians/quality-guardian.md` reports ≥1 smell above the agreed threshold.

## Action (the body of the iteration)

1. Pick the smell with the highest **interest** (the one that makes future changes most
   expensive), not the biggest in lines.
2. Confirm (or write) the behavior test covering the area — it is the safety net proving that
   nothing changed; without it, no refactoring.
3. Refactor without changing observable behavior.
4. Run the suite before **and** after: they must be identical (same tests green, same functional
   result) — any difference is a regression, not an improvement.

## Exit condition (success)

Smell count ≤ the agreed threshold, with the behavior tests green before and after, confirmed by a
reviewer who did not do the refactor. The threshold is **never** raised so the smell "passes" —
that is gaming the metric (`loops/README.md` §Cross-cutting principles).

## Anti-infinite-loop safeguard

- **Stagnation:** 3 iterations without lowering the smell count → stop.
- **Oscillation:** refactoring A introduces an equivalent smell in B (duplication moved, not
  eliminated) → stop immediately; a sign that a shared abstraction is missing, not that more point
  refactoring is needed.
- **Hard cap:** 5 iterations per code area. Once exceeded, escalate to the user: it may signal an
  architectural problem a local refactor cannot solve (a candidate for
  `loops/L08-technical-debt.md` instead of an immediate fix).

## STATE.md record

```
L04 · code smells · metric 23→14→14 · iter 3 (cap 5) · last progress: iter 2 · status: AT RISK
```

## Example (data platform — ingestion pipeline)

The guardian reports the same "normalize column name" logic duplicated across four source
connectors (CSV, API, external DB, Excel file), each copy already slightly different from the
others — duplication above the threshold and a silent fork beginning. The data engineer first
writes a test pinning each connector's current behavior (even with the small differences), extracts
a shared, parameterizable `normalizeColumnName` function, and migrates the four connectors one by
one, running the suite between each migration. Result: four calls to the same function, zero
behavior change, smell closed. Without the prior pinning tests, the extraction would have
force-uniformized the real differences between connectors — a behavior change disguised as a
refactor.

## Related

- `agents/13-guardians/quality-guardian.md` — detects and measures the smells.
- `agents/13-guardians/README.md` — the guardian's cadence and common report.
- `checklists/definition-of-done.md` · `checklists/pre-merge.md` — per-slice checks of this loop.
- `pipelines/ci-quality.md` — the automated measurement that feeds the metric.
- `knowledge/proven-patterns.md` — the target patterns of many of these refactors.
- `loops/L08-technical-debt.md` — where a smell that is a structural symptom escalates.
