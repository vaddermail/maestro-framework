# Job Queue · single executor, multiple submission

> **Production validation:** 2nd confirmation in a domain distinct from the origin project (P2 —
> 2026-08 curation round; nuances confirmed: single executor, kill-switch via environment
> variable, failures never silent). The design stands; confidence rises.

Reusable module for **reliable asynchronous work**: several points of the system submit work,
**one** executor drains it, and no effect happens twice. It encapsulates the "queue with a single
executor" pattern (`knowledge/proven-patterns.md` §1) as a capability adoptable on its own.

## The problem it solves

Whenever an effect should not block the request that originated it — sending an email, calling an
external integration, recomputing an aggregate, generating a report — the temptation is to run it
inline. That chains three classic defects:

- **Duplicated effects:** two producers fire the same email; a retry resends what had already gone.
- **Lost effects:** the request confirms to the user, but the process dies before the effect runs.
- **Ghost effects:** the effect runs and **then** the transaction rolls back — something that never
  happened got notified.

The queue solves this by separating **submitting** (cheap, transactional, many) from **executing**
(one only, idempotent, observable). The detail of *why* is in `knowledge/origin-lessons.md` §C5.

## The model (concepts and entities, stack-agnostic)

- **Job** — a unit of work: `type`, `payload`, `fingerprint`, `state`, `attempts`, `availableAt`,
  `result/error`. It presumes no table, topic or file — it is the concept.
- **Producer** — any path that submits: an HTTP handler, a cron, a CLI command, a backoffice button.
  Submitting is `insert-if-absent` by `fingerprint`.
- **Fingerprint** — a **stable, deterministic** key identifying the effect, not the attempt:
  `type:entity:context` (e.g. `welcome-email:customer#4471`). Two producers with the same
  fingerprint produce **one** job.
- **Executor (worker)** — **single** per type of work. It claims eligible jobs, executes, marks the
  outcome. Single does not mean one machine: it means **one** consumer processes each job at a time
  (guaranteed by atomic lock/claim), even with several replicas.
- **Backoff** — on failure, the job returns to the queue with `availableAt` postponed exponentially
  (e.g. 1min, 5min, 25min) and `attempts++`.
- **DLQ (dead-letter queue)** — the destination of jobs that exhausted their attempts: they do
  **not** disappear, they stay visible for manual triage.
- **States** — `pending → running → completed` | `failed(→retry)` | `dead(DLQ)`. It is a small
  state machine (`modules/state-machines.md`).

Natural link to the **transactional outbox**: the job is inserted **inside the transaction** of the
fact that originates it (`knowledge/proven-patterns.md` §3), so rollback ⇒ zero jobs, with no extra
code.

## Non-negotiable rules (numbered, verifiable)

1. **Submission is `insert-if-absent` by fingerprint.** Verifiable: submitting the same fingerprint
   N times creates **one** job; a test asserts it.
2. **Only one executor effects each job.** The claim is atomic (lock/`SELECT … FOR UPDATE SKIP
   LOCKED` or equivalent). Verifiable: two workers in parallel over the same queue never execute the
   same job (concurrency test).
3. **Execution is idempotent.** Even if a job runs twice (failure after the effect, before marking
   completed), the net effect is a single one — idempotency belongs to the **handler**, anchored on
   the fingerprint.
4. **One item's failure never aborts the batch.** Each job is an independent transaction; an error
   marks that job and the executor moves on.
5. **Nothing fails silently.** Every error is logged with the fingerprint and correlation;
   exhausting attempts moves to the **DLQ**, never deletes (`knowledge/proven-patterns.md` §10).
6. **Retries with backoff and a ceiling.** There is a maximum number of attempts and a growing
   interval; without a ceiling, a poisoned job hammers the system forever.
7. **Each job's state is queryable.** There is a way to answer "where is this work?" without reading
   logs — pending, running, completed, dead, with attempt count and last error.
8. **Kill-switch per type/channel.** A job type can be suspended without a new deploy
   (`modules/feature-flags.md`); jobs pile up in `pending`, they are not lost.

## How to adopt it in a new product (steps)

1. **Decide the substrate** with the user (`core/decision-engine.md`): a table in the relational DB
   (the simplest and transactional — recommended by default), or a dedicated broker if volume
   demands it. Do not introduce queue infrastructure before needing it.
2. **Define the Job record** and the partial unique index on `fingerprint` **where** the job is
   still active (guarantees rule 1 at the lowest layer — `knowledge/proven-patterns.md` §5).
3. **Create the submission gateway** `enqueue(tx, type, payload)` that participates in the caller's
   transaction (outbox).
4. **Write the executor** with atomic claim, drain loop, backoff, DLQ and structured logging.
5. **Register the handlers per type**, each idempotent and with a fake in dev/test.
6. **Expose the state** (backoffice or endpoint) and wire the **per-type kill-switch** to the flags.
7. **Test the risky logic:** dedupe, two-worker concurrency, retry/backoff, path to the DLQ
   (`knowledge/permanent-rules.md` §7).

## Variations and trade-offs

- **Queue in the DB vs dedicated broker.** DB: transactional with the rest of the domain (trivial
  outbox), observable via SQL, great up to thousands/min. Broker (Redis/RabbitMQ/SQS/…): greater
  scale and fan-out, but the outbox stops being free and you gain a piece of infra to operate. Start
  in the DB.
- **Logical vs physical single executor.** A single replica avoids concurrency but is a single point
  of stoppage; several replicas with atomic claim (`SKIP LOCKED`) give fault tolerance while keeping
  "one per job". Prefer the latter as soon as availability matters.
- **Ordering.** The simple queue does not guarantee order across jobs; if order matters (events per
  aggregate), partition by key and serialize within the partition — see
  `agents/05-backend/events-specialist.md`.
- **Priorities.** A priority column or separate queues per class keeps heavy reports from delaying
  urgent emails — only once they compete for throughput.

## Example (multi-domain)

**E-commerce — order confirmation email.** On payment confirmation, the handler inserts, in the same
transaction, a job `order-confirmation-email:order#8812`. If the gateway confirms but the app
crashes before commit, the whole transaction reverts: no order and no email. If two gateway webhooks
arrive (normal duplication), the fingerprint guarantees a single email. The executor sends; if SMTP
fails, backoff and retry; after 5 attempts, a DLQ visible for support to investigate.

**Data platform — reprocessing a batch.** A nightly cron and a "reprocess now" backoffice button
both submit `recalculate-aggregate:2026-07`. Since they share the fingerprint, coinciding in time
they generate **one** job, not two concurrent recalculations over the same partition.

## Known pitfalls

- **A fingerprint that includes the attempt** (timestamp, random UUID) defeats the dedupe — it must
  be stable on the **effect**, not on the event.
- **A non-idempotent handler** turns a legitimate retry into a duplicated effect; rule 3 is about
  the handler, not the queue.
- **A DLQ nobody looks at** is a silent graveyard — it needs an alert and an owner
  (`agents/13-guardians/README.md`).
- **Effect before commit** (send the email and *then* persist) reintroduces the ghost effect; the
  job joins the transaction, delivery is always post-commit.
- **Non-atomic claim** (read-mark-execute without a lock) reopens the TOCTOU race that rule 2 closes
  — see `knowledge/origin-lessons.md` §C4.
- **Without an attempt ceiling**, a poisoned job consumes the executor indefinitely.

## Related

- `knowledge/proven-patterns.md` — §1 single queue, §3 outbox, §10 visible fallbacks.
- `agents/05-backend/queue-specialist.md` — the agent that implements this module.
- `agents/05-backend/events-specialist.md` — outbox, ordering and event idempotency.
- `modules/state-machines.md` — the job's states as an explicit machine.
- `modules/feature-flags.md` — the per-type/channel kill-switch.
- `modules/ai-observability.md` — when jobs call AI models, account for the consumption.
- `knowledge/origin-lessons.md` — §C4 (locks/TOCTOU), §C5 (outbox).
