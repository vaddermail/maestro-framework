# L03 — Security Issues

> Loop `L03` of the Maestro framework — persists while open security findings exist, resolving
> by real severity (not by detection order). Follows the anatomy in `loops/README.md`.

An unresolved security finding does not disappear by being ignored — it sits waiting to be
exploited. This loop exists so that no finding is left "for later" without that decision being
explicit, signed off by the user, and never the agent's.

## Identification

| Field | Value |
| --- | --- |
| **When it runs** | F7 (review panel + pentest, before launch); F9 (continuous, guardian's cadence) |
| **Agent that executes the action** | `agents/09-security/security-coordinator.md` triages and prioritizes; the specialist that owns the finding's area (`owasp-top10-specialist`, `secure-authentication-specialist`, `authorization-and-least-privilege-specialist`, …) fixes it; `agents/09-security/pentester.md` and the scanners in `pipelines/ci-security.md` feed new findings |
| **Suggested model** | Top for triage of critical/high severity and for designing the fix; Standard to apply an already-known mitigation (`core/model-routing.md`) |

## Progress metric

Number of security findings in `open` state, counted separately by severity
(critical/high/medium/low) — the metric that decides the exit is **critical + high**, not the raw
total.

## Entry condition

There is ≥1 security finding in `open` state — from pentest, SAST/DAST, security review
(`agents/12-reviewers/security-reviewer.md`) or the threat model.

## Action (the body of the iteration)

1. Triage by **real severity**: raw score (CVSS or equivalent) crossed with exploitability in the
   concrete system (threat model) — a "critical" in an unexposed component can be worth less than
   a "medium" on the authentication path.
2. Resolve the highest real severity first, never the easiest to fix.
3. Apply the fix with a reversal path (a flag if the regression risk is high —
   `modules/feature-flags.md`).
4. Validate: regression green + live proof confirming the exploit no longer works.

## Exit condition (success)

Zero critical/high findings in `open` state. Medium/low findings may transition to **accepted
residual risk** — but only by an explicit user decision, recorded in
`product/05-security/residual-risk.md`, never closed by agent decree.

## Anti-infinite-loop safeguard

- **Stagnation:** 3 iterations on the same finding without moving its state → stop that specific
  finding (the others continue).
- **Oscillation:** fixing one finding reintroduces another (e.g. tightening CSP breaks a flow that
  reopens an authorization finding) → stop immediately; it is a sign of a point fix instead of a
  structural one.
- **Hard cap:** 4 attempts per individual finding. Once exceeded, the finding escalates as a
  candidate for **residual risk** — it is never silenced; the user decides to accept the risk, cut
  the feature, or redesign (escalate to `agents/09-security/threat-modeler.md` if structural).

## STATE.md record

```
L03 · security · metric 5→3→3 · iter 3 (cap 4) · last progress: iter 2 · status: AT RISK
```

## Example (internal app — HR portal)

The `pentester` reports a critical finding: an employee can see another employee's salary record by
changing the `id` in the URL (IDOR). The `security-coordinator` classifies it as critical and
exploitable (it requires no special credentials). The
`authorization-and-least-privilege-specialist` fixes it: the route now always filters by the
server-side identity, never by the request's `id`, and returns 404 (not 403) outside the scope.
Regression green; live proof confirms that another employee's `id` now returns 404. The finding
closes as fixed-and-validated, documented with the cause (missing server-side scoping,
`knowledge/proven-patterns.md` §6).

## Related

- `agents/09-security/security-coordinator.md` — owns triage and residual risk.
- `agents/09-security/README.md` — the map of specialists who fix each type of finding.
- `agents/09-security/pentester.md` — the main producer of findings in F7.
- `checklists/pre-production-security.md` — the gate this loop must satisfy.
- `core/quality-gates.md` — P7 does not pass with critical/high open.
- `playbooks/adversarial-audit.md` — the scrutiny that feeds additional findings.
