# Starters

Where the **agnostic** framework meets a **concrete stack**. Following the same pattern as
`adapters/README.md` — which confines tool coupling — this folder confines stack coupling: the
starter **contract** is defined here, agnostic; the **implementations** live in
`starters/starter-<stack>/` (in this folder or as sibling repositories), are optional and are
born from real projects. The motive is the biggest avoidable kickoff cost: slice 0
(`checklists/definition-of-done.md` §F6 — Skeleton (slice 0)) demands the **outcome** — runners,
guardrails and pipeline green before the first slice — but each project pays for the **build**
from scratch. A starter pre-pays that build without marrying the framework to any stack.

## What a starter is — and what it is not

A starter is a code skeleton for a concrete stack that delivers slice 0 **fulfilled on the first
commit**: tests running in CI, guards on and pipeline green before any functionality exists.

What it is **not**:

- **It is not the framework.** Maestro remains executable, stack-agnostic documentation
  (`README.md`). A starter is code, coupled by nature — which is why it lives only here, just as
  tool coupling lives only in `adapters/`.
- **It is not mandatory.** A project without a starter for its stack builds slice 0 by hand, as
  always — the gate is exactly the same; the starter only changes who pays for the build.
- **It is not a product template.** Zero domain decisions: the same starter serves an online
  store, a B2B invoicing SaaS or an internal logistics app. It brings base engineering — never screens,
  business rules or the product's data model.
- **It does not waive the process.** The test strategy is written before slice 0
  (`workflows/W06-build.md` §Preconditions) and the skeleton checklist is still confirmed item
  by item — using a starter means verifying faster, not verifying less.

## The contract — what every starter delivers on the first commit

Everything below is verifiable; a starter that fails one item does not enter this folder:

- [ ] **Test runner per surface** (frontend, backend, …) configured and **running in CI**, with
      at least one real test passing per surface — typecheck and build passing do not count as
      tested (`checklists/pre-merge.md`).
- [ ] **Guardrails on** in CI from the first commit: lint, static analysis, architecture
      boundaries and secret scanning.
- [ ] **Pipeline green on day 0**, with the surfaces running separately — no undocumented manual
      steps between a clean copy and green.
- [ ] **Slice 0 fulfilled**: the "F6 — Skeleton (slice 0)" block of
      `checklists/definition-of-done.md` confirmed item by item in the starter's README, with
      the evidence for each one.
- [ ] **Structure compatible with the artifact protocol**: the starter does not create, occupy
      or collide with `product/`, `CLAUDE.md`, `STATE.md` or the framework folder — those paths
      belong to the project (`core/artifact-protocol.md` §The project's `product/` tree). The
      code follows the shape foreseen at the end of that tree (apps/, packages/, infra/, … per
      the architecture).
- [ ] **Zero secrets**: no real value in the repository or its history; sensitive configuration
      via documented `*.example` and runtime injection (`playbooks/secrets-management.md`).
- [ ] **Stable versions pinned**: LTS runtime, GA majors, lockfile under version control
      (`knowledge/permanent-rules.md` §6 — Stable versions by default).
- [ ] **A single kickoff command** documented in the starter's README: from clean copy to local
      pipeline green with one command (or a script that chains the steps).
- [ ] **Provenance declared** in the starter's README: the framework version it was validated
      with (`_meta/VERSION.md`), the validation date and the origin project code (P2, P3, … —
      the same anonymity rule as `knowledge/candidates.md`).

## The mirror rule of isolation

Principle 19 of `_meta/STYLE-GUIDE.md` says no document assumes a stack. Starters are the
confined exception — and the isolation cuts both ways:

- **Nothing outside `starters/` may assume a stack.** No core document, agent, workflow,
  checklist or template may depend on a starter existing, reference a concrete starter or treat
  a technology as given. An agnostic document that needs to speak of an accelerated kickoff
  defers to this folder — just as it defers to `adapters/` when the subject is a tool.
- **Nothing in a starter may alter framework contracts.** A starter fulfills the contract above;
  it does not redefine gates, checklists, the artifact protocol or workflows. If fulfilling the
  contract seems to require changing an agnostic document, the coupling escaped its place — the
  starter is what is wrong (the exact mirror of the rule in `adapters/README.md`).

Practical consequence, and audit criterion: deleting all of `starters/` changes not a comma in
the rest of the framework.

## How a starter is born

Never from imagination. A starter **is distilled from a real project** that proved the skeleton —
CI green throughout the build, guards catching real problems — and enters through the same
circuit as all the framework's knowledge:

1. During the build, the project records what its skeleton taught — category `block` of
   `templates/project/FRAMEWORK-IMPROVEMENTS.md.template`.
2. At the close of a milestone, it reports to the upstream framework
   (`playbooks/report-framework-improvements.md`), including the distillation: the skeleton
   extracted from the product, with no domain code, no data and no secrets.
3. `agents/14-meta/framework-curator.md` treats the proposal as a candidate, under the promotion
   rules of `knowledge/candidates.md` §Entry and exit rules. Promotion enters via curation PR
   (`playbooks/framework-curation.md` §Steps) as a **MINOR** in `_meta/VERSION.md` — creating
   `starters/starter-<stack>/` (or the pointer to the sibling repository), the row in this
   folder's table and the entry in `_meta/INVENTORY.md`, all in the same step
   (`core/extensibility.md`).

## How it is maintained — and how it rots in plain sight

Stacks move faster than processes; a stalled starter lies by omission. The same expiry logic as
`knowledge/candidates.md` applies here:

- Each starter **declares the framework version it was validated with** and the date — in its
  README and in this folder's table.
- **Confirmation:** every new project that uses the starter and closes slice 0 green with it
  reports that as an `improvements` issue — confirmation is countable and traceable, never
  subjective.
- **Expiry:** 12 months (or 3 curation rounds) without a new confirmation, or a framework MAJOR
  published after the validation, and the curator marks the starter `needs-revalidation` in this
  folder's table, in the following round. It remains usable — but whoever copies it is warned
  that green day 0 is no longer guaranteed and that slice 0 must be verified in full.
- **Revalidating** = running the kickoff command against the current framework version and
  confirming the contract item by item; the new date and version get recorded.

## How a project uses a starter

The option enters at kickoff (`workflows/W00-project-kickoff.md`) when the stack is already a
hard constraint declared by the user — many projects arrive that way
(`workflows/W00-project-kickoff.md` §Decision points). When the stack is still open, the
decision belongs to F3 and the starter's natural moment becomes the entry to F6, immediately
before slice 0. In either case, the sequence is the same:

1. Copy the starter to the project root **after** copying the framework (`START-HERE.md`
   §Part 1) — and confirm it touched neither the framework folder, `CLAUDE.md`, `STATE.md` nor
   `product/`.
2. Run the single kickoff command documented in the starter's README.
3. Verify slice 0 **green**: pipeline running on the surfaces, guardrails active — item by item
   against `checklists/definition-of-done.md` §F6 — Skeleton (slice 0), never on trust.
4. Record in `STATE.md`: starter used, starter version and validated framework version, and the
   stack choice as a decision to formalize in an ADR (`product/02-architecture/decisions/`).

A project **without** a starter for its stack loses nothing contractual: it builds slice 0 by
hand, as always — and, once the MVP closes, it is the natural candidate to distill the next
starter.

## The starters in this folder

| Starter | Stack | Validated with | Status |
| --- | --- | --- | --- |
| *(none yet)* | — | — | — |

Honest status: **no `starter-<stack>` exists yet**. The first natural candidate is the
distillation of a real product from the ecosystem — the "runnable starter" candidate recorded in
`knowledge/candidates.md` (type `block`, P2, partially promoted: this contract; the "guards at
the door" part already went up as slice 0). This contract exists first on purpose: when that
distillation arrives, it enters made to measure — instead of inventing the form at the same time
as the content.

## Related

- `adapters/README.md` — the isolation pattern this folder replicates, from tools to stacks.
- `checklists/definition-of-done.md` — the F6 — Skeleton (slice 0) block, the outcome the
  contract guarantees.
- `workflows/W00-project-kickoff.md` — the kickoff where the option to use a starter enters.
- `workflows/W06-build.md` — the phase whose slice 0 the starter pre-pays.
- `playbooks/framework-curation.md` — the single door for starter entry and maintenance.
- `knowledge/candidates.md` — the waiting room where the first starter's implementation awaits
  distillation.
- `knowledge/permanent-rules.md` — secrets out of version control and stable versions.
- `core/artifact-protocol.md` — the project tree every starter is compatible with.
