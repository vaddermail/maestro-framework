# Question Engine

How the framework gets information from the user. It is the mechanism that makes the principle of
**"never assume"** (`MANIFESTO.md` §2) real without turning the process into an interrogation:
**smart questions, in batches, with options and a recommendation** — all of it recorded.

## When to ask

1. An agent finds a **gap** in a required input (its agent spec says what it needs).
2. A decision is **the user's by nature**: scope, money, risk, taste, priority
   (see `core/orchestrator.md` §Human approval).
3. Two sources **contradict each other** and neither is clearly the source of truth.
4. A proposed default has consequences that are hard to reverse — confirm before acting.

**When NOT to ask:** whatever can be verified in the artifacts or the code gets verified; whatever
has an established convention in the framework follows the convention and gets noted; whatever is
detail with no impact on the user's decision, the agent decides and records.

## The format of every question

Every question put to the user carries **six elements** — context, question, why it matters,
options, recommendation and the "If you don't answer" clause:

```markdown
### P-014 · User authentication  [phase F3 · blocks: ADR-004]

**Context:** The application will have internal company users and external customers.
**Question:** How should users authenticate?
**Why it matters:** It defines the identity architecture — changing later costs weeks plus an
account migration.
**Options:**
1. **Entra ID / Google Workspace (SSO)** — no passwords to manage; requires everyone to have a
   corporate account. Cost ~0; better security.
2. **Own email + password** — works for anyone; adds password resets, MFA and secure credential
   storage to maintain — more risk surface.
3. **Hybrid (internal SSO + external invites)** — covers both; more complex to build (+X days).
**Recommendation:** Option 1 if all users have a corporate account; otherwise, 3.
**If you don't answer:** we assume the recommended option **as provisional and reversible**,
marked for confirmation before the F3 gate.
```

Format rules:

1. **Plain language.** The person answering may have no technical background — trade-offs are
   explained through consequences (time, cost, risk, future effort), not jargon.
2. **Closed options + an escape hatch.** 2–4 concrete options; "another idea / I don't know" is
   always a valid answer. "I don't know" activates the default recommendation, marked as
   **provisional**.
3. **Always a recommendation.** An agent that asks without recommending is exporting its own work
   to the user.
4. **Unique ID (`P-nnn`)** for tracking: the answer links to the artifacts it unblocked.
5. **"If you don't answer" clause, always.** States what the Orchestrator will do if the answer
   doesn't arrive before the gate. It is condition 1 of §When to assume by default: a question
   without this clause is not assumed — it blocks.

## When to assume by default (the single rule)

Faced with an unanswered question, the Orchestrator assumes the recommended option **only when all
four conditions hold**:

1. the question included the **"If you don't answer"** clause with that explicit consequence;
2. the default is **reversible** at no material cost;
3. the decision does **not** belong to the mandatory human approval matrix
   (`core/quality-gates.md` §Human approval matrix — the seven categories, including
   destructive/bulk actions and reopening closed decisions);
4. it is **not** a critical requirements ambiguity (`loops/L01-ambiguous-requirements.md`) — those
   stay pending, always.

What gets assumed is recorded as `assumed-by-default (provisional)` in `questions-and-answers.md`
and in `STATE.md` §Decisions made on behalf of the absent owner, and is **confirmed at the next
gate**. Anything that fails one of the conditions goes to `STATE.md` §Pending decisions — an
honest block is worth more than a silent assumption. This is the only rule about assuming by
default: `core/orchestrator.md` §Recovery and the workflows point here; they do not redefine it.

## Batches, not a barrage

- Gaps **escalate to the Orchestrator**, which groups them by theme/phase into a **coherent
  batch** (ideally 3–8 questions; never more than 12).
- A batch states what stays **blocked** by each missing answer — the user sees the cost of
  delaying.
- Urgent questions (blocking today's work) are separated from those that can wait until the end of
  the phase.
- Never repeat an already-answered question: check the history first (below). If the previous
  answer looks wrong in light of new information, **quote the old answer** and ask whether it
  stands.

## Record (auditable)

All questions and answers live in `product/01-requirements/questions-and-answers.md`
(even those from other phases — a single history, ordered, searchable):

```markdown
## P-014 · User authentication
- **Status:** answered | pending | assumed-by-default (provisional)
- **Asked:** 2026-07-08 (F3) · **Answered:** 2026-07-09
- **Answer:** Option 1 (Entra ID SSO). "Everyone has a company account."
- **Unblocked:** ADR-004, FR-031
```

- **Pending** questions are mirrored in `STATE.md` §Pending decisions (that is where the next
  session finds them).
- Answers **assumed by default** must be confirmed by the phase gate — the gate does not pass with
  critical provisionals.

## Associated loop

`loops/L01-ambiguous-requirements.md`: while open ambiguities/gaps exist → build a batch → ask →
integrate the answers into the artifacts → re-verify. It exits when no critical gaps remain.
Safeguard: if the user does not answer, the loop does **not** spin idle — the pending items get
recorded and work proceeds wherever it does not depend on them.

## Anti-patterns

- ❌ Asking what the history already answers → ✅ read `questions-and-answers.md` first.
- ❌ Vague open question ("what do you think about security?") → ✅ concrete options with
  consequences.
- ❌ Assuming in silence → ✅ assume **by declared default**, marked provisional and visible.
- ❌ Technical interrogation ("REST or GraphQL?") with no translation → ✅ ask about the
  consequences the user can evaluate; the technical translation is the agent's job.
- ❌ 30 questions at once → ✅ batches by theme, prioritized by what they block.

## Related

- `core/orchestrator.md` — who groups and places the batches.
- `core/decision-engine.md` — what happens to answers that become technical decisions.
- `loops/L01-ambiguous-requirements.md` — the loop this engine feeds.
- `agents/01-requirements/ambiguity-hunter.md` — the main producer of gaps.
