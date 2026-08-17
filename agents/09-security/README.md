# 09 — Security

Defense in depth, across the **entire** lifecycle. Unlike the other categories, security **is not
a phase** — it is a cross-cutting dimension (F1–F9): it enters discovery (what we protect and from
whom), design (threats and controls), build (code free of the OWASP flaws), verification (ASVS,
pentest, scans) and operation (security guardian, CVEs). That is why this category has a
**coordinator** with a seat in every phase, not just one-off specialists.

## The principle: untrusted client, server as sole authority

The whole category rests on a rule inherited from the origin project (`knowledge/origin-lessons.md`):
**authorization, scoping and hiding of sensitive data live on the server; the client only declares
intent.** Client-side blur is cosmetic; data a profile cannot see **does not leave** the server.
The authorization and least-privilege agents echo `modules/rbac-and-scoping.md`.

## Agents in this category

| Agent | One line | Dominant phase |
| --- | --- | --- |
| `agents/09-security/security-coordinator.md` | Orchestrates cross-cutting security; owner of the residual risk | F1–F9 |
| `agents/09-security/threat-modeler.md` | Threat modeling (STRIDE or equivalent) per critical feature | F5 |
| `agents/09-security/owasp-top10-specialist.md` | Systematic OWASP Top 10 coverage in design and review | F3, F7 |
| `agents/09-security/asvs-specialist.md` | ASVS verification by level (L1–L3) according to risk | F7 |
| `agents/09-security/cis-benchmarks-specialist.md` | CIS benchmarks for OS, DB, cloud and containers | F8 |
| `agents/09-security/hardening-specialist.md` | Server/service hardening: minimal surfaces | F8 |
| `agents/09-security/http-headers-specialist.md` | CSP, HSTS, frame-ancestors and the remaining security headers | F6, F8 |
| `agents/09-security/secure-authentication-specialist.md` | Robust authentication: sessions, credentials, MFA, account recovery | F5–F6 |
| `agents/09-security/authorization-and-least-privilege-specialist.md` | Authorization and least privilege on the server, role by role | F5–F7 |
| `agents/09-security/sast-specialist.md` | Static code analysis in CI: rules, triage, zero noise tolerated | F6–F7 |
| `agents/09-security/dast-specialist.md` | Dynamic testing against the running application | F7 |
| `agents/09-security/pentester.md` | Pentest with scope, rules of engagement and an actionable report | F7 |
| `agents/09-security/dependency-analyst.md` | Vulnerabilities in dependencies: audit, triage, deliberate fixing | F6–F9 |
| `agents/09-security/supply-chain-specialist.md` | Supply chain: reproducible builds, provenance, malicious packages | F6–F8 |
| `agents/09-security/sbom-manager.md` | SBOM inventory of what ships and of its licenses/vulnerabilities | F8–F9 |
| `agents/09-security/exposed-secrets-hunter.md` | Secrets in code, history and logs: detection, rotation, response | F6–F9 |
| `agents/09-security/secrets-and-rotation-manager.md` | Secrets policy: where they live, who accesses them, rotation and leak response | F5–F9 |
| `agents/09-security/container-analyst.md` | Image/container security: minimal base, non-root, scan | F7–F8 |
| `agents/09-security/infrastructure-analyst.md` | Security audit of the infra/cloud designed by category 08 | F8 |
| `agents/09-security/tls-specialist.md` | The application's TLS policy: versions, ciphers, renewal | F8 |
| `agents/09-security/waf-specialist.md` | WAF: rules, documented exceptions, gradual blocking mode | F8 |
| `agents/09-security/privacy-specialist.md` | GDPR by design: personal-data map, legal bases, DPIA, data-subject rights | F2, F5, F7 |
| `agents/09-security/ai-security-specialist.md` | Security of LLM features: prompt injection, untrusted output, agency, BYOK | F5–F9 |

## Coverage map: design → build → verify → operate

| Moment | Who enters | What it produces |
| --- | --- | --- |
| **Design (F1–F5)** | `security-coordinator`, `threat-modeler`, `owasp-top10-specialist` | Threats per critical feature, required controls, security requirements |
| **Build (F6)** | `owasp-top10-specialist`, `http-headers-specialist` | Code free of the Top 10 flaws; security headers configured |
| **Verify (F7)** | `asvs-specialist`, `security-reviewer`, `pentester` | ASVS verification by level, review against the threat model, pentest |
| **Operate (F8–F9)** | `cis-benchmarks-specialist`, `hardening-specialist`, `security-guardian` | Hardened infra, benchmarks applied, continuous CVE watch |

## Recommended order of work

1. The **coordinator** opens the dimension in F1 and sets the product's **risk profile** (calibrating
   everyone else's effort — L1 vs L3 on ASVS, full vs shallow STRIDE).
2. The **threat modeler** runs per critical feature as soon as the specification (F5) stabilizes;
   feeds the design with controls.
3. The **OWASP Top 10 specialist** follows design and build (F3, F6) and reviews the code (F7).
4. **ASVS** verifies in F7 against the decided risk level.
5. **CIS, hardening and headers** harden the infra and the service in F8, before go-live.
6. The coordinator **closes the dimension** by consolidating the residual risk, which the user signs.

## How the Orchestrator convenes it

`core/orchestrator.md` **does not treat security as a single stop**: it enrolls the coordinator
as a permanent participant and convenes each specialist at the gate of their phase
(`core/quality-gates.md`). The go-live security gate is
`checklists/pre-production-security.md`; automation runs in `pipelines/ci-security.md`; the
issues found feed `loops/L03-security-issues.md` (and `loops/L07-cves.md` in
operation). Independent review belongs to `agents/12-reviewers/security-reviewer.md`.

## Related

- `agents/13-guardians/security-guardian.md` — this category's continuation in production.
- `modules/rbac-and-scoping.md` · `modules/audit-and-provenance.md` — capabilities security demands.
- `checklists/pre-production-security.md` · `pipelines/ci-security.md`
- `workflows/W07-quality-and-security.md` — the phase where the category concentrates.
