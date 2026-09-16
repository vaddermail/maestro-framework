# Pre-Production Security

The security gate for P7 → F8 (`core/quality-gates.md`): no product advances to
`checklists/go-live.md` without this checklist complete. Owner:
`agents/09-security/security-coordinator.md`; runs in F7 and repeats on every relevant release
in F9.

## Headers and transport

- [ ] Security headers configured (CSP, HSTS, `X-Content-Type-Options`, `frame-ancestors`) —
      `agents/09-security/http-headers-specialist.md`.
- [ ] Modern TLS on all entry points (no TLS 1.0/1.1, current ciphers) —
      `agents/09-security/tls-specialist.md`.
- [ ] Certificates with automatic renewal verified, not dependent on manual action.
- [ ] Behind a proxy, the application trusts **only the forwarded headers the proxy writes**
      (origin and protocol, typically); a forwarded host or port header that the proxy does not set
      or strip arrives forged from the client and lands in the absolute URLs generated — including
      the password-reset link. Test that sends the forged headers and asserts none of it reaches URL
      generation (`agents/09-security/http-headers-specialist.md` §Rules).

## Secrets

- [ ] No secret in the Git repository, including history — swept by
      `agents/09-security/exposed-secrets-hunter.md`.
- [ ] Production secrets live outside the code, injected at runtime, and are rotatable without a
      new deploy (`playbooks/secrets-management.md`).
- [ ] Rotation of critical secrets has a defined procedure and owner
      (`agents/09-security/secrets-and-rotation-manager.md`).

## Automated scans

- [ ] SAST run on the current code, with no critical/high findings open
      (`agents/09-security/sast-specialist.md`).
- [ ] Dependency scan with no unaddressed critical/high CVEs
      (`agents/09-security/dependency-analyst.md`).
- [ ] Container/image scan with no critical vulnerabilities left to fix
      (`agents/09-security/container-analyst.md`).
- [ ] Secrets scan of the CI pipeline clean (`pipelines/ci-security.md`).
- [ ] Lockfile enforced as `frozen` in CI; CI actions/plugins and base images pinned by
      SHA/digest; promoted artifact with signed and verified provenance
      (`agents/09-security/supply-chain-specialist.md`, `pipelines/ci-security.md`).
- [ ] Every unfixed finding has its risk explicitly accepted by the user, with a remediation
      deadline — never silently ignored.

## Authentication, authorization and least privilege

- [ ] ASVS verification at the level decided for the product run and with no failures unresolved
      (`agents/09-security/asvs-specialist.md`).
- [ ] OWASP Top 10 coverage confirmed in code review (2025 edition, recorded in the report)
      (`agents/09-security/owasp-top10-specialist.md`).
- [ ] Authorization and scoping confirmed as the server's exclusive responsibility — no access
      decision only on the client (`modules/rbac-and-scoping.md`).
- [ ] Service accounts, DB credentials and cloud/CI permissions follow least privilege,
      **exercised** end to end under the production role — a smoke test that runs with the
      least-privilege credentials, not the DB owner
      (`agents/09-security/authorization-and-least-privilege-specialist.md`).
- [ ] **Rate limits** keyed by identity (user, session, token) with a much higher per-IP ceiling —
      per-IP alone, a shared network (an event, an office, a carrier with NAT) blocks everyone over
      a few; counters in storage with atomic increment; proven with a **parallel** burst inside the
      window, reading the rate-limit headers — serial requests fall outside the window and the
      limiter looks broken.
- [ ] No credential shared between environments (dev/staging/production).

## Backups and recovery

- [ ] Automatic backup configured **and** tested with a real restore, not just scheduled
      (`agents/06-data/backup-specialist.md`).
- [ ] RTO/RPO defined and accepted by the user (`agents/06-data/disaster-recovery-planner.md`).
- [ ] The restore rehearsal proved it touched the real schema and tables before the result counted
      (`agents/06-data/backup-specialist.md` §Rules).

## AI features *(not applicable if the product does not call models — record it in `STATE.md`)*

- [ ] Direct and indirect prompt injection tested adversarially with evidence
      (`agents/09-security/ai-security-specialist.md`).
- [ ] Model output treated as untrusted input: escaping by sink, tool allowlist, scoping
      inherited from the user.
- [ ] Per-model kill switch and credit ceiling wired and tested (`modules/ai-observability.md`,
      `modules/credit-management.md`).
- [ ] Format or behavior invariants that must always hold (never leak a field, always answer in
      this format, never X) live in **code** — validation or post-processing —, never only in the
      system prompt: the model yields to the user's request against the instruction
      (`agents/09-security/ai-security-specialist.md` §Rules).

## Residual risk

- [ ] List of accepted (unfixed) findings with justification, **explicitly signed off by the
      user** — never a silent decision by the agent (`core/quality-gates.md`).

## Related

- `core/quality-gates.md` — the P7 gate this checklist closes.
- `checklists/go-live.md` — the next gate, which depends on this one.
- `pipelines/ci-security.md` — the automation of the scans.
- `agents/09-security/README.md` — the full category and the coverage map.
- `playbooks/secrets-management.md` — secrets and rotation detail.
- `agents/13-guardians/security-guardian.md` — the continuation in production.
