# Pitfalls of AI-Assisted Development

Typical failures of people building software with AI agents — and how Maestro **blocks them by
construction**, not by reminder. Each pitfall names the framework mechanism that neutralizes it. For
the Orchestrator and the reviewers, this is a list of *smells* to hunt.

> **Stable IDs:** pitfalls are identified by `AR-1`…`AR-24` and cited as `§AR-n`, immune to
> renumbering — for the same reason as H1–H5 in `core/artifact-protocol.md` §Handling rules. A
> new pitfall gets the next number; none is ever renumbered.

## Reasoning and truth

**AR-1. Confident hallucination.** The AI invents an API, a fact, a number — with full confidence.
→ Block: absolute honesty (`knowledge/permanent-rules.md` §2); mandatory grounding in the
source of truth (`modules/single-source-of-content.md`); when in doubt, do not write. Reviewers
check facts against artifacts, not against the fluency of the text.

**AR-2. "It works" without proof.** Green typecheck and tests taken as proof that the system does what
it should. → Block: **real live proof** is an irreplaceable gate (`checklists/definition-of-done.md`
§Per code change; `core/quality-gates.md`).
Green tests prove the code does not break; they do not prove it solves the problem.

**AR-3. Assuming instead of asking.** Filling gaps with plausible assumptions. → Block: the
question engine (`core/question-engine.md`) and loop L01; a missing input **stops** the agent,
it does not invite it to guess.

**AR-4. Accepting the brief as infallible.** Faithfully implementing a spec that contains a bug. →
Block: owner's mindset (`knowledge/permanent-rules.md` §1) — the implementer **questions** the
spec; a specialist may conclude "what I am being asked to do is wrong", and that is valid output.

## Scope and drift

**AR-5. Doing more than what was asked (silent scope creep).** "While I was at it, I also redid…" →
Block: bounded vertical slices (`workflows/W06-build.md`); out-of-scope changes are the user's
decision (gates). Additive proceeds; destructive/lateral asks.

**AR-6. Reopening closed decisions.** Re-litigating in every session what was already decided. →
Block: closed decisions (`core/decision-engine.md`); reopening requires material novelty and is
done in the open.

**AR-7. Two sources of truth that diverge.** The AI duplicates a fact/label/rule "to be quick". →
Block: SSOT with automatic guardrails (`knowledge/proven-patterns.md` §4, §7).

## Memory and continuity

**AR-8. State kept in the session's head.** Trusting that "I remember what we decided". → Block: memory
in files (`core/project-memory.md`); it is written down or it does not exist. Every session starts
by reading `STATE.md`.

**AR-9. Losing the handover between sessions/tools.** Half-done work with no trail to resume from. →
Block: session-end protocol (`START-HERE.md` §2.5); pending items and decisions made on the owner's
behalf get recorded.

**AR-10. A lesson relearned by repeating the bug.** → Block: `STATE.md` §Lessons with the *why* +
*how to apply*; promotion to `knowledge/` once it proves general. Rule: record the **provenance** of
hard rules so nobody "simplifies" them without understanding why they exist.

## Cost and scale of the AI process itself

**AR-11. Top-tier model for everything.** Running mechanical work and every subagent on the most
expensive model. → Block: per-task routing (`core/model-routing.md`); what drains the budget is
**fan-out on the expensive tier**, not the strong model on the hard problem.

**AR-12. Trusting unverified cost optimizations.** Assuming the caching/batching is saving money.
→ Block: mandatory skepticism — verify the real prerequisites before counting on the savings.

**AR-13. Too many tools, too much context.** Loading plugins/documents that add no value **now** and
cost something in every session. → Block: evolutionary adoption (`adapters/claude-code.md`):
adopt when it makes sense, remove when it stops making sense.

## Concurrency, environment and tooling (execution pitfalls)

**AR-14. Heavy suites/tasks in parallel blow up the machine.** WASM/in-memory-DB tests in parallel
→ OOM in the dev environment. → Block: run heavy suites serially; the subagent controller
closes them explicitly instead of leaving them hanging on a monitor (`agents/10-quality/README.md`).

**AR-15. The dev engine hides concurrency bugs.** A lightweight DB engine that serializes races
production does not serialize. → Block: test locks/transactions against the real engine too; real
parity is a gate whenever the slice touches data (`agents/06-data/migration-engineer.md`).

**AR-16. A dependency upgrade that silently breaks something.** E.g. error mapping changes without
warning. → Block: deliberate updates with changelog + tests (`playbooks/dependency-updates.md`);
the Dependency Guardian (`agents/13-guardians/dependency-guardian.md`) validates before
adopting.

**AR-17. Changing a shared component/label and breaking distant tests.** → Block: **maximum-coverage**
verification that also sweeps whatever is one step away (`knowledge/permanent-rules.md` §7).

**AR-18. Bugs that only exist in the real browser/runtime.** Components that behave differently from
what the unit test suggests. → Block: real live proof (AR-2) and an E2E smoke in the target
environment.

**AR-19. Killing processes by name, not by port.** A "kill by name" kills the wrong process or misses
the right one. → Block: operate by exact identifier (echoing `knowledge/permanent-rules.md`
§4 — by ID, never by substring), including when managing processes.

## Verification

**AR-20. Self-validation.** The AI that produced the work declares it done. → Block: independent
verification, always (`core/quality-gates.md`); whoever produces never validates.

**AR-21. Trusting a single perspective.** A single reviewer/verifier gives the green light. → Block:
panels and **adversarial audit** (`playbooks/adversarial-audit.md`) — convergence of two
independent audits is high confidence, but even that gets verified.

**AR-22. Manipulated gate.** The agent disables, deletes or weakens the test, raises the
threshold, adds `skip`/`only`, or mocks the dependency that was failing — to make the gate go
green. → Block: `checklists/pre-merge.md` (no test weakened); every diff that touches test files,
CI configuration or thresholds is reviewed by someone who did not write it
(`agents/12-reviewers/README.md`) and appears as its own item in the review report;
`loops/L02-failing-tests.md` counts "test changed to pass" as non-progress for the iteration.

## Context and delegation

**AR-23. Compacted context mistaken for complete context.** After compaction or in a long
session, the agent follows a summary of `CLAUDE.md`/`STATE.md`, reopens closed decisions, or
loses track of what was in progress. → Block: re-read `CLAUDE.md` and `STATE.md` §In progress
after any compaction and before every gate — if the summary contradicts the file, the file wins;
one slice per session (`workflows/W06-build.md`); the non-obvious goes into `STATE.md` at the end
of every block, not at the end of the session (`core/project-memory.md` §Anti-patterns).

**AR-24. Subagent report mistaken for state.** "Done and tested" returned by a subagent is not
the state of the repository. → Block: the controller validates the report against the diff and
the real output before accepting it (`agents/10-quality/README.md` §This category's critical
pitfall, generalized to all fan-out); no gate passes on the basis of a report with no evidence in
the format of `knowledge/proven-patterns.md` §Live proof.

## Related

- `knowledge/permanent-rules.md` — the rules these pitfalls justify.
- `knowledge/origin-lessons.md` — the real cases they came from.
- `core/orchestrator.md` §Orchestrator anti-patterns — the pitfalls specific to the coordinator
  role.
- `playbooks/adversarial-audit.md` — the method that hunts them in batch.
- `loops/L02-failing-tests.md` · `checklists/pre-merge.md` — where pitfall 22 is blocked.
