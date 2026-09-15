# L07 — CVEs

> Loop `L07` of the Maestro framework — persists while there are CVEs left to triage, driving each
> one to a terminal state (fixed, mitigated, or not-applicable). Follows the anatomy in
> `loops/README.md`.

A published CVE on a component we use is not an optional task — it is a window of time closing in
the attacker's favor. This loop exists so that no CVE sits "under analysis" with no owner and no
deadline.

## Identification

| Field | Value |
| --- | --- |
| **When it runs** | F9 — daily scan cadence + per event (publication of a CVE affecting the SBOM) |
| **Agent that executes the action** | `agents/13-guardians/security-guardian.md`, following `playbooks/cve-response.md`; coordinates with `agents/13-guardians/dependency-guardian.md` when the fix is a dependency bump |
| **Suggested model** | Standard for triage and low/medium-severity CVEs; Top for impact analysis and patch planning of critical CVEs (`core/model-routing.md`) |

## Progress metric

Number of applicable CVEs (affecting an SBOM component) still without a **terminal state**
(fixed-and-validated / mitigated-with-accepted-risk / not-applicable-justified).

## Entry condition

A CVE feed, a dependency advisory, or a scanner from `pipelines/ci-security.md` reports ≥1 CVE
affecting a component present in the SBOM (`agents/09-security/sbom-manager.md`), still without a
terminal state.

## Action (the body of the iteration)

Follows `playbooks/cve-response.md` step by step:

1. Confirm applicability against the SBOM (affected version, component actually used).
2. Analyze real impact by cross-checking with the threat model (exploitability in the concrete
   context, not just the score).
3. Plan: patch available? regression risk? temporary mitigation possible?
4. Apply the patch (or trigger the `dependency-guardian` for the bump) behind a flag if the
   regression risk is high.
5. Validate: green regression + live proof confirming the vulnerability is closed.

## Exit condition (success)

Zero applicable CVEs without a terminal state. Each one documented: fixed and validated, mitigated
with residual risk signed off by the user, or not-applicable with the justification written down.

## Anti-infinite-loop safeguard

- **Stagnation:** 3 iterations on the same CVE without moving its state → stop that CVE
  specifically.
- **Oscillation:** patching one CVE reintroduces another (the bump breaks a dependency that becomes
  vulnerable again in a different version) → stop immediately; treat it as a dependency-architecture
  decision, not as one more attempt.
- **Hard cap:** 4 iterations per CVE. Once exceeded, the CVE escalates to a **residual risk**
  candidate — it is never silenced without a decision; the user decides to accept (with a review
  deadline), mitigate some other way, or fund the larger migration that resolves it.

## STATE.md record

```
L07 · CVEs · metric 4→2→2 · iter 3 (cap 4) · last progress: iter 2 · status: AT RISK
```

## Example (e-commerce — checkout with product image processing)

The daily scan flags a critical CVE in an image-processing library used to generate product
thumbnails when new items are uploaded. Confirmed in the SBOM: affected up to version 3.2.1, we use
3.2.0. Threat model: the library processes files uploaded by authenticated suppliers in the catalog
panel — exploitable, surface limited to that role. Patch available in 3.2.2, no breaking changes.
Applied right away; green regression; live proof with a known malformed image (correctly rejected).
The CVE closes as fixed-and-validated, SBOM updated, lesson recorded: "third-party image
processing: keep on the latest patch; surface = supplier uploads."

## Related

- `agents/13-guardians/security-guardian.md` — owner of this loop's full cycle.
- `playbooks/cve-response.md` — the step-by-step procedure the action follows.
- `agents/09-security/sbom-manager.md` — the inventory without which impact analysis is unreliable.
- `agents/13-guardians/dependency-guardian.md` — executes the corrective bumps.
- `checklists/pre-production-security.md` — the gate this loop must satisfy before go-live.
- `workflows/W09-continuous-operation.md` — the F9 cadence where this loop runs by default.
