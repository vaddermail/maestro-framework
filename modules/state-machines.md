# State Machines · critical flows as explicit states and transitions

> **Production validation:** 2nd confirmation in a domain distinct from the origin project (P2 —
> 2026-08 curation round; nuance confirmed: **pure** machines in the shared api↔web contract, the
> api as the authority — never duplicated across layers). The design stands; confidence rises.

A module for modeling **any flow where an entity moves through phases** with irreversible effects
along the way — an order (cart → paid → shipped → delivered), an article (draft → in review →
published → archived), a support ticket (open → in progress → resolved → closed), a subscription
(active → suspended → cancelled). Instead of scattering `if state == …` across the code, the flow is
declared as an **explicit state machine**: the possible states, the **allowed transitions**, each
one's **transactional side effects**, **who** may trigger it, and which are the **irreversible
terminal states**. It is the skeleton the approvals and lifecycle modules use underneath.

## The problem it solves

When a critical flow lives spread across conditionals, a system's most expensive defects appear:

- **Impossible transitions that happen.** A "cancelled" order goes back to "shipped" because nowhere
  forbade that passage. The state becomes inconsistent and nobody knows how it got there.
- **Half-done effects.** The "ship" transition should decrement stock, charge the customer and
  notify; one path does two of the three and a failure leaves the world halfway, with no rollback.
- **Terminal states that reopen.** Something "refunded" or "deleted" — which should be final — gets
  touched again, corrupting data that had already closed the books.
- **Races on the transition.** Two concurrent actions read the same state and both transition,
  running the effect twice (charging twice, shipping twice).

The explicit state machine closes all four: only declared transitions are possible, each is atomic
with its effects, terminals are guarded, and the transition acquires a lock.

## The model (concepts and entities, stack-agnostic)

- **State (`state`)** — a named, finite phase of the entity. The set of states is closed and known;
  there are no implicit "states" formed by combinations of loose flags.
- **Transition (`transition`)** — a **declared** passage from an origin state to a destination one,
  with a name (`ship`, `cancel`, `publish`). What is **not** declared is **forbidden** — the
  transition matrix is an allow-list, not a deny-list.
- **Guard (`guard`)** — the precondition a transition requires to be legal (`stock available`,
  `payment confirmed`, `reviewer assigned`). A failed guard refuses the transition with a clear
  error, with no effect.
- **Effect (`effect`)** — the consequences the transition produces, **all in the same transaction**:
  data mutations, events emitted (via `modules/job-queue.md`/outbox), audit entries. Either
  everything happens, or nothing (rollback).
- **Transition authority** — who may trigger it (which role/scope), confirmed on the server
  (`modules/rbac-and-scoping.md`). *Being able to transition* is distinct from *the transition being
  legal*: authority is about the actor, the guard is about the state.
- **Terminal state (`terminal`)** — a state with **no outgoing transition**. It is irreversible by
  construction and guard-protected: no operation reopens it.
- **Overlay (orthogonal layer)** — when a temporary concern competes with the permanent state (a
  reservation over an assignment, an edit-draft over a published item), it is modeled as a
  **separate layer** applied on top, and the presented state **derives** from both — the permanent
  one is never overwritten (`knowledge/proven-patterns.md` §9).

## Non-negotiable rules (numbered, verifiable)

1. **Only declared transitions are possible.** The origin→destination matrix is an allow-list; any
   undeclared passage is refused. Test: attempting a transition outside the matrix fails with an
   invalid-transition error, without changing the state.
2. **Each transition is atomic with all its effects.** Mutations, events and audit run in the same
   transaction; a failure reverts everything. Test: forcing an effect to fail leaves the state
   **unchanged** and zero partial effects.
3. **The guard is evaluated before the effect, inside the transaction.** A failed precondition
   refuses without producing an effect. Test: a transition with a false guard changes nothing.
4. **Terminal states have no outgoing transition.** No operation reopens a terminal. Test: every
   transition out of a terminal state is refused; the matrix declares no exit from it.
5. **The transition acquires a lock on the entity (concurrency).** Read-decide-write without a lock
   allows two concurrent transitions (`knowledge/origin-lessons.md` C4/C8). Test: two simultaneous
   transitions on the same entity result in one applied and one refused, never both.
6. **Authority is confirmed on the server.** Whoever transitions is validated against the granted
   roles (`modules/rbac-and-scoping.md`), not against the client. Test: forging the role does not
   authorize the transition.
7. **The presented state derives; orthogonal concerns are layers.** A temporary action never
   overwrites permanent state; the overlay ends and the base is restored. Test: ending a temporary
   layer returns the exact base state that existed before, not a default.
8. **Every transition leaves a trail.** Who, when, from which state to which, and why
   (`modules/audit-and-provenance.md`). Test: the history reconstructs the entity's full path.

## How to adopt it in a new product (steps)

1. **Identify the critical flows** (those with irreversible effects or money/sensitive data
   involved) and, for each one, **enumerate the finite states**.
2. **Design the transition matrix** (origin → destination → name → guard → authority → effects) in a
   canonical document (`templates/specification/state-machine.md.template`).
3. **Mark the terminals** and prove they have no exit; decide which concerns are **overlays** rather
   than states (`knowledge/proven-patterns.md` §9).
4. **Enforce the invariants at the data layer** where possible (partial unique index for "≤1 open
   state", exclusivity `CHECK`) beyond the application guards (`knowledge/proven-patterns.md` §5).
5. **Implement each transition as a single transactional use case**, reused by every entry path
   (`knowledge/proven-patterns.md` §8) — portal, backoffice and API share the same core.
6. **Test the machine exhaustively**: every legal transition, every illegal transition refused,
   every guard, and the concurrency (`agents/10-quality/unit-test-engineer.md`).

## Variations and trade-offs

- **Simple machine vs statechart (nested/parallel states).** Most flows are solved with flat
  states; nesting (an "active" with sub-states) and parallel regions gain expressiveness at the
  cost of complexity — only when the domain truly demands it.
- **State as a column vs history with start/end.** Storing only the current state is simple but
  loses the path; modeling it as a history of periods (`start`/`end`) gives audit and
  "state as of a date" for free, but requires deriving the current one
  (`knowledge/proven-patterns.md` §5).
- **Actor-triggered vs time/event-triggered transitions.** Some transitions are human (approve,
  ship); others automatic (expire after 30 days, close after inactivity). The automatic ones run on
  a single executor (`modules/job-queue.md`), not on ad-hoc reads.
- **Synchronous effects vs via outbox.** Mutations of the aggregate itself stay in the transition;
  external effects (email, integration) are emitted as events in the same transaction and
  delivered asynchronously (`knowledge/proven-patterns.md` §3).

## Example (1–2, multi-domain)

**E-commerce order.** States: `cart → awaiting-payment → paid → preparing → shipped → delivered`,
with `cancelled` and `refunded` branches (terminals). The `pay` transition has the guard "payment
confirmed" and atomic effects: decrement stock, create invoice, emit the shipping event (Rule 2).
`delivered` and `refunded` are terminals with no exit (Rule 4) — a delivered order does not "go
back" to shipped. The concurrency between "cancel" and "ship" is resolved by lock (Rule 5): one
wins, the other is refused.

**Editorial publishing.** An article moves through `draft → in-review → approved → published →
archived`. "Publish" requires the guard "reviewer approved" and editor authority (Rule 6). An
**edit to an already published article** does not overwrite the published one: it creates an
edit-draft **overlay** that coexists, and the published version only changes when that edit is,
itself, approved and promoted (Rule 7, `knowledge/proven-patterns.md` §9).

## Known pitfalls

- **Deny-list instead of allow-list.** Trying to forbid the bad transitions always lets one
  through; only what is **declared** is allowed (Rule 1).
- **Effects outside the transition's transaction.** "I change the state and then fire the effects"
  loses effects when the app crashes midway, and leaves the world halfway with no rollback
  (Rule 2).
- **Reopening a terminal "just this once".** A final state that gains an exception stops being
  final and corrupts what closed within it (accounts, stock, invoices) (Rule 4).
- **Transitioning without a lock.** The read-decide-write window charges twice or ships twice under
  concurrency (Rule 5, `knowledge/origin-lessons.md` C4).
- **Overwriting permanent state with temporary state.** The short-term reservation that erases the
  base assignment is the bug class overlays prevent (Rule 7).
- **Derivable state stored as a column and diverging.** If the state can be derived from the facts,
  derive it; two copies diverge (`knowledge/proven-patterns.md` §4).

## Related

- `modules/approval-engine.md` — the approval chain is a state machine.
- `modules/entity-lifecycle.md` — onboarding/offboarding as transitions with resource release.
- `modules/job-queue.md` — external effects and time-based transitions run on a single executor.
- `modules/rbac-and-scoping.md` — the transition's authority is confirmed on the server.
- `modules/audit-and-provenance.md` — every transition leaves an immutable trail.
- `knowledge/proven-patterns.md` — §5 (dual invariants), §8 (shared service), §9 (layers).
- `templates/specification/state-machine.md.template` — where the transition matrix is documented.
