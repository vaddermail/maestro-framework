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
  `START-HERE.md` §2.2). If it does not, find it out first (the `Current version` line of the
  copy's `Maestro/_meta/VERSION.md`) and record it — do not sync without knowing where you start
  from. The upstream repository is in `STATE.md` §Situation header or in `Maestro/_meta/ORIGIN`
  (release copies carry it).
- Clean project working tree (no uncommitted changes) — the sync must be an isolated commit,
  revertible in one go.
- Access to the upstream framework's **target release** (the ZIP published per tag — the canonical
  distribution source, already sanitized by the upstream `_meta/DO-NOT-DISTRIBUTE` list, with the
  SHA-256 in the notes).

## Steps

1. **Get the target release into a temporary folder.** With `gh`:
   `gh release download vA.B.C -R <org/repo> -p 'Maestro-*.zip' -D /tmp/maestro-sync` (without
   `gh`, download the file from the releases page). Verify the SHA-256 against the one published
   in the release notes (`sha256sum /tmp/maestro-sync/Maestro-vA.B.C.zip`). The ZIP **has no
   top-level folder**: `unzip -q /tmp/maestro-sync/Maestro-vA.B.C.zip -d /tmp/maestro-sync/Maestro`.
   Verify with `grep 'Current version' /tmp/maestro-sync/Maestro/_meta/VERSION.md`.
2. **Read the changelog** in `/tmp/maestro-sync/Maestro/_meta/VERSION.md`, between the project's
   version and the target. Classify the jump: PATCH/MINOR follow this playbook; **MAJOR requires
   reading the breaking-change notes and assessing impact before continuing** — if the contract
   between agents changed (artifact protocol, lifecycle, agent template), list what changes for
   THIS project and get the user's OK. Also read the **Project impact** lines of the entries
   spanned (step 6b).
3. **Check that the copy was not edited locally**: `bash Maestro/_meta/verify.sh --integridade`
   (compares the copy against the origin release's `_meta/SHA256SUMS` manifest; needs `sha256sum`
   or `shasum` — without them it says NOT VERIFIABLE and exits with 2). Only on a copy older than
   2.5.0, with no manifest, use `diff -rq` against the old release. If it diverges → **stop**. For
   each difference, decide with the user: promote upstream (it is a general improvement — record it
   in `FRAMEWORK-IMPROVEMENTS.md` and submit it via `playbooks/report-framework-improvements.md`;
   incorporation follows curation and `core/extensibility.md`) or discard (it was an improper
   edit — but the friction that motivated it almost always deserves an entry in the same report: a
   local edit is the strongest signal that the framework got in the way). Only continue with the
   copy reconciled. If *all* files fail on a Windows machine, it is Git's CRLF conversion, not an
   edit: the **user** restores it with `git checkout -- Maestro/` (the agent does not run
   `git checkout --`: it is on the adapter's denylist, and that is how it should be).
4. **Replace the copy**: `rsync -a --delete /tmp/maestro-sync/Maestro/ Maestro/`. It is safe
   because, by the rule above, nothing project-specific lives inside `Maestro/`. In Claude Code,
   the `permissions.deny` on `Maestro/**` covers edits, not this `rsync`; `rm -rf` is denied to the
   agent by design — without `rsync`, it is the user who deletes the folder before the `cp -r`.
5. **Run the self-check** of the installed version: `bash Maestro/_meta/verify.sh` and
   `bash Maestro/_meta/verify.sh --integridade`. Both must come out green; if they fail, the copy
   got corrupted — revert (see Rollback) and start over.
6. **Assess impact on the project**, in two parts:
   - **6a — product artifacts** (`product/**` instantiated from `templates/discovery`,
     `templates/specification`, `templates/technical`): **not touched** — they were valid when
     written; new gates/checklists apply to **future** work; new agents become available without
     ceremony. Only a MAJOR that renames artifacts requires work here.
   - **6b — living files** (`STATE.md`, `CLAUDE.md`, `FRAMEWORK-IMPROVEMENTS.md`,
     `product/99-records/genesis.md`), in three sub-steps: **(i) sections** — compare the `## `
     titles of the new template in `Maestro/templates/project/` against the instantiated file **by
     name, ignoring numbering** (numbering changes between versions; "Report log" is the same
     section whether it is §7 or §8); every missing section gets added at the template's
     position — empty, except `CLAUDE.md` §F0 calibration, which gets filled from the `STATE.md`
     profile and the cadence table — with the line *(section added in the X → Y sync)*; **(ii)
     fields** — the **Project impact** line of each changelog entry spanned lists new fields inside
     existing sections (e.g. "AI cost" in the §Done blocks), which the title comparison does not
     see; **(iii) errata** — the only exception to "never rewritten": text in an existing section
     that contradicts a permanent rule gets rewritten (2.10.0: `CLAUDE.md` §How to work, steps 5–6,
     "Commit + push" → "Propose the commit"); **(iv) genesis** — if `product/99-records/genesis.md`
     does not exist (projects predating 2.6.0, or adopted without it), instantiate it from the
     template with «Measured since:» set to this sync's date; phases already closed get marked «not
     measured — before instantiation», never reconstructed, and in F9 the next line is the next
     evolution's (§Evolutions). A project that skips this step ends up with 17 agent
     specs (24 files) writing to a `STATE.md` §Debt it does not have; `_meta/verify-project.sh`
     warns. Jumps with known impact on living files:

     | Version | Living file | Section to add |
     | --- | --- | --- |
     | 2.5.0 | `FRAMEWORK-IMPROVEMENTS.md` | §Candidate confirmation |
     | 2.8.0 | `STATE.md` | §Debt |
     | 2.10.0 | `CLAUDE.md` | §F0 calibration (i); the `@Maestro/knowledge/permanent-rules.md` import (ii); §How to work steps 5–6 rewritten (iii — errata: they contradicted permanent rule 8) |
     | 2.10.0 | `STATE.md` | "AI cost" field in §Done blocks; ledger lines in §In progress |
     | 2.10.0 | `FRAMEWORK-IMPROVEMENTS.md` | §Framework usage this phase (i) |
     | 2.10.0 | project root | `FORBIDDEN-TERMS` (from `templates/project/FORBIDDEN-TERMS.template`) |
     | 1.4.0 | `product/99-records/genesis.md` | instantiate if missing, with «Measured since» (iv); in those that exist, §Evolutions (i) |

     As of 2.10.0, every `_meta/VERSION.md` entry that changes a `templates/project/*.template`
     ends with a **Project impact** line — the table above does not grow by hand.
7. **Record the version in the three living files that carry it**: `STATE.md` §Situation header
   (new version, date, jump from → to, decisions from steps 2–3), `CLAUDE.md` §The framework
   (Maestro), and the header of `FRAMEWORK-IMPROVEMENTS.md` (the "Framework version copied" field)
   — these are three copies of the same fact; if they diverge, the one in
   `Maestro/_meta/VERSION.md` is authoritative and `_meta/verify-project.sh` warns.
8. **Regenerate the tool's scaffold**, when the adapter provides for it (Claude Code:
   `bash Maestro/adapters/claude-code/generate-scaffold.sh`; when a scaffold already existed, the
   `git diff` of `.claude/agents/` is the exact list of specs that changed —
   `adapters/claude-code.md` §Executable scaffold).
9. **Isolated commit** ("sync Maestro X.Y.Z → A.B.C"), proposed to the user — it includes the copy,
   the living files, and the scaffold.

**Continuous drift detection:** between syncs, any session can run
`bash Maestro/_meta/verify.sh --integridade` — it compares the copy against the origin release's
`_meta/SHA256SUMS` manifest and flags local edits on the spot, instead of letting them pile up
until step 3 of the next sync. In Claude Code, the session-start hook does this every session, and
`permissions.deny` prevents the edit before it happens. `_meta/verify-project.sh` also warns when
upstream has published a release newer than the copy (check 8) — "deliberate" cannot degenerate
into "never". Reading upstream is not syncing: nothing you look at there enters `Maestro/`.

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

The step 9 commit is the unit of rollback: `git revert` (or restoring the previous version's
folder from history) returns the project to the exact pre-sync state. No product artifact was
touched by steps 1–5 (only the copy, the living files, and the scaffold, all in the same commit),
so the rollback has no side effects.

## Related

- `_meta/VERSION.md` — the framework's SemVer and changelog.
- `workflows/W00-project-kickoff.md` — where the initial copy happens and the version is recorded.
- `core/extensibility.md` — how to extend the framework without editing what exists.
- `knowledge/README.md` — the circuit that promotes project lessons upstream.
- `playbooks/add-an-agent.md` — the right path when the "local edit" was a new agent.
- `playbooks/report-framework-improvements.md` — the destination of local edits that were
  improvements.
- `checklists/pre-merge.md` — applies to the sync commit like any other.
- `adapters/claude-code.md` — the scaffold that gets regenerated in step 8.
