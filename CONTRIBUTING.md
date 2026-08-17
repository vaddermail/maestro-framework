# Contributing to Maestro

Maestro improves the way it tells products to improve: through a **feedback circuit with gates**.
This repository is the public, English edition of the framework; contributions flow through the
same circuit the framework itself prescribes — adapted to GitHub.

## The golden rule of the circuit

**Signals go up, releases come down.** You never need write access to contribute: field reports
and pull requests go up; curated, versioned releases come down. Every change is reviewed by a
maintainer before it teaches anything to anyone.

## Three ways to contribute

### 1. Field report (the most valuable one)

You used Maestro on a real project and learned something — a trap the framework doesn't prevent,
a pattern that worked with measured gains, friction where the framework was silent, or a reusable
building block. Open an issue with the **field report** template. Rules:

- Every entry carries **what → why → evidence → suggested destination**. A lesson without a why
  and evidence is an opinion, and opinions don't merge.
- **Sanitize before sending**: no personal data, client names, secrets, or confidential domain
  detail. The lesson generalizes; the context stays home.
- One project's lesson becomes a **candidate** (`knowledge/candidates.md`) and waits for a second,
  independent confirmation before being promoted — so also report when you **confirm or refute an
  existing candidate** (reference its stable ID, `C-nnn`). Confirmations are as valuable as new
  reports: they are what unlocks promotions.

### 2. Pull request

For concrete changes (a new agent spec, a playbook, a fix):

- **Addition over surgery**: extend without rewriting what exists (`core/extensibility.md`).
  Changes that alter contracts between agents are MAJOR and need discussion first — open an issue.
- Follow the style guide (`_meta/STYLE-GUIDE.md`) and, for agent specs, the template with all its
  sections in order (`agents/_template/AGENT-TEMPLATE.md`).
- **`bash _meta/verify.sh` must pass** — it runs in CI on every PR and checks inventory,
  cross-references, spec structure, the artifact graph and more. Register new files in
  `_meta/INVENTORY.md`.
- New knowledge claims need the same standard as field reports: why + evidence. Content invented
  from imagination — including starters not distilled from a real project — will be declined.

### 3. Confirmations and refutations

Read `knowledge/candidates.md`. If your project lived one of the pending candidates — or tried it
and it failed — say so in an issue, with evidence. Two independent confirmations promote a
candidate into the framework; refutations are recorded too, so the same debate never restarts
from zero.

## What maintainers do (curation)

Reports and PRs are triaged in curation rounds (`playbooks/framework-curation.md`): security,
data and gates first, then by age; every item gets a written verdict — promoted, candidate,
or declined with reasons. No issue is closed without one. The maintainer merge is the final gate:
an error in the framework multiplies into every product built with it, so the bar is deliberate.

## Ground rules

- English, in the repository's engineering register; one agent, one responsibility; everything
  written down; nothing that only works for one stack outside `starters/`.
- Be honest about provenance: state whether something comes from a real project or is a proposal.
- No AI-generated bulk submissions without real-project evidence behind them.

Thank you — the framework only gets wiser through people who use it for real.
