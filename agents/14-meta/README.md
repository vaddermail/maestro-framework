# 14-meta — the framework working on itself

Category outside the project lifecycle: the agents here do not build product — they keep
**Maestro itself** learning from those who use it. They act on the framework's **upstream
repository** (never on a project's copy), close the circuit described in `knowledge/README.md`
§How knowledge circulates, and answer the test that validates the framework: *did product
no. N come out cheaper and better than no. N−1?*

## Agents

| Agent | Responsibility |
| --- | --- |
| `agents/14-meta/framework-curator.md` | Turns the projects' improvement reports (issues labeled `improvements`) into curated framework evolution: triages, deduplicates, manages `knowledge/candidates.md` and proposes PRs — never direct commits. |

## What sets this category apart

- **A different stage.** Categories 00–13 work inside a project; 14 works on the upstream
  repository. A project's Orchestrator **never** summons these agents — the project's side of the
  circuit is only `playbooks/report-framework-improvements.md`.
- **Its own cadence.** No phase triggers it: it fires on accumulated reports, on a phase close in
  a project, or on elapsed time — see `playbooks/framework-curation.md` §Preconditions.
- **A human at the gate.** The output is always a proposal (PR with evidence); the merge belongs
  to the framework owner (`MANIFESTO.md` — the human decides). A framework error multiplies
  across every project that copies it; that is why this gate is the most conservative of all.

## Related

- `knowledge/README.md` — the knowledge circuit this category closes.
- `knowledge/candidates.md` — the waiting room managed by the curator.
- `playbooks/framework-curation.md` — the curation procedure.
- `playbooks/report-framework-improvements.md` — the project side: how the reports arrive.
- `core/extensibility.md` — the addition rules that curation respects.
- `_meta/VERSION.md` — the SemVer that carries promotions to the projects.
