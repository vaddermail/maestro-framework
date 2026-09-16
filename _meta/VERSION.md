# Framework Version

**Current version: 1.4.0** (2026-09-16)

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

### 1.4.0 — 2026-09-16

Synced from upstream 2.13.0. **The genesis measures the projects that were not born with it — and
the ones that no longer close phases.** The owner asked whether a project already under way should
have the genesis dossier; the critical answer was yes, and the gap was bigger than the question: the
sync playbook — the path projects under way actually take — never instantiated it, so three of four
projects synced upstream that day were left without it and with the gate warning forever; a product
in F9 never closes a phase again, so the genesis as designed would stay empty forever in a mature or
adopted-in-production product; and the template claimed the phase row was part of the definition of
done, which never mentioned it.

- **Instantiated mid-project, without inventing:** `templates/project/GENESIS.md.template` gains
  «Measured since:»; phases closed before it are marked «not measured — before instantiation» and the
  gate does not count them. `playbooks/sync-framework.md` step 6b gains sub-step (iv); the W00
  adoption says the same. Improvements were already collected retroactively by
  `FRAMEWORK-IMPROVEMENTS.md`; what was missing was the quantitative instrument.
- **In F9 the unit is the evolution:** §Evolutions in the genesis — one line per closed `EV-nnn`,
  demanded by the exit gate of `workflows/W10-feature-evolution.md` and by the definition of done
  §F9. `knowledge/learning-curve.md` gains the curve per evolution: in a mature product «each
  evolution cheaper and better than the previous one» is the promise that exists; in one adopted in
  production, it is the only one.
- **The gate** (`_meta/verify-project.sh` check 6) tells measured from «not measured», warns in F9
  when EV-nnn are recorded without a line, says NOT VERIFIED while no evolution has closed, and does
  not demand phases before the adoption. Cases 16a–16d, failing before the implementation.
- Complements to AR-25, AR-26 and AR-27 from the last triage of the origin ecosystem: the positive
  control proves the class, not the case; text-based command guards tokenize with the real parser;
  double quotes also betray through `$`; the shell's working directory can drift back to the main
  tree between harness calls.

**Impact on projects** (sync playbook, step 6b): `product/99-records/genesis.md` — instantiate if
missing, with «Measured since:» and earlier phases «not measured»; in those that exist, add
§Evolutions. In F9, the next evolution to close writes the first row.

### 1.3.0 — 2026-09-16

Synced from upstream 2.11.0 and 2.12.0 in one step. The upstream theme: **real use teaches the
framework**. Until then upstream learned only from what projects remembered to report — two issues
in two months. 2.11.0 came from a survey run directly on five real projects (their improvement
files, lessons sections, the `CLAUDE.md` rules each had to add by hand, the Git history — and the
framework's own gates run against each project); 2.12.0 promoted nineteen of the resulting
candidates with a single confirmation, under the rule that already allowed it for the obviously
general. What travelled back down, in this edition's terms:

- **The gate nobody ran.** In three projects `verify-project.sh` was installed and never run; one
  sat from F6 to F8 with the gate red. It is now stage 8 of `pipelines/ci-quality.md`, step 10 and a
  P0 criterion in W00, an item in the `CLAUDE.md.template` done summary — and its warnings, which
  block nothing and so were read by no one, are injected by the session-start hook (up to six).
- **A CRLF guard** in the seven scripts: a copy with Windows line endings died on
  `set: pipefail: invalid option name`, and that is how one adopter stopped running the gate. They
  now stop with exit 2 and say how to restore. Case 12 exercises all seven.
- **Adopting in a product that already exists** (`workflows/W00-project-kickoff.md`): inventory
  before calibration (step 6b, the existing-system analyst in adoption mode), an `Adoption` field in
  the `STATE.md` template, and a gate that stops demanding traces and records of phases the product
  never went through — while demanding `product/00-discovery/existing-system.md` instead. Test
  strategist in existing-system mode. Cases 13a–13h, on both sides of every boundary; a 13-mutation
  matrix against the gate script is fully killed.
- **Living memory with a ceiling** and **pending decisions with an age**: compaction trigger and
  procedure in `core/project-memory.md` §Memory hygiene; `core/question-engine.md` §Pending
  decisions: age and expiry («opened on» per item, a decision at 30 days, batch triage above 15);
  the gate warns above 60 KB, 3 000 characters on a line, 30 days, 15 open, and on items without a
  date. Cases 14a–14b and 15a–15b.
- **AR-25 to AR-28:** an instrument never proven to catch what it looks for (live proof gains a
  sixth field, «Control»; a gate only counts once proven to fail); the shell lies to the agent;
  concurrent sessions in the same repository (`core/orchestrator.md` §Parallelism); a loading state
  that masks the reproduction.
- **Production configuration: fail-closed and exercised, not only written** (proven patterns §12),
  applied in go-live, pre-merge, pre-production security and CD; real concurrent actors before
  go-live; rate limits keyed by identity; one DB per purpose.
- **New module `modules/multi-repository-product.md`** — the largest capability gap the survey
  found: the framework assumed one product = one repository. Truth in files in the repository that
  owns the subject area, conversation as typed items with a closing criterion, mesh not star,
  whoever closes a blocker tells whoever is waiting.
- **Everything else the 2.12.0 promotions brought:** long near-idle runs across the product's time
  boundaries; warm-up before health checks and the health script's betrayals; runbook derived from
  the diff; the restore drill proves its target first; the system prompt is intent, not a contract;
  forwarded headers trusted only when the proxy writes them; a public identifier never becomes the
  internal scope id without explicit resolution; FK column types read in the oldest environment;
  visibility asserted from what renders; local reproducible gate with hosted CI as a second opinion;
  «cancelled» as a third CI outcome; executable RF/BR-to-test traceability; the CI green measured
  this content; multi-major upgrades one step at a time; one fact in one place.
- **Corrections:** `generate-contracts.sh` copied only the first line of each item — about two
  thirds of Rules, Limitations and Done criteria reached the Orchestrator cut mid-sentence with check
  19 green (contracts are ≈40 % of a spec, not 35); `actions/checkout` v4 → v7.0.1 in both workflows.

**Impact on projects** (sync playbook, step 6b): `STATE.md` gains the `Adoption` field in the
situation header and «opened on yyyy-mm-dd» on each pending decision; `CLAUDE.md` gains the
«Coding standards» line and the `verify-project.sh` item in the done summary; the project CI gains
the project-gate stage.

### 1.2.1 — 2026-09-16

**The generality test moves to the source.** Maestro serves any kind of product, yet only the
curator filtered out what belonged to a single product — after the report had been written,
sanitized, sent and triaged. The project side checked privacy and never asked whether a lesson
would help anyone else. This is a change to the framework's own circuit, requested by the owner,
not a lesson from a project: it does not go through the candidates. PATCH — it makes an existing
rule ("product lessons stay in `STATE.md` §Lessons", `knowledge/README.md`) applicable where
entries are written; no contract between agents changes. Born in this edition and **going back
upstream**.

- **New `knowledge/README.md` §The generality test:** two questions (another domain, another
  stack), a routing table for what fails — moved, never deleted — and a worked rewrite from
  incident to general form.
- **Applied at both ends of the circuit.** `templates/project/FRAMEWORK-IMPROVEMENTS.md.template`
  carries it at capture time; `playbooks/report-framework-improvements.md` step 1 applies it at
  consolidation and step 3 puts the counts in the issue body; `playbooks/framework-curation.md`
  step 4 makes a domain-specific verdict name the question that failed, so the reporting project
  calibrates its next filter.
- **Outside contributors see it too:** `CONTRIBUTING.md` and the field-report issue template.

**Impact on projects** (`playbooks/sync-framework.md` step 6b): `FRAMEWORK-IMPROVEMENTS.md` gains
the "Generality" note under the sanitization note. No other live file changes.

### 1.2.0 — 2026-09-15

Synced from upstream 2.10.0, whose theme was **executable and verifiable**: the adapter stops
promising what it never shipped, and the gates stop printing green over things they never
evaluated. 170 documents translated, 15 contract indexes generated, and the whole
`adapters/claude-code/` package ported. Traffic went both ways again: one fix travelled
**mirror → upstream** before this sync (the unknown-flag guard), and one defect found *here*
goes back up (see the last bullet).

- **The Claude Code adapter now ships an executable scaffold.** `adapters/claude-code/` brings
  `generate-scaffold.sh` (derives `.claude/agents/maestro-*` from the specs, with the model tier
  and tools per spec, plus a lock file and `--check` for drift), three hooks (`SessionStart`,
  `PreToolUse`, `Stop`), the `settings.json` template and five skills. Until now the adapter
  described a scaffold nobody could run. `test-hooks.sh` exercises all of it in 38 cases, in CI
  and from inside the release ZIP.
- **Check 8 stops approving anchors that do not exist.** The match is now anchored at the START
  of the heading (optional numbering stripped): the previous version degraded into "the first
  word is a substring of any heading" and approved `§Gate P99` against "Anatomy of a gate". A
  second, strict pass resolves anchors to the project's live files (`STATE.md`, `CLAUDE.md`,
  `FRAMEWORK-IMPROVEMENTS.md`) against the matching template. Seven orphan anchors were found
  and fixed by it here.
- **Checks 16–19: loops, modules, workflows and derived contracts.** The mandatory skeletons the
  folder READMEs have declared since 1.0 were never verified — a loop without an
  anti-infinite-loop safeguard is the one addition that can set an agent iterating without a
  ceiling. Four loops were carrying a `## STATE.md ledger` heading their own README calls
  `## STATE.md record`. Check 19 keeps `agents/NN-category/CONTRACTS.md` — the short index the
  Orchestrator reads instead of loading whole specs — in step with the specs.
- **The forbidden-terms sweep is case-insensitive and reads file names too.** The
  case-sensitive version let 15 occurrences of one term travel upstream. It also stops printing
  the term itself: CI logs get read as well. `release.yml` repeats it inside the extracted ZIP.
- **Stable pitfall IDs.** `knowledge/ai-pitfalls.md` items are `AR-1`…`AR-24` and cited as
  `§AR-n`. Citing a pitfall by position broke silently every time one was inserted; check 8
  now rejects a numeric citation to that file outright. 24 citations were converted.
- **`--integrity` detects extra files, and says so when it cannot check.** `sha256sum -c` only
  looks at what is listed, so a file *added* to a copy passed as "identical". It now also
  falls back to `shasum` and exits 2 — NOT VERIFIABLE — when neither is on PATH: a red light
  about something nobody looked at is as dishonest as a green one. A new `.gitattributes`
  (`* -text`) stops Git line-ending conversion from failing every file on Windows.
- **The project gate gained gate records, spec-before-code and Q&A.** `verify-project.sh` now
  checks that every closed gate left its record in `product/99-records/gates/`, that
  `product/04-specification/` has an approved artifact before F6, that the question history
  exists, and that provisional assumptions are confirmed. Future dates (a deadline, a roadmap)
  no longer count as a memory update. `test-project-gate.sh` grew to 12 exercised cases.
- **New: `_meta/generate-contracts.sh`, `_meta/scan-report.sh`.** The first derives the 15
  `CONTRACTS.md`; the second is the mechanical secrets/PII/forbidden-terms sweep required
  before publishing any report upstream.
- **New documents:** `workflows/W13-decommissioning.md`,
  `playbooks/legacy-system-migration.md`, `playbooks/change-effort-profile.md`,
  `agents/00-discovery/existing-system-analyst.md`,
  `agents/05-backend/product-analytics-specialist.md` (154 specialists),
  `templates/project/GATE.md.template`, `templates/project/FORBIDDEN-TERMS.template`,
  `templates/technical/agent-briefing.md.template`.
- **Found here, going back upstream (PATCH):** check 8's anchor trimming cut at *any* hyphen,
  so the English `§Non-negotiable business rules` was truncated to `§Non` and reported orphan.
  Portuguese headings carry no hyphens, so upstream never saw it. The fix — require a space
  before the dash — is in this edition's `_meta/verify.sh` and belongs upstream too. Upstream
  also documents `test-hooks.sh` as 37 cases; both suites run 38.

### 1.1.0 — 2026-08-19

Synced from upstream 2.9.0, whose theme was closing the gates that printed green over things
they had never evaluated. The traffic went both ways this time: the unknown-flag fix travelled
**mirror → upstream** (it was 1.0.3's), and everything below travelled back down.

- **The project gate is now exercised, not merely shipped.** New `_meta/test-project-gate.sh`
  builds four synthetic projects — compliant, deviant, unreadable phase, unfilled genesis — and
  demands the gate approve the first and fail the others *for the right reason*. It runs on every
  PR and, in `release.yml`, **from inside the extracted ZIP**. Until now CI only ran the framework
  gate: the gate that projects actually run had never been exercised before reaching them.
- **`_meta/verify-project.sh` stops printing green over what it did not look at.** An unreadable
  phase silently fell back to F0, so the gate reported "closed-phase artifacts left a trace" over
  an empty `product/` — it now says **NOT VERIFIED**, which is the truth. The genesis dossier
  counted the template's own `{{...}}` example rows as measured phases, meaning the instrument
  that measures the framework's promise went green over placeholders. `verifica_fase` also now
  covers `product/06-tests` (a hard precondition of W06) and `product/07-operations`.
- **Check 14 — forbidden-terms sweep.** Reads `_meta/FORBIDDEN-TERMS` (shipped empty, on purpose:
  the terms are yours) and fails if any listed name appears in a distributable file. `release.yml`
  repeats the sweep **inside the extracted ZIP**, the last point where a real name can still be
  stopped. Provenance is meant to travel by project codename (`knowledge/candidates.md`, rule 5);
  that rule had no gate, and upstream found changelog lines resolving the codename↔project map in
  full, already shipped into two copies. A rule without a gate is a wish.
- **Check 15 — internal `§` citations by name, never by number.** 1.0.3 inserted `## 8. Debt` into
  the STATE template and pushed the historical log to `## 9`, but the hygiene note kept sending
  old sessions to "§8" — straight into technical debt. Seven self-referential `§N` citations
  across the project templates are now `§Section name`, immune to renumbering, and the check
  prevents the relapse.
- **Checks 1 and 3 now know about `_meta/DO-NOT-DISTRIBUTE`.** A file that is legitimately cited
  and legitimately absent from a copy is no longer a broken reference — which is what adding
  `FORBIDDEN-TERMS` to the inventory would otherwise have caused. The `SHA256SUMS` exception,
  previously hardcoded for the same reason, is now just a case of the general rule.

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
