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
4. **Up next** — ordered next steps.
5. **Pending decisions** — questions waiting on the user (`P-nnn`), with context and what they
   block.
6. **Decisions made on behalf of the absent owner** — when moving forward was necessary, recorded
   explicitly as revisitable.
7. **Lessons** — the **non-obvious** things learned, each with the *why* and the *how to apply*.
   Bugs that repeated, tool pitfalls, course corrections. (Before adding: check for duplicates —
   update instead of duplicating; delete what proved wrong.)
8. **Debt** — technical debt accepted knowingly, each with an owner and the trigger that pays it.
   What is recorded here is not re-flagged by reviewers and guardians (`loops/L08-technical-debt.md`).
9. **Historical log** — previous sessions, collapsed/summarized (see §Memory hygiene).

Associated discipline:

- **Session start:** startup protocol — sync (pull), read `STATE.md`, confirm the environment,
  only then work (`playbooks/developer-onboarding.md` §Session-start protocol).
- **Session end:** update `STATE.md` **always** (`START-HERE.md` §2.5). A session that does not
  update the state is half-lost work.

## Where each kind of knowledge lives

| Type | Where | Anti-example |
| --- | --- | --- |
| Stable working rule | `CLAUDE.md` | Repeated orally every session |
| State and pending items | `STATE.md` | In the last session's head |
| Structural decision + why | ADR in `product/02-architecture/decisions/` | In a commit comment |
| Business rule | `product/04-specification/` | Only in the code |
| Non-obvious lesson | `STATE.md` §Lessons | Relearned by repeating the bug |
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
- **Compaction has a trigger, not goodwill.** The principle above existed and no project followed
  it: measured across four projects, live memory reached hundreds of thousands of tokens in one,
  tens of thousands within two weeks in another, a table cell with thousands of characters in a
  third — and every session pays for all of it up front. Compact **at the close of each phase or
  milestone** and whenever `_meta/verify-project.sh` warns (a file above 60 KB, or a line above
  3,000 characters). The procedure has three steps: (1) each closed §Done and §Historical log
  block collapses into 2–4 lines per milestone, with the "AI cost" total (it is what the genesis
  reads); (2) whatever would have been lost but still matters — a lesson, a decision — moves up
  to its own section before the collapse; (3) the detail is not copied to another file, it stays
  in Git — `git log -p STATE.md` returns it. The "Last updated" cell describes **the last
  session**, never a chain of "Before, …".
- **Lessons do not stay in the middle of prose.** A "Lesson:" written in the middle of a §Done
  block moves up to §Lessons at session close — and, if it teaches the framework, to
  `FRAMEWORK-IMPROVEMENTS.md`. On one project, the lessons section said "none yet" a month after
  the file had several, scattered through the text.
- **No secrets.** Never in any versioned file — references by path
  (`playbooks/secrets-management.md`).
- **Failed experiments are recorded with the exact reason** — so nobody repeats the attempt three
  sessions later.
- **An operational fact lives in one place; the rest point to it.** A permissions recipe written
  in two files went stale in one of them and broke the same service again. And a fact about the
  state of a volatile external system (another repository, a service) is recorded as the
  **command that re-derives it** with its controls, never as the value — a value about another
  repository rotted in under an hour, and it was the fix for one that had rotted in four days.
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
