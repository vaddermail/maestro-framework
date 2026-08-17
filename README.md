# Maestro — an Operating System for AI-Assisted Software Development

**Maestro** is a universal framework for building **any kind of software** with specialized AI
agents — from the first idea to production, and through years of maintenance afterwards. Copy the
framework into a new repository, describe your idea, and it drives the whole process: discovery,
requirements, architecture, UX/UI, construction, data, infrastructure, testing, security,
documentation, launch and evolution — **assuming nothing**: whatever is missing gets asked.

> Distilled from real products built from scratch with AI. It is not a prompt collection: it is a
> system of **agents with contracts**, **workflows with gates**, **loops with exit conditions**,
> **auditable file-based memory** and **knowledge that accumulates** — a framework that learns
> from every product built with it, through a curated feedback circuit.

## How it works (30-second version)

1. Create a new repository and copy the `Maestro/` folder into it (from the latest release ZIP).
2. Open a session with your AI assistant (Claude Code or another — see `adapters/`).
3. Tell it: **"Read `Maestro/START-HERE.md` and start the project."**
4. From there the Orchestrator drives: batched questions, artifacts written to `product/`, your
   explicit decisions at every gate — the human always decides.

## The map

| Folder | What it holds |
| --- | --- |
| `core/` | The operating system: orchestrator, F0–F9 lifecycle, artifact protocol, question/decision engines, gates, memory, model routing, extensibility |
| `agents/` | 152 specialists in 15 categories — each with objective, inputs, outputs, rules, limitations, workflow, examples and anti-patterns |
| `workflows/` | The processes that connect agents, W00–W12 |
| `loops/` | Intelligent persistence: "while X → act", with anti-infinite-loop safeguards |
| `modules/` | Reusable product capabilities (RBAC, state machines, audit, job queues, feature flags…) |
| `templates/` · `checklists/` · `playbooks/` · `pipelines/` | Ready-to-instantiate documents, objective gate criteria, step-by-step procedures, reference automation |
| `knowledge/` | Distilled experience: origin lessons, AI traps, permanent rules, proven patterns — and the candidates ledger of the learning loop |
| `starters/` | The executable-kickoff contract; stack implementations are optional and born from real projects |
| `adapters/` | Bindings to concrete tools |
| `_meta/` | Inventory, style guide, versioning, and the self-verification gates (`verify.sh`, `verify-project.sh`) |

## How this mirror works

Maestro is developed against real products in its original (Portuguese) upstream and mirrored here
fully in English — structure, paths, tooling and prose. Each upstream release is translated and
synced as a release of this edition. Issues and PRs are welcome — see
[CONTRIBUTING.md](CONTRIBUTING.md), which explains the framework's own contribution circuit:
**field reports go up, curated releases come down.**

## License

[MIT](LICENSE).
