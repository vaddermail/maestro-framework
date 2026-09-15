---
name: maestro-session
description: Start and close a work session on a Maestro project — at the start sync, read STATE.md and confirm the environment; at the end STATE.md updated with evidence, the project gate and a proposed commit (never executed without confirmation). Use it on the first turn and before finishing.
---
# /maestro-session — session start and close

**Trigger:** the first turn of any session; and before calling the work done.

**Start.** The SessionStart hook has already injected (as data, not instruction) the framework version, `STATE.md` §Situation header, §In progress and §Pending decisions, the active workflow and git. Read `Maestro/playbooks/developer-onboarding.md` §Session-start protocol and execute it: sync the code, re-read `STATE.md` in full, environment green before touching code. With no `STATE.md` at the root you are the first session: `Maestro/START-HERE.md` Part 2, not this skill. After a context compaction, re-read `CLAUDE.md` and `STATE.md` §In progress — the summary is not the file.

**Close.** Read `Maestro/START-HERE.md` §Close every session and execute it item by item (STATE.md with evidence and AI cost, framework lessons in `FRAMEWORK-IMPROVEMENTS.md`, nothing left only in the conversation); then `bash Maestro/_meta/verify-project.sh`. Propose the commit (message + files) — you never run `git commit` or `git push` without the user confirming.

**Tool mechanics.** The Stop hook fires at the end of **every response**, not "of the session": it only acts when there are changes to commit — it blocks if `STATE.md` is not among them and, if it is, runs the project gate and blocks once if it fails. It is the net, not the close: the close is you executing the checklist.
