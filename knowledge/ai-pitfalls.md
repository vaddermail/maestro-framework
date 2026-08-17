# Pitfalls of AI-Assisted Development

Typical failures of people building software with AI agents — and how Maestro **blocks them by
construction**, not by reminder. Each pitfall names the framework mechanism that neutralizes it. For
the Orchestrator and the reviewers, this is a list of *smells* to hunt.

## Reasoning and truth

**1. Confident hallucination.** The AI invents an API, a fact, a number — with full confidence.
→ Block: absolute honesty (`knowledge/permanent-rules.md` §2); mandatory grounding in the
source of truth (`modules/single-source-of-content.md`); when in doubt, do not write. Reviewers
check facts against artifacts, not against the fluency of the text.

**2. "It works" without proof.** Green typecheck and tests taken as proof that the system does what
it should. → Block: **real live proof** is an irreplaceable gate (`checklists/definition-of-done.md`
§Per code change; `core/quality-gates.md`).
Green tests prove the code does not break; they do not prove it solves the problem.

**3. Assuming instead of asking.** Filling gaps with plausible assumptions. → Block: the
question engine (`core/question-engine.md`) and loop L01; a missing input **stops** the agent,
it does not invite it to guess.

**4. Accepting the brief as infallible.** Faithfully implementing a spec that contains a bug. →
Block: owner's mindset (`knowledge/permanent-rules.md` §1) — the implementer **questions** the
spec; a specialist may conclude "what I am being asked to do is wrong", and that is valid output.

## Scope and drift

**5. Doing more than what was asked (silent scope creep).** "While I was at it, I also redid…" →
Block: bounded vertical slices (`workflows/W06-build.md`); out-of-scope changes are the user's
decision (gates). Additive proceeds; destructive/lateral asks.

**6. Reopening closed decisions.** Re-litigating in every session what was already decided. →
Block: closed decisions (`core/decision-engine.md`); reopening requires material novelty and is
done in the open.

**7. Two sources of truth that diverge.** The AI duplicates a fact/label/rule "to be quick". →
Block: SSOT with automatic guardrails (`knowledge/proven-patterns.md` §4, §7).

## Memory and continuity

**8. State kept in the session's head.** Trusting that "I remember what we decided". → Block: memory
in files (`core/project-memory.md`); it is written down or it does not exist. Every session starts
by reading `STATE.md`.

**9. Losing the handover between sessions/tools.** Half-done work with no trail to resume from. →
Block: session-end protocol (`START-HERE.md` §2.5); pending items and decisions made on the owner's
behalf get recorded.

**10. A lesson relearned by repeating the bug.** → Block: `STATE.md` §Lessons with the *why* +
*how to apply*; promotion to `knowledge/` once it proves general. Rule: record the **provenance** of
hard rules so nobody "simplifies" them without understanding why they exist.

## Cost and scale of the AI process itself

**11. Top-tier model for everything.** Running mechanical work and every subagent on the most
expensive model. → Block: per-task routing (`core/model-routing.md`); what drains the budget is
**fan-out on the expensive tier**, not the strong model on the hard problem.

**12. Trusting unverified cost optimizations.** Assuming the caching/batching is saving money.
→ Block: mandatory skepticism — verify the real prerequisites before counting on the savings.

**13. Too many tools, too much context.** Loading plugins/documents that add no value **now** and
cost something in every session. → Block: evolutionary adoption (`adapters/claude-code.md`):
adopt when it makes sense, remove when it stops making sense.

## Concurrency, environment and tooling (execution pitfalls)

**14. Heavy suites/tasks in parallel blow up the machine.** WASM/in-memory-DB tests in parallel
→ OOM in the dev environment. → Block: run heavy suites serially; the subagent controller
closes them explicitly instead of leaving them hanging on a monitor (`agents/10-quality/README.md`).

**15. The dev engine hides concurrency bugs.** A lightweight DB engine that serializes races
production does not serialize. → Block: test locks/transactions against the real engine too; real
parity is a gate whenever the slice touches data (`agents/06-data/migration-engineer.md`).

**16. A dependency upgrade that silently breaks something.** E.g. error mapping changes without
warning. → Block: deliberate updates with changelog + tests (`playbooks/dependency-updates.md`);
the Dependency Guardian (`agents/13-guardians/dependency-guardian.md`) validates before
adopting.

**17. Changing a shared component/label and breaking distant tests.** → Block: **maximum-coverage**
verification that also sweeps whatever is one step away (`knowledge/permanent-rules.md` §7).

**18. Bugs that only exist in the real browser/runtime.** Components that behave differently from
what the unit test suggests. → Block: real live proof (§2) and an E2E smoke in the target
environment.

**19. Killing processes by name, not by port.** A "kill by name" kills the wrong process or misses
the right one. → Block: operate by exact identifier (echoing `knowledge/permanent-rules.md`
§4 — by ID, never by substring), including when managing processes.

## Verification

**20. Self-validation.** The AI that produced the work declares it done. → Block: independent
verification, always (`core/quality-gates.md`); whoever produces never validates.

**21. Trusting a single perspective.** A single reviewer/verifier gives the green light. → Block:
panels and **adversarial audit** (`playbooks/adversarial-audit.md`) — convergence of two
independent audits is high confidence, but even that gets verified.

## Related

- `knowledge/permanent-rules.md` — the rules these pitfalls justify.
- `knowledge/origin-lessons.md` — the real cases they came from.
- `core/orchestrator.md` §Orchestrator anti-patterns — the pitfalls specific to the coordinator
  role.
- `playbooks/adversarial-audit.md` — the method that hunts them in batch.
