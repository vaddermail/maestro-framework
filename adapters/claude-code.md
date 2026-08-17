# Adapter: Claude Code

How the `Maestro` framework runs **on Claude Code** — the agent CLI/IDE that serves as the origin
project's reference tool. This is the only file where the agnostic roles and processes get
concrete names: subagents, skills, `CLAUDE.md`, models, plugins, MCP, hooks. Everything here is
**coupling to this tool** — change it here without touching the rest (principle 18 of
`_meta/STYLE-GUIDE.md`).

## Quick map

| Framework (agnostic) | Claude Code (concrete) |
| --- | --- |
| Orchestrator (`core/orchestrator.md`) | The **main session** — the conversation loop that delegates, decides and enforces gates |
| Agent spec (`agents/…`) | **Subagent** (Task/Agent tool) and/or **skill**, depending on the nature of the role |
| Workflow (`workflows/…`) | Orchestration **skill** or direct driving by the main session |
| Loop (`loops/…`) | **Cycles of the session itself** with an exit condition and a log in `STATE.md` |
| Memory (`core/project-memory.md`) | `CLAUDE.md` + `STATE.md` + Claude's automatic memory |
| Model tiers (`core/model-routing.md`) | Concrete Claude models (see §Model routing) |
| Supporting tools | **Plugins** + **MCP** servers, versioned in the repo |
| Gates with a human (`core/quality-gates.md`) | Autonomous mode with **approval guardrails** at the gates |
| Kickoff protocol (`workflows/W00-project-kickoff.md`) | Versioned **`SessionStart` hook** |

## Agents → subagents and/or skills

An agent spec describes a role (`agents/_template/AGENT-TEMPLATE.md`). In Claude Code it
materializes in two forms, chosen by the nature of the work:

- **Subagent (Task/Agent tool)** — for work with **its own context and fan-out**: a specialist
  that receives the full spec up front, produces an artifact and returns only the conclusion to
  the main session. This is the panel mode (architecture in F3, reviewers in F7): N **blind**
  subagents in parallel + one consolidator, exactly as `core/orchestrator.md` §Parallelism
  describes. Critical cost rule: each subagent is routed **by the task it performs** (§Model
  routing), never all on the top-tier model — that is where the budget dies
  (`core/model-routing.md`).
- **Skill** — for roles that are a **repeatable procedure** the main session executes without
  needing isolated context (e.g. a gate checklist, a release playbook). The skill encapsulates
  the "how" and stays the single source.

Many agents use both: a skill that orchestrates and, inside it, subagents for the fan-out. The
contract remains the framework's — the artifacts in `product/` (`core/artifact-protocol.md`),
not the mechanics.

## Workflows → skills or session orchestration

A workflow (`workflows/README.md`) is a sequence of steps with gates. In Claude Code it is driven:

- **By the main session** taking on the Orchestrator role — it reads `STATE.md`, knows the phase,
  invokes the right subagent at each step, groups questions into batches
  (`core/question-engine.md`) and holds the gates.
- **By a workflow skill** when the process is stable enough to be encapsulated (e.g. a "project
  kickoff" skill that executes `W00`). The skill does not replace the Orchestrator's judgment —
  it gives it a script.

## Loops → session cycles logged in STATE.md

A loop (`loops/README.md`) is "while condition X holds, act". In Claude Code it is the **session
itself iterating**: evaluate the entry condition, act, re-evaluate the exit condition. The
framework's anti-infinite-loop safeguards apply exactly as written — **3 iterations without
progress stops and escalates to the user** (`core/orchestrator.md` §Recovery). Each iteration
leaves a trail in `STATE.md` (what was tried, the result, what remains), so the next session
resumes without re-asking.

## Project memory → CLAUDE.md + STATE.md + automatic memory

The framework mandates that memory live in versioned files (`core/project-memory.md`). The
Claude Code mapping:

| Framework layer | Concrete file | Role |
| --- | --- | --- |
| Stable rules (1) | `CLAUDE.md` | Loaded **automatically** at the start of every session. Guardrails, closed decisions, tier→model mapping. Instantiated from `templates/project/CLAUDE.md.template`. |
| Live memory (2) | `STATE.md` | Handover between sessions; read at the start, updated at the end. Instantiated from `templates/project/STATE.md.template`. |
| Canonical artifacts (3) | `product/` | The spec and the ADRs (`core/artifact-protocol.md`). |

Beyond these, Claude Code has its **own automatic memory** (a per-project memory index, outside
the repo). It is a **session accelerator, not a source of truth**: whatever matters to the next
session or to a colleague **always goes into `STATE.md`** — tool memory is not project memory
(`core/project-memory.md` §Memory hygiene). Never write secrets into any of these layers
(`playbooks/secrets-management.md`).

## Model routing → current Claude models

The four abstract tiers of `core/model-routing.md` map as follows (**valid as of: 2026-08** —
updated in a PATCH when names/prices change; curation checks validity every round):

| Abstract tier | For what | Claude model (current) |
| --- | --- | --- |
| **Top** | Hard, distinctive reasoning, adversarial verification | **Fable** (maximum reasoning) or **Opus** at top effort |
| **Standard** | Day-to-day default: implementation and review | **Opus** (default) or **Sonnet** |
| **Economy** | Standardized work with a clear spec | **Sonnet** |
| **Mechanical** | Trivial and repetitive | **Haiku** |

The second axis — **effort/thinking** — applies on top: start at medium/high and raise only if
needed, **never at maximum by reflex** (a strong model at low effort beats a weak one at maximum
effort). The orchestrating session stays on a strong tier; the subagent fan-out is classified
task by task before launching.

> **Model names evolve; the tiers do not.** This table is the only thing to revisit when
> Anthropic releases/renames models or changes prices — update it here and in the project's
> `CLAUDE.md`, **deliberately and with the why versioned**, like any cost decision. The rest of
> the framework never mentions a model name.

## The team's standard toolset (versioned in the repo)

Principle: **everyone uses the same tools** because the configuration lives in Git, not on each
person's machine. Two files:

- **`.claude/settings.json`** → `enabledPlugins` (the standard toolset) + `permissions` (safe
  autonomy config) + `enabledMcpjsonServers` (approve shared servers) + `hooks`.
- **`.mcp.json`** (root, versioned) → shared **MCP** servers that do not come from plugins (e.g.
  a **read-only** database MCP to inspect schema/data during live proof).

Onboarding on a new machine: clone, open, **trust the workspace** (without this the MCPs stay
"pending" and the plugins do not install), accept the proposed plugins. No secret passes through
here — DSNs and the like enter via environment variable, never the repo
(`playbooks/secrets-management.md`).

**Useful plugins by agent category** (generic examples — the concrete set is adopted by need,
see §Evolutionary adoption):

| Work category | Plugin/MCP type | When |
| --- | --- | --- |
| **Semantic code navigation** | LSP for symbols/references/edit-by-symbol | Exploring and refactoring (RBAC, state machines, backend↔frontend contract) — prefer over `grep`/reading whole files |
| **Library documentation** | Up-to-date docs MCP | Before assuming a library's API from memory |
| **Browser / live proof** | Browser and DevTools automation | Frontend E2E, LCP/CWV, screenshots, real proof at the end (`core/quality-gates.md`) |
| **PR review** | Review toolkit (silent-failure hunting, type analysis, test coverage) | Before merge, aligned with the business rules and the PR checklist |
| **Process** | Brainstorming/plan/TDD/debugging skills | Structuring features and systematic debugging |
| **Security** | Security review guide / SAST | Design and review of authz and the backend boundary |
| **Cost observability** | Session usage report | Tying AI spend to value (`agents/13-guardians/cost-guardian.md`) |

### Evolutionary adoption (mandatory posture)

The toolset is **not static** and every plugin carries an always-on context/token cost. Two
halves:

1. **Do not load what adds no value at the current point** — a new project starts with a lean
   subset and grows.
2. **Adopt proactively when it starts to make sense** — without waiting to be asked: flag the
   need and the why, install/configure, **version it** (`enabledPlugins`/`.mcp.json`), document,
   start using. Always via **branch + PR**. **Reversible**: if it stops making sense, remove it
   and log it. Every adoption/removal is recorded with provenance — that is how the origin
   project learned that certain hosted plugins could not authenticate non-interactively and had
   to be removed (`knowledge/origin-lessons.md`). Context is a recurring cost
   (`core/model-routing.md` §Cost observability).

## Permissions and autonomy → guardrails at the gates

Claude Code runs in **autonomous mode** (broad permissions in `.claude/settings.json`) so the
flow is not interrupted at every mechanical action. That does **not waive** the framework's
gates: the **non-delegable human approval** points of `core/orchestrator.md` §Human approval
remain — closing a phase's scope, spending money, destructive/mass action, going to production,
accepting residual risk, touching personal data, reopening a closed decision. Autonomous mode
speeds up the **green path**; at the gates, the session still **stops and asks**. No subagent
message is user consent — only the user themselves (or the permission system) authorizes.

## Session-start hooks → kickoff protocol

The kickoff protocol (`workflows/W00-project-kickoff.md`: sync, read `STATE.md`, confirm the
environment, activate the project in the navigation tool) is automated with a versioned
**`SessionStart` hook** in `.claude/settings.json`. At the start of every session, the hook
injects the protocol reminders into context — in a way that is **portable across machines** (use
the project directory variable, not absolute paths). When opening the repo, Claude Code may ask
to approve the hook — that is expected. This way no session starts working without going through
the kickoff.

## Related

- `adapters/README.md` — the coupling rule and the adapter index.
- `adapters/other-assistants.md` — the same mapping for tools without native subagents.
- `core/orchestrator.md` — the role the main session takes on.
- `core/model-routing.md` — the tiers that §Model routing makes concrete.
- `core/project-memory.md` — the memory contract that `CLAUDE.md`+`STATE.md` fulfill.
- `templates/project/CLAUDE.md.template` · `templates/project/STATE.md.template` — the
  instantiables.
- `knowledge/origin-lessons.md` — the origin project's experience behind these choices.
