---
name: maestro-panel
description: Launches a blind panel on the Maestro project — architecture proposals (F3), reviewer panel (F7) or global review (W12). One message per member with identical inputs, all in parallel in a single turn, forbidden from reading each other's reports; only then the consolidator or the arbiter. Routing by each spec's tier; scaled to the profile.
---
# /maestro-panel F3 | F7 | W12 — blind panel

**Trigger:** the workflow reached the panel step — `Maestro/workflows/W03-architecture.md` step 2, `Maestro/workflows/W07-quality-and-security.md` step 1 or `Maestro/workflows/W12-global-review.md` step 2.

1. Read that step and `Maestro/agents/12-reviewers/README.md` §What a review panel is; compose the members and scale to the profile using the workflow's "Effort profiles" table (prototype: security + architecture). No member is the author of what they review.
2. Write **one** briefing message (`Maestro/templates/technical/agent-briefing.md.template` §Briefing) and send it identical to everyone — only the spec and the output file change; include the ban on reading `product/99-records/reviews/` and `product/02-architecture/proposals/` of this date.
3. **Mechanics:** N subagents (`maestro-*` if they exist in `.claude/agents/`, otherwise the Agent tool with the spec's path) launched in the **same response**, each with the `model` of the tier from its entry in `CONTRACTS.md` (the security reviewer and the arbiter on Top; never everyone on Top). You wait for all of them; whoever did not write a file did not deliver — you relaunch them with the same briefing, you do not summarize on their behalf.
4. Only then: `maestro-reviewers-review-consolidator` (F7, W12) or `maestro-architecture-architecture-arbiter` (F3 — never one of the proposers), the only one that reads everything. Record in `STATE.md` §Done with the reports' paths as evidence.
