# 10 — Quality

The category that **proves the product works** — not by feeling, but by reproducible evidence.
It works mostly in **F6 (build)** and **F7 (quality & security)** of `core/lifecycle.md`,
and leaves behind a permanent asset: the **regression harness** that the guardians
(`agents/13-guardians/`) run forever in F9. The principle that runs through the whole category:
**quality proportional to risk** (`MANIFESTO.md` §9) — testing effort concentrates on business
rules, authorization, money, personal data and irreversible flows, not spread as blind coverage
over getters and setters.

## Agents in the category

| Agent | One line |
| --- | --- |
| `agents/10-quality/test-strategist.md` | Designs the strategy: what is tested, at which level, and what is faked (external I/O). |
| `agents/10-quality/unit-test-engineer.md` | Tests business rules and invariants in isolation, with fakes for everything that is I/O. |
| `agents/10-quality/integration-test-engineer.md` | Tests against the real DB, contracts and transactions — where fakes lie. |
| `agents/10-quality/e2e-test-engineer.md` | Walks profiles × pages and the critical flows end to end; closes with a real live smoke. |
| `agents/10-quality/performance-test-engineer.md` | Load, stress and traffic profiles against the known limits of the NFRs. |
| `agents/10-quality/regression-test-engineer.md` | Maintains the harness that keeps fixed bugs from returning, updated with every new flow. |
| `agents/10-quality/coverage-auditor.md` | Audits coverage by risk (not by percentage) and names the test gaps. |

## Recommended order of work

1. **Strategy first** (`test-strategist`) — defines the pyramid and the risk→level map **before**
   a single test is written. Without this, the engineers produce unbalanced coverage.
2. **Unit + integration in parallel per slice** (`unit-test-engineer`,
   `integration-test-engineer`) — each F6 vertical slice carries its own, as it is built.
3. **E2E of the critical flows** (`e2e-test-engineer`) — when there is a complete path to exercise.
4. **Performance** (`performance-test-engineer`) — near F7/F8, against the quantified NFRs.
5. **Regression** (`regression-test-engineer`) — continuously absorbs every test from the previous
   steps into the harness; it is the legacy that outlives the category.
6. **Coverage audit** (`coverage-auditor`) — at the F7 gate, verifies that the risk is covered.

The Orchestrator (`core/orchestrator.md`) assembles the graph from the **Inputs**/**Interactions**
sections of the agent specs, not from this rigid order. A slice's unit and integration tests run
with the build of that slice (`workflows/W06-build.md`); E2E, performance and the audit
concentrate at the phase gate.

## Duties shared by every agent in the category

- **Test the risk logic, not the trivial** (`knowledge/permanent-rules.md` §7). A test that would
  pass on any generic product is not worth the cost of maintaining it.
- **Fakes/mocks only for external I/O**; domain logic is tested for real (`test-strategist`).
- **The mock mirrors the real server** — same shapes, same write rules; a mock that lies gives a
  false green (`knowledge/proven-patterns.md` §7, `knowledge/ai-pitfalls.md` §AR-2).
- **The real live proof is an irreplaceable gate** — green tests prove the code does not break,
  not that it solves the problem (`checklists/definition-of-done.md`;
  `knowledge/ai-pitfalls.md` §AR-2).
- **Whoever produces does not validate** — reviewing the substance of the tests belongs to an
  independent agent, `agents/12-reviewers/test-reviewer.md` (`core/quality-gates.md`).
- **One DB per purpose.** The suite never runs against the development DB, and a migration is
  never rehearsed on a DB shared by live services: each purpose has its own disposable DB. On one
  project, the suite wiped the development DB; on another, migrating the shared DB desynced the
  services using it.

## This category's critical pitfall: heavy suites in parallel

Test suites with in-memory DBs, WASM or many processes **blow up the dev machine with OOM**
when run in parallel — it happened often enough in the origin project to become law
(`knowledge/ai-pitfalls.md` §AR-14). Rules that **every** agent in this category follows:

- **Heavy suites run serially** (no file-level parallelism), focused per file, in the foreground.
- **A subagent never runs the full suite in the background.** The "package-manager filter +
  pattern" idiom often **does not filter** (it runs everything) and kills the subagent silently.
  Use the runner directly, per file.
- **The controlling agent closes its subagents explicitly** and validates the green WIP by
  comparing the repository state with the report — it never leaves a subagent hanging on a monitor.

## How the Orchestrator convenes it

`workflows/W06-build.md` invokes unit and integration tests per slice;
`workflows/W07-quality-and-security.md` convenes E2E, performance and the `coverage-auditor` for
the F7 gate. The regression harness passes, in the end, to the stewardship of
`agents/13-guardians/quality-guardian.md`, which runs it on the F9 cadence.
The category **produces** tests; **reviewing** the strategy and the substance belongs to
`agents/12-reviewers/test-reviewer.md`.

## Related

- `agents/README.md` · `agents/_template/AGENT-TEMPLATE.md`
- `workflows/W06-build.md` · `workflows/W07-quality-and-security.md` · `core/quality-gates.md`
- `templates/technical/test-plan.md.template` · `checklists/definition-of-done.md`
- `agents/12-reviewers/test-reviewer.md` — the independent eyes on what this category produces.
- `agents/13-guardians/quality-guardian.md` — who inherits the harness in production.
