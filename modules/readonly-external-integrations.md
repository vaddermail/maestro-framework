# Read-Only External Integrations · the master system is an assumed contract

Reusable module for data whose **truth lives in another system**: an identity directory, an ERP, a
project system, a product catalog. The product **reads** and reflects, **never edits** the fields
the source manages — and behaves honestly when the source is unavailable.

## The problem it solves

Many products consume data that does not belong to them. The temptation is to copy it and start
treating it as their own — and then:

- fields managed out there become **editable** here, the two copies diverge, and nobody knows which
  is the truth (the bug class of `knowledge/proven-patterns.md` §4);
- every re-sync creates **duplicates** by doing a blind insert instead of an upsert;
- when the source goes down, the product either shows stale data as if fresh, or blows up — instead
  of honestly saying what it knows.

The correct posture is treating the external system as an **assumed contract**: read-only, with a
source stamp, and an explicit degraded behavior.

## The model (concepts and entities, stack-agnostic)

- **Master system** — the source that **owns** a set of fields. For those fields, the product is a
  **mirror** — never a co-author.
- **Local replica** — the copy the product keeps to be able to function and do *joins*. Each record
  carries the **stable external ID**, the **stamp** (`source`, `syncedAt`) and, ideally, the **raw
  source payload** as provenance (`modules/audit-and-provenance.md`).
- **Externally managed fields vs local fields.** An entity may have fields coming from the source
  (read-only) **and** fields owned by the product (editable) — the boundary is explicit, not
  implicit. E.g.: an employee's name and department come from the directory; the theme preference
  is local.
- **Integration gateway (adapter)** — the only point that talks to the external system, behind an
  interface. In dev/test, a **fake adapter** returns sample data (`knowledge/origin-lessons.md`
  §C9).
- **Synchronization** — the process that brings data from the source: `upsert by external ID`,
  never a blind insert (`knowledge/proven-patterns.md` §2). It runs on a single executor
  (`modules/job-queue.md`).
- **Write-back (optional)** — when the product *needs* to propose changes to the source, it is
  **also** a gateway, from early on, even if it starts as a no-op; it does not dissolve into local
  logic.

## Non-negotiable rules (numbered, verifiable)

1. **Fields managed by the source are read-only in the product.** Verifiable: no form or endpoint
   edits them; an attempt is rejected by the server, not just hidden in the UI
   (`knowledge/proven-patterns.md` §6).
2. **Synchronization is an upsert by stable external ID.** Verifiable: syncing the same batch N
   times creates no duplicates (idempotency test).
3. **Every replicated record carries a source stamp.** `source` + `syncedAt` present; verifiable by
   schema/test. The UI can show "updated X ago".
4. **The source prevails on the fields it manages.** In a conflict, the master system's truth wins
   on its fields; local fields are untouched by the sync.
5. **Honest behavior when the source is unavailable.** Verifiable: with the adapter failing, the
   product serves the last replica **marked as possibly stale** (or refuses explicitly), and
   **logs** the degradation — it never fakes freshness (`knowledge/proven-patterns.md` §10).
6. **All external access goes through the gateway.** No scattered calls to the master system;
   verifiable by the existence of a single adapter and a fake in test.
7. **Write-back, if it exists, is explicit and reversible.** Never a silent local edit that "maybe"
   reaches the source; it is a named operation with an observable outcome.

## How to adopt it in a new product (steps)

1. **Map the ownership boundary** with the user (`core/question-engine.md`): which fields belong to
   the source (read-only) and which are local (editable). This list is the central decision.
2. **Define the local replica** with external ID, stamp and (if feasible) raw payload.
3. **Design the integration gateway** and write the **fake adapter** before the real one — dev does
   not depend on the external system being up.
4. **Implement the synchronization** as an idempotent upsert, scheduled via `modules/job-queue.md`.
5. **Define the degraded behavior** case by case: serve stale-with-warning, or refuse; always
   logged.
6. **Block editing of managed fields** on the server (not only in the UI) and mark them as
   read-only in the content catalog (`modules/single-source-of-content.md`).
7. **If there is write-back**, create the gateway right away, even as a no-op, so the design does
   not forget it.

## Variations and trade-offs

- **Scheduled pull vs webhook push vs on-demand.** Scheduled pull is the simplest and most robust
  (the source needs no knowledge of us). Webhooks give freshness but require a reliable endpoint
  and reconciliation all the same. On-demand (fetching from the source on every read) avoids a
  replica but couples availability and latency — rarely worth it.
- **Full replica vs cache with TTL.** A replica allows *joins* and works with the source offline; a
  TTL cache is lighter but does not serve rich queries. The choice follows the access pattern
  (`agents/06-data/data-modeler.md`).
- **Stale-with-warning vs refusing on unavailability.** For context data (name, photo), serving
  stale with a warning is acceptable; for sensitive decisions (effective permissions, balances),
  refusing is more honest. Decided per field, not wholesale.
- **Store the raw payload or only the fields used.** The raw payload is provenance and
  future-proofing (fields we do not use yet), at the cost of space; recommended when space is not
  critical.

## Example (multi-domain)

**Internal app — identity from the corporate directory.** Name, email and department come from
Entra/LDAP: read-only, with `syncedAt`. The app adds local fields (preferences, internal
assignments) that it **edits freely**. A nightly sync upserts by `objectId`; running it twice
duplicates nobody. If the directory is down at login time, the profile from the last sync is shown
with "data as of HH:MM" and the degradation is logged — no profile is invented.

**E-commerce — catalog from the PIM.** Title, description and base price belong to the PIM
(read-only); the store's stock and promotions are local. The PIM feed upserts by SKU; a SKU that
disappears from the feed is marked `discontinued`, not deleted (reversibility —
`knowledge/permanent-rules.md` §4). If the PIM fails, the store keeps selling with the last
catalog, flagging internally that it is stale.

## Known pitfalls

- **Blind insert in the sync:** duplicates on every run and loses provenance — rule 2 (upsert by
  external ID) exists precisely for this.
- **Managed fields editable "just this once":** the exception becomes the rule and the copies
  diverge; the ownership boundary (step 1) must be hard.
- **Faking freshness on unavailability:** serving stale data **without** a warning reads as current
  and leads to wrong decisions; the silence is the failure (`knowledge/proven-patterns.md` §10).
- **Coupling dev to the external system:** without a fake adapter, nobody develops while the source
  is down and the tests turn brittle (`knowledge/origin-lessons.md` §C9).
- **Scattered calls to the master:** without a single gateway, one escapes the instrumentation and
  the fake; centralize (rule 6).
- **Deleting instead of marking removed:** a record that leaves the feed may come back; marking
  `discontinued` is reversible, deleting is not.

## Related

- `knowledge/proven-patterns.md` — §2 upsert by stable ID, §4 SSOT, §10 visible fallbacks.
- `agents/06-data/data-modeler.md` — replica, external keys and access patterns.
- `modules/job-queue.md` — synchronization on a single executor.
- `modules/audit-and-provenance.md` — raw payload and source stamp as provenance.
- `modules/single-source-of-content.md` — marking externally managed fields as read-only.
- `knowledge/origin-lessons.md` — §C9 (gateway + fake adapter + idempotent upsert).
