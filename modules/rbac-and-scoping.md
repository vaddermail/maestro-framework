# RBAC and Scoping · authority and scope, always on the server

> **Production validation:** 2nd confirmation in a domain distinct from the origin project (P2 —
> 2026-08 curation round; nuance confirmed: scoping as a **composable SQL predicate** on hot
> paths, not an in-memory set). The design stands; confidence rises.

A module to answer, in any multi-user product, two **distinct** questions: *which actions can this
actor perform?* (authorization/RBAC) and *over which subset of data?* (scoping by organizational
unit). They are **orthogonal axes** — a branch manager has broad authority but a narrow scope; an
auditor has full scope but read-only authority. The rule cutting across everything: the decision
lives **100% on the server**, because the client is untrusted; it fails **closed**; and sensitive
fields are redacted **per field category**, not through a single all-or-nothing gate.

## The problem it solves

- **Collapsing authority and scope.** Treating them as one thing breeds bugs in both directions:
  giving someone access to another unit's data because they had the "action", or denying a
  legitimate action because the scope did not line up (`knowledge/origin-lessons.md` B2).
- **Trusting the client.** Any check done in the browser can be bypassed; any field sent "just not
  shown" gets read in the payload. Hiding in the frontend is not security.
- **Fail-open.** A `role ?? "ADMIN"` that turns "no role" into "full access" is a real, catastrophic
  defect (`knowledge/origin-lessons.md` C1). Absence of permission must **deny**.
- **All-or-nothing redaction.** A single "sees everything / sees nothing" gate does not model
  reality: the same user may see a customer's email but not their card number. Hiding is **per
  field category**.

## The model (concepts and entities, stack-agnostic)

- **Actor (`actor`)** — whoever makes the request: a user, a service account, an integrated system.
- **Role (`role`)** — a named set of **permissions** (actions). An actor holds one or more roles;
  the client may **declare** which one is active, but the server **confirms** it against the roles
  actually granted.
- **Permission (`permission`)** — the authority for an action on a resource type (`read-invoice`,
  `approve-expense`, `delete-user`). It is the **authority** axis.
- **Scope (`scope`)** — the subset of data the actor reaches, typically by organizational unit
  (department, region, customer, project, tenant). It is the **scoping** axis, independent of
  authority.
- **Policy (`policy`)** — the rule combining role + scope + resource to produce *allow/deny*. It
  lives close to the data (ideally in the DB too, not only in the app).
- **Sensitive field category (`fieldCategory`)** — a classification of fields by sensitivity
  (`personal-identifier`, `secret`, `financial`, `health`). Redaction is decided **per category**,
  with the permission to see that category — not via a global flag.

The underlying pattern is `knowledge/proven-patterns.md` §6: the client declares intent, the server
decides; the *query* filters by the server's identity; the output redacts by authorization.

## Non-negotiable rules (numbered, verifiable)

1. **Authorization and scoping are separate axes.** The decision evaluates both independently;
   neither ever proxies for the other. Test: a role with broad authority and narrow scope sees
   **less** data, and a broad scope with read-only authority can**not** write.
2. **The decision lives on the server; the client only declares intent.** No authority is decided on
   the client. Test: a forged request (role/scope tampered in the payload) is refused by the server.
3. **Fail-closed by default.** No resolvable role, no applicable policy, or in doubt → **deny**;
   never assume superuser. Test: an actor with no role gets a denial, not full access
   (`knowledge/origin-lessons.md` C1).
4. **Scoping filters at the query's source, not at presentation.** Data outside the scope **never
   leaves** the database; no fetch-everything-and-filter-at-the-end. Test: the query returns only
   the scoped subset, even if the UI asks for more.
5. **Out-of-scope returns "not found", not "not authorized".** A resource outside the scope responds
   as nonexistent (404), not as forbidden (403), to avoid leaking its existence. Test: requesting a
   resource of another unit is indistinguishable from requesting one that does not exist.
6. **Sensitive fields are redacted per category, with defense in depth.** Not emitted in the query
   **and** redacted on output, per field category (`knowledge/proven-patterns.md` §6). Test:
   without permission for the `secret` category, the field does not appear in the payload — being
   hidden on the screen is not enough.
7. **Authority is confirmed per operation, not once at the entrance.** Every sensitive action
   revalidates; no trusting a check done at login. Test: changing the role mid-session changes what
   the next action allows.
8. **Policies are auditable and versionable.** Who holds which role and which scope is traceable,
   and the history of grants/revocations is recorded (`modules/audit-and-provenance.md`). Test: an
   access grant traces back to who gave it and when.
9. **A public identifier never becomes the internal scope id without explicit resolution, at a
   single point.** A URL or token identifier (a string) stored as an organizational-unit id went
   through the DB engine's implicit type conversion: scope-dependent features "never worked", and
   when the string started with digits, the scope pointed at **another** unit — a years-old
   cross-tenant leak, invisible to the suite. Public→internal resolution in the middleware and only
   there; a test that asserts the scope bound after every public route.

## How to adopt it in a new product (steps)

1. **Enumerate the product's roles and actions** (the authority matrix) and, **separately**, the
   **scope units** (along which dimension the data partitions: tenant, region, department, project).
2. **Classify sensitive fields by category** and map which role sees which category
   (`agents/06-data/data-modeler.md`, `agents/09-security/README.md`).
3. **Write the backend contract** declaring: authz on the server, filtering in the query,
   404-out-of-scope, redaction per category
   (`templates/specification/backend-contract.md.template`).
4. **Enforce the policy close to the data** — DB policies beyond the app guards
   (`knowledge/proven-patterns.md` §5,§6) — and choose the model (pure RBAC vs ABAC — see
   Variations), recording it in an ADR (`templates/project/ADR-DECISION.md.template`).
5. **Connect to authentication** (`agents/05-backend/authentication-specialist.md`): identity comes
   from authn, authority and scope from this module.
6. **Test adversarially**: forge role/scope, request another unit's resources, read payloads looking
   for fields that should be redacted (`playbooks/adversarial-audit.md`).

## Variations and trade-offs

- **Pure RBAC vs ABAC (attributes).** RBAC (role → permissions) is simple, readable and enough for
  most products; ABAC (decision by actor/resource/context attributes) is more expressive — needed
  when the rule depends on dynamic data ("the record's owner", "during working hours") — but harder
  to audit. Many products are RBAC with a handful of ABAC rules (ownership).
- **Hierarchical vs flat scope.** Units in a tree (region → branch → team) allow scope inheritance
  (whoever reaches the region reaches the branches), at the cost of evaluation complexity; flat
  scopes are trivial but do not model inheritance.
- **Multi-tenant: row-level vs schema/DB isolation.** Filtering by `tenant_id` in every query is
  simple and cheap but depends on never forgetting the filter (enforce at the low layer); isolating
  by schema/DB is stronger but heavier to operate.
- **Server-side redaction vs per-role projections.** Redacting fields on output is flexible; having
  distinct *views*/projections per role is safer (the field does not even exist in the projection)
  but multiplies the contracts.

## Example (1–2, multi-domain)

**Clinic-management platform (multi-tenant).** Each clinic is a tenant (scope). A receptionist has
authority to schedule but **not** to see clinical history; a doctor sees the history of **their**
patients (per-doctor scope within the tenant). Health fields are a sensitive category: the
receptionist receives the payload **without** those fields (Rule 6). Requesting a patient from
another clinic answers "not found" (Rule 5). With no resolved role, deny (Rule 3).

**Internal invoicing tool (company with branches).** The scope axis is the branch. A branch
accountant has broad authority (create, edit, close invoices) but only over **their** branch; the
group controller has full scope but authority only to read and export — the two axes cross in
opposite ways (Rule 1). IBANs and tax data are the `financial` category, redacted for whoever does
not need them.

## Known pitfalls

- **Fail-open (`?? "ADMIN"`).** The default that turns a missing role into full access — this
  module's most dangerous defect (Rule 3, `knowledge/origin-lessons.md` C1).
- **Filtering on the client/at presentation.** Fetching everything and hiding it on screen sends the
  data in the payload; filter **in the query** (Rule 4).
- **403 instead of 404 out of scope.** Answering "not authorized" confirms the resource exists — it
  leaks information. Out of scope is "not found" (Rule 5).
- **All-or-nothing redaction.** A single gate does not model "sees the email but not the card";
  redact per field category (Rule 6).
- **Trusting an entrance check.** Authorizing only at login and not revalidating per operation
  leaves the session with powers already revoked (Rule 7).
- **Confusing authentication with authorization.** Knowing *who it is* (authn) says neither *what
  they can do* nor *over which data*; they are distinct layers
  (`agents/05-backend/authentication-specialist.md`).

## Related

- `modules/audit-and-provenance.md` — grants, revocations and accesses leave an immutable trail.
- `modules/state-machines.md` — each transition's authority is confirmed with this module.
- `modules/approval-engine.md` — the approver's authority comes from here.
- `knowledge/proven-patterns.md` — §6: authorization and hiding exclusive to the server.
- `knowledge/origin-lessons.md` — B2 (authority ≠ scoping) and C1 (fail-closed).
- `agents/05-backend/authorization-specialist.md` — who implements the policy on the server.
- `templates/specification/backend-contract.md.template` — where authz, scoping and redaction are
  declared.
