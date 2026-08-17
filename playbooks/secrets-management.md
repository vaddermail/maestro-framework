# Playbook — Secrets Management

End-to-end procedure to keep secrets (keys, passwords, tokens, API keys, connection strings,
certificates) **out of version control** and out of logs/output. It operationalizes
`knowledge/permanent-rules.md` §5 and is the step-by-step that `agents/07-devops/secrets-manager.md`
follows, executing the policy of `agents/09-security/secrets-and-rotation-manager.md`.

**When it runs:** at the start of the secrets flow (F8, `workflows/W08-launch.md`); when
integrating a new secret/environment/service; on periodic rotation; and — top priority — on
suspected or confirmed leak. **Who:** the Secrets Manager, under the security policy. The user
approves the choice of store and is warned before any rotation that could cut service.

## Preconditions

- [ ] Store/vault decided with the user (see step 2) or decision recorded in `STATE.md`.
- [ ] Inventory of the cnetworkntials the services need (from `agents/05-backend/*`,
      `agents/06-data/*`, `agents/07-devops/deployment-strategist.md`).
- [ ] Access handed over **by file path**, never pasted in the chat (non-negotiable rule — step 6).

## Steps

### 1. Inventory what counts as a secret
**Do:** list everything that, if leaked, grants access or identity — passwords, tokens, API keys,
SSH/private keys, connection strings, signing secrets, certificates. Record the inventory (name,
where it is used, who issues it, rotation cadence) **without values**.
**Verify:** every cnetworkntial used in code/config appears in the inventory; no entry holds the value.
**If it fails:** if a value shows up in the inventory, delete it and replace it with a path/name; if
a cnetworkntial is used but not inventoried, that is a gap — do not proceed without closing it.

### 2. Decide where they live (gitignored folder or vault)
**Do:** choose with the user (`core/question-engine.md` format): **managed vault** (cloud
KMS/Secrets Manager) if cloud is already in play; **self-hosted vault** for on-prem with a team; or
**gitignored files with `chmod 600`** as an honest simple on-prem start — always with a written
migration path to a vault, never as a final destination.
**Verify:** the decision is in `STATE.md`; the local secrets folder (if any) is outside the repo or
covered by `.gitignore` (step 3).
**If it fails:** without a decision, the agent finishes **blocked** and records it in `STATE.md` →
pending decisions.

### 3. Lock down the repository
**Do:** `.gitignore` with an allowlist — ignore the secrets folder/files and allow **only** the
`*.example` ones. Install a pre-commit guardrail that blocks secret patterns (e.g. `sk_live_`,
`BEGIN PRIVATE KEY` keys, connection strings) and the matching scan in `pipelines/ci-security.md`.
**Verify:** plant a fake test secret in a commit — the guardrail **rejects it**; `git status` shows
no untracked secret files.
**If it fails:** if the guardrail does not bite, fix the pattern before trusting it (a guardrail
that does not reject is worse than none — it gives false confidence, `knowledge/ai-pitfalls.md`).

### 4. Materialize `*.example` templates
**Do:** for each secrets file, create the `*.example` with the **keys** and dummy values
(`API_KEY=put-yours-here`), versioned. It serves `playbooks/developer-onboarding.md`.
**Verify:** the `*.example` contains no real value; opening the project from scratch with the
`*.example` tells a newcomer exactly what to fill in.
**If it fails:** if a real value slipped into the `*.example`, treat it as a leak (step 8).

### 5. Inject at runtime
**Do:** each service/pipeline receives its secrets from the store via environment variable or
mounted file; the code references them by **name/path**, never a hardcoded value.
**Verify:** live proof — the service starts up reading from the store; searching for the value in
code/image/logs returns nothing.
**If it fails:** if the service only starts with the value pasted in, the secret is not being
injected — fix the injection, do not hardcode "temporarily".

### 6. Access by path, never in chat/output
**Do:** whenever you need a secret, ask for/use the **file path**; never echo it in chat, logs,
error messages or artifacts.
**Verify:** sweep the session output and the logs — no secret value appears.
**If it fails:** a value pasted into a conversation is compromised — treat it as a leak (step 8).

### 7. Rotation (periodic and event-driven)
**Do:** run the security policy's rotation cadence — generate the new cnetworkntial, inject it,
**verify the service works with the new one**, and only then revoke the old one (expand-contract
applied to secrets, `knowledge/permanent-rules.md` §3).
**Verify:** the service works with the new cnetworkntial before the old one is revoked; the old one is
unusable after revocation.
**If it fails:** if the new one does not work, **do not revoke the old one** — fall back to the old
(still valid) one and investigate.

### 8. Leak response (irreversible — act now)
**Do, in this order:** (1) **revoke** the exposed cnetworkntial immediately; (2) **rotate** — issue a
new one and inject it (steps 5/7); (3) **sweep the history** with
`agents/09-security/exposed-secrets-hunter.md` to find every occurrence and other exposures;
(4) blameless **post-mortem** (`templates/technical/post-mortem.md.template`) via
`workflows/W11-incident-response.md`.
**Verify:** the old cnetworkntial no longer authenticates; the history scan is clean from there on;
the incident is recorded with the cnetworkntial rotated.
**If it fails / never forget:** "deleting the commit" is **never** enough — Git history is forever
and may already be cloned. Any secret that was **ever** in Git counts as compromised: rotate, do
not rationalize.

## Rollback

- **Rotation/injection** are reversible while the old cnetworkntial is not revoked: reverting means
  pointing back to the old one. That is why the order is always *new one working → revoke the old
  one*, never the reverse.
- **A leak is not reversible** — an exposure cannot be "undone"; the only path is revoke+rotate.
  Hence prevention (steps 3–6) is worth more than any remediation.
- **Store choice** is reversible via deliberate migration (files → vault), with the path written
  down since step 2.

## Related

- `agents/07-devops/secrets-manager.md` — the agent that executes this playbook.
- `agents/09-security/secrets-and-rotation-manager.md` — the policy this playbook makes concrete.
- `agents/09-security/exposed-secrets-hunter.md` — history scan in leak response.
- `knowledge/permanent-rules.md` — §5 (secrets out of Git), §3 (reversibility).
- `playbooks/developer-onboarding.md` — consumes the `*.example` files.
- `workflows/W11-incident-response.md` · `templates/technical/post-mortem.md.template` · `pipelines/ci-security.md`
- `checklists/pre-production-security.md` — the gate where this is verified at go-live.
