# Adapters

Where the **agnostic** framework meets a **concrete tool**. Everything else in the framework
describes **roles and processes** — what an agent does, which artifacts it produces, which gate
guards it — without ever assuming which tool executes that work. An adapter bridges the gap: it
says **how a specific tool** (Claude Code, Cursor, Copilot, …) realizes those roles and processes.

This separation is principle 18 of `_meta/STYLE-GUIDE.md`: the framework executes nothing on its
own; tool coupling lives **only here**.

## The coupling rule

**No document outside `adapters/` may assume a tool.** Concretely:

- An agent document (`agents/…`) describes a **role** (inputs, responsibility, outputs,
  interactions) — never "run subagent X" or "use plugin Y". Execution mechanics belong to the
  adapter.
- A workflow (`workflows/…`) describes a **sequence of steps and gates** — not "invoke skill Z".
  How each step gets triggered belongs to the adapter.
- `core/` describes **contracts** (file-based memory, abstract model tiers, gates) — concrete
  names (`CLAUDE.md`, a specific model, a settings file) enter through the adapter.

If a core, agent or workflow document needs to mention a tool, the right move is to defer to the
respective adapter — as `core/orchestrator.md` and `core/model-routing.md` do, pointing to
`adapters/claude-code.md` instead of embedding tool mechanics. That way, switching tools changes
**one** file, not the whole framework.

## What an adapter must map

Every adapter answers the same questions, for its tool:

| Framework role/process | The adapter says… |
| --- | --- |
| **Orchestrator** (`core/orchestrator.md`) | who takes on the maestro role (the main session? a dedicated agent?) |
| **Agent specs** (`agents/…`) | how a role becomes execution (dedicated subagent, sequential session, skill) |
| **Workflows/loops** (`workflows/`, `loops/`) | how a sequence is driven and where the progress log lives |
| **Memory** (`core/project-memory.md`) | where the stable rules and live state live, and how the tool loads them |
| **Model routing** (`core/model-routing.md`) | which concrete models fill the Top/Standard/Economy/Mechanical tiers |
| **Gates and human approval** (`core/quality-gates.md`) | how the tool's autonomy mode respects the gates that require the human |
| **Supporting tools** | which plugins/integrations the tool offers, versioned for the whole team |

## This framework's adapters

| Adapter | Tool | Status |
| --- | --- | --- |
| `adapters/claude-code.md` | **Claude Code** — CLI/IDE with subagents, skills, plugins, MCP and hooks | Complete, tested mapping (it is the origin project's tool) |
| `adapters/other-assistants.md` | **Other assistants** — Cursor, Copilot, Codex CLI, aider and the like | Adaptation principles and the viable minimum |
| `adapters/claude-code/` | **Executable scaffold for Claude Code** — `adapters/claude-code/generate-scaffold.sh` (specs → `.claude/agents/`, per phase, with a verifiable lock), `adapters/claude-code/settings.json.template` (permissions + hooks), three hooks (session start, artifact guard, session end), five `/maestro-…` skills and `adapters/claude-code/test-hooks.sh` | Shipped with the copy; generated to the project root in W00 step 9, at every phase transition and after syncing (`adapters/claude-code.md` §Executable scaffold) |

Adding a new adapter follows `core/extensibility.md`: create the file here, register it in
`_meta/INVENTORY.md` in the same step, and **touch no** agnostic document — if the mapping seems
to require changing the core, that is a sign the coupling escaped the adapter.

## Related

- `_meta/STYLE-GUIDE.md` — principle 18 (coupling lives only in adapters).
- `adapters/claude-code.md` — the concrete mapping for Claude Code.
- `adapters/other-assistants.md` — adapting to other code assistants.
- `core/orchestrator.md` — the role every adapter materializes in a tool.
- `core/extensibility.md` — how to add an adapter without touching the existing ones.
