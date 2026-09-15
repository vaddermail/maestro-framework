# Checklists — Objective Verification

A checklist is the concrete criterion of a gate (`core/quality-gates.md`) or a loop
(`loops/README.md`): it turns "looks done" into items confirmed one by one. It always runs at the
end of a phase, a code slice, or an event (incident, launch) — never midway, as a substitute for
the work itself. The deliberate exception is the **"F6 — Skeleton (slice 0)"** block of
`checklists/definition-of-done.md`, which runs **on entry** to the build: guards and runners get
wired before the first slice, not on the eve of go-live (1.3.0 promotion, 2 confirmations).

## How a checklist is used

- Each lifecycle gate (`core/lifecycle.md`) references one or more checklists in its criteria
  (`core/quality-gates.md`).
- Items are confirmed **one by one**, instantiating the gate record
  (`templates/project/GATE.md.template`) in `product/99-records/gates/` — the checklists in
  `Maestro/` are not edited — with real evidence in the format of
  `knowledge/proven-patterns.md` §Live proof (what, where, literal output, when, who verified). An
  item without evidence stays unchecked — it is never checked "on trust"
  (`knowledge/permanent-rules.md` §2).
- **The verifier is never whoever produced** the work: an independent reviewer, a test harness, or
  the Orchestrator for formal criteria. It is the same anti-self-validation rule as in
  `core/quality-gates.md`. In Claude Code, the verifier is a fresh subagent that receives only the
  artifacts and the checklist — never the conversation history (`adapters/claude-code.md`
  §Independent verification → subagent without the production context); in other tools, a new
  session with only the files.
- **A failed checklist blocks the gate.** There is no partial pass: either every item passes, or
  the gate stays shut. The only way out is an **explicit waiver from the user**, recorded with the
  why and the risk assumed — never a silent shortcut by the agent.
- The outcome (passed / failed + failed items + waivers with the risk assumed) lives in the gate
  record in `product/99-records/gates/`, with a summary in `STATE.md`; `_meta/verify-project.sh`
  looks for those records for each closed phase.

## Who runs each checklist

| Checklist | When it runs | Who runs it |
| --- | --- | --- |
| `checklists/definition-of-done.md` | F6 entry (slice 0), end of each phase and on every code change | Orchestrator confirms; the agent owning the phase gathers the evidence — never checks its own items (`core/quality-gates.md`) |
| `checklists/pre-merge.md` | before any merge to the integration branch | independent reviewer (`agents/12-reviewers/`) |
| `checklists/pre-production-security.md` | gate P7 (F7→F8) and on every relevant release | `agents/09-security/security-coordinator.md` |
| `checklists/accessibility.md` | per screen, in F4 (definition) and F7 (verification) | `agents/03-experience/accessibility-specialist.md` |
| `checklists/web-performance.md` | per route, in F4 (budget) and F7 (measurement) | `agents/03-experience/web-performance-specialist.md` |
| `checklists/go-live.md` | gate P8 (F8 → production) | `agents/07-devops/deployment-strategist.md` + user approval |
| `checklists/post-incident.md` | after mitigating any incident, before closing it | post-mortem owner (`workflows/W11-incident-response.md`) |
| `checklists/pr-review.md` | every PR, before `checklists/pre-merge.md` | reviewer independent of the author |

## Related

- `core/quality-gates.md` — the gates these checklists serve.
- `core/lifecycle.md` — the phases where each gate fits.
- `loops/README.md` — the other consumer of checklists (a loop's exit condition).
- `core/project-memory.md` — where the outcome of each verification is recorded.
- `agents/12-reviewers/README.md` — who typically runs the review checklists.
- `_meta/STYLE-GUIDE.md` — the `- [ ]` convention and the format of all documents.
- `templates/project/GATE.md.template` — the gate record that each checklist instantiates.
