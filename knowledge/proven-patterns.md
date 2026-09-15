# Proven Patterns

Architecture and operations patterns validated in real production. Not textbook theory: each one
solved a concrete class of defects in the origin project. The engineering agents and the modules
(`modules/`) implement them; this file is the *why* behind them.

## 1. Work queue with a single executor

Several points may **submit** work; **one** worker executes; deduplication by stable *fingerprint*.

- **Problem it solves:** duplicated effects (two emails, two jobs), races between producers,
  reprocessing after a failure.
- **How:** materialize the effect as a queue record **inside the transaction** of the fact that
  originates it (transactional outbox — see §3), with dedupe by stable key
  (`event:origin:recipient:context`) and `insert-if-absent`. A single executor drains the backlog,
  decoupled, with a per-channel kill switch. Failures are **logged**, never silent; one failing
  item never aborts the batch.
- **Detail:** `modules/job-queue.md`, `modules/ai-observability.md`.

## 2. Upsert by stable ID, never a blind insert

Syncs and imports do an **upsert keyed on a stable external identifier**, not inserts.

- **Problem it solves:** duplicates on every re-sync; loss of provenance.
- **How:** `insert-or-update` targeting the external ID; store the raw source payload as
  provenance; stamp origin + moment (`syncedAt`). The master system's truth prevails in the
  fields it manages.
- **Detail:** `modules/readonly-external-integrations.md`.

## 3. Transactional outbox — side effects inside the transaction

Emails, events and integrations are materialized in the same transaction as the fact that causes
them.

- **Problem it solves:** notifying about something that later rolled back; or losing the
  notification for something that was committed.
- **How:** `emitEvent(tx, …)` inside the transaction; delivery is asynchronous via the single
  executor (§1). Rollback ⇒ zero effects, with no extra code.

## 4. Single source of truth for everything that repeats

Any fact that appears in more than one place has **one** editable source; the rest **derives**.

- **Problem it solves:** the two copies diverge — the most stubborn bug class there is.
- **Applies to:**
  - **Data/relations:** store one side of the relation, derive the inverse by query; computable
    state is **never** a column (it is derived). E.g. license consumption is the *seat* record; the
    per-device software list is informational.
  - **Front-back contracts:** one schema declaration feeds validation, server types, client types
    and the API docs (`modules/single-source-of-content.md` §How to adopt it in a new product,
    step 7 (contracts)).
  - **UI content:** labels, tooltips and help in a single catalog that serves the screen **and**
    the grounding of any help AI (`modules/single-source-of-content.md`).
- **How to enforce it:** automatic guardrails (one test that sweeps everything and fails on any
  duplication outside the source) — see §7.

## 5. Invariants enforced at the lowest possible layer — AND replicated above

The rules that can **never** be violated live as DB constraints, **and** as application guards on
top.

- **Problem it solves:** a code bug or an unforeseen path violates the rule; the app alone is not
  enough.
- **How:** exclusivity → `CHECK`; "≤1 open relation per entity" → **partial** unique index
  (`WHERE ended_at IS NULL`); the app raises the friendly error, early; a test inserts the illegal
  row and **asserts the constraint violation by name**. "Current state" relations are modeled as
  history with `started_at/ended_at`.
- **Detail:** `modules/state-machines.md`, `agents/06-data/data-modeler.md`.

## 6. Authorization and data hiding are server-only (untrusted client)

Every decision about authority, scoping and hiding of sensitive fields lives on the server.

- **Problem it solves:** any client-side check can be bypassed; any field sent "just not shown" is
  read.
- **How:** the client **declares** intent (e.g. active profile); the server **confirms** against
  the roles actually granted. Filter in the *query* by the server-side identity; "outside my scope"
  returns **404, not 403** (it does not leak existence). **Fail-closed:** no profile → deny, never
  assume superuser. Sensitive data gets **defense in depth**: not emitted in the query **and**
  redacted on output per authorization.
- **Critical distinction:** *authorization* (which actions) and *scoping* (which data subset) are
  **distinct** axes — collapsing them creates bugs in both directions.
- **Detail:** `modules/rbac-and-scoping.md`, `agents/05-backend/authorization-specialist.md`.

## 7. Quality guardrails as tests that sweep everything

Product rules (content SSOT, UI conformance, invariants) only stick when they are **enforced by
tests** that sweep everything by convention — not by good will.

- **Problem it solves:** good intentions erode; a rule that is not checked stops being followed by
  the third sprint.
- **How:** one test that walks every module/key and fails if anything escapes the convention (every
  action has a tooltip; every label comes from the catalog; every secret is redacted). Design
  system components that **enforce the rule by construction** (you cannot create a button without a
  tooltip).
- **Detail:** `modules/single-source-of-content.md`, `pipelines/ci-quality.md`.

## 8. One shared service for operations with multiple entry paths

An operation reachable through several interfaces (portal, back office, API, CLI) keeps its
**effect logic in a single shared use case**; the paths differ only in presentation and
preconditions.

- **Problem it solves:** the *drift* where one path gains an effect the other forgets (a return
  that updates the mileage in one place and not the other).
- **How:** a single transactional core, reused; each path handles only its own UX and its own
  preconditions (e.g. the self-service path lands as "pending validation"; the manager path
  validates in one step).

## 9. State in orthogonal layers (base + overlay)

When two concerns compete for the same field (permanent vs temporary, published vs edit draft,
assignment vs reservation), separate them into **independent layers** and **derive** the presented
state — instead of overwriting destructively.

- **Problem it solves:** the bug class where a temporary action destroys permanent state (a
  short-term reservation that erases the base assignment).
- **How:** the entity has a base layer and an overlay layer applied on top without altering it; the
  displayed state is derived from both; ending the overlay reverts to the base, not to a global
  default.
- **Smell to recognize:** "this temporary action writes over a field that also holds long-term
  state" → decompose into layers.
- **Detail:** `modules/state-machines.md`.

## 10. Visible fallbacks, never silent

Every error/degradation path is **logged**; none is silently swallowed.

- **Problem it solves:** the system "works" while hiding failures that only surface once they are
  already an incident.
- **How:** missing config → **logged** no-op; channel failure → flagged and visible; 5xx exception
  → recorded with correlation. If a limit is hit (truncate, skip, sample), **say so** — silence
  reads as "covered everything" when it did not.

## 11. Live proof — the minimum evidence format

"Done", "tested" and "works" only count when they come with evidence in a format someone else can
reproduce and verify.

- **Problem it solves:** a paraphrased "works" is not reproducible — "tests ran" and "confirmed"
  are claims, not proof; without a minimum format, live proof degrades into a feeling with another
  name, and absolute honesty (`knowledge/permanent-rules.md` §2) is left without a criterion.
- **How:** every piece of done/tested/works evidence has **five fields**:
  1. **What** — the exact command, URL or action exercised.
  2. **Where** — the environment and commit (or build) it ran on.
  3. **Literal output** — a pasted excerpt, ≤20 lines, never paraphrased; for tests, the runner's
     summary line with the counts (passed / failed / skipped).
  4. **When** — date (yyyy-mm-dd).
  5. **Who verified** — and it is **≠ who did the work** (`knowledge/ai-pitfalls.md` §AR-20,
     self-validation).

  Missing a field → it is not evidence: record it as "unverified", never as done. This is the
  format of the `Evidence:` field in `STATE.md` §Done and what a gate requires before it passes.
- **Detail:** `checklists/definition-of-done.md` §Per code change;
  `core/quality-gates.md`.

## Related

- `modules/README.md` — the reusable implementation of these patterns.
- `knowledge/origin-lessons.md` — the concrete defects that proved them.
- `agents/05-backend/README.md` · `agents/06-data/README.md` — who applies them.
