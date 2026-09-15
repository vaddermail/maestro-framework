# L02 — Failing Tests

> Loop `L02` of the Maestro framework — persists while failing tests exist, always fixing the
> **cause**, never the test (unless the test is proven wrong). Follows the anatomy in
> `loops/README.md`.

A failing test is the cheapest defect detector the framework has — and the easiest to defraud
("comment out the test", "raise the timeout", "delete the inconvenient assert"). This loop exists
so that the only accepted exit is the system behaving correctly, never a silenced detector.

## Identification

| Field | Value |
| --- | --- |
| **When it runs** | F6 (continuous, per slice); reopened in F7 by the regression harness and in F9 on every change |
| **Agent that executes the action** | The owner of the failing code — `agents/04-frontend/` or `agents/05-backend/` depending on the layer — fixes the cause; coordinated by `agents/10-quality/test-strategist.md`. "Wrong test" is only decided with attached proof (the requirement/spec it contradicts), never for convenience |
| **Suggested model** | Standard for the fix; escalates to Top if the root cause touches RBAC, a state machine or a critical flow with reversibility (`core/model-routing.md`) |

## Progress metric

Number of tests in `failing` state reported by the harness (unit + integration + E2E + regression,
summed), in the last complete run.

A test that is disabled, weakened, marked `skip`/`only`, or mocked to pass **does not lower the
metric**: it counts as no progress for the iteration (`knowledge/ai-pitfalls.md` §AR-22,
manipulated gate) and feeds the safeguard's stagnation count.

## Entry condition

The test harness reports ≥1 failing test in a run (local, CI, or regression).

## Action (the body of the iteration)

1. Isolate the failing test and identify the **root cause** — never stop at the first hypothesis;
   reproduce before fixing.
2. Decide: bug in the code (the general rule) or test proven wrong (the exception — attach the
   proof: which requirement/spec/acceptance criterion the test contradicts).
3. Apply the minimal, reversible fix to the cause (never to the symptom or the detector —
   `loops/README.md` §Cross-cutting principles). Changing the test, the threshold, a `skip`/`only`
   or a mock to go green counts as no progress for the iteration; a diff that touches tests, CI, or
   thresholds is reviewed by someone who did not write it (`checklists/pre-merge.md`).
4. Run the full suite locally, frontend and backend separately, **both** green before declaring
   the iteration done.

## Exit condition (success)

Zero failing tests, confirmed by an independent run of the harness (CI or another agent/reviewer —
never just the local run of whoever fixed it, which is self-validation).

## Anti-infinite-loop safeguard

- **Stagnation:** 3 consecutive runs without lowering the failing test count → stop.
- **Oscillation:** the same set of failing tests reappears (the fingerprint of the test list
  repeats) — a sign that the previous fix did not touch the cause, or introduced a regression that
  undoes the progress; stop immediately.
- **Hard cap:** 6 iterations per slice/PR. Once exceeded, escalate to the user: it may be a
  symptom that the slice is bigger than one session can solve, of an architectural problem, or of
  two contradictory requirements materialized in two tests that cannot both pass (in that case the
  problem actually belongs to `loops/L01-ambiguous-requirements.md`, not to this loop).

## STATE.md record

```
L02 · failing tests · metric 12→7→7 · iter 3 (cap 6) · last progress: iter 2 · status: AT RISK
```

## Example (e-commerce — cart and coupons)

The integration suite fails on `cart.apply-coupon.test`: a 20% coupon applied to a cart with an
item already on sale should return an error ("coupons do not stack with sale prices"), but the
test records that the discount was applied anyway. The initial hypothesis ("the test is outdated")
fails on verification: **BR-014** explicitly confirms that coupon and sale price do not stack. The
real cause is an `if` that only checks the first cart item, not all of them. The
`calculateDiscount` function is fixed to iterate over all items; the suite goes back to green on
both layers (unit for the calculation + integration for the checkout flow). Without this
discipline, the "quick fix" would have been commenting out the test — hiding a real billing bug.

## Related

- `agents/10-quality/README.md` — the category that provides the harness and the strategy.
- `agents/10-quality/test-strategist.md` — coordinates the suite and the safety net.
- `agents/10-quality/regression-test-engineer.md` — the harness that reopens this loop in F7/F9.
- `checklists/definition-of-done.md` · `checklists/pre-merge.md` — the gates this loop must satisfy.
- `core/quality-gates.md` — P6 does not pass with red tests.
- `knowledge/ai-pitfalls.md` — §2, "works without proof", this loop's twin pitfall.
