# W04 — Experience (F4)

> **Phase:** F4 · **Exit gate:** P4 · **Core agents:** `agents/03-experience/` (7
> essential + 3 conditional), conducted by `core/orchestrator.md`.

## Objective

Design **how the product is used and looks before a single line of interface code exists**:
flows and journeys, wireframes, visual direction, design system as tokens, component inventory,
responsiveness and accessibility — consolidated into an **approved screen map**. It is the
materialization of "UX before UI, specification before code" (`MANIFESTO.md` §4): the frontend
(F6) will only have to **implement** what is decided here, not invent it.

## Preconditions (entry gate)

- [ ] P2 closed: requirements, `BR-nnn` and acceptance criteria `approved`
      (`product/01-requirements/`).
- [ ] Personas and use cases from F1 `approved` (`product/00-discovery/personas/`,
      `use-cases/`) — one designs for concrete people and tasks, not for an imagined user.
- [ ] F3 ADRs `approved` — the architecture constrains what the UI can assume (SSR, real time,
      offline).

Without approved personas and use cases, the category **does not start**
(`agents/03-experience/README.md`).

## Steps (agent → artifact)

The order follows `agents/03-experience/README.md`. Artifacts in `product/03-experience/`.

| # | Agent | Artifact | Depends on |
| --- | --- | --- | --- |
| 1 | `agents/03-experience/ux-researcher.md` | `flows-and-journeys.md` + `screen-map.md` skeleton | personas + use cases (F1), `FR` (F2) |
| 2 | `agents/03-experience/wireframer.md` | `wireframes/` (one per screen/flow, text/ASCII, no color) | 1 |
| 3a | `agents/03-experience/ui-designer.md` | visual direction (hierarchy, density, **light theme by default**) | 2 |
| 3b | `agents/03-experience/design-system-architect.md` | `design-system.md` (color/typography/spacing/radius tokens, never hardcoded) | 2 (parallel with 3a) |
| 4 | `agents/03-experience/component-architect.md` | `components.md` (closed inventory, all states) | 2, 3b |
| 5a | `agents/03-experience/responsiveness-specialist.md` | `screen-map.md` review (mobile-first ≈390px **and** desktop) | 2–4 |
| 5b | `agents/03-experience/accessibility-specialist.md` | `accessibility.md` (WCAG, keyboard, contrast, `checklists/accessibility.md`) | 2–4 |

**Conditional (only when discovery calls for it):**
`agents/03-experience/web-performance-specialist.md` (surface with a latency budget),
`seo-specialist.md` (public indexable product), `internationalization-specialist.md` (more than
one locale). **One does not design for requirements that do not exist** — the Orchestrator only
convenes them when needed.

**Parallelism (`core/orchestrator.md` §Parallelism):** visual direction (3a) and tokens (3b) move
together — the designer decides, the architect encodes it as semantic tokens; responsiveness (5a)
and accessibility (5b) review everything the previous steps produced, in the real viewport and
against WCAG, before the gate. Content (labels, tooltips, help) comes from the single catalog
(`modules/single-source-of-content.md`), never duplicated on the screen.

> **Scale to the profile:** in a prototype, wireframes and screen map collapse into a single
> `product/03-experience/ux.md` with ASCII; tokens stay minimal but they **exist** (never
> hardcoded colors, even in a prototype).

## Decision points

Gaps go up to the Orchestrator in **batches** (`core/question-engine.md`). Typical F4 batches:

- **Screen priority** — what is a main vs secondary flow; what stays out of the visual MVP.
- **Visual tone** — density (information vs breathing room), formality, brand (if one exists).
- **Target accessibility** — WCAG level to meet; keyboard and screen-reader support.
- **Responsiveness** — which breakpoints, what collapses/reorders on the phone.

**Mandatory human approval (P4):** the **screen map** and the **wireframes of the critical
flows** are validated by the user — UX decisions can be revisited, but **never silently**
(`agents/03-experience/README.md`). The product is theirs.

## Loops it opens

- F4 does not run a dedicated numbered loop; its iteration is the **wireframe review cycle** with
  the user (flow by flow) until the screen map stabilizes. **Safeguard** (`loops/README.md`):
  3 rounds without convergence on a screen → the Orchestrator isolates the open decision and
  raises it as a single question, instead of networksigning blindly. Accessibility findings that
  imply flow rework reopen step 1 — record it in `STATE.md`.

## Exit gate (P4)

`core/quality-gates.md` + `checklists/definition-of-done.md`:

- [ ] **Screen map approved by the user**, with the wireframes of the **critical flows** validated.
- [ ] Design system with **defined tokens** (two levels, never hardcoded); light theme by default.
- [ ] Component inventory with all states (empty, loading, error, success).
- [ ] **Accessibility** plan accepted (`checklists/accessibility.md`) and real responsiveness
      verified on a small and a large viewport.

**Who verifies:** the Orchestrator (completeness) + `accessibility-specialist` and
`responsiveness-specialist` (substance). **Who approves:** the user (screen map). The
`agents/12-reviewers/ux-reviewer.md` only audits against personas in F7. With P4 closed,
`workflows/W05-specification.md` starts.

## Failure and blocker recovery

`core/orchestrator.md` §Recovery. `wireframer` without an approved `flows-and-journeys.md`, or
`component-architect` without tokens → return the gap as a question batch, **never assume**.
User unavailable to validate the screen map → the map stays `in-review`, the pending item in
`STATE.md` → "Decisões pendentes"; F5 **does not start** without P4 closed. A divergence found in
F6 (a screen impossible to implement as designed) sends work back to F4 — record the reason in
`STATE.md`.

## Effort profiles

| Profile | F4 depth |
| --- | --- |
| **Prototype** | ASCII wireframes of the main flows; minimal tokens; basic accessibility (contrast + keyboard). |
| **Internal product** | Full screen map; design system with tokens; WCAG AA on the critical flows. |
| **Commercial product** | + budgeted web performance; i18n if multi-locale; audited accessibility. |
| **Enterprise platform** | + technical SEO if there is a public surface; WCAG AA/AAA per compliance; versioned design system. |

## Related

- `agents/03-experience/README.md` — the category, the order and the conditional agents.
- `workflows/W03-architecture.md` — the previous phase (supplies the ADRs that constrain the UI).
- `workflows/W05-specification.md` — the next phase (consumes flows and rules).
- `agents/04-frontend/README.md` — who implements, in F6, what this phase designs.
- `modules/single-source-of-content.md` — the content catalog the UI consumes.
- `checklists/accessibility.md` — the practical per-screen WCAG verification.
