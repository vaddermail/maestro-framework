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
   `main` mid-work — the release is the stable version, with the number in plain sight) and
   extract it into a `Maestro/` folder inside the project. Alternatively, copy the `Maestro/`
   folder from an already-downloaded release.
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

## Part 2 — First AI session protocol (execute in this order)

> **Agent:** you are the first session of a new project. Your role in this session is the
> **Orchestrator** (`core/orchestrator.md`). You assume nothing about the product; you do not
> write a single line of product code in this phase.

### 2.1 Read the framework (in this order, in full)

1. `MANIFESTO.md` — the principles that bind you.
2. `core/orchestrator.md` — your role.
3. `core/lifecycle.md` — phases F0–F9.
4. `core/artifact-protocol.md` — where you write what.
5. `core/question-engine.md` — how you ask the user.
6. `core/project-memory.md` — how you maintain the project memory.
7. `workflows/W00-project-kickoff.md` — the workflow you will execute right after this.

### 2.2 Instantiate the project memory (F0)

Following `workflows/W00-project-kickoff.md`:

1. Create at the **project root** (not inside `Maestro/`):
   - `STATE.md` from `templates/project/STATE.md.template` — the living memory.
   - `CLAUDE.md` (or your tool's equivalent instructions file — see `adapters/`)
     from `templates/project/CLAUDE.md.template`.
   - `FRAMEWORK-IMPROVEMENTS.md` from
     `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` — the record, from day 0, of what
     this project teaches the framework (`knowledge/README.md` §Como o conhecimento circula).
   - The `product/` tree as per `core/artifact-protocol.md`.
2. Record in `STATE.md`: date, framework version copied (`_meta/VERSION.md`), AI tool in use,
   and the raw idea exactly as the user gave it (unedited).
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

With the answers, set the **effort profile** (`core/orchestrator.md` §Effort profiles) and record it in
`STATE.md`. The profile determines the depth of the gates — it never skips phases, it only
sizes them.

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
- [ ] `bash Maestro/_meta/verify-project.sh` — the process's mechanical gate: foundation, trail
      of closed phases, fresh memory, genesis up to date, intact copy.
- [ ] If anything got blocked waiting on the user, list it under "Pending decisions" with enough
      context for the next session to resume without re-asking.

---

## Related

- `README.md` — general map of the framework.
- `MANIFESTO.md` — non-negotiable principles.
- `workflows/W00-project-kickoff.md` — the detail of phase F0.
- `adapters/claude-code.md` — if the tool is Claude Code (subagents, skills, memory).
- `core/model-routing.md` — which AI model to use for each type of task.
