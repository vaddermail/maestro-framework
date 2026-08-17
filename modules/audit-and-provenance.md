# Audit and Provenance · who did what, and where the data came from

> **Production validation:** 2nd confirmation in a domain distinct from the origin project (P2 —
> curation round of 2026-08; confirmed nuances: immutability in 3 layers — code with no
> UPDATE/DELETE → trigger+REVOKE in the DB → hash-chain; partition by month **on day 0**; real
> least-privilege for the application role). The design holds; confidence rises.

A module that gives any product two guarantees that get requested late and cost dearly to add
afterwards: an **immutable audit trail** (who did what, when, and the before/after state) and
**data provenance** — especially for data an AI generated or enriched, with origin, moment and an
**undo** path. It is the system's forensic memory: it answers "who authorized this?", "who changed
this value and what was it before?" and "was this description written by a person or suggested by
a model — and how do I revert it?".

## The problem it solves

- **Not knowing who did what.** Without a trail, an improper change, a suspicious access or a
  contested decision have no answer — the data itself was overwritten and the past is gone.
- **An audit log that can be tampered with.** A "history" that can be edited or deleted is not
  auditing; it is decoration. If the same operation that changes the data can also rewrite the
  record, there is no guarantee.
- **AI enrichment without a trace.** A model fills in a field, suggests a category, rewrites a
  text — and afterwards nobody can tell what was human from what was generated, nor undo a
  suggestion that turned out wrong. Without provenance, AI content becomes an irreversible fact
  of unknown origin (`knowledge/permanent-rules.md` §2).
- **Keeping everything forever (or nothing).** Without a retention policy, either sensitive data
  accumulates indefinitely (legal risk) or what was needed to investigate gets deleted.

## The model (concepts and entities, stack-agnostic)

- **Audit entry (`auditEntry`)** — an **immutable**, append-only record of a fact: **actor**
  (who, or which system/AI), **moment**, **action**, affected **resource**, and the
  **before/after** (the changed values, not the whole object). It is never edited nor deleted.
- **Provenance (`provenance`)** — metadata about a datum's **origin**: entered by a human,
  imported from an external system (`modules/readonly-external-integrations.md`), or **generated
  by AI**. For AI, it stores the model/version, the *prompt*/grounding context, the moment and a
  confidence level when one exists — so the content is *grounded* and reversible
  (`knowledge/origin-lessons.md`).
- **Undo/Reversal** — the path to undo a change: since the trail stores the **before**, a datum
  touched by AI (or by a bulk operation) can be reverted to its previous value without a heroic
  manual restore (`knowledge/permanent-rules.md` §3).
- **Correlation (`correlation`)** — an identifier that ties together the entries of one
  operation/request (several mutations of one transition are a single story), linking to the logs
  and traces (`agents/05-backend/logging-specialist.md`).
- **Retention policy (`retention`)** — per record category, how long it is kept and how it is
  discarded (or anonymized) at the end, reconciling the duty to audit and data minimization.

The trail is not a `modules/job-queue.md` nor an application log: it is a **persisted business
fact**, typically written in the **same transaction** as the fact it describes (like the outbox —
`knowledge/proven-patterns.md` §3), so there is never action without trace nor trace without
action.

## Non-negotiable rules (numbered, verifiable)

1. **Audit entries are immutable and append-only.** No code path updates or deletes them
   (retention expiry is the only removal, and it is itself audited). Test: trying to edit/delete
   an entry is rejected by the data layer, not just by the app.
2. **Every sensitive action writes its trail in the same transaction as the fact.** If the fact
   commits, the trace exists; if it rolls back, no orphan trace remains. Test: a rollback of the
   fact leaves zero entries; a committed fact always has its entry.
3. **Each entry identifies the actor, including when it is AI or a system.** "System" and "AI"
   are named actors, not anonymous ones. Test: no entry has an empty actor; a change made by AI
   identifies the model/version.
4. **The trail stores the before **and** the after of the changed fields.** "It was changed" is
   not enough; the previous and the new value are stored. Test: from one entry, the prior value
   of every touched field can be reconstructed.
5. **Data generated/touched by AI carries provenance and is reversible.** Origin (model, moment,
   grounding) recorded and an undo path to the previous value. Test: an AI-enriched field is
   distinguishable from a human one and can be reverted without a manual restore
   (`knowledge/permanent-rules.md` §2,§3).
6. **The audit does not leak what authorization hides.** Viewing the trail respects RBAC and the
   per-field-category redaction (`modules/rbac-and-scoping.md`): a sensitive field redacted in
   the data is redacted in the before/after. Test: whoever cannot see a field also does not see
   it in the history.
7. **No secrets in the trail.** PINs, keys, tokens are never written in the clear in an entry
   ("changed" is stored, not the value). Test: sweeping the trail reveals no secret
   (`knowledge/permanent-rules.md` §5).
8. **An explicit retention policy exists per category.** Each record type has a term and a form
   of disposal/anonymization. Test: records past their term are discarded/anonymized per the
   policy, and the disposal is itself audited.

## How to adopt it in a new product (steps)

1. **List the auditable actions** (those that change sensitive state, money, accesses, personal
   data) and the **data sources** that need provenance (imports, AI generation).
2. **Model the append-only `auditEntry`** and the **provenance** of the relevant fields,
   enforcing immutability at the data layer (`knowledge/proven-patterns.md` §5;
   `agents/06-data/data-auditor.md`).
3. **Write the trail inside the transaction** of each fact (outbox pattern —
   `knowledge/proven-patterns.md` §3), with correlation shared with logs/traces.
4. **Wire AI provenance to the undo**: store the before of each enriched field and expose the
   reversal (`knowledge/permanent-rules.md` §2,§3).
5. **Define retention per category** and record it in an ADR
   (`templates/project/ADR-DECISION.md.template`), reconciling audit with
   minimization/compliance.
6. **Expose the audit respecting RBAC** (`modules/rbac-and-scoping.md`) and test adversarially
   that neither secrets nor redacted fields escape (`playbooks/adversarial-audit.md`).

## Variations and trade-offs

- **Application-level trail vs event sourcing.** A trail alongside the current state is simple
  and enough for most products; event sourcing (the state **is** the sum of the events) gives
  perfect audit and *time-travel*, at the cost of great complexity — only when the domain
  justifies it.
- **Field diff vs full snapshot.** Storing only the changed fields is compact and readable;
  storing the whole object at each change is simpler to reconstruct but grows fast. The diff with
  before/after is the usual middle ground.
- **Retention: long (audit) vs short (minimization).** Regulated sectors demand years of trail;
  data protection asks to minimize. It is solved per category: retain the audit fact, anonymize
  the personal data inside it when its term expires.
- **Immutability by convention vs by construction.** A trail "nobody should edit" erodes; a trail
  the data layer **prevents** from being edited (append-only, permissions, chained hash) endures
  (`knowledge/proven-patterns.md` §7).

## Example (1–2, multi-domain)

**Content platform with assistive AI.** An editor uses an assistant that suggests an article's
title and summary. Each AI-filled field stores **provenance**: model, version, moment and the
grounding context (Rule 5). The editor sees an "AI-suggested" badge and can revert to the
previous value in one click (the trail stored the before — Rule 4). If it later turns out the
model hallucinated a date, every suggestion from that version is findable via provenance and
revertible.

**Internal banking system.** Every change to an account (limit, address, state) writes its trail
in the same transaction (Rule 2), with actor, before/after and correlation with the request. The
IBAN and ID-document fields are a sensitive category: whoever cannot see them in the data also
does not see them in the history (Rule 6). No secret (PIN, token) enters the trail in the clear
(Rule 7). The trail is retained seven years by legal obligation; the personal data inside it is
anonymized when its applicable term ends (Rule 8).

## Known pitfalls

- **An editable audit log.** If the app can rewrite the history, it is not auditing. Append-only
  enforced at the data layer (Rule 1).
- **Writing the trail outside the fact's transaction.** "I make the change and then record it"
  loses the trace when the app dies midway; or records something that rolled back (Rule 2).
- **An anonymous actor on system/AI actions.** "Changed automatically" without saying by which
  process/model makes the audit useless (Rule 3).
- **AI enrichment without provenance or undo.** Generated content that blends with the human kind
  and can be neither distinguished nor reverted violates data honesty (Rule 5,
  `knowledge/permanent-rules.md` §2).
- **Secrets in the clear in the before/after.** Auditing a key change by storing the key turns
  the trail into a target (Rule 7).
- **A trail that ignores RBAC.** Exposing in the history what authorization redacts in the data
  is a leak through a side door (Rule 6).
- **Retaining everything indefinitely.** Without a policy, the trail accumulates personal data
  forever — a legal liability instead of a forensic asset (Rule 8).

## Related

- `modules/rbac-and-scoping.md` — the audit respects authorization and per-category redaction.
- `modules/state-machines.md` — each transition writes its audit entry.
- `modules/readonly-external-integrations.md` — provenance of data imported from external systems.
- `modules/credit-management.md` · `modules/approval-engine.md` — every movement/decision is
  auditable.
- `knowledge/permanent-rules.md` — §2 (honesty/provenance) and §3 (reversibility/undo).
- `knowledge/proven-patterns.md` — §3 (transactional outbox) and §7 (enforced by tests).
- `agents/06-data/data-auditor.md` — designs the trails, provenance and retention.
