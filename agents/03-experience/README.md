# 03 — Experience (UX and UI before code)

The category that designs **how the product is used and looks before a single line of interface
code exists**. It translates the requirements and business rules from F2
(`workflows/W02-requirements.md`) into flows, screens, tokens and components that the frontend
(F6, `agents/04-frontend/README.md`) only has to **implement** — not invent. It is the
materialization of the principle "UX before UI, specification before code" (`MANIFESTO.md` §4).

## Phase and scope

- **Dominant phase:** F4, orchestrated by `workflows/W04-experience.md`.
- **Input:** discovery dossier (F1) — personas, use cases, MVP — and requirements + business
  rules (F2). Without approved personas and use cases, the category does not start: we design for
  concrete people and tasks, not for an imagined user.
- **Output:** an **approved screen map** with flows, wireframes, visual direction, design system
  (tokens) and component inventory — the UX/UI contract that passes the F4 gate
  (`core/quality-gates.md`).

## Agents in this category

| Order | Agent | Single responsibility |
| --- | --- | --- |
| 1 | `agents/03-experience/ux-researcher.md` | Flows, journeys and information architecture, validated against personas |
| 2 | `agents/03-experience/wireframer.md` | Low-fidelity wireframes (text/ASCII) per screen, no color or styling |
| 3 | `agents/03-experience/ui-designer.md` | Visual direction: hierarchy, density, tone; light theme by default |
| 4 | `agents/03-experience/design-system-architect.md` | Core tokens (color, typography, spacing, radius) in two tiers, never hardcoded |
| 5 | `agents/03-experience/component-architect.md` | Inventory of reusable components, with all states and workarounds encapsulated |
| 6 | `agents/03-experience/responsiveness-specialist.md` | Real mobile-first layout (≈390px) and desktop; grid pitfalls |
| 7 | `agents/03-experience/accessibility-specialist.md` | WCAG, keyboard, contrast, screen readers (`checklists/accessibility.md`) |
| — | `agents/03-experience/web-performance-specialist.md` | Web performance budgets (LCP/CLS/INP), when applicable |
| — | `agents/03-experience/seo-specialist.md` | Technical SEO, only when the product has a public indexable surface |
| — | `agents/03-experience/internationalization-specialist.md` | i18n/l10n, when there is more than one locale |

The last three are **conditional**: the Orchestrator only summons them if discovery indicates the
need (public product → SEO; multi-locale → i18n; surface with a latency budget → web performance).
We do not design for requirements that do not exist.

## Recommended order of work

1. **Flows first** (`ux-researcher`): without the task map and the information architecture,
   wireframes are guesswork. This agent also produces the skeleton of the **screen map**.
2. **Wireframes** (`wireframer`): structure and content of each screen, still in black and white —
   to discuss the *what* without the distraction of *how it looks*.
3. **Visual direction and tokens in parallel** (`ui-designer` + `design-system-architect`): the
   visual language and the tokens that materialize it advance together; the designer decides, the
   architect encodes it in semantic tokens.
4. **Components** (`component-architect`): distills the wireframes into a closed inventory of
   reusable pieces, each with all its states.
5. **Responsiveness and accessibility** review everything the previous agents produced, in the
   real viewport and against WCAG — before the F4 gate.

## How the Orchestrator summons it

The Orchestrator (`core/orchestrator.md`) assembles the F4 graph from the **Inputs** and
**Interactions** sections of these agent specs: `wireframer` waits for the approved
`flows-and-journeys.md`; `component-architect` waits for wireframes **and** tokens. Any agent left
without a mandatory input returns the gap as a question batch (`core/question-engine.md`) instead
of assuming. The F4 gate only passes with the screen map approved by the user — UX decisions are
revisitable, but never silent.

## Related

- `workflows/W04-experience.md` — the process that chains these agents.
- `agents/04-frontend/README.md` — who implements what this category designs.
- `agents/12-reviewers/ux-reviewer.md` — reviews the real flows against personas in F7.
- `modules/single-source-of-content.md` — the content catalog the UI consumes (labels, tooltips, help).
- `knowledge/origin-lessons.md` §D — the frontend/content lessons this category inherits.
- `agents/_template/AGENT-TEMPLATE.md` — the template for each agent spec.
