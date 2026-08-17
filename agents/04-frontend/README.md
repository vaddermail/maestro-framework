# 04 — Frontend (client engineering)

The category that builds the **client application**: the app structure, the screens, the API
integration, the state/cache and the UI tests. It works in phase **F6** (build —
`workflows/W06-build.md`), downstream of experience (F4, `agents/03-experience/`) and in parallel
with the backend (`agents/05-backend/`) and data (`agents/06-data/`), under the API contract the
server publishes.

> Category principle: the **client is untrusted** (`knowledge/proven-patterns.md` §6).
> The frontend assumes it only receives what the active profile may see and that the server
> confirms all authority — the UI may hide and disable for UX, never for security. And every piece
> of text that reaches the user comes from the **single source of content**
> (`modules/single-source-of-content.md`), never hardcoded in the screen.

## Agents in this category

| Agent | One line |
| --- | --- |
| `agents/04-frontend/frontend-architect.md` | Client app structure: routing, layers, conventions, bootstrap of the content layer (SSOT) and of the tokens. |
| `agents/04-frontend/screen-implementer.md` | Builds each screen from the wireframe + design system, with a **tooltip on every action** and **filters/sorting on every list**. |
| `agents/04-frontend/api-integrator.md` | Typed API client generated from the contract, **mocks that mirror the server** (MSW or equivalent), normalized errors (RFC 7807). |
| `agents/04-frontend/state-and-cache-specialist.md` | Client state, server-data cache, synchronization and invalidation; base+overlay layers. |
| `agents/04-frontend/frontend-test-engineer.md` | Component/screen tests (with axe) and client E2E smoke in a small **and** a large viewport. |

## Recommended order of work

1. **Frontend Architect** sets up the skeleton: routing, layers, conventions and the **typed
   content layer** + consumption of the design system tokens — *before* any screen exists.
2. **API Integrator** generates the typed client and the mocks from the contract, so that the
   screens have coherent data from day one (dev + tests).
3. **State & Cache Specialist** defines the cache/invalidation policy and the state layers the
   screens will reuse.
4. **Screen Implementer** builds screen by screen on these foundations (tooltips, filters,
   loading/error/empty states).
5. **Frontend Test Engineer** covers components and screens and runs the E2E smoke; it follows
   along in parallel, not only at the end.

> Steps 2–4 iterate by **vertical slice** (`workflows/W06-build.md`): one screen at a time, with
> its client, mocks, state and tests — never "all the screens first, integration later".

## How the Orchestrator summons it

`core/orchestrator.md` activates the category when the F4 gate has passed (wireframes + design
system approved) and the API contract exists (from `agents/05-backend/api-designer.md`). It builds
the dependency graph from the **Inputs**/**Interactions** sections of the agent specs: the
architect first, then the rest in slices. It hands control back to the F7 reviewers
(`agents/12-reviewers/frontend-reviewer.md`, `agents/12-reviewers/ux-reviewer.md`) and, in
production, to `agents/13-guardians/performance-guardian.md`.

## Phase(s)

**F6 (build)** is the dominant phase. The category **consumes** F4 (experience) and the F5
contract, and **feeds** F7 (review/quality). In F9, the screens and the client evolve via
`workflows/W10-feature-evolution.md`.

## Related

- `agents/README.md` — global index and agent types.
- `agents/03-experience/README.md` — what this category receives (wireframes, design system, tokens).
- `agents/05-backend/README.md` — the other side of the API contract.
- `agents/10-quality/README.md` — the test strategy and the full-system multi-profile E2E.
- `modules/single-source-of-content.md` · `modules/rbac-and-scoping.md` — the modules this category applies.
- `workflows/W06-build.md` — the vertical-slice process this category lives in.
