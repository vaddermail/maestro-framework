# Entity Lifecycle · transactional onboarding and offboarding

> **Production validation:** 2nd confirmation in a domain distinct from the origin project (P2 —
> curation round of 2026-08; confirmed nuances: GDPR erasure is irreversible; the audit trail
> never stores PII in the clear — reference by id, so the trace survives erasure). The design
> holds; confidence rises.

Reusable module for the **entry and exit of long-lived entities** — people, customers, contracts,
devices, suppliers — which over their lifetime **accumulate resources and responsibilities**. The
critical point is the **exit**: release everything the entity held **atomically**, block if there
are responsibilities left to reassign, and leave an auditable terminal state.

## The problem it solves

An active entity keeps gaining links: an employee has equipment, accesses, a car, license seats;
a customer has subscriptions, open invoices, data; a contract has allocated resources. When it
leaves, each of those links **must be resolved** — and this is where products fail:

- **Partial release:** the equipment is released but the access is forgotten; midway through the
  process something fails and the entity is left in limbo (half in, half out).
- **Orphaned resources:** a license seat nobody released keeps costing; an access left active is
  a security risk.
- **Abandoned responsibilities:** the departing person was the one responsible for returning
  something, or the approver of an open process — and nobody reassigned it.

The exit must be **all-or-nothing** and **blocking when needed**. It is a direct application of
the atomic transaction with locks (`knowledge/origin-lessons.md` §C4) and of the service shared
by multiple channels (`knowledge/proven-patterns.md` §8).

## The model (concepts and entities, stack-agnostic)

- **Lifecycle entity** — has a `life state` that is an explicit machine
  (`modules/state-machines.md`): typically `pre-active → active → exiting → terminated`, with
  named transitions and effects.
- **Associated resources** — everything the entity holds and the exit must release:
  bidirectional relations (`device.owner ↔ collab.devs`), assignments, seats, accesses. The
  release puts each one back in its free state and keeps the other side of the relation coherent.
- **Reassignable responsibilities** — roles the entity occupies that **cannot be left empty**:
  being an approver, being responsible for an open return, owning a process. They are **gates**.
- **Blocking gate** — a precondition that **prevents** the exit from completing until resolved.
  It is not "skipped"; either the responsibility is reassigned, or the exit does not close
  (`modules/approval-engine.md` for the gate pattern).
- **Exit operation (offboarding)** — the single transactional use case that executes **all** the
  effects at once. It can be triggered through several channels (HR, backoffice, automatic on an
  event from the source system — `modules/readonly-external-integrations.md`), all with
  **identical effects** (`knowledge/proven-patterns.md` §8).
- **Auditable terminal state** — after the exit, **what** was released, **when** and **by whom**
  is recorded immutably (`modules/audit-and-provenance.md`). The terminal state does not reopen
  silently; reactivating is a new, recorded transition.

## Non-negotiable rules (numbered, verifiable)

1. **The exit is atomic: all-or-nothing.** All resources are released in the **same
   transaction**; if one step fails, nothing changes. Verifiable: inject a failure midway and
   assert the state stayed intact (no partial release).
2. **No resource is left orphaned.** On termination, every associated resource is free and
   coherent on both sides (`knowledge/proven-patterns.md` §4). Verifiable: after offboarding, a
   sweep finds no resource still linked to the terminated entity.
3. **Gates block completion.** If there is a responsibility left to reassign, the exit **does not
   close**; verifiable: trying to terminate with an unresolved gate is refused with a clear
   error.
4. **Identical effects through every channel.** Verifiable: triggering the exit through each
   channel produces the **same** final state (same test, different inputs) — no channel forgets
   an effect.
5. **Concurrency closed with locks.** The operation locks the central aggregate (`FOR UPDATE` or
   equivalent) to close the TOCTOU window between reading responsibilities and releasing
   resources (`knowledge/origin-lessons.md` §C4).
6. **The terminal state is auditable and explicit.** Verifiable: an immutable record exists of
   what was released, when and by whom; the entity ends in a named terminal state, not merely
   "deleted".
7. **Reversal is a new transition, not a magic `undo`.** Reactivating a terminated entity is a
   deliberate, recorded step — the resources do not "come back" on their own
   (`knowledge/permanent-rules.md` §3).

## How to adopt it in a new product (steps)

1. **Model the entity's life state machine** with the user (`modules/state-machines.md`): states,
   transitions, who may do each one.
2. **Inventory the associated resources** and how each one is released (set free + coherence of
   the inverse side).
3. **Identify the reassignable responsibilities** and turn them into explicit **gates**.
4. **Write the exit use case** as a single transactional core, with the aggregate locked,
   executing all the effects; secondary effects (notify, integrate) via the outbox
   (`modules/job-queue.md`).
5. **Wire every trigger channel** to that same use case — none reimplements the logic
   (`knowledge/proven-patterns.md` §8).
6. **Record the terminal state** in the audit trail (`modules/audit-and-provenance.md`).
7. **Test the risk logic:** atomicity under failure, absence of orphans, gates blocking,
   concurrency, parity across channels (`knowledge/permanent-rules.md` §7).

## Variations and trade-offs

- **Synchronous vs two-phase offboarding.** Synchronous (everything in one transaction) is the
  most correct for internal effects. **External** effects (revoking access in a third-party
  system) don't fit in the DB transaction — model them as outbox jobs, with the "revoking" state
  visible until confirmation (`modules/job-queue.md`,
  `modules/readonly-external-integrations.md`).
- **Hard gate vs warning.** A critical responsibility (sole approver, pending return) is a
  **hard** gate that blocks; a minor one can be a warning that gets recorded. Decide per type;
  never collapse everything into warnings (the protection is lost) nor everything into blocks
  (trivial exits stall).
- **Reversible vs definitive termination.** Prefer a terminal state **reversible via a new
  transition** (recorded reactivation) over deleting data — deletion is irreversible and rarely
  required early (`knowledge/permanent-rules.md` §3). Definitive purge, when mandatory (legal
  retention), is a separate operation, with a plan and a backup
  (`knowledge/permanent-rules.md` §4).
- **Light onboarding vs onboarding with gates.** The entry usually has fewer gates than the exit,
  but the pattern is the same: named transition, coherent effects, explicit state.

## Example (multi-domain)

**HR — employee exit.** Triggering the offboarding (by HR, from the backoffice, or automatically
when the directory marks the account inactive) runs a single transaction: it releases the
equipment (→ in stock), revokes the accesses, drops all of the person's license seats, unassigns
the car and sets the employee to `Departed`. **Gate:** if the person was the one responsible for
returns still open, the exit **does not close** until that role is reassigned — nothing is
released while the gate is unresolved. Everything lands in the audit trail; reactivating
(rehiring) is a new transition.

**SaaS — closing a customer account.** Terminating the subscription releases seats, cancels
provisioned resources and marks the account `closed` — atomically. **Gate:** if there is an open
invoice, the closure blocks until it is settled or explicitly forgiven. The data enters a
reversible retention period before any purge; revoking access to external services runs as jobs,
visible until confirmed.

## Known pitfalls

- **Release without a transaction:** releasing resource by resource outside a transaction leaves
  the half-in-half-out limbo at the first error — rule 1 is the heart of the module.
- **Forgetting the other side of the relation:** releasing `entity.resource` without resetting
  `resource.entity` reintroduces the bidirectional incoherence
  (`knowledge/proven-patterns.md` §4).
- **A channel that diverges:** implementing the exit in two places guarantees one gains an effect
  the other forgets — the return that updates a field in one place and not in the other (rule 4,
  §8 of the patterns).
- **An optional gate:** leaving the responsibility-to-reassign as a "warning" leaves approvers
  and returns orphaned; if it is critical, it blocks.
- **TOCTOU on exit:** reading "has no responsibilities" and releasing without a lock lets a new
  responsibility slip in between the read and the write (rule 5).
- **Terminating by deleting:** deletion is irreversible and loses the audit; the terminal state
  is a state, not a `DELETE`.

## Related

- `modules/state-machines.md` — the entity's life state as an explicit machine.
- `modules/approval-engine.md` — the blocking-gate pattern, separate from authorization.
- `modules/rbac-and-scoping.md` — who may trigger the exit and reassign responsibilities.
- `modules/job-queue.md` — external exit effects via outbox/single executor.
- `modules/audit-and-provenance.md` — the auditable terminal state.
- `modules/readonly-external-integrations.md` — exit triggered by a source-system event; external
  revocation.
- `knowledge/proven-patterns.md` — §4 SSOT/relations, §8 one shared service for N channels.
- `knowledge/origin-lessons.md` — §C4 (atomic transaction with locks).
