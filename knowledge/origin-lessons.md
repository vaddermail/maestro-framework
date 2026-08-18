# Origin Lessons

**Generalized** lessons from the origin project — a real product built from scratch with AI, which
went from an HTML prototype to a real TypeScript monorepo through ~40 vertical slices, two
adversarial audits and a mature team process. The origin project's domain stays out; what
generalizes is the **system of work** and the engineering patterns.

Each lesson carries the *why* and the *how to apply*. They are the defect memory the framework
inherits so it does not repeat them in another product.

---

## A. Specification and memory

**A1. Layered, numbered spec with explicit precedence, agnostic of technology.**
The sources of truth are organized in layers with a declared reading **and** precedence order,
plus a written tie-break rule (prototype diverges from the spec → the spec wins, the divergence
gets recorded). The spec describes the *what/why* (rules, flows, states) and never the *how*
(stack, DB) — that lives in separate ADRs.
- *Why:* it gives agents a **deterministic** path to resolve contradictions without inventing; and
  it allows swapping the stack without rewriting the product's intent.
- *Apply:* `core/artifact-protocol.md` + `core/project-memory.md`; specs in
  `product/04-specification/`, decisions in ADRs.

**A2. The spec is also defect memory.** Annotate every hard rule with its **provenance** (the
defect/decision that originated it).
- *Why:* it stops a future agent from "simplifying" a safeguard because it does not see why it
  exists.
- *Apply:* mandatory provenance (`core/project-memory.md` §Memory hygiene).

**A3. STATE.md is the handover: hyper-detailed top, collapsed history.**
- *Why:* a state file that grows without hygiene stops being findable — memory nobody reads is not
  memory.
- *Apply:* `core/project-memory.md`; also record **decisions taken on behalf of the absent
  owner**, as revisitable.

**A4. Give the full spec up front and self-contained plans, task by task.**
- *Why:* it cuts round-trip turns and reduces AI cost; an implementer with full context makes
  fewer mistakes.
- *Apply:* `core/model-routing.md` §6; `workflows/W06-build.md`.

---

## B. Business rules and integrity

**B1. Three orthogonal control mechanisms that do not substitute for each other:** eligibility
gate (blocks the flow early) ≠ authorization approval (closes the flow) ≠ tier proportional to a
value. Thresholds **configurable in data, never fixed per profile nor in code**; every decision
persists the path used.
- *Why:* collapsing the mechanisms makes the system rigid and auditing impossible.
- *Apply:* `modules/approval-engine.md`.

**B2. Authority ≠ scoping — distinct axes.** *Authority* = which actions I can take; *scoping* =
which subset of data I see. Collapsing them creates bugs in both directions.
- *Why:* it was a real source of defects; a profile can have broad authority and narrow scoping,
  or the reverse.
- *Apply:* `modules/rbac-and-scoping.md`.

**B3. One source of truth per fact; the inverse is derived.** Bidirectional relationships store
one side and derive the other; computable state is **never** a column.
- *Why:* two editable copies of the same fact diverge — the most stubborn class of bug.
- *Apply:* `knowledge/proven-patterns.md` §4; `agents/06-data/data-modeler.md`.

**B4. Hard invariants in the DB + guards in the app.** The constraint is the last line of
defense; the app gives the friendly error. Test the constraint by inserting the illegal row and
asserting the violation by name.
- *Apply:* `knowledge/proven-patterns.md` §5.

**B5. State in orthogonal layers (base + overlay).** A temporary action must never destroy
permanent state; decompose and derive the presented state.
- *Apply:* `modules/state-machines.md`; `knowledge/proven-patterns.md` §9.

**B6. One operation with N entry paths = one shared service.** The paths differ only in
presentation and preconditions; the effect is the same code.
- *Apply:* `knowledge/proven-patterns.md` §8.

**B7. Seed demo data with dates relative to an anchor date, never absolute.**
- *Why:* a demo with fixed dates "ages" and starts showing everything as late/expired.
- *Apply:* `agents/06-data/data-modeler.md` (seeds).

---

## C. Backend and data (engineering)

**C1. Untrusted client: authorization, scoping and hiding of sensitive data 100% server-side.**
The client declares intent (active profile via header); the server confirms. Out of scope → 404,
not 403. Fail-closed (no profile → deny, never superuser).
- *Why:* a fail-open `?? "ADMIN"` turned "no profile" into "full access" — it existed and was
  fixed.
- *Apply:* `modules/rbac-and-scoping.md`; `agents/05-backend/authorization-specialist.md`.

**C2. A data contract in a single declaration feeds validation + server types + client types +
API docs.** An intermediate snapshot (e.g. OpenAPI) decouples the frontend's pace without losing
typing.
- *Why:* it eliminates drift between "what is validated", "what the type says" and "what the doc
  promises".
- *Apply:* `modules/single-source-of-content.md` §How to adopt it in a new product, step 7
  (contracts); `agents/05-backend/api-designer.md`.

**C3. Uniform module anatomy:** thin edge (protocol) → orchestration (authorization +
composition) → business rule (pure/transactional function that receives the DB connection).
- *Why:* the hard logic stays testable without HTTP and composable inside larger transactions.
- *Apply:* `agents/05-backend/README.md`.

**C4. Critical operations in one transaction, with pessimistic locks.** `FOR UPDATE` on whoever
mutates the central aggregate, shared lock on the inverse operation that only needs it not to
change. Closes TOCTOU windows.
- *Apply:* `knowledge/proven-patterns.md` §1,§5; `modules/entity-lifecycle.md`.

**C5. Transactional outbox for side effects.** Emit the event inside the transaction; delivery by
a single executor, idempotent by fingerprint; kill-switch per channel; failures logged.
- *Apply:* `modules/job-queue.md`.

**C6. Errors the UI acts on carry a structured payload, not just a string.** A single, standard
error format across the whole API (e.g. problem+json), with extension members so the UI reacts
without fragile parsing.
- *Apply:* `agents/05-backend/api-designer.md`; `agents/04-frontend/api-integrator.md`.

**C7. Expand-contract migrations; validate constraints in two phases with legacy data.** New
CHECK applied without validating the legacy rows, then backfill + validation. Never drop/rename
what is in use.
- *Apply:* `playbooks/expand-contract-db-migration.md`.

**C8. Distinguishing NULL from FALSE and closing TOCTOU are details that bite.** A CHECK only
rejects on strict FALSE (NULL passes); read-decide-write without a lock has a race.
- *Apply:* `agents/06-data/data-modeler.md` (SQL pitfalls).

**C9. External integration behind a port, with a fake adapter in dev and idempotent upsert by
external ID.** Store the raw payload as provenance; write-back as a port from early on (even
no-op).
- *Apply:* `modules/readonly-external-integrations.md`.

---

## D. Frontend and content

**D1. A single catalog of UI content (labels + tooltips + help), typed, with a key convention.**
It serves the screen **and** the grounding of any help AI — including modules not yet built,
marked "Planned".
- *Apply:* `modules/single-source-of-content.md`; `agents/11-documentation/user-help-writer.md`.

**D2. Product rules only stick if enforced by tests that sweep everything by convention.** Tooltip
on every action, label always from the catalog, no hardcoded colors → a test that fails if
anything slips through.
- *Apply:* `knowledge/proven-patterns.md` §7; `pipelines/ci-quality.md`.

**D3. Encapsulate library workarounds in design system components, with the why inline.**
- *Why:* there are browser-only bugs (e.g. a tooltip that does not fire on a disabled button)
  nobody should rediscover.
- *Apply:* `agents/03-experience/component-architect.md`.

**D4. Central design tokens with a semantic layer; light theme by default; mobile-first tested on
the real viewport.** Recurring pitfall: grids that break for lack of `min-width:0` on children.
- *Apply:* `agents/03-experience/design-system-architect.md`,
  `agents/03-experience/responsiveness-specialist.md`, `checklists/web-performance.md`.

**D5. Mocks mirror the server with the same logic** (upsert by id, dedupe, error format) and keep
parity; runtime shape validation enabled only in dev/test.
- *Apply:* `agents/04-frontend/api-integrator.md`.

---

## E. Process, verification and cost

**E1. The real live proof catches defects that hundreds of green tests never see.** It is an
irreplaceable gate before declaring "it works".
- *Apply:* `checklists/definition-of-done.md` §Per code change — the real live proof is the gate;
  the tool-specific materialization lives in `adapters/claude-code.md`.

**E2. The final adversarial review of the branch catches cross-slice regressions that per-slice
reviews never see.** The convergence of two independent audits is high confidence — but even that
gets verified.
- *Apply:* `playbooks/adversarial-audit.md`; `workflows/W12-global-review.md`.

**E3. Guardrails as CI tests + a two-level pipeline** (fast in-memory tests + a real parity job).
And always keep a **local merge gate** for when hosted CI becomes unavailable (cost/minutes).
- *Apply:* `pipelines/ci-quality.md`, `pipelines/ci-security.md`.

**E4. Generated snapshots/artifacts (OpenAPI, clients, schemas) are regenerated by command, never
by hand.** And the contract snapshot is identical across consumers.
- *Apply:* `agents/05-backend/api-designer.md`; `pipelines/ci-quality.md`.

**E5. The agent's toolset is versioned in the repo, with evolutionary adoption.** The team uses
the same tools; adopt what adds value **now**, remove what stops adding it — every change recorded
with the why. Failed tooling experiments get recorded so they are not repeated.
- *Apply:* `adapters/claude-code.md`.

**E6. Model routing per task; fan-out on the expensive tier is what drains the budget.** A strong
model at low effort beats a weak model at maximum effort. Cost rules evolve with the budget and
are versioned with the why.
- *Apply:* `core/model-routing.md`.

**E7. Subagents die in long suites or when yielding to a monitor; the controller closes them
explicitly.** Heavy suites (WASM/in-memory DB) in parallel blow up the machine via OOM.
- *Apply:* `agents/10-quality/README.md`; `knowledge/ai-pitfalls.md` §14.

**E8. Owner's mindset: flag risks BEFORE implementing; destructive/mass changes come with a plan
+ a list.**
- *Apply:* `knowledge/permanent-rules.md` §1,§4.

---

## What **not** to generalize (warnings)

- Flow names and rule sets specific to the origin domain are **examples** of the mechanics —
  generalize the pattern (atomic transaction, outbox, double invariants, authority services), not
  the domain.
- Concrete stack choices (lightweight DB engine in dev, exact library combination, "numeric as
  string" for money) are that project's trade-offs — the pattern matters, the choice is decided
  case by case (`core/decision-engine.md`).
- Framework idioms (guards/decorators of a specific framework) illustrate the *idea* (two
  authorization layers, policy in the DB), not an implementation to copy.

## Related

- `knowledge/permanent-rules.md` · `knowledge/proven-patterns.md` · `knowledge/ai-pitfalls.md`
- `modules/README.md` — the modules that encapsulate these lessons.
- `core/project-memory.md` — how new lessons rise from a project into here.
