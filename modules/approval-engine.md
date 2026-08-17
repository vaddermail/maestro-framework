# Approval Engine · configurable tiers by value or risk

A module for **who must authorize what, and in which order**, when an action needs approval before
taking effect — an expense, a refund, publishing content, granting an access, changing a contract.
The approval tier is **proportional to a value or risk** and **configurable in data**, never fixed
per profile nor in code. Before tier approval, a **need-validation gate** decides whether the
request may even enter the flow — and it is a **separate** mechanism, one that does not replace
the approval. Everything approved leaves an **auditable trail** of who approved what and through
which channel.

## The problem it solves

Approvals are a recurring source of defects because three distinct mechanisms are frequently
**collapsed into one** (`knowledge/origin-lessons.md` B1):

- **"Finance approves everything up to X, above that the director."** Carved into code, this
  breaks at the first reorganization: the org chart changes, code changes and a deploy happens.
  And it doesn't answer "why did this 4,999 request pass while the 5,001 one required the
  director?".
- **Confusing *may approve* with *needs to happen*.** A request can be perfectly authorizable on
  value and still be unnecessary (buying what is already in stock). If the only filter is value,
  the unnecessary-but-cheap always gets through.
- **Not knowing who approved.** When the decision doesn't persist the channel used and the
  concrete approver, auditing is impossible and accountability dilutes.

The module separates the three axes and makes the tier **data, not code**.

## The model (concepts and entities, stack-agnostic)

- **Request (`request`)** — the thing that needs authorization, with a **value** or **risk
  level** that determines the tier (an amount, a sensitivity classification, a requested access
  level).
- **Need gate** — an **initial and separate** step that decides whether the request is even
  eligible: does it make sense? is there an alternative? does it comply with policy? It is an
  entry **yes/no**, not a value approval. A request can pass the gate and fail at the tier, or
  the reverse.
- **Tier (`tier`)** — the rule, **in data**, that maps a value/risk band to the set of required
  approvers. Typically a table of bands (`0–1,000 → manager`; `1,000–10,000 → manager +
  director`; `> 10,000 → + board`). It is **configurable** without a deploy.
- **Approval chain (`chain`)** — the concrete sequence of steps a request generates on entry,
  from the tier applicable at that moment. Each step has a **role/approver**, a **state**
  (pending/approved/rejected) and, once decided, **who** and **when**.
- **Decision (`decision`)** — the immutable record of each approval/rejection: approver, moment,
  justification, and the **channel** used (portal, backoffice, delegation). It feeds the audit.
- **Delegation** — the rule that lets an approver transfer their authority for a period
  (absence), without losing the trace that it happened by delegation.

Tier evaluation is a case of decision by configurable rule, a relative of tariff evaluation in
`modules/credit-management.md` — the logic is read from data, not compiled.

## Non-negotiable rules (numbered, verifiable)

1. **The tier is configurable in data, never fixed per profile nor in code.** Changing who
   approves what is done in configuration, without a deploy. Test: changing the tier table
   changes the chain generated for a new request, without touching code.
2. **The need gate is separate from tier approval and does not replace it.** They are two
   orthogonal steps; passing one does not imply passing the other. Test: an eligible request
   (gate yes) can sit pending at the tier, and a cheap request (trivial tier) can be barred at
   the gate.
3. **The chain derives from the value/risk at submission time.** The tier applied is the one in
   force when the request entered, not today's. Test: changing the table does not alter chains
   already in flight.
4. **Every decision persists who, when, why and through which channel.** No approval is anonymous
   or traceless. Test: every approved/rejected step leads back to an identified approver and a
   moment (`modules/audit-and-provenance.md`).
5. **The effect only occurs when the chain is complete.** While a step is missing, the approved
   action takes no effect. Chain completion and the effect are atomic
   (`modules/state-machines.md`). Test: approving the next-to-last step does not fire the effect.
6. **A rejection at any step ends the chain.** An approver who rejected is not "skipped". Test:
   rejecting a step moves the request to the rejected state, without consulting the following
   steps.
7. **Whoever approves has their authority confirmed on the server.** The profile/approver is
   validated against the roles actually granted (`modules/rbac-and-scoping.md`), not against what
   the client declares. Test: forging the role does not approve.
8. **No self-approval, unless by explicit rule.** By default, the author of a request is not an
   approver of their own request. Test: submitting and trying to approve one's own request is
   refused, except where policy expressly allows it.

## How to adopt it in a new product (steps)

1. **Identify the actions that require approval** and, for each one, the **tier axis** (monetary
   value? risk level? data sensitivity?).
2. **Define the need gate** — the eligibility question that runs **before** the tier — and make
   it explicit in the business rules (`agents/01-requirements/business-rules-modeler.md`).
3. **Model the tier table in data** (bands → approvers) and the chain as a state machine
   (`modules/state-machines.md`); the approved effect runs when the chain closes.
4. **Wire authority to RBAC** (`modules/rbac-and-scoping.md`) and each decision to the audit
   trail (`modules/audit-and-provenance.md`).
5. **Record the choices in an ADR** (`templates/project/ADR-DECISION.md.template`): tier axis,
   sequential vs parallel, delegation and self-approval rules.
6. **Expose the pending queue to the approver** and the chain's state to the requester, with
   texts from the single source (`modules/single-source-of-content.md`).

## Variations and trade-offs

- **Sequential vs parallel.** Approvers in series (each one only sees after the previous one)
  give control and accumulated context, but are slow; in parallel (all at once, N of M required)
  they are fast but may approve without seeing their peers' decision.
- **"All" quorum vs "N of M".** Requiring all approvers of a step is safer and more fragile (one
  absentee stalls everything); requiring N of M is resilient but dilutes accountability.
- **Tier by value vs by risk vs matrix.** Value is objective and easy to configure; risk is more
  faithful but requires classifying every request; a matrix (value × category) is the most
  expressive and the most expensive to maintain.
- **Delegation: yes or no.** Without delegation, an absence blocks; with delegation, you gain
  continuity but need a clear trace that it happened by delegation (Rule 4) so the audit doesn't
  lose the thread.

## Example (1–2, multi-domain)

**A company's expense platform.** A purchase request first goes through the **need gate** (is the
item already in stock? is there a framework contract covering it?) — separate from the value.
Only then does the **tier table** determine the chain: up to €1,000 the team manager approves; up
to €10,000 manager + director; above that, the board comes in. The table is editable by finance
without a deploy (Rule 1). The purchase order is only issued when the chain closes (Rule 5); each
approval records who and when (Rule 4).

**Content moderation platform (marketplace).** The tier axis is **risk**, not value: a low-risk
listing publishes with one automatic approval; sensitive categories (health, finance) require a
human reviewer; content flagged by several users escalates to a second reviewer. The need gate is
the initial triage (does it comply with the category rules?), distinct from the risk decision.

## Known pitfalls

- **Collapsing the need gate into value approval.** It lets the unnecessary-but-cheap always get
  in and makes the necessary-but-expensive look suspicious. They are separate axes (Rule 2,
  `knowledge/origin-lessons.md` B1).
- **Carving the tiers into code.** Every reorganization becomes a deploy, and there is no way for
  a business manager to adjust thresholds. Tiers are data (Rule 1).
- **Applying today's tier to old chains.** The table changes and in-flight chains "skip" or
  "gain" approvers retroactively. The chain freezes the tier from submission time (Rule 3).
- **Effect before the chain closes.** Issuing the order/publishing/granting the access "early"
  while an approver is still missing defeats the flow's purpose (Rule 5).
- **Anonymous approval.** Without persisting approver + channel, the audit cannot answer "who
  authorized this?" (Rule 4).
- **Silent self-approval.** Letting the author approve their own request by default opens an
  internal-control hole (Rule 8).

## Related

- `modules/state-machines.md` — the approval chain is a state machine; the effect runs on close.
- `modules/rbac-and-scoping.md` — the approver's authority is confirmed on the server.
- `modules/audit-and-provenance.md` — each decision is an immutable audit entry.
- `modules/credit-management.md` — tier evaluated by configurable rule, like the tariffs.
- `knowledge/origin-lessons.md` — B1: the three orthogonal mechanisms that don't substitute for
  each other.
- `agents/01-requirements/business-rules-modeler.md` — translates the gate and the tiers to the
  domain.
