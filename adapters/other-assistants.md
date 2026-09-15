# Adapter: other code assistants

How to run the `Maestro` framework on assistants **without** native subagents or with poorer
orchestration than Claude Code — **Cursor**, **GitHub Copilot**, **Codex CLI**, **aider** and the
like. This is not a closed per-tool mapping (they change too fast); it is the **adaptation
principles** and the **viable minimum** that make the framework work on any of them. The
framework's contract is the **artifacts and the gates**, not the mechanics — so the essentials
carry over; what changes is the comfort.

## What the framework requires of any tool

Whatever the tool, three things must exist. Without them, it is not the framework running — it is
improvisation:

1. **Memory in versioned files.** `CLAUDE.md` (or the tool's equivalent) for the stable rules +
   `STATE.md` for the live state + `product/` for the canonical artifacts. This is what enables
   the handover across sessions, people and tools (`core/project-memory.md`).
2. **Manual gate discipline.** Where Claude Code holds the gates through the orchestrating
   session, on another tool the human (or the session) holds them **consciously**: the
   non-delegable approval points of `core/orchestrator.md` §Human approval do not disappear
   just because the tool does not enforce them.
3. **Model routing, even if coarse.** The tiers of `core/model-routing.md` apply even when the
   choice is just "strong model" vs "fast model": use the strong one for distinctive reasoning,
   the fast one for the mechanical.

If the tool offers this, you have the **viable minimum**. Everything else is an ergonomics gain.

## Where each tool keeps the stable rules

The `CLAUDE.md` equivalent — the automatically loaded project instructions file — exists in most
tools under a different name. Always instantiate from `templates/project/CLAUDE.md.template` and
adjust the file name to the tool:

| Tool | Where the project's stable rules live |
| --- | --- |
| **Cowork** | Project instructions file (the `CLAUDE.md` equivalent) in the project's shared folder; gates and question batches run in the conversation — with no subagent fan-out, the reviewer panel runs sequentially — **a new session per reviewer** |
| **Cursor** | Project rules (`.cursor/rules/…`, or the workspace's single rules file) |
| **GitHub Copilot** | The repository's instructions file for Copilot |
| **Codex CLI** | Agent instructions file at the repo root |
| **aider** | Conventions file pointed at the session + the initial `read`/context |

Whatever the name, the **source of truth is the repository** — `STATE.md` and `product/` are
shared and tool-agnostic; only the rules file changes label. Two people on different tools share
context with a `git pull`.

The `@Maestro/knowledge/permanent-rules.md` line that `templates/project/CLAUDE.md.template`
carries is Claude Code import syntax: **on other tools it is an inert line** — it loads nothing.
Reading `knowledge/permanent-rules.md` is done by hand, as the first step of the kickoff protocol
(`playbooks/developer-onboarding.md` §Session kickoff protocol), in every session — leaving it in
the file does no harm and keeps `CLAUDE.md` portable across tools.

## Simulating subagents when there are none

The biggest deficit of these tools is the **absence of real subagents** — no fan-out of N blind
specialists + consolidator (`core/orchestrator.md` §Parallelism). Compensate with **sequential
sessions that communicate through file artifacts**:

- **Architecture panel (F3) / reviewers (F7):** instead of N parallel subagents, run N sequential
  **new sessions** (a clean context window per role — in the same window, the next role has
  already seen the previous one's report and the panel stops being blind), each playing one
  specialist's role, **writing its report to its own file** in `product/…` (format of
  `templates/technical/review-report.md.template`).
  Only afterwards does a **consolidation** pass read all the files and produce the single plan.
  The "blind" isolation is achieved by **not giving** a pass the other passes' reports until
  consolidation.
- **Vertical slices (F6):** run one at a time; coordination lives in `STATE.md` (what is done,
  what is in progress), not in session memory.
- **Loops (`loops/…`):** the same session iterates, with the **explicit exit condition** and the
  safeguard of stopping at 3 iterations without progress — each lap's log goes to `STATE.md`.
- **Context cost per role-session:** each role-session reads only its role's context package
  (`adapters/claude-code.md` §Agents → subagents and/or skills) — the spec (~11 KB), the artifacts
  under review and the report template; never the other roles' specs (a full reviewer panel is
  ~130 KB of specs). If the tool does not allow opening a new session per role, the user opens it;
  `STATE.md` says which role is next to run.
- **Compiled subagents (`.claude/agents/maestro-*`):** do not exist here. The Orchestrator reads
  `agents/NN-category/CONTRACTS.md` (phases, type, layer, inputs, outputs, criteria) to assemble
  the graph and the briefing, and **passes the spec by path** in the sequential pass — the
  role-session reads it in full; the orchestrating session never loads it.
- **Independent verification (gates, live proof):** "whoever verifies is never whoever produced"
  requires a **new session with only the files** — the artifact or diff, the checklist section and
  the evidence format (`knowledge/proven-patterns.md` §Live proof) — never the conversation nor
  the slice's plan. The session that produced does not verify; the gate's record says who
  verified and with what context.

The file artifact **is** the context-passing mechanism the subagents would provide in memory.
Slower, equally correct.

## What is lost without native orchestration — and how to compensate

| Loss | Compensation |
| --- | --- |
| **Real parallel fan-out** | Sequential + file artifacts (above). Slower; the result must be the same. |
| **Tool-enforced gates** | Explicit checklists at each gate (`checklists/`), validated by hand; the human confirms before moving on. |
| **Automatic model routing** | Conscious manual choice per task; log deviations in `STATE.md`. |
| **Team-versioned toolset** | Document in `STATE.md`/README the extensions/MCP the tool uses, for parity across people — even if the tool does not version them itself. |
| **Session-start hook** | **Manual**, disciplined kickoff protocol (`playbooks/developer-onboarding.md` §Session kickoff protocol): sync, read `STATE.md` and `knowledge/permanent-rules.md`, confirm the environment — every session, no exception; `workflows/W00-project-kickoff.md` is only the first session. |
| **Session-end hook** | `START-HERE.md` §2.5 checklist, run by hand before ending, with `bash Maestro/_meta/verify-project.sh` — the project's gate is the same on any tool. |
| **Compiled subagents** | The Orchestrator reads `agents/NN-category/CONTRACTS.md` and passes the spec by path in the sequential pass (above). |
| **Independent verification by a clean subagent** | A new session with only the files to verify, the checklist and the evidence format — never the conversation (above). |
| **Tool permissions and hooks** (read-only copy, canonical tree, destructive actions) | Discipline: never edit `Maestro/` (`--integrity` flags it), write only in the tree of `core/artifact-protocol.md`, and a plan + the user's OK before any destructive action (`core/orchestrator.md` §Human approval). |
| **The tool's automatic memory** | No real loss: the framework never depended on it — the canonical memory is the versioned files (`core/project-memory.md`). |

## Underlying principle

A poorer tool **does not lower the bar** — it only transfers to the human and to file discipline
what Claude Code automates. The framework was designed agnostic precisely for this: the role and
process documents read the same on any assistant; only this adapter changes. If a new tool gains
subagents or hooks, promote its mapping to a dedicated adapter (`core/extensibility.md`),
without touching the rest.

## Related

- `adapters/README.md` — the coupling rule and the adapter index.
- `adapters/claude-code.md` — the full mapping on the reference tool (the target to imitate).
- `core/project-memory.md` — the viable minimum: memory in versioned files.
- `core/orchestrator.md` — the gates and the parallelism simulated by hand.
- `playbooks/developer-onboarding.md` — the session kickoff protocol to execute manually (every time).
- `workflows/W00-project-kickoff.md` — the first session of a new project.
- `core/extensibility.md` — how to promote a new tool to a dedicated adapter.
