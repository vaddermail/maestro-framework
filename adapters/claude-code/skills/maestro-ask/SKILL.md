---
name: maestro-ask
description: Turns the accumulated gaps into a batch of P-nnn questions to the user in the format of the Maestro question engine, records it in product/01-requirements/questions-and-answers.md, mirrors the pending items in STATE.md and applies the single rule for assuming by default. Use it when an agent returns gaps or a decision belongs to the user.
---
# /maestro-ask — a batch of questions, not a barrage

**Trigger:** a subagent's return carries "Gaps → P-nnn", a decision is the user's by nature (scope, money, risk, priority), or two sources contradict each other.

1. Read `Maestro/core/question-engine.md` — §When to ask, §The format of every question, §Batches, not a barrage and §Record — and execute it: filter out what can be verified in the artifacts or has a convention in the framework; you never repeat what `product/01-requirements/questions-and-answers.md` already answers.
2. A batch of 3–8 questions (never more than 12) in the engine's format, with `P-nnn` IDs following on from the log. Record it in the log and mirror it in `STATE.md` §Pending decisions **before** sending; a single message to the user, with the cost of postponing each answer.
3. With no answer, only `Maestro/core/question-engine.md` §When to assume by default (the four conditions) allows moving on: met → `assumed-by-default (provisional)` in the log and in `STATE.md` §Decisions made on behalf of the absent owner, confirmed at the next gate; one of them failed → it stays pending and the work goes on where it does not depend on it.
4. **Mechanics:** questions to the user come only from the main session — no subagent asks; the `maestro-*` return gaps in their §Return and it is here that the batch is formed.
