# Report improvements to the upstream framework

The project's side of the learning circuit (`knowledge/README.md` §How knowledge circulates):
consolidate the project's `FRAMEWORK-IMPROVEMENTS.md` and deliver it to the upstream repository
as an **issue** — signals go up, releases come down; a project never writes directly to the
framework. The project's Orchestrator (`core/orchestrator.md`) runs it at the close of F6/F7/F8
(an item of `checklists/definition-of-done.md`) and, in F9, at the effort profile's cadence.
Several people and projects can report simultaneously without conflict — issues are independent;
serialization happens later, during curation (`playbooks/framework-curation.md`).

## Preconditions

- `FRAMEWORK-IMPROVEMENTS.md` exists at the project root (instantiated in F0 from
  `templates/project/FRAMEWORK-IMPROVEMENTS.md.template`) and has new entries since the last
  submission — **if it has none, there is no submission**: this playbook never fabricates content
  to meet a calendar; capture is event-driven, only the submission is milestone-driven.
- The project's user has an account with permission to **open issues** on the upstream repository
  (nothing more — no write access to the code is needed). Without access, see step 5 (fallback).
- The upstream repository's name/URL is recorded in the project's `STATE.md` (it lives there since
  kickoff, next to the copied framework version).

## Steps

1. **Consolidate.** Reread the new entries (without the `(submitted #nnn)` mark) across the five
   sections. Does each have the what, the why, evidence and a suggested destination? Incomplete
   ones are completed now or wait for the next submission — entries without a why and evidence are
   never sent. **Recovery sweep:** before closing consolidation, cross-check `STATE.md` (§Lessons
   and §Done since the last submission) and, if cheap, the period's `git log` against the file's
   entries — any framework lesson that escaped in-the-moment capture goes in now, marked
   `(recovered)`. This does not replace capture in the moment; it catches what slipped past it.
   **Candidate confirmation:** reread the copy's `knowledge/candidates.md` and fill in the
   artifact's confirmations section (by `C-nnn` ID, with evidence) — confirming or refuting what
   other projects reported is as valuable as reporting anew, and it is what unblocks promotions.
   **At the close of F8**, also include the "Close" block of the genesis dossier
   (`product/99-records/genesis.md`) — it is what curation uses to update the ecosystem's curve
   (`knowledge/learning-curve.md`).
2. **Sanitize.** An explicit check, entry by entry: no personal data, no client names, no secrets,
   no confidential domain detail. The lesson in its general form; the evidence by path/commit,
   without pasting sensitive content. When in doubt about an entry, ask the user before including
   it (`core/question-engine.md`). Close with a **mechanical sweep** of the consolidated body
   ("Gates, not gut feelings" — it is the circuit's only irreversible step): secret and PII
   patterns (keys, tokens, personal e-mails, IBAN/tax-ID numbers) plus the project's local list of
   forbidden terms (client names, confidential domain terms — kept in a project file, **never
   submitted**). Only proceed with a clean sweep; the result is noted in the §Submission log.
3. **Open the issue** on the upstream repository, with the `improvements` label:

   ```
   gh issue create --repo {{upstream-framework-repo, e.g. vaddermail/maestro-framework}} \
     --label improvements \
     --title "[improvements] {{project-name}} — {{milestone, e.g. close of F7}}" \
     --body-file {{consolidated-file}}
   ```

   The body is self-contained (the curator may not be able to read the project's repository):

   ```
   Project: {{name}} · Domain (1 line, sanitized): {{…}}
   Copied framework version: {{X.Y.Z}} · Milestone: {{phase closed / cadence}}

   ## New pitfalls
   {{new entries from this section, complete}}

   ## Proven patterns (with measured gain)
   ## Cross-validation of existing patterns
   ## Friction and omissions
   ## Reusable blocks
   {{same — sections with no new entries are omitted}}
   ```

4. **Record the submission.** In `FRAMEWORK-IMPROVEMENTS.md`: mark the submitted entries with
   `(submitted #nnn)` and append the line to the §Submission log. In `STATE.md`: one line under
   "Done" with the issue number. When the curation verdict arrives (a comment on the issue),
   update the log's "Result" column.
5. **Fallback without issue access.** If the user has no account/permission on the upstream
   repository: deliver the same consolidated body to the framework owner through the agreed
   channel (e-mail, message, shared file) and record the submission all the same — the recipient
   opens the issue themselves, **marked as proxy** (e.g. `[proxy: e-mail]` in the title), so the
   curation queue stays complete and the verdict knows how to return through the same channel
   (`playbooks/framework-curation.md` step 8). What must not happen is the lesson dying in the
   project.

**Special case — local edits to the framework copy:** when step 2 of
`playbooks/sync-framework.md` finds differences in the copy, each difference first becomes an
entry in "Friction and omissions" (or "Reusable blocks") and follows this playbook — only then is
the copy reconciled. A local edit is the strongest involuntary report there is: someone needed the
framework to be different.

## Rollback

Submitting an issue changes nothing in the project or the framework — a mistaken submission is
closed with an explanatory comment, and the `(submitted #nnn)` marks are corrected in the file.
There is only one real irreversible risk: **sensitive content published in the issue** — which is
why sanitization is an explicit step before submission; if it happens, delete/edit the issue
immediately and treat it as a data incident in the project (`workflows/W11-incident-response.md`).

## Related

- `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` — the artifact this playbook submits.
- `playbooks/framework-curation.md` — what happens to your report on the other side.
- `knowledge/README.md` — the full circuit; `knowledge/candidates.md` — where single-project
  lessons wait for the second confirmation.
- `checklists/definition-of-done.md` — the phase closes that require this submission.
- `playbooks/sync-framework.md` — the reverse path: how promotions come back to the project.
