# Knowledge

The distilled experience the framework carries. While `agents/`, `workflows/` and `modules/`
say **how to do it**, `knowledge/` says **what we learned to do it this way** — each rule with
the real cost that originated it. It is what stops an agent from "simplifying" a safeguard
because it does not understand why it exists.

## Files

- `knowledge/permanent-rules.md` — the working rules that hold in any project:
  owner's mindset, absolute honesty, reversibility, mass changes, stable versions.
- `knowledge/origin-lessons.md` — generalized lessons from the origin project, each with
  the *why* and the *how to apply*. It is the defect memory the framework inherits.
- `knowledge/ai-pitfalls.md` — typical failures of AI-assisted development and how the
  framework blocks them by construction.
- `knowledge/proven-patterns.md` — architecture/operations patterns validated in production
  (single-executor queue, upsert by ID, SSOT, visible fallbacks, defense in depth).
- `knowledge/candidates.md` — the waiting room: lessons reported by one project, awaiting the
  second confirmation before promotion (maintained by `playbooks/framework-curation.md`).

## How knowledge circulates

The circuit's golden rule: **signals go up, releases come down.** A project never writes to the
framework; the framework never changes underneath a project.

```
real project ──(in the moment)──▶ FRAMEWORK-IMPROVEMENTS.md (at the project root)
                                        │  phase close — playbooks/report-framework-improvements.md
                                        ▼
                       `improvements` issues on the upstream repository
                                        │  curation — playbooks/framework-curation.md
                                        ▼
        knowledge/candidates.md ──(≥2 confirmations)──▶ PR + human merge ──▶ knowledge/ (MINOR)
                                                                                        │
real project ◀──(deliberate sync — playbooks/sync-framework.md)◀────────┘
```

1. **Downstream (framework → project):** agents reference these files instead of repeating the
   principles. An agent spec that needs to invoke "reversibility" points to
   `knowledge/permanent-rules.md` — it does not rewrite the rule. Promotions reach projects
   via release (`_meta/VERSION.md`) and deliberate sync — never automatically.
2. **Upstream (project → framework):** capture is **mandatory and in the moment** — from F0 on,
   every project keeps its `FRAMEWORK-IMPROVEMENTS.md`
   (`templates/project/FRAMEWORK-IMPROVEMENTS.md.template`), consolidates it at phase closes
   (`checklists/definition-of-done.md`) and sends it as an issue to the upstream framework
   (`playbooks/report-framework-improvements.md`). The `agents/14-meta/framework-curator.md`
   triages, manages `knowledge/candidates.md` (a lesson from **one** project waits for the
   second confirmation) and proposes promotions via **PR** — which only land with a merge by
   the framework owner, in a MINOR update. **Product** lessons stay in `STATE.md` §Lessons
   (`core/project-memory.md`); what goes to the improvements file is what belongs to the
   **framework**. That is how Maestro grows wiser with every product.

## Golden rule of this directory

Every statement carries the **why** and the **how to apply**. A lesson without a why becomes
superstition; a principle without application becomes decoration. If you cannot write both,
you have not yet understood the lesson — do not write it down.

## Related

- `core/project-memory.md` — where lessons live in a project before they rise.
- `MANIFESTO.md` — the principles this knowledge substantiates.
- `playbooks/adversarial-audit.md` — the method that produces the most lessons.
- `playbooks/report-framework-improvements.md` · `playbooks/framework-curation.md` — the two
  sides of the upward circuit.
- `agents/14-meta/framework-curator.md` — who curates what the projects report.
