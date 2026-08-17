# PR Review

The checklist for the **independent** reviewer (never the author) before `checklists/pre-merge.md` —
the concrete operationalization of the rule "whoever verifies is never whoever produced"
(`core/quality-gates.md`). It focuses on the correctness and risk of the code, not on the state of
the repository (that is `checklists/pre-merge.md`).

## Functional correctness

- [ ] The code does what the specification/requirement asks — confirmed against
      `product/04-specification/`, not just against the PR description.
- [ ] Obvious domain edge cases considered (empty, zero, duplicate, concurrency) — not just the
      happy path.
- [ ] No duplicated logic that already exists elsewhere in the code (reuse instead of a parallel
      rewrite).

## Business rules and invariants

- [ ] Every business rule touched matches exactly what is numbered in
      `product/04-specification/`; divergence resolved (the spec wins, or the spec is updated
      first, in the open).
- [ ] Bidirectional relationships and data invariants kept consistent on both sides
      (`agents/06-data/data-modeler.md`).
- [ ] State machines respected: only allowed transitions, with the transition's full effects
      (`modules/state-machines.md`).

## Authorization and scoping

- [ ] Every decision about who can do/see what is enforced on the server, never only on the client
      (`modules/rbac-and-scoping.md`).
- [ ] Organizational scoping applied to **all** queries/endpoints touched, not just
      some.
- [ ] Sensitive fields hidden by server-side authorization, not just by not appearing on the screen
      (defense in depth).

## Tests

- [ ] New/changed tests exercise the risk logic (business rules, authorization,
      reversibility) — not just the happy path.
- [ ] Tests fail without the fix and pass with it — confirmed, not assumed.
- [ ] No test was weakened (assert removed, threshold raised) just to pass.

## Reversibility

- [ ] The change has a clear reversal path: simple revert, flag, or migration with a down plan
      (`knowledge/permanent-rules.md` §3).
- [ ] Destructive/bulk changes (delete, batch update) act by exact ID, never by
      substring/fuzzy search.

## Silent failures

- [ ] No empty error block or exception swallowed without a log; all degradation is visible
      (`knowledge/proven-patterns.md` §10).
- [ ] External I/O failures (network, queue, third-party API) handled explicitly, not ignored by
      default.
- [ ] Limits hit (truncate, skip, sample) are reported, never hidden as success.

## Related

- `checklists/pre-merge.md` — the next gate, which presumes this review is done.
- `agents/12-reviewers/README.md` — who executes it and the review panel format.
- `modules/rbac-and-scoping.md` — the authorization and scoping detail.
- `modules/state-machines.md` — the transitions and effects detail.
- `knowledge/proven-patterns.md` — visible fallbacks, SSOT, invariants.
- `knowledge/permanent-rules.md` — reversibility and destructive changes.
