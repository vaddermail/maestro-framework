# Playbook — Developer Onboarding

Take a **new participant** from zero to operational **with one command**, and then start every
session in a disciplined way. "Participant" means both a **human** (a developer joining the team)
and an **AI agent** (a new Claude Code/Cowork/other session) — both need the same: synchronized
code, a reproducible environment, dedicated access and the project memory read before touching
anything.

**When it runs:** when someone/something joins the project (starter kit, steps 1–5); and **at the
start of every work session** (session-start protocol, steps 6–8). **Who:** the new participant
themselves, guided by this playbook; a human on the team approves the creation of dedicated access.

## Preconditions

- [ ] Repository accessible (clone via key/deploy key, never a pasted token —
      `playbooks/secrets-management.md`).
- [ ] An **idempotent** setup script exists at the root (e.g. `setup.sh`) — if it does not, creating
      it is the first contribution (step 3).
- [ ] `STATE.md`, `CLAUDE.md` (or the tool's instructions — `adapters/`) and the `product/` tree
      exist in the project (created at kickoff, `workflows/W00-project-kickoff.md`).

## Steps

**Starter kit (once, on joining):**

### 1. Get the code
**Do:** clone the repository via the dedicated access (key/deploy key). Confirm you are in the
target environment (e.g. VS Code over WSL, never PowerShell — an origin rule from the origin
project).
**Check:** clean `git status`; `git log -1` shows the latest commit of the integration branch.
**If it fails:** if the access does not work, do not paste tokens into the chat — request/create a
dedicated credential (step 4) and record the path, not the value.

### 2. Read the project memory **before** touching anything
**Do:** read, in this order, `CLAUDE.md` (stable rules), `STATE.md` (done/in progress/up next/
pending decisions/lessons) and the `product/` index. An AI agent also reads `START-HERE.md` and the
adapter for its tool (`adapters/claude-code.md` or `adapters/other-assistants.md`).
**Check:** you can say in two sentences where the project stands and what the next task is —
without asking anyone.
**If it fails:** if `STATE.md` is not enough to resume, that is a memory gap — record it and ask
for context, **never guess** (`knowledge/ai-pitfalls.md` §3, §8).

### 3. Sync the environment with one command
**Do:** run the idempotent setup script (`./setup.sh`): it installs the runtime at the pinned
version (lockfile/`.nvmrc`/`engines` — `knowledge/permanent-rules.md` §6), dependencies, extensions
and tools. Running it twice must **not** break anything.
**Check:** the script exits with code 0; a second run is idempotent (no errors, no duplicates);
lint and local tests run (`pipelines/ci-quality.md`).
**If it fails:** if the setup is not idempotent or a step is missing, **fix the script** (so the
next person does not trip), do not hand-patch the local machine — fixing the script is the value.

### 4. Get dedicated, revocable access
**Do:** create/receive the participant's **own** credentials (deploy key, minimal-scope token),
distinct from other people's and **revocable** without breaking anyone else's. Fill in local
secrets from the `*.example` files (`playbooks/secrets-management.md`).
**Check:** the participant can access what they need and **only** what they need (least privilege);
revoking their credential affects no one.
**If it fails:** sharing a credential "to be quick" is security debt — create the dedicated one,
even if it costs minutes.

### 5. First guided contribution
**Do:** pick a **small, additive** slice (a fix, a test, a doc clarification) to exercise the full
cycle: dedicated branch → change → verification → green PR → heads-up to the colleague
(`knowledge/permanent-rules.md` §8, `checklists/pre-merge.md`).
**Check:** the PR passes lint+tests (front and back run separately — run both); it is reviewed by
someone who is **not** the author (`knowledge/ai-pitfalls.md` §20).
**If it fails:** if the first PR does not go green, it signals a badly synced environment (back to
step 3) or an unread rule (back to step 2) — fix the cause, do not force the merge.

**Session-start protocol (every time):**

### 6. Sync the code
**Do:** `git fetch` + `git pull --rebase` on the integration branch. Never assume local is the most
recent.
**Check:** local is ahead of or equal to the integration branch's remote, with no unresolved
divergence.
**If it fails:** on divergence or a dirty shared *working tree*, **stop and clarify** instead of
overwriting (`knowledge/permanent-rules.md` §8).

### 7. Sync the environment and read the state
**Do:** run the setup if dependencies changed; reread `STATE.md` (lessons and decisions may have
changed since the last session).
**Check:** environment green (local lint/tests) and state read before touching code.
**If it fails:** if the environment will not go green, fix it before moving on — do not build on a
broken base.

### 8. Close the session (always)
**Do:** update `STATE.md` (done/in progress/up next, decisions made and pending, non-obvious
lessons with the why); confirm that everything touched is in files, nothing only in the
conversation (`START-HERE.md` §2.5, `core/project-memory.md`).
**Check:** the next session (human or AI) can resume from `STATE.md` alone.
**If it fails:** half-done work with no trace gets lost between sessions — record the blocker with
enough context to resume without re-asking.

## Rollback

- A departing participant is rolled back by **revoking their dedicated access** (step 4) — that is
  why it is dedicated and revocable (offboarding is this playbook's mirror image:
  `modules/entity-lifecycle.md`).
- The environment is disposable: the idempotent setup (step 3) rebuilds from scratch, so there is
  no manual state to preserve on the machine.

## Related

- `START-HERE.md` — project start (the first session of all).
- `workflows/W00-project-kickoff.md` — instantiation of the memory this playbook assumes.
- `core/project-memory.md` — `STATE.md` and handover between sessions/people/tools.
- `playbooks/secrets-management.md` — the `*.example` files and the dedicated credentials.
- `adapters/claude-code.md` · `adapters/other-assistants.md` — AI-tool-specific startup.
- `knowledge/permanent-rules.md` — §6 (pinned versions), §8 (collaborative Git).
- `checklists/pre-merge.md` · `pipelines/ci-quality.md` — the first contribution's gate.
