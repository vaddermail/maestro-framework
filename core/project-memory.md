# Project Memory

How a project driven by AI agents **remembers everything** — across sessions, across people,
across tools and across years. The founding rule: **memory lives in the repository, in versionable
local files — never in a tool's session.** Any agent, in any tool, picks up the project by reading
files; nothing relevant may exist only in the ephemeral memory of a conversation.

## The memory layers (and the reading order)

Stratified sources of truth, read in this order — with **explicit precedence** and a written
tie-break rule (when two diverge, the one above wins and the divergence gets recorded):

| # | File/folder | Nature | Changes |
| --- | --- | --- | --- |
| 1 | `CLAUDE.md` (or equivalent) | **Stable rules**: how to work, guardrails, closed decisions, model mapping | Rarely, with weight |
| 2 | `STATE.md` | **Living memory**: done / in progress / next / pending items / lessons | Every session |
| 3 | `product/` | **Canonical artifacts**: discovery, requirements, spec, ADRs (`core/artifact-protocol.md`) | Per phase/slice |
| 4 | Code + tests | The implementation of the spec (if they diverge, the spec wins — update one or the other, in the open) | Continuously |
| 5 | `CHANGELOG.md` | The history of *what changed and why*, per milestone | Per milestone |

## STATE.md — the handover

The most important file of the day-to-day: it is where one session **hands over** to the next (or
to a human colleague). Structure (instantiated from `templates/project/STATE.md.template`):

1. **Situation header** — current phase, active workflow, effort profile, framework version.
2. **Done** — completed blocks (what, verification evidence).
3. **In progress** — what is halfway, with enough for someone else to resume **without
   re-asking**.
4. **Next** — ordered next steps.
5. **Pending decisions** — questions waiting on the user (`P-nnn`), with context and what they
   block.
6. **Decisions made on behalf of the absent owner** — when moving forward was necessary, recorded
   explicitly as revisitable.
7. **Lessons** — the **non-obvious** things learned, each with the *why* and the *how to apply*.
   Bugs that repeated, tool pitfalls, course corrections. (Before adding: check for duplicates —
   update instead of duplicating; delete what proved wrong.)
8. **Historical log** — previous sessions, collapsed/summarized (see §Memory hygiene).

Associated discipline:

- **Session start:** startup protocol — sync (pull), read `STATE.md`, confirm the environment,
  only then work (`workflows/W00-project-kickoff.md`).
- **Session end:** update `STATE.md` **always** (`START-HERE.md` §2.5). A session that does not
  update the state is half-lost work.

## Where each kind of knowledge lives

| Type | Where | Anti-example |
| --- | --- | --- |
| Stable working rule | `CLAUDE.md` | Repeated orally every session |
| State and pending items | `STATE.md` | In the last session's head |
| Structural decision + why | ADR in `product/02-architecture/decisions/` | In a commit comment |
| Business rule | `product/04-specification/` | Only in the code |
| Non-obvious lesson | `STATE.md` §Lições | Relearned by repeating the bug |
| Improvement that belongs to the framework (not the product) | `FRAMEWORK-IMPROVEMENTS.md` at the root | Dies in commits and in heads; the framework does not learn (`playbooks/report-framework-improvements.md`) |
| User question/answer | `product/01-requirements/questions-and-answers.md` | Re-asked every 3 sessions |
| Rule provenance | Annotation in the spec itself ("origin: defect X") | Lost — the spec becomes dogma without context |

**Rules with provenance:** annotating in the specs the origin of each hard rule (the
defect/decision that created it) turns the specification into defect memory — it prevents a future
agent from "simplifying" it for not understanding why it exists.

## Memory hygiene

- **Detailed top, collapsed history.** `STATE.md` grows; the top stays hyper-detailed about the
  present and the history is summarized by milestones (old detail stays in Git/CHANGELOG).
  A 200KB `STATE.md` where nobody finds anything has stopped being memory.
- **No secrets.** Never in any versioned file — references by path
  (`playbooks/secrets-management.md`).
- **Failed experiments are recorded with the exact reason** — so nobody repeats the attempt three
  sessions later.
- **Tool memories ≠ project memory.** Tool session state (an MCP's active project, a plugin's
  cache) is neither persisted nor assumed — whatever matters moves into the project files.

## Anti-patterns

- ❌ "I remember what we decided" → ✅ it is written down or it does not exist.
- ❌ Updating the state "at the end of the day" and the session dying first → ✅ update at the end
  of every block.
- ❌ A lesson written without the why ("careful with X") → ✅ why + how to apply, otherwise it
  becomes superstition.
- ❌ Duplicating the same lesson in new words → ✅ search for and update the existing one.
- ❌ Memory in a proprietary tool (session notes, threads) → ✅ the repository, always.

## Related

- `templates/project/STATE.md.template` · `templates/project/CLAUDE.md.template` — the
  instantiables.
- `core/artifact-protocol.md` — canonical memory through artifacts.
- `core/decision-engine.md` — ADRs and closed decisions.
- `knowledge/README.md` — how lessons rise from project to framework.
