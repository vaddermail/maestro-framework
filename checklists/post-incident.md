# Post-Incident

Runs after any mitigated incident, before considering it closed
(`workflows/W11-incident-response.md`). Ensures the incident produces **verified** learning — not
just an archived report nobody ever looks at again.

## Post-mortem

- [ ] Post-mortem written (`templates/technical/post-mortem.md.template`) with a factual timeline
      of the events.
- [ ] Root cause identified — not just the symptom that fired the alert.
- [ ] **Blameless** post-mortem: it describes what failed in the system/process, not who "messed
      up" (`knowledge/permanent-rules.md`).
- [ ] Impact quantified (duration, users/requests affected, data lost if any).

## Prevention actions

- [ ] Every prevention action has a named owner and a concrete deadline.
- [ ] Actions cover the root cause, not just a one-off patch of the symptom that fired the alert.
- [ ] Proposed destructive or high-risk actions go through human approval before executing
      (`knowledge/permanent-rules.md` §4).

## Verification

- [ ] Every action marked as done has **evidence of independent verification** — not the word of
      whoever implemented it (`core/quality-gates.md`).
- [ ] When the prevention is a new test, the test reproduces the original incident (fails before
      the fix, passes after) — confirmed, not presumed.
- [ ] When applicable, a real drill confirms the same conditions no longer reproduce the incident.

## Memory

- [ ] Lesson recorded in `STATE.md` §Lessons, with the **why** and the **how to apply** — not
      just "watch out for X" (`core/project-memory.md`).
- [ ] Checked that the lesson does not duplicate an existing one — the existing one gets updated
      instead of duplicated.
- [ ] Post-mortem archived somewhere accessible to future sessions (`product/99-records/`).

## Related

- `workflows/W11-incident-response.md` — the workflow that opens this checklist.
- `templates/technical/post-mortem.md.template` — the post-mortem format.
- `core/project-memory.md` — where the lesson is recorded.
- `knowledge/permanent-rules.md` — honesty and destructive changes.
- `core/quality-gates.md` — the independent verification rule.
