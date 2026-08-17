# Single Source of Content · one catalog serves UI, tooltips and AI

> **Production validation:** 2nd confirmation in a domain distinct from the origin project (P2 —
> 2026-08 curation round; nuance confirmed: vocabulary/dropdowns from a single source, editable
> and audited). The design stands; confidence rises.

Reusable module for the product's **textual content** — labels, descriptions, messages, tooltips,
help — to live in a **single editable source**, from which everything else derives. It is the
single-source-of-truth pattern (`knowledge/proven-patterns.md` §4) applied to the strings the user
reads.

## The problem it solves

The same text tends to be written many times: the button label, the tooltip explaining it, the
manual entry, the answer an AI assistant gives about that function. When duplicated, they
**diverge** — the button says one thing, the help another, the AI invents a third. It is the most
stubborn bug class there is, because each copy looks correct in isolation.

Worse in an AI product: if the help assistant is *grounded* in text different from what the screen
shows, it lies with confidence. Content honesty is zero-tolerance (`knowledge/permanent-rules.md`
§2) — and it is only guaranteed if there is **one** origin.

## The model (concepts and entities, stack-agnostic)

- **Catalog** — the file (or typed set) that is the **only** editable origin of content. Each entry
  has a **stable key** by convention (`domain.entity.action.aspect`, e.g. `invoice.issue.tooltip`).
- **Content entry** — for each key: the short text (label), the explanation (tooltip/description),
  and — where applicable — the **rich help entry with examples**. The full help is not a separate
  document: it is the same catalog, at its most detailed level.
- **Consumers** — all derive, none rewrites:
  - **UI** — the screen reads the label and the tooltip by key.
  - **Help menu** — renders the rich entries with examples.
  - **AI grounding** — any product assistant answers from the **same** catalog; the help that
    serves the human is the context that serves the AI (`modules/ai-observability.md`).
  - **Tests/guardrails** — verify coverage and absence of duplication.
- **State provenance** — entries for modules yet-to-be-built are marked `Planned`, so the AI knows
  they exist without claiming they already work.

Distinct from, but aligned with, two neighbors: **design tokens** (colors, spacing —
`agents/03-experience/design-system-architect.md`) are the SSOT of the *visual*; **i18n**
(`agents/03-experience/internationalization-specialist.md`) is the same externalized-strings
discipline extended to several languages. The catalog is the foundation of both.

## Non-negotiable rules (numbered, verifiable)

1. **No content string hardcoded outside the catalog.** Verifiable: a test that sweeps the code and
   fails on finding user-visible text embedded (`knowledge/proven-patterns.md` §7).
2. **One key, one text.** The same concept does not have two entries; verifiable by detecting
   duplicate values in the catalog.
3. **Every action/control has a tooltip.** Verifiable: a test that walks the action components and
   fails if any does not reference a tooltip key (`knowledge/origin-lessons.md` §D2).
4. **The help and the AI grounding read the same catalog.** There is no parallel "help document" nor
   a *prompt* with copied text; the AI is *grounded* in the source, not in a copy.
5. **Keys follow the declared convention.** A new key respects the `domain.entity.action.aspect`
   pattern; verifiable by key linting.
6. **Entries for not-ready modules are marked `Planned`.** The AI never claims something works just
   because the entry exists; the state is explicit.
7. **Removing a feature removes its entries.** No orphan keys; verifiable by detecting keys that are
   referenced-but-nonexistent and existent-but-never-referenced.

## How to adopt it in a new product (steps)

1. **Define the catalog format** (`core/decision-engine.md`): a typed module in the product's
   language (e.g. `content.ts`) is the simplest and gives compile-time checking; message files
   (i18n) when there is multilingual support from the start.
2. **Fix the key convention** and document it in the product glossary.
3. **Create the single accessor** `t(key, params?)` — the point through which every consumer reads.
4. **Enforce by construction:** design-system components that **refuse** to create a button/action
   without being passed a tooltip key (`knowledge/origin-lessons.md` §D3).
5. **Wire up the guardrails:** tests for "no loose strings", "every action has a tooltip", "no
   orphan keys", "no duplicates".
6. **Point the AI assistant at the catalog** as its grounding source — the same one that feeds the
   help menu (`agents/11-documentation/user-help-writer.md`).
7. **Extend the pattern to contracts**, if applicable: a single schema declaration feeds
   validation, types and documentation (`knowledge/origin-lessons.md` §C2) — the same principle at
   another layer.

## Variations and trade-offs

- **Typed module vs i18n files.** Typed: key errors at compile time, safe refactors, no infra;
  single-language at its base. i18n: multilingual and pluralization from the ground up, but more
  ceremony and runtime checking. If a second language is realistically likely, starting with i18n
  saves a migration.
- **Single catalog vs per module.** One giant file does not scale for reading; splitting by domain
  (`content/billing.ts`, `content/support.ts`) while keeping the single accessor preserves the
  single source without the monolith.
- **Inline help vs separate knowledge base.** Keeping them **in the same source** is the point of
  the module; if the knowledge base grows into long articles, generate them **from** the catalog,
  never in parallel to it.
- **Where the AI grounding lives.** Composing the AI context from the catalog at runtime avoids
  drift, but costs tokens; if caching, invalidate whenever the catalog changes — parity is
  non-negotiable.

## Example (multi-domain)

**SaaS platform — coherent tooltip, help and chatbot.** The "Archive project" action has
`project.archive.label` = "Archive", `project.archive.tooltip` = "Removes the project from active
lists; reversible in Settings > Archive", and `project.archive.help` with a step-by-step example.
The button, the help panel and the support chatbot read all three from the same entry — when the
behavior changes (it stops being reversible), **one** place is edited and the three consumers
follow. The chatbot never contradicts the tooltip because it drinks from the same source.

**Online store — single error message.** "Card declined by the issuing bank" lives in
`checkout.payment.declined`. It appears on the checkout screen, in the failure email and in the
help article "Why was my payment declined?" — without three versions aging separately.

## Known pitfalls

- **Loose strings creeping back:** without the sweep test (rule 1), hardcoding returns by the third
  sprint — a rule that is not verified stops being followed.
- **AI prompt with copied text:** copying the help into a *system prompt* recreates the duplication
  the module eliminates; the prompt references the catalog, it does not transcribe it.
- **Positional/index keys** (`msg_42`) instead of semantic ones: they make the catalog unreadable
  and refactoring dangerous.
- **Duplicating instead of reusing** "because this context is slightly different": if the text is
  the same, it is one key; if it is truly different, it is another key with its own name — never
  two identical copies.
- **Help aging apart from the product:** keeping the help as a separate document reintroduces the
  divergence; the help **is** the catalog at its rich level
  (`agents/13-guardians/documentation-guardian.md`).

## Related

- `knowledge/proven-patterns.md` — §4 SSOT, §7 guardrails that sweep everything.
- `agents/11-documentation/user-help-writer.md` — the full help with examples as a single source.
- `agents/04-frontend/frontend-architect.md` — content SSOT in the client app.
- `agents/03-experience/design-system-architect.md` — the sibling SSOT, for visual tokens.
- `agents/03-experience/internationalization-specialist.md` — the same discipline across languages.
- `modules/ai-observability.md` — the catalog as grounding for the product assistant.
- `knowledge/origin-lessons.md` — §D1, §D2 (catalog and guardrails), §C2 (contracts).
