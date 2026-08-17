# Modules — reusable capabilities distilled from the origin project

A **module** is a reusable **product** capability — not a code library. It describes the
conceptual design, the non-negotiable rules and the pitfalls of something **any** new product can
adopt: a credit ledger, an approval engine, an audit trail. Where an agent (`agents/README.md`)
says *who does the work* and a workflow (`workflows/README.md`) says *in what order*, a module
says *what to build and why to build it that way* — agnostic of stack, cloud and domain.

Modules are the practical distillation of the patterns in `knowledge/proven-patterns.md` and of
`knowledge/origin-lessons.md`: each one encapsulates an already-solved class of defects, so the
same bugs don't have to be relearned the hard way in another product.

## What a module is **not**

- **Not code, nor a dependency to install.** It is the *what/why*; the concrete *how* (language,
  DB, framework) is decided with `core/decision-engine.md` at instantiation time.
- **It assumes no domain.** The examples are multi-domain (e-commerce, SaaS, data platform,
  internal app) — the mechanics generalize, the domain does not (`knowledge/origin-lessons.md`
  §What not to generalize).
- **Not mandatory.** Adopt what adds value **at the product's current point**; the rest stays
  available for when it makes sense (`core/extensibility.md`).

## How a module is adopted into a product

Three steps, always in this order:

1. **Choose** — during specification (`workflows/W05-specification.md`) or an evolution
   (`workflows/W10-feature-evolution.md`), identify that the product has the need the module
   solves. When in doubt between adopting now or later, adopt when the need is **real and
   present**, not speculative.
2. **Instantiate in the domain** — translate the module's generic concepts into the product's
   ubiquitous language (`agents/01-requirements/glossary-curator.md`) and write the concrete
   rules into the specs (`agents/01-requirements/business-rules-modeler.md`). The module's
   "non-negotiable rules" are copied into the product's business rules **with their provenance**
   — so that no future agent "simplifies" them without understanding why they exist
   (`knowledge/origin-lessons.md` A2).
3. **Record the adoption** — open an ADR (`templates/project/ADR-DECISION.md.template`) stating
   that the module was adopted, in which variant and why; and leave a trace in `STATE.md`
   (`core/project-memory.md`). An unrecorded adoption is one the next session knows nothing
   about.

## Decoupling principle

**Modules do not depend on each other.** Each one is adopted in isolation and makes sense on its
own — the same open-closed property as the agents (`core/extensibility.md`): registering =
existing, with no surgery on the existing ones. They can, however, **compose** when the product
adopts them together, and composition happens through **shared artifacts**, never through direct
coupling:

- `modules/approval-engine.md` **emits** transitions that `modules/state-machines.md` executes,
  and **both** write to `modules/audit-and-provenance.md`;
- `modules/rbac-and-scoping.md` decides *who may* transition; the state machine decides *whether
  the transition is legal*.

No module imports another to work: a product can adopt only the audit trail, or only the credits.
Where a module **assumes** another's output, it says so in the "Related" section — it does not
embed it.

## Common skeleton of a module file

All modules (except this README) follow **exactly** this structure, in this order — so the reader
can jump from one module to another without relearning the format:

| Section | What it answers |
| --- | --- |
| `# Title · context line` | What the module is, for whom, in one sentence |
| `## The problem it solves` | The class of defects/need that justifies the module |
| `## The model (concepts and entities, stack-agnostic)` | The entities and relations, without picking technology |
| `## Non-negotiable rules (numbered, verifiable)` | The invariants every instance must respect — each one confirmable |
| `## How to adopt it in a new product (steps)` | The concrete instantiation path |
| `## Variations and trade-offs` | The open decisions and when to choose each option |
| `## Example (1–2, multi-domain)` | Realistic instances in different domains |
| `## Known pitfalls` | The typical mistakes of those implementing the module |
| `## Related` | 3–8 paths that exist in `_meta/INVENTORY.md` |

## The framework's modules

| Module | What it offers |
| --- | --- |
| `modules/credit-management.md` | Generic credit ledger: accounts, movements, tariffs, quotas, kill-switch; for AI, APIs, tools, per user/organization. |
| `modules/approval-engine.md` | Approvals by configurable tier (value/risk), separate need-validation gate. |
| `modules/state-machines.md` | Critical flows as explicit state machines: states, transitions, effects, who may. |
| `modules/rbac-and-scoping.md` | Profiles, scopes per organizational unit, server-side enforcement, untrusted client. |
| `modules/audit-and-provenance.md` | Immutable audit trail; provenance of AI-touched data, with undo. |
| `modules/job-queue.md` | Queue with a single executor: multiple submission, dedupe by fingerprint, retries, visibility. |
| `modules/feature-flags.md` | Flags and kill-switches: risky changes that switch off without a deploy; flag hygiene. |
| `modules/single-source-of-content.md` | SSOT for labels/descriptions/help: one source file serves UI, tooltips and AI grounding. |
| `modules/ai-observability.md` | Accounted AI consumption (tokens, cost, per feature/model/user), alerts, per-model kill-switch. |
| `modules/readonly-external-integrations.md` | External systems as an assumed contract: read-only, synchronization, externally managed fields. |
| `modules/entity-lifecycle.md` | Onboarding/offboarding of entities with transactional release of all associated resources. |

## Related

- `core/extensibility.md` — how a module is added/adopted without breaking the existing ones.
- `knowledge/proven-patterns.md` — the production patterns the modules encapsulate.
- `knowledge/origin-lessons.md` — the concrete defects that proved them.
- `core/decision-engine.md` — how the concrete variant is decided at instantiation.
- `templates/project/ADR-DECISION.md.template` — where a module's adoption is recorded.
- `agents/01-requirements/business-rules-modeler.md` — maps the module's rules to the domain.
