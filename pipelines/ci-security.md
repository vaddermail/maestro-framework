# Security CI

Pipeline that runs in parallel with `pipelines/ci-quality.md`, dedicated to finding security
problems before they reach production: code, dependencies, secrets, images and, on its own cadence,
the running test environment itself. Materialized by
`agents/07-devops/github-actions-specialist.md` (or equivalent vendor); the concrete scan rules
come from `agents/09-security/`.

## Principles

- **Shift-left, but without alert fatigue.** Scans run as early as possible (on every push), but
  they only **block by severity**, not on any finding — unprioritized noise teaches the team to
  ignore the pipeline.
- **Secrets scan covers diff AND history.** A secret committed 40 commits ago is as real as one in
  the latest — the diff scan catches the new one on every push, the full-history scan (periodic)
  catches the forgotten one.
- **A finding without an immediate fix does not disappear — it becomes a loop.** Whatever is not
  resolved in the job itself goes into `loops/L03-security-issues.md` (open findings) or
  `loops/L07-cves.md` (dependency CVEs), with an owner and a deadline per severity.
- **The SBOM is a living artifact**, generated on every build — not a document produced once and
  forgotten; it is the basis for responding to a CVE announced the next day
  (`agents/09-security/sbom-manager.md`).
- **DAST does not run on every PR.** It is slow and needs a provisioned environment; it runs on a
  schedule against a stable test environment, not on every one-line change.
- **The build proves its origin.** An artifact without verifiable provenance is not promotable —
  `pipelines/cd-delivery.md` verifies the attestation before promoting.

## Stages

1. **Trigger** — SAST, secrets scan (diff) and dependency scan run on every `push`/PR (fast
   enough). Container scan runs when the image is built. DAST and the full-history secrets scan
   run **on a schedule** (e.g. nightly/weekly), never per PR.
2. **SAST** — static analysis of the source code against security rules
   (`agents/09-security/sast-specialist.md`); blocks at the agreed severity threshold.
3. **Secrets scan (diff)** — on every new commit, checks only what changed; any confirmed secret
   blocks immediately and triggers `playbooks/secrets-management.md` (emergency rotation).
4. **Secrets scan (full history)** — periodic, sweeps the entire repository
   (`agents/09-security/exposed-secrets-hunter.md`). A finding **confirmed real and live**
   immediately triggers the emergency rotation (`playbooks/secrets-management.md` — revoke +
   rotate), as in stage 3; the rest (false positives, dummies, and the decision to clean or
   rewrite history) open an item in `loops/L03-security-issues.md` for triage — the past is
   never fixed on its own.
5. **Dependency scan (SCA)** — known CVEs in direct and transitive dependencies
   (`agents/09-security/dependency-analyst.md`); blocks by severity, feeds
   `loops/L07-cves.md` with the rest. The scanner reads the previous artifact's **VEX**
   (`agents/09-security/sbom-manager.md`) — justified verdicts (`not_affected`) do not block again;
   a CVE present in the KEV catalog blocks as critical regardless of CVSS.
6. **Container scan** — built image, before the *push* to the registry
   (`agents/09-security/container-analyst.md`); blocks on critical/high.
7. **SBOM generation** — on every build, attached to the artifact and versioned
   (`agents/09-security/sbom-manager.md`); consumed by future CVE response
   (`playbooks/cve-response.md`).
8. **Scheduled DAST** — against the test environment, regular cadence (e.g. daily/weekly)
   (`agents/09-security/dast-specialist.md`); findings enter the same severity triage.
9. **Supply chain integrity** — on every `push`/PR: install in `frozen`/`ci` mode (a lockfile
   resolution mismatch fails the build); dependency hash verification; CI actions/plugins and base
   images pinned by SHA/digest (a floating tag fails). When the artifact is built, generate
   **signed provenance** (an SLSA-type attestation, at a level agreed with the user via the
   question from `agents/09-security/supply-chain-specialist.md`) with the SBOM and the VEX from
   stage 7 attached. Always blocks — there is no "medium integrity".

## Findings triage (what blocks)

| Severity | Effect |
| --- | --- |
| Critical / High | Blocks merge (code) or promotion (container/DAST); fix before moving on |
| Medium | Does not block; goes into `loops/L03-security-issues.md` or `loops/L07-cves.md` with a deadline |
| Low / informational | Recorded, reviewed on cadence by `agents/13-guardians/security-guardian.md`, without blocking |

A confirmed secret always blocks, regardless of the severity the tool assigns — there is no such
thing as a "low-severity secret" (`knowledge/permanent-rules.md` §5).

## Example (neutral pseudocode, illustrative)

```yaml
pipeline: ci-security
triggers: [push, pull_request, scheduled(daily)]
stages:
  - job: sast
    runs_on: [push, pull_request]
    blocks_if: severity >= high
  - job: secrets-scan-diff
    runs_on: [push, pull_request]
    blocks_if: confirmed_finding
  - job: dependency-scan
    runs_on: [push, pull_request]
    blocks_if: severity >= high
    otherwise: open_item(loops/L07-cves.md)
  - job: container-scan
    runs_on: [image_build]
    blocks_if: severity >= critical
  - job: generate-sbom
    runs_on: [image_build]
    produces: [versioned-sbom, vex]
  - job: supply-chain-integrity
    runs_on: [push, pull_request, image_build]
    blocks_if: lockfile_mismatch | floating_pin | missing_provenance
    produces: signed-attestation
  - job: secrets-scan-history
    runs_on: [scheduled(weekly)]
    otherwise: open_item(loops/L03-security-issues.md)
  - job: dast
    runs_on: [scheduled(daily)]
    target: test-environment
```

## Related

- `pipelines/README.md` · `pipelines/ci-quality.md` · `pipelines/cd-delivery.md`
- `loops/L03-security-issues.md` · `loops/L07-cves.md`
- `checklists/pre-production-security.md` · `playbooks/secrets-management.md` · `playbooks/cve-response.md`
- `agents/09-security/security-coordinator.md` · `agents/09-security/sbom-manager.md`
