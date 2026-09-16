# Report improvements to the upstream framework

The project's side of the learning circuit (`knowledge/README.md` §How knowledge circulates):
consolidate the project's `FRAMEWORK-IMPROVEMENTS.md` and deliver it to the upstream repository
as an **issue** — signals go up, releases come down; a project never writes directly to the
framework. The project's Orchestrator (`core/orchestrator.md`) runs it at the close of F6/F7/F8
(an item of `checklists/definition-of-done.md`) and, in F9, at the effort profile's cadence
(`agents/13-guardians/README.md` §Cadences per profile). Several people and projects can report
simultaneously without conflict — issues are independent;
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

1. **Consolidate.** Reread the new entries (without the `(sent #nnn)` mark) across the five
   sections. Does each have the what, the why, evidence and a suggested destination? Incomplete
   ones are completed now or wait for the next submission — entries without a why and evidence are
   never sent. **Generality test:** each entry — the recovered ones below included — answers the
   two questions of `knowledge/README.md` §The generality test: another domain, another stack.
   What can be rewritten in general form is rewritten now; what fails is moved, never deleted
   (product lessons to `STATE.md` §Lessons, stack-bound blocks to destination `starters/`), and
   the counts go in the issue body (step 3). **Recovery sweep:** before closing consolidation,
   cross-check `STATE.md` (§Lessons,
   §Done, §Debt and §Decisions made on behalf of the absent owner, since the last submission — debt
   accepted "because of the framework" or a decision made because the framework did not say what
   to do is reportable friction) and, if cheap, the period's `git log` against the file's
   entries — any framework lesson that escaped in-the-moment capture goes in now, marked
   `(recovered)`. This does not replace capture in the moment; it catches what slipped past it.
   **Framework usage:** include the file's §Framework usage this phase section (specs convened,
   specs opened and set aside, engine questions assumed by default) — it goes in the issue body as
   the "Framework usage" section; it is the only signal that tells upstream which specs carry
   weight without earning it and which questions are poorly designed. **Candidate confirmation:**
   reread `knowledge/candidates.md` from the **upstream's most recent release** —
   `gh release download --repo {{upstream-repo}} --pattern 'Maestro-*.zip'` and read the
   `knowledge/candidates.md` inside it; if the project's copy is already that version, the copy is
   enough — and fill in the artifact's confirmations section (by `C-nnn` ID, with evidence):
   confirming or refuting what other projects reported is as valuable as reporting anew, and it is
   what unblocks promotions. **Confirming candidates does not require syncing the copy**
   (`playbooks/sync-framework.md` is deliberate and may involve a MAJOR; confirmation does not
   wait for that). **At the close of F8**, also include the "Close" block of the genesis dossier
   (`product/99-records/genesis.md`) — it is what curation uses to update the ecosystem's curve
   (`knowledge/learning-curve.md`).
2. **Sanitize.** An explicit check, entry by entry: no personal data, no client or project names,
   no secrets, no confidential domain detail. The lesson in its general form; the evidence by
   path/commit, without pasting sensitive content. When in doubt about an entry, ask the user
   before including it (`core/question-engine.md`). Close with the **mechanical sweep** of the
   consolidated body ("Gates, not gut feelings" — it is the circuit's only irreversible step):

   ```
   bash Maestro/_meta/scan-report.sh {{consolidated-file}} FORBIDDEN-TERMS
   ```

   The script scans for secret and PII patterns (keys, tokens, e-mails, IBAN/tax-ID numbers,
   credentials in URLs) and the project root's local `FORBIDDEN-TERMS` list — the project's name,
   its clients' and people's names, and confidential domain terms, one regex per line;
   instantiated in F0 from `templates/project/FORBIDDEN-TERMS.template` and **never submitted**.
   It prints file:line and the pattern's name, never the value. **The issue opens only on exit
   0**; the result is noted in the §Report log.
3. **Open the issue** on the upstream repository, with the `improvements` label:

   ```
   gh issue create --repo {{upstream framework org/repo — read from Maestro/_meta/ORIGIN or from STATE.md}} \
     --label improvements \
     --title "[improvements] {{sanitized domain, 1 line — e.g. B2B scheduling SaaS}} — {{milestone, e.g. close of F7}}" \
     --body-file {{consolidated-file}}
   ```

   **The project's or client's real name never enters the issue** (title, body, attachments): the
   upstream issue list is read by every project that reports. The curator identifies the project by
   the issue's author and assigns it a project code (P2, P3, …) in the first comment; the
   code↔project map is kept by the owner outside any repository projects have access to
   (`knowledge/candidates.md` §Entry and exit rules, rule 5).

   The body is self-contained (the curator may not be able to read the project's repository):

   ```
   Domain (1 line, sanitized): {{…}}
   Copied framework version: {{X.Y.Z}} · Milestone: {{phase closed / cadence}}
   Generality test: {{n}} entries sent · {{m}} kept in the project (product lessons / stack-bound)

   ## New pitfalls
   {{new entries from this section, complete}}

   ## Proven patterns (with measured gain)
   ## Cross-validation of existing patterns
   ## Friction and omissions
   ## Reusable blocks
   ## Candidate confirmation
   ## Framework usage
   {{same — sections with no new entries are omitted; "Framework usage" always goes in}}
   ```

4. **Record the submission.** In `FRAMEWORK-IMPROVEMENTS.md`: mark the submitted entries with
   `(sent #nnn)` and append the line to the §Report log. In `STATE.md`: one line under
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
closed with an explanatory comment, and the `(sent #nnn)` marks are corrected in the file.
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
