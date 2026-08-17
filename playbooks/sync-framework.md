# Syncing the framework in an existing project

A project copies Maestro once, at kickoff (`workflows/W00-project-kickoff.md`); the upstream
framework keeps evolving in its own repository, by SemVer (`_meta/VERSION.md`). This playbook
brings a project up to a newer version — **deliberately, never automatically**. The project's
Orchestrator (`core/orchestrator.md`) runs it, with the user approving the version jump. A single
rule makes syncing safe: **a project's framework copy is read-only** — local extensions live in
project files (outside `Maestro/`) or get promoted upstream (`knowledge/README.md` §How knowledge
circulates); the copy is never edited.

## Preconditions

- The project's `STATE.md` records the copied framework version (mandatory since
  `START-HERE.md` §2.2). If it does not, find it out first (the copy's `Maestro/_meta/VERSION.md`)
  and record it — do not sync without knowing where you start from.
- Clean project working tree (no uncommitted changes) — the sync must be an isolated commit,
  revertible in one go.
- Access to the upstream framework's **target release** (the ZIP published per tag — the canonical
  distribution source, already sanitized by the upstream `_meta/DO-NOT-DISTRIBUTE` list) and to the
  changelog (`_meta/VERSION.md`).

## Steps

1. **Read the upstream changelog** between the project's version and the target version
   (`_meta/VERSION.md`). Classify the jump: PATCH/MINOR follow this playbook; **MAJOR requires
   reading the breaking-change notes and assessing impact before continuing** — if the contract
   between agents changed (artifact protocol, lifecycle, agent template), list what changes for
   THIS project and get the user's OK.
2. **Check that the copy was not edited locally**: `diff -rq` between the project's copy and the
   upstream version the project claims to have. If there are differences → **stop**. For each
   difference, decide with the user: promote upstream (it is a general improvement — record it in
   `FRAMEWORK-IMPROVEMENTS.md` and submit it via `playbooks/report-framework-improvements.md`;
   incorporation follows curation and `core/extensibility.md`) or discard (it was an improper
   edit — but the friction that motivated it almost always deserves an entry in the same report: a
   local edit is the strongest signal that the framework got in the way). Only continue with the
   copy reconciled.
3. **Replace the copy** with the contents of the target release's ZIP (full copy with removal of
   what no longer exists — e.g. extract to a temporary folder and `rsync -a --delete`). It is safe
   because, by the rule above, nothing project-specific lives inside `Maestro/`.
4. **Run the self-check** of the installed version: `Maestro/_meta/verify.sh`. It must come out
   green; if it fails, the copy got corrupted — revert (see Rollback) and start over.
5. **Assess impact on the project's artifacts**: old template instances are **not touched** (they
   were valid when written); new gates/checklists apply to **future** work; new agents become
   available without ceremony. There is only work to do if the changelog says so explicitly (e.g.
   a MAJOR that renames artifacts).
6. **Record in `STATE.md`**: new framework version, date, jump (from → to), and any decision made
   in steps 1–2.
7. **Isolated commit** ("sync Maestro X.Y.Z → A.B.C"), proposed to the user.

**Continuous drift detection:** between syncs, any session can run
`bash Maestro/_meta/verify.sh --integridade` — it compares the copy against the origin release's
`_meta/SHA256SUMS` manifest and flags local edits on the spot, instead of letting them pile up
until step 2 of the next sync.

## Distribution alternatives (teams with mature Git)

Copying from a release ZIP is the **default** (simple, sanitized by the `_meta/DO-NOT-DISTRIBUTE`
list, requiring no Git from whoever is starting out). Two alternatives, with honest trade-offs:

- **Submodule pinned to a tag** — Git-native hash integrity and explicit updates
  (`git submodule update`); in exchange, the well-known operational friction of submodules and
  **no sanitization** (it points at the full upstream repository — acceptable only when the whole
  team may see upstream).
- **Subtree** — single history and updates by merge; simpler day-to-day than the submodule, but it
  mixes the framework's history with the project's and is also **not sanitized**.

Either alternative keeps the usual rules: read-only copy, deliberate version jump, record in
`STATE.md`.

## Rollback

The step 7 commit is the unit of rollback: `git revert` (or restoring the previous version's
folder from history) returns the project to the exact pre-sync state. No project artifact was
touched by steps 1–4, so the rollback has no side effects.

## Related

- `_meta/VERSION.md` — the framework's SemVer and changelog.
- `workflows/W00-project-kickoff.md` — where the initial copy happens and the version is recorded.
- `core/extensibility.md` — how to extend the framework without editing what exists.
- `knowledge/README.md` — the circuit that promotes project lessons upstream.
- `playbooks/add-an-agent.md` — the right path when the "local edit" was a new agent.
- `playbooks/report-framework-improvements.md` — the destination of local edits that were
  improvements.
- `checklists/pre-merge.md` — applies to the sync commit like any other.
