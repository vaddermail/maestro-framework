---
name: maestro-phase
description: Executes the workflow of the Maestro project's current phase step by step — reads «Current phase» in STATE.md, opens the matching Maestro/workflows/Wnn, summons the maestro-* subagents with the briefing, respects approved inputs and the effort profile. Use it to move work forward inside a phase.
---
# /maestro-phase — execute the current phase's workflow

**Trigger:** there is work to move forward inside the phase declared in `STATE.md` §Situation header (phase, profile, active workflow).

1. Read `Maestro/workflows/README.md` §How a workflow is executed and execute the phase's `Maestro/workflows/W0N-….md` by dependency, not by numbering (W10–W13 only by event or request). Preconditions `approved` or the workflow does not start; loops closed before the gate.
2. Per step, read only the **entry** `## <agent>` in `Maestro/agents/NN-category/CONTRACTS.md` (inputs, outputs, tier, criteria) — not the spec and not the whole file. Summon it as `Maestro/core/orchestrator.md` §Invoking an agent requires, with the briefing from `Maestro/templates/technical/agent-briefing.md.template` §Briefing; gaps for the user → /maestro-ask, never an assumption; panels → /maestro-panel.
3. **Mechanics:** the subagent `maestro-<category>-<slug>` exists in `.claude/agents/` if the phase's workflow cites it (that is what the scaffold generates); otherwise, the Agent tool with the spec's path in the prompt and the tier's `model`. Going up a tier on a conditional step (e.g. "Top for the risk judgment") = the Agent tool with an explicit `model` and the spec's path — the subagent's frontmatter is fixed.
4. Receive only the §Return (six fields) and validate it against the file and the `git diff`, never against the report. Record it in `STATE.md` §In progress at the end of each block; exit gate → /maestro-gate.
