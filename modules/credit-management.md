# Credit Management · generic balance-and-consumption ledger

A module to **account for and limit** the consumption of any measurable, chargeable resource —
calls to an AI model, requests to a paid API, processing minutes, SMS sends, tool executions. It
gives a product a **per-account balance**, an **immutable history** of everything that came in and
went out, **tariffs** that convert usage into cost, **quotas** that stop abuse and a
**kill-switch** to cut consumption in an emergency. It serves individual users and organizations,
with hierarchy between them.

## The problem it solves

Whenever a product lets users consume something that **costs money on every use**, three defects
show up together:

- **A balance that lies.** Storing a `balance` field and `update`-ing it on every operation
  creates races (two simultaneous consumptions read the same balance and both deduct from the old
  value) and makes it impossible to reconstruct *how* that number was reached. When the customer
  disputes the invoice, there is no answer.
- **Consumption with no ceiling.** Without a quota, a looping bug or a malicious user drains the
  budget before anyone notices — the first signal is the provider's invoice.
- **No way to stop.** When cost spikes, there is no button that cuts consumption **without a new
  deploy**.

The module solves all three with one central principle: **the balance is never written, it is
derived** from a history of movements that only grows.

## The model (concepts and entities, stack-agnostic)

- **Account (`account`)** — the balance holder. It can be a user, an organization, a project or
  an environment. Accounts can form a **hierarchy** (an organization with per-team sub-accounts);
  in that case, decide whether the quota is top-level, shared, or per sub-account (see
  Variations).
- **Movement (`movement`)** — an **immutable**, dated fact: a credit (in) or a debit (out), with
  amount, reason, a reference to the operation that originated it (idempotency — see Rule 4) and
  author. A movement is never edited nor deleted; a mistake is corrected with a **reversal
  movement** that cancels it, leaving both in the history.
- **Balance** — **not a field**; it is the sum of the account's movements (`Σ credits − Σ
  debits`). A **derived, cached** value can be kept for fast reads, but the source of truth is
  always the history, and the cache reconciles from it.
- **Tariff (`tariff`)** — the rule that converts a unit of usage into a credit amount (`per 1000
  tokens of model X`, `per call to API Y`, `per minute of transcoding`). Versioned: a tariff
  changes over time, and an old movement keeps the tariff that **was in force** when it happened.
- **Quota (`quota`)** — a limit on an account within a window (per day, per month, total). It can
  be **hard** (blocks when reached) or **soft** (lets it pass but alerts). Distinct from the
  balance: an account can have balance and still be limited by quota.
- **Kill-switch** — a per-account, per-tariff or global switch that, when on, makes every
  matching debit be **denied** without touching the code (a case of `modules/feature-flags.md`).

Reserve/consume happens in **two phases** when the cost is only known at the end (see Rule 5):
reserve an estimate, execute, adjust to the real value.

## Non-negotiable rules (numbered, verifiable)

1. **The balance is derived, never written.** No operation does `SET balance = …`. Test: summing
   all of an account's movements must yield exactly the displayed balance; a cached value that
   diverges from the sum is a defect.
2. **Movements are immutable.** No code path updates or deletes an existing movement. A
   correction is always a **new** reversal movement referencing the original. Test: trying to
   edit a movement is rejected by the data layer (constraint/append-only), not just by the app.
3. **Every debit is atomic with the effect it pays for.** Debiting and executing the charged
   operation happen in the **same transaction** (or with reserve-confirm — Rule 5). Never execute
   the operation and debit "later"; never debit and execute without guaranteeing the debit. Test:
   a rollback of the operation leaves zero movements.
4. **Debits are idempotent by stable reference.** Each debit carries the key of the operation
   that originated it; repeating the same operation does not create a second debit. Test:
   submitting the same operation twice (retry) results in a single movement.
5. **Unknown cost consumes in two phases: reserve → confirm/release.** When the real cost is only
   known at the end, reserve an estimate (already counted against the available balance),
   execute, and adjust to the real value (confirm the excess or release the remainder). Test: a
   reservation never confirmed expires and is released; the available balance reflects open
   reservations.
6. **The quota is checked before the debit, inside the same lock.** Reading the quota, deciding
   and debiting without a lock has a race (TOCTOU — `knowledge/origin-lessons.md` C8). Test: N
   concurrent consumptions against a quota of N−1 leave exactly one failing.
7. **The kill-switch denies fail-closed.** When on, the matching debit is refused with a clear
   error; it never "slips through by mistake". Test: with the switch on, every charged operation
   is blocked and recorded.
8. **Every balance/quota decision lives on the server.** The client never decides whether it has
   balance; it declares the intent and the server confirms (`modules/rbac-and-scoping.md`). Test:
   forging the request does not bypass the quota.
9. **Every movement is auditable.** Who, when, how much, why and which operation — no gaps
   (`modules/audit-and-provenance.md`). Test: any debit leads back to the operation and the
   author.

## How to adopt it in a new product (steps)

1. **Delimit the charged resource and its unit** (tokens? calls? minutes?) and what an
   **account** is in the product (user, organization, both with hierarchy).
2. **Model** `account`, `movement` (append-only), `tariff` (versioned) and `quota`, with the
   balance as a **derived query** — never an editable column (`agents/06-data/data-modeler.md`).
3. **Enforce the invariants at the lowest layer** (`knowledge/proven-patterns.md` §5):
   append-only via constraint/trigger; debit+effect in the same transaction with a lock on the
   account.
4. **Choose the variants** (prepaid vs postpaid; top-level vs per-sub-account quota;
   reserve-confirm vs direct debit) and **record them in an ADR**
   (`templates/project/ADR-DECISION.md.template`).
5. **Wire the kill-switch** to the flags module (`modules/feature-flags.md`) and the
   balance/quota alerts to observability (`modules/ai-observability.md` when the resource is AI).
6. **Expose the history to the holder** (statement) and the limits (quota used/remaining), with
   the texts coming from the single source (`modules/single-source-of-content.md`).

## Variations and trade-offs

- **Prepaid vs postpaid.** Prepaid (the balance must be positive before consuming) protects the
  provider but slows the user down; postpaid (consume and invoice at the end, with a credit
  limit) is more fluid but takes on bad-debt risk. Many products combine both: postpaid up to a
  ceiling, prepaid above it.
- **Direct debit vs reserve-confirm.** Direct debit is simpler and serves cost known up front (a
  call with a fixed price); reserve-confirm is mandatory when the cost is only known at the end
  (token streaming, variable-duration transcoding).
- **Top-level vs per-sub-account quota.** In an organization, a single top-level quota is simple
  but lets one team drain the others' budget; per-sub-account quotas isolate but require
  allocation management.
- **Balance cache: yes or no.** Deriving the balance by summing movements is correct but
  expensive on accounts with millions of rows; a reconcilable cache (periodic snapshot +
  movements since) solves it without violating Rule 1.

## Example (1–2, multi-domain)

**SaaS platform with AI.** Each organization has a credit account. An assistant's answer reserves
credits from a token estimate, makes the model call, and confirms with the real consumption
returned by the provider (Rule 5). The tariff is per model and versioned (the price changed → new
tariff, old statements keep the old one). A per-model kill-switch cuts the most expensive one if
the month's cost spikes (ties into `modules/ai-observability.md`). The statement shows every
request and its cost; the admin sees the monthly quota consumed.

**SMS-sending marketplace.** Each customer preloads balance. Sending a campaign debits one
movement per batch, idempotent by the campaign reference (Rule 4) — resending on a timeout does
not charge twice. The tariff varies by destination country. A hard daily quota keeps a looping
script from draining the balance before the customer notices (Rule 6).

## Known pitfalls

- **Storing `balance` as a column and "keeping it up to date".** The origin of the races and the
  irreconcilable invoices. The balance is **derived** (Rule 1); if a cache is needed, it
  reconciles from the history.
- **Debiting outside the effect's transaction.** "I call the API and deduct afterwards" loses
  debits when the app dies midway; "I deduct and then call" charges without delivering. It must
  be atomic (Rule 3).
- **Forgetting retry idempotency.** Every network retry becomes a duplicate debit. Without a
  stable operation key, the customer pays double (Rule 4).
- **Checking the quota before acquiring the lock.** It creates the TOCTOU window where N
  concurrent requests all pass a quota that only covered one (Rule 6,
  `knowledge/origin-lessons.md` C8).
- **An unversioned tariff.** Changing the price retroactively rewrites the history's cost — last
  month's statement changes on its own. The tariff is stamped onto the movement when it happens.
- **Reservations that never expire.** A reservation stuck on an aborted operation "eats"
  available balance forever; every reservation has an expiry term (Rule 5).

## Related

- `modules/ai-observability.md` — when the charged resource is AI: tokens/cost per model and
  alerts.
- `modules/feature-flags.md` — the consumption kill-switch is a flag switchable off without a
  deploy.
- `modules/audit-and-provenance.md` — every movement is an immutable audit entry.
- `modules/rbac-and-scoping.md` — the balance/quota decision lives on the server, untrusted
  client.
- `knowledge/proven-patterns.md` — §4 (the balance is derived) and §5 (invariants at the lowest
  layer).
- `agents/06-data/data-modeler.md` — models the append-only ledger and the constraints.
- `agents/13-guardians/cost-guardian.md` — watches the real cost against the budget.
