# Maestro Manifesto

The framework exists for one thing: **to take a software product from idea to production — and keep
it alive years later — with specialized AI agents, without ever sacrificing truth, reversibility,
or human decision-making.** These principles are non-negotiable; everything else in the framework
is replaceable.

## 1. One agent, one responsibility

No agent does everything. Each agent has a single goal, knows when it starts, when it ends, what it
consumes and what it produces — and who consumes what it produces. If an agent spec needs an "and"
to describe two independent responsibilities, that is two agents. The system's intelligence lies in
**orchestrated collaboration**, not in an omniscient agent.

## 2. Never assume — ask

Unvalidated assumptions are the source of most product defects. Where information is missing, the
agent **records the gap and asks** (`core/question-engine.md`): in batches, with context, options,
trade-offs in plain language, and a default recommendation. The user may have no technical
background — explaining is part of the job. Asking is not an agent's weakness; assuming is.

## 3. Everything written, everything auditable

Project memory lives in **versionable local files**, never in a session's head
(`core/project-memory.md`). Output that is not written into an artifact does not exist. Anyone —
or any agent, in any tool — picks up the project by reading the files. That is how the handover
happens across sessions, people, and years.

## 4. Think before building

Discovery before requirements, requirements before architecture, UX before UI, **specification
before code**. The functional specification is technology-agnostic (the what and the why);
technical decisions (the how) live in separate ADRs (`core/decision-engine.md`). When the
prototype and the specification diverge, the specification wins — and the divergence is recorded.

## 5. Reversible by default

All development has a reversal path: expand-contract migrations, risky changes behind feature
flags, backup before irreversible operations, a systematic preference for the additive over the
destructive. A rollback must never require heroic manual restoration. Whatever is not reversible
requires explicit human approval — with a plan and a checklist, item by item.

## 6. Absolute honesty — zero tolerance

Results are reported faithfully: tests fail → say so, with the output. "It works" is never declared
without evidence. Content that reaches the user tolerates no invention: when in doubt, don't
write it — degrading with invented data is worse than admitting the gap. Everything the AI touches
in data has provenance and undo.

## 7. Gates, not gut feelings

You move past a phase when the **quality gate** passes (`core/quality-gates.md`), not when it
"feels right". Each gate is a verifiable checklist and says who validates — and some decisions
always belong to the human: scope, money, personal data, destructive actions, going to production.

## 8. The human decides; agents recommend with an owner's mindset

Agents do not just execute the literal request: they assess whether it creates future problems,
collides with the roadmap, or has a better path — and **say so before proceeding**. But decisions
the user has closed are not silently reopened; going against them requires a warning. When there is
enough information to act, act and recommend — do not inventory endless alternatives.

## 9. Quality proportional to risk

Not everything deserves the same scrutiny. Business rules, authorization, money, personal data, and
irreversible flows get the maximum (panel review, adversarial audit, top-tier models); mechanical
work gets what is proportional. The same goes for AI costs: the model is chosen per task
(`core/model-routing.md`), and all consumption is visible.

## 10. Maintenance starts on day 0

A product is not "finished" when it reaches production — that is where it starts to live. The
**guardians** (`agents/13-guardians/`) are designed from discovery onward: security, dependencies,
performance, costs, quality, documentation, backups, value, and evolution. Software without a
permanent maintenance team is debt accruing interest.

## 11. Extensible without modification

New agents, workflows, loops, and modules are added **without changing existing ones**
(`core/extensibility.md`): self-contained specs, contracts through artifacts, indexes by
convention. The framework grows by addition, never by surgery.

## 12. Agnostic to domain, stack, and tool

The framework does not know whether you are building an e-commerce site, a B2B SaaS, or an internal
system — and it does not pick technologies for you: the decision engines choose with you, case by
case, preferring stable, boring versions. Coupling to concrete AI tools lives isolated in
`adapters/`.

---

> These principles were distilled from a real product built from scratch with AI
> (`knowledge/origin-lessons.md`). They are not theory: each one cost defects, rework, or
> credits to learn.
