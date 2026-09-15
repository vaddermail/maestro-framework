---
name: maestro-gate
description: Runs a Pn quality gate of the Maestro project item by item with evidence, runs the project's mechanical gate, writes the record in product/99-records/gates/ and STOPS for the human where the approval is theirs. It never declares a partial pass. Use it to close a phase, a slice (P6) or the MVP (P6b).
---
# /maestro-gate Pn — pass (or not) a gate

**Trigger:** the phase's (or the slice's) steps and loops are closed and it has to be decided whether the work moves on.

1. Read `Maestro/core/quality-gates.md` §Anatomy of a gate and §Human approval matrix, and the phase's section in `Maestro/checklists/definition-of-done.md` (plus the specific checklist when one exists: pre-merge, pre-production security, go-live). The profile sizes the evidence, not the existence of the item.
2. Create the record from `Maestro/templates/project/GATE.md.template` in `product/99-records/gates/Pn-YYYY-MM-DD.md` and go through it item by item with evidence in the format of `Maestro/knowledge/proven-patterns.md` §Live proof. A checklist executed by another agent → one line, evidence = the report's path.
3. **Mechanics:** the live proof runs in a fresh subagent (Agent tool) that receives only the artifact or diff, the checklist's section, the evidence format and the instruction to write the record — never the conversation nor the plan (`Maestro/adapters/claude-code.md` §Independent verification). `bash Maestro/_meta/verify-project.sh`: every ✗ line is a failed item.
4. A failed item → it does not pass; only the user derogates, with the reason and the risk assumed in the record. Where the matrix requires a human, present the filled-in record and **stop**. Passed → the phase's line in the genesis, `STATE.md` updated, and `bash Maestro/adapters/claude-code/generate-scaffold.sh` for the new phase.
