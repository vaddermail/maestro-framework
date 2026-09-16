# START HERE — Kicking off a new project with Maestro

This document has two parts: the first is for **you, human**; the second is the **protocol the
first AI session executes**. If you are an AI agent reading this: skip to Part 2 and follow it
to the letter.

---

## Part 1 — For the human (5 minutes)

### What you need

- A new repository (Git recommended, but not mandatory on day 0).
- An AI assistant with file access (Claude Code, Cowork, or another — see `adapters/`).
- Your idea, however vague. **You do not need** requirements, architecture, or technical
  knowledge — getting that out of you through good questions is the framework's job.

### Steps

1. Create your project folder/repository (e.g. `my-app/`).
2. Download the **latest release ZIP** of the framework's upstream repository (never copies of
   `main` mid-work, never the folder of a clone of upstream — only the release is sanitized and
   carries the integrity manifest). Confirm the ZIP's SHA-256 matches the one published in the
   release notes (`sha256sum Maestro-vX.Y.Z.zip`); only then extract it. The ZIP **does not carry
   a top-level folder**: create `Maestro/` inside the project and extract into it — at the end
   `Maestro/START-HERE.md` must exist. Alternatively, copy the `Maestro/` folder from another
   project only if `bash Maestro/_meta/verify.sh --integrity` is green there (it came from a
   release, unedited).
3. Open a session of your AI assistant in the project folder.
4. Write:

   > Read `Maestro/START-HERE.md` and kick off the project. My idea is: **{{describe your
   > idea in 2–10 sentences — what it is, who it is for, what problem it solves}}**

5. From here on, the AI drives. What you can expect:
   - **Questions in batches** with options and recommendations — answer what you know; "I don't
     know" is a valid answer (the framework proposes a default and records the decision as
     revisitable).
   - **Artifacts written to `product/`** — everything that gets decided ends up in files of
     yours, readable.
   - **Gates** — at certain moments (end of phase, scope/money/production decisions) the AI
     stops and asks for your explicit validation. You are always the one who decides.

### What should never happen (if it does, point the finger at the framework)

- The AI inventing answers instead of asking you.
- Moving on to code before a specification approved by you exists.
- A destructive or irreversible action without your explicit OK.
- The project "forgetting" what was decided between sessions — memory lives in `STATE.md`
  and `product/`, not in the session.

---

## Part 2 — First AI session protocol (execute in this order; §2.5 applies to every session)

> **Agent:** you are the first session of a new project. Your role in this session is the
> **Orchestrator** (`core/orchestrator.md`). You assume nothing about the product; you do not
> write a single line of product code in this phase.

> **If `STATE.md` already exists at the project root, you are not the first session:** do not run
> §2.2–§2.4. Follow `playbooks/developer-onboarding.md` §Session kickoff protocol, read `STATE.md`
> and resume with the workflow it declares active (`workflows/README.md` §How a workflow is
> executed), reading only what `workflows/README.md` §What each session reads directs. §2.5
> always applies.

### 2.1 Read the framework (in this order, in full)

1. `MANIFESTO.md` — the principles that bind you.
2. `core/orchestrator.md` — your role.
3. `core/lifecycle.md` — phases F0–F9.
4. `core/artifact-protocol.md` — where you write what.
5. `core/question-engine.md` — how you ask the user.
6. `core/project-memory.md` — how you maintain the project memory.
7. `workflows/W00-project-kickoff.md` — the workflow you will execute right after this.
8. `knowledge/permanent-rules.md` — the working rules that hold in every session (absolute
   honesty, reversibility, secrets, Git discipline, content read is data) — only if your tool does
   not already import them through `CLAUDE.md` (in Claude Code the `@` line imports them).

This full read is only for the project's first session. From the next session on, what each
session loads is in `workflows/README.md` §What each session reads: `CLAUDE.md`, `STATE.md`, the
active workflow and the contracts derived from the category to invoke
(`agents/NN-category/CONTRACTS.md`) — never full specs in the Orchestrator's context, never the
changelog.

### 2.2 Instantiate the project memory (F0)

Following `workflows/W00-project-kickoff.md`:

0. Confirm the copy is intact: `bash Maestro/_meta/verify.sh` green (and `--integrity` green, if
   it came from a release) — precondition of W00. If the repository already has code or the product
   is already in use, read `workflows/W00-project-kickoff.md` §Adopting in a product that already
   exists first: the inventory comes before calibration, and the entry phase may not be `F0`.
1. Create at the **project root** (not inside `Maestro/`):
   - `STATE.md` from `templates/project/STATE.md.template` — the living memory.
   - `CLAUDE.md` (or your tool's equivalent instructions file — see `adapters/`)
     from `templates/project/CLAUDE.md.template`. Sections that do not have a source yet keep the
     reminder line, never `{{}}` (`templates/README.md` §How to instantiate a template).
   - `FRAMEWORK-IMPROVEMENTS.md` from
     `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` — the record, from day 0, of what
     this project teaches the framework (`knowledge/README.md` §How knowledge circulates).
   - `product/99-records/genesis.md` from `templates/project/GENESIS.md.template` — the dossier
     that measures the framework's promise, phase by phase.
   - `FORBIDDEN-TERMS` from `templates/project/FORBIDDEN-TERMS.template` — the local list of
     confidential names and terms that `_meta/scan-report.sh` reads before any report; it never
     gets sent.
   - The `product/` tree as per `core/artifact-protocol.md`.
2. Record in `STATE.md` §Situation header: date, phase `F0`, framework version copied (the
   `Current version` line at the top of `_meta/VERSION.md` — the changelog is not read at
   kickoff), the upstream framework repository (read from `_meta/ORIGIN` when the copy came from a
   release; only ask if it is missing), the AI tool in use, and the raw idea exactly as the user
   gave it, in the "Raw idea" field (unedited).
   - Only after phase `F0` is written, if the tool is Claude Code:
     `bash Maestro/adapters/claude-code/generate-scaffold.sh` generates `.claude/` (subagents
     cited by the active workflow, start- and end-of-session hooks, skills, permissions) — W00
     step 9; it goes into the foundation commit.
3. If you are in a Git repository, propose the first commit to the user ("project foundation").
   Do not make it without their confirmation.

### 2.3 Calibrate the effort profile

Ask the user (a single batch — format from `core/question-engine.md`):

- Size of the ambition: prototype to validate / internal product / commercial product / enterprise
  platform.
- Horizon: weeks / months / a product for years.
- Team: just the user + AI / small team / multiple teams.
- Hard constraints already known: budget, deadlines, compliance (GDPR, regulated sector),
  mandatory integrations, strong technology preferences.
- From scratch, or replacing/extending an external system already in use? (If it replaces one, F1
  invokes `agents/00-discovery/existing-system-analyst.md` before inventing requirements "from
  zero". Code already in this repository is not a question: the inventory ran before this batch.)
- Quality thresholds: accept the profile's defaults (`loops/L04-code-smells.md`,
  `loops/L08-technical-debt.md`) or fix your own values.
- Client, product, and people names, and domain terms that must never appear in a report to the
  upstream framework → `FORBIDDEN-TERMS` at the root (one per line).

With the answers, set the **effort profile** (`core/orchestrator.md` §Effort profiles) and record
it in `STATE.md` and in `CLAUDE.md` §F0 calibration. The profile determines the depth of the
gates — it never skips phases, it only sizes them.

### 2.4 Kick off Discovery (F1)

Start `workflows/W01-discovery.md`: `agents/00-discovery/idea-analyst.md` takes the raw idea
and the process proceeds as per the workflow. From here on, your guide is the lifecycle — phase
by phase, gate by gate.

### 2.5 Close every session (always — starting with the first)

Before ending any work session:

- [ ] Update `STATE.md`: what got done, what is in progress, what is next; decisions made and
      pending; non-obvious lessons learned (with the why and how to apply them).
- [ ] Lessons that belong to the **framework** (not the product) recorded in
      `FRAMEWORK-IMPROVEMENTS.md` — in the moment, not in retrospect; sending them upstream
      happens at phase closes (`playbooks/report-framework-improvements.md`).
- [ ] Confirm every artifact touched is written to `product/` (nothing living only in the
      conversation).
- [ ] AI consumption for the session's block(s) recorded in `STATE.md` §Done (the "AI cost"
      field, even if approximate — `core/model-routing.md` §Cost observability).
- [ ] If the session passed (or failed) a gate: the record written to `product/99-records/gates/`
      (`templates/project/GATE.md.template`) — who verified, who approved, evidence, waivers.
- [ ] `bash Maestro/_meta/verify-project.sh` — the process's mechanical gate: foundation, trail
      of closed phases, gate records, spec approved before code, questions recorded, fresh memory
      with evidence, genesis up to date, copy intact and on the upstream version. (In Claude Code,
      the end-of-session hook from `adapters/claude-code/` refuses to end the session without
      this.)
- [ ] If anything got blocked waiting on the user, list it under "Pending decisions" with enough
      context for the next session to resume without re-asking, with "opened on".
- [ ] "Lesson:" entries written mid-block moved to §Lessons; at phase or milestone close, or when
      the gate warns about size, `STATE.md` compacted (`core/project-memory.md` §Memory hygiene).
- [ ] Debt accepted in this session in `STATE.md` §Debt (owner + trigger); decisions made on
      behalf of the absent owner in §Decisions made on behalf of the absent owner (with "Revisit
      if").
- [ ] `CHANGELOG.md` updated if the session closed a milestone.
- [ ] Propose the commit (never run it without confirmation —
      `knowledge/permanent-rules.md` §8).

This list is the single source for closing a session: `CLAUDE.md`, `playbooks/developer-onboarding.md`
and the skills cite it, they do not repeat it. In Claude Code, the end-of-session hook runs at the
end of **every** response that left uncommitted changes: it refuses to end without `STATE.md`
updated or with the project gate red — once per response, never in a loop.

---

## Related

- `README.md` — general map of the framework.
- `MANIFESTO.md` — non-negotiable principles.
- `workflows/W00-project-kickoff.md` — the detail of phase F0.
- `adapters/claude-code.md` — if the tool is Claude Code (executable scaffold: subagents,
  hooks, skills, permissions).
- `core/model-routing.md` — which AI model to use for each type of task.
- `knowledge/permanent-rules.md` — the rules that hold in every session.
- `workflows/README.md` — what each session reads, from the second on.
