# Framework curation

The upstream framework's side of the learning circuit: turning the queue of `improvements` issues
into curated evolution — candidates, promotions via PR and verdicts — without ever leaving a
report unanswered. It is executed by `agents/14-meta/framework-curator.md` **in the upstream
repository**, with the framework owner as sole approver. The cadence lives here, not in the
projects: projects report when they close milestones; the upstream curates when the triggers
below fire.

## Preconditions

- **Cadence trigger** (any one; whichever comes first): ≥3 open issues with the
  `improvements` label · a project closed F6 (P6b), F7 or F8 and reported · 3 months since the
  date in `knowledge/candidates.md`, top table · owner's request.
- Clean, up-to-date clone of the upstream repository (`git status` clean, `main` current); `gh`
  authenticated with access to the repository.
- `_meta/verify.sh` green **before starting** — no curating on top of an inconsistent framework.
- `knowledge/candidates.md` read, including the declined ones (never reopen without material news).

## Steps

1. **Collect the queue and triage:** `gh issue list --label improvements --state open`. Read all of
   them before judging any one — the strongest signal is repetition across projects, and it only
   shows in the whole set. **Entry triage** when the queue exceeds the batch: security/data/gates
   first, then by age. **Maximum batch: 10 issues per round** — the rest get the comment
   "scheduled for the next round" (with expected date) and **no issue goes 2 rounds without an
   outcome**.
2. **Validate on entry,** issue by issue: format (what + why + evidence + suggested destination)
   and sanitization — **re-run the mechanical scan** for secrets/PII over the issue body (the
   second independent gate of the circuit's only irreversible step; the first ran in the
   project, `playbooks/report-framework-improvements.md` step 2). Incomplete → comment asking for
   the fields and skip it this round. With sensitive data → ask for a sanitized resend, edit/delete
   the exposed content, skip.
3. **Deduplicate and group** by theme: across the round's issues, against `knowledge/candidates.md`
   and against knowledge already promoted (`knowledge/`, modules, checklists, templates). Note
   per item: new · reinforcement of a candidate (the confirmations/refutations by `C-nnn` ID from
   the reports' confirmation section add directly to the right candidate) · cross-validation of
   existing knowledge · repeat of a
   declined one.
4. **Classify each item** on a curation branch (`git checkout -b curation/YYYY-MM`):
   - **Duplicate/cross-validation** → add the confirmation (on the candidate, or an "also
     confirmed in {…}" note in the promoted file). With no new content, it is a PATCH.
   - **Domain-specific** → written verdict on the issue; record as declined in candidates.
   - **New, 1 project** → entry in candidates (`awaiting-confirmation`, count 1, link to the issue).
   - **Confirmed (≥2 projects)** → promote in step 5. "Obviously general with 1" exception: only
     with an explicit question to the owner, never on own initiative
     (`agents/14-meta/framework-curator.md`
     §Rules).
5. **Draft the promotions,** by addition (`core/extensibility.md`): the content in the right
   destination, generalized but with evidence and provenance **by project code** (P2, P3, … +
   issue — never the name or the stack, because candidates and notes travel in the copies:
   `knowledge/candidates.md` §Entry and exit rules); changelog entry and proposed version
   bump in `_meta/VERSION.md` (MINOR for new content, PATCH for clarifications;
   anything that changes contracts stops immediately → MAJOR question to the owner). Update
   `knowledge/candidates.md` (promoted/new/declined rows + round header;
   **re-evaluate the expired candidates** per rule 6 — it runs even when the round fired on
   another trigger — and **move to §Archive** the promoted/declined ones older than 2 rounds).
   Also check the validity of the layers→models table in `adapters/claude-code.md` (stamp
   older than 3 months → the round includes its update as a PATCH). If any report in the round is
   an **F8 closure** with a genesis block, add the product's row (by P-n code) to
   `knowledge/learning-curve.md` and write the reading in the PR. Run
   `_meta/verify.sh` — green mandatory.
6. **Open the PR** (never a direct commit to `main`): summary table *item → origin → destination →
   classification*, a **"Round metrics"** block (issues processed/deferred, median
   issue→verdict time, active candidates and average age, promotions/declines/dormant — the
   cumulatives are updated in the `knowledge/candidates.md` header), pending questions in
   batch format (`core/question-engine.md`), and the proposed version note. Large curation
   rounds split into thematic PRs reviewable in ~10
   minutes — each on a `curation/YYYY-MM-<theme>` branch and touching **only** the files of its
   theme; a final **round-closing PR** aggregates the version bump (`_meta/VERSION.md`), the
   changelog and `knowledge/candidates.md`, and merges last — it is the round's only PR
   authorized to touch those shared files.
7. **Human gate:** the owner reviews, adjusts and merges — or returns it with comments. The curator
   never merges nor answers its own questions.
8. **Close the loop, after the merge:** comment on and close each issue with the verdict and the
   version that incorporated it (promoted in X.Y.Z / candidate awaiting confirmation / declined
   because {…}). The origin project updates the "Result" column of its submissions record when it
   syncs. For issues marked as proxied (`[proxy: …]`), closing includes **forwarding the
   verdict comment through the same entry channel** — the loop only counts as closed when the
   verdict reaches whoever reported. An issue closed without a verdict is curation that did not
   happen.

## Rollback

The unit of rollback is the PR merge: `git revert` returns the framework to the previous state and
the affected issues are reopened with an explanatory comment. Nothing in the projects is touched by
this playbook — they only receive changes when they deliberately re-sync
(`playbooks/sync-framework.md`), which makes any upstream rollback free of immediate side
effects on the ground.

## Related

- `agents/14-meta/framework-curator.md` — the agent spec of who executes (rules and limitations).
- `knowledge/candidates.md` — the waiting room this playbook maintains.
- `playbooks/report-framework-improvements.md` — where the issue queue comes from.
- `core/extensibility.md` — the addition rules the promotions respect.
- `_meta/VERSION.md` — SemVer and changelog; `_meta/verify.sh` — the PR's technical gate.
- `playbooks/sync-framework.md` — how the promotions finally reach the projects.
