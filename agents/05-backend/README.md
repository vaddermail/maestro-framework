# 05 — Backend (server engineering)

The agents that build the **trusted side** of the system: the server, home of authorization,
scoping, transactional integrity, the redaction of sensitive fields and the contracts the client
consumes. The principle that runs through the whole category: **the client is untrusted** — it
declares intent, the server confirms and decides (`knowledge/origin-lessons.md` §C1,
`modules/rbac-and-scoping.md`).

## Phase(s) and when it enters

Dominant phase **F5–F6** (`core/lifecycle.md`). It splits into two moments:

- **F5 (specification):** `api-designer.md` fixes the **contract** — resources, errors,
  pagination, versioning — as the single source feeding validation, server types, client types and
  the documentation (`knowledge/origin-lessons.md` §C2). No code yet; it is the *what* of the API.
- **F6 (build):** the specialists implement that contract in vertical slices
  (`workflows/W06-build.md`), in the order data → backend → frontend, with continuous tests.

## Uniform module anatomy (the rule that unifies the category)

Every backend module in this framework has **three layers**, always in the same order
(`knowledge/origin-lessons.md` §C3):

| Layer | Responsibility | What it does **not** do |
| --- | --- | --- |
| **Thin edge** (protocol) | Translates HTTP/gRPC/message into a typed call; validates the *shape* of the input; returns the standard error format | Decides neither authorization nor business rules |
| **Orchestration** | Confirms authority and scoping (server), opens the transaction, composes the steps, triggers side effects via outbox | Speaks no protocol; does not hold the pure rule |
| **Pure/transactional domain** | The business rule as a function that receives the DB connection (or data already loaded); testable without HTTP, composable inside larger transactions | Knows nothing of HTTP, headers, or the response format |

*Why:* the hard logic stays testable without the network and reusable inside larger transactions —
and the same operation served through several routes (portal, backoffice, API, CLI) shares the
transactional core, differing only at the edge (`knowledge/proven-patterns.md` §8). Reviewers
verify this separation in `agents/12-reviewers/backend-reviewer.md`.

## Agents in this category

**Contract and API styles**
- `agents/05-backend/api-designer.md` — designs the contract (resources, errors, pagination) and chooses the style with the user; SSOT of the contract.
- `agents/05-backend/rest-specialist.md` — REST: resources, verbs, status codes, pragmatic HATEOAS, OpenAPI.
- `agents/05-backend/graphql-specialist.md` — GraphQL: schema, resolvers, N+1, per-field authorization.
- `agents/05-backend/grpc-specialist.md` — gRPC: protobuf, streaming, message versioning.
- `agents/05-backend/api-versioning-specialist.md` — versions and deprecates APIs without breaking clients.

**Identity and access**
- `agents/05-backend/authentication-specialist.md` — authn: OIDC/OAuth2, sessions vs tokens, MFA, service accounts.
- `agents/05-backend/authorization-specialist.md` — authz: RBAC/ABAC, server-side scoping, untrusted client, fail-closed.

**Performance and async**
- `agents/05-backend/caching-specialist.md` — layered caching, keys, TTL, invalidation, stampede.
- `agents/05-backend/queue-specialist.md` — job queues: single executor, dedupe by fingerprint, retries, DLQ.
- `agents/05-backend/events-specialist.md` — domain/integration events: outbox, ordering, idempotency.
- `agents/05-backend/scalability-architect.md` — horizontal/vertical scale, bottlenecks, backpressure, limits.

**Observability**
- `agents/05-backend/logging-specialist.md` — structured logging, levels, correlation, no secrets in the logs.
- `agents/05-backend/metrics-specialist.md` — RED/USE metrics, SLIs, cardinality under control.
- `agents/05-backend/product-analytics-specialist.md` — product events (funnels, activation, drop-off) tied to the yardstick's KPIs; zero PII, pseudonymization, consent, versioning, live proof.
- `agents/05-backend/observability-architect.md` — traces + logs + metrics correlated; actionable alerts; AI costs visible.
- `agents/05-backend/ai-features-specialist.md` — LLM features: grounding on the single source, versioned prompts, executable evals, guardrails/fallback, credits and AI observability applied.

## Recommended order of work

1. **Contract first** (`api-designer`) — decides the style with the user and writes the
   contract; it is everyone else's input.
2. **Identity and access** (`authentication-specialist` → `authorization-specialist`) — before
   any endpoint that returns data; authn establishes *who*, authz decides *what/which subset*.
3. **Implementation of the chosen style** (one of `rest`/`graphql`/`grpc`) on top of the three-layer
   anatomy, slice by slice.
4. **Performance and async** as the slice demands — caching, queues, events.
5. **Observability** from the first slice — logging and metrics are not a final touch-up; product
   events (`product-analytics-specialist`) come in with the slice whose flow feeds a KPI.

## How the Orchestrator summons it

`core/orchestrator.md` assembles the dependency graph from the **Inputs**/**Interactions** sections
of each agent spec. In F5 it calls only the `api-designer`; in F6 it calls the specialists in
the order above, per vertical slice, coordinating with `agents/06-data/` (upstream — the persisted
model) and `agents/04-frontend/` (downstream — the consumer of the contract). Authorization,
scoping, integrity and the redaction of sensitive fields are the **exclusive responsibility** of
this layer (`templates/specification/backend-contract.md.template`).

## Related

- `agents/06-data/README.md` — the persisted truth the backend orchestrates.
- `agents/04-frontend/README.md` — the untrusted client that consumes the contracts.
- `modules/rbac-and-scoping.md` · `modules/job-queue.md` · `modules/state-machines.md` — reusable capabilities the agents apply.
- `knowledge/proven-patterns.md` · `knowledge/origin-lessons.md` §C — the patterns the category implements.
