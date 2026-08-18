# Framework Version

**Current version: 1.0.3** (2026-08-17)

The framework is versioned with [SemVer](https://semver.org/) applied to executable documentation:

- **MAJOR** — changes that break the contract between agents (artifact protocol, lifecycle, agent
  template). Existing projects need a conscious migration.
- **MINOR** — new agents, workflows, loops, modules, templates or playbooks (additive extension —
  see `core/extensibility.md`).
- **PATCH** — fixes and clarifications that do not change behavior.

Every project that copies the framework records **which version it copied** in its `STATE.md`. The
framework evolves in this repository through pull requests and curation
(`playbooks/framework-curation.md`); projects re-synchronize deliberately from release ZIPs —
never automatically.

## Changelog

### 1.0.3 — 2026-08-17

Everything an 8-dimension multi-agent audit found, each finding independently reproduced before
being fixed. The audit is the first real exercise of this edition's own adversarial-audit
playbook, run against the framework itself.

**Gates that did not work (the worst class — a gate that passes while broken is worse than none):**

- `_meta/verify-project.sh` matched the Portuguese labels `versão da framework` and
  `framework-mãe` in `STATE.md`. A project filling in the English template correctly
  (`**Framework version**`, `**Upstream framework repository**`) failed the gate with exit 1 and
  a false warning. Both checks are now bilingual, like the phase check already was.
- `_meta/verify.sh` check 9 validated references to `COMECAR-AQUI.md`, a file that does not exist
  in this edition, and never checked `START-HERE.md`, which 15 files cite — a broken
  `START-HERE.md` reference passed silently. Verified by injecting one.
- The release workflow gated the full checkout, never the artifact it publishes. It now extracts
  the built ZIP, asserts no `DO-NOT-DISTRIBUTE` entry leaked into it, and runs both `verify.sh`
  and `--integrity` inside the extracted copy before publishing. This is the check that would
  have caught 1.0.2's bug at build time instead of after release.
- The manifest builder compared `DO-NOT-DISTRIBUTE` entries as exact strings while the ZIP
  builder treated them as globs; a future pattern entry would have been excluded from the ZIP yet
  hashed into the manifest, breaking `--integrity` in every copy. Both use glob matching now.
- `--integridade` is now `--integrity` (the old spelling still works), and an unknown flag is an
  error instead of silently running the wrong check.

**Contracts that pointed nowhere:**

- 29 citations across 17 reviewer/guardian specs sent accepted technical debt to
  `STATE.md §Debt` — a section that did not exist. It exists now (`## 8. Debt`, with owner and
  payment trigger), documented in `core/project-memory.md`. This is what stops reviewers from
  re-flagging debt already accepted, cycle after cycle.
- 11 citations pointed at `STATE.md §Closed decisions`/`§Decisions`; closed decisions live in
  `CLAUDE.md §7`. Redirected.
- `core/artifact-protocol.md` had two independent lists numbered 1–5 (`Principles` and
  `Handling rules`), so `§4` meant different things to different documents — and four citations
  did resolve to the wrong rule. Handling rules are now `H1`–`H5`; the four citations were
  repointed.
- `playbooks/report-framework-improvements.md` wrote to `§Submission log`; the template's section
  is `Report log`. Also unified the entry marker on `(sent #nnn)`.

**Translation defects:**

- A `rede`→`network` replacement had run without word boundaries, corrupting English words
  containing that substring: `credentials`→`cnetworkntials` (59 occurrences, concentrated in
  authentication, secrets and DevOps specs, where the term matters most), plus `redeploy`,
  `redefine`, `redesign`, `redeliver`, `redeemed` and `.azuredevops/`. All restored.
- Portuguese identifiers survived in example blocks (event names, API paths, metric labels,
  a feature-flag key) — translated, with a repo-wide sweep for the same class.
- `agents/00-discovery/` used `Default` as a model tier; the canonical tiers are
  Top/Standard/Economy/Mechanical (`Default = Standard` is a routing rule, not a tier name).
- The `Type` field is now the template's canonical form (lowercase, in backticks) across all 152
  specs, instead of five competing spellings.

**Confidentiality:**

- `.mapa-pt-en.json` carried workflow metadata quoting an absolute local path that named the
  private upstream repository. The file now contains only the translation map itself.
- `knowledge/origin-lessons.md` named concrete domain features of the origin project in the very
  section that promises its domain stays out. Generalized.

### 1.0.2 — 2026-08-17

- Fix: `_meta/DO-NOT-DISTRIBUTE` listed itself as excluded from the release ZIP. Since the
  inventory and `playbooks/sync-framework.md` both cite this file as present in every copy, the
  self-exclusion made `_meta/verify.sh` fail with 2 errors in every distributed copy, right after
  extraction — before a project even started. The file carries only filenames, nothing
  confidential, so it now ships; the actual secrets (the PT↔EN translation memory) stay excluded.
  Verified by rebuilding the release ZIP locally and running the gate inside the extracted copy.
- Also created the missing `improvements` GitHub label — the issue template and the curation
  playbook both depend on it, but it had never been created on the repository, so every field
  report opened through the template would have landed unlabeled and invisible to the curation
  queue.

### 1.0.1 — 2026-08-17

- Fix: `_meta/verify-project.sh` check 1 still looked for a `produto/` directory at the project
  root (a leftover from the upstream edition); it now checks `product/`, matching the canonical
  tree. Without this fix the project gate failed every project of this edition at check 1.

### 1.0.0 — 2026-08-17

- First public English edition, derived from the private upstream framework (Maestro 2.6.0, PT),
  where it was distilled from real products built from scratch and hardened by a 14-agent
  adversarial audit (43 recommendations implemented). Fully English: structure, paths, tooling
  and prose — verified by `_meta/verify.sh` and a repository-wide residue sweep.
- The ecosystem state starts fresh in this edition: the candidates ledger
  (`knowledge/candidates.md`) and the learning curve (`knowledge/learning-curve.md`) are empty —
  they will be filled by the first products built with this edition and by community field
  reports (`CONTRIBUTING.md`).
