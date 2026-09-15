# W09 — Continuous Operation (Phase F9)

The phase that **never ends**. A product is not "done" when it reaches production — that is where it
starts to live (`MANIFESTO.md` §10: maintenance starts on day 0). F9 keeps it healthy forever
through a **permanent team of guardians**, each watching one dimension at its **own cadence**,
without waiting for a human to remember to look. Where an F7 reviewer asks "is it good enough to
launch?", a guardian asks "is it still good, today?".

> **Phase:** F9 (perpetual) · **Entry gate:** P8 (product in production, rollback rehearsed)
> · **Exit gate:** none — there are **cadences (P9)** and loops L02–L08 always armed
> · **Previous workflow:** `workflows/W08-launch.md` · **cross-cutting:**
> `workflows/W10-feature-evolution.md`, `workflows/W11-incident-response.md`

## Objective

Keep the product secure, fast, cheap, documented and recoverable over the years — with real proof,
never "looks fine". Each guardian cycle ends in an **auditable terminal state** (resolved /
mitigated / not-applicable), and the non-obvious goes back into project memory
(`core/project-memory.md`); what is general and framework-level goes up to the upstream framework
at the profile's cadence (`agents/13-guardians/README.md` §Cadences per profile;
`playbooks/report-framework-improvements.md`).

## Preconditions (entry gate)

- [ ] P8 passed: product in production, monitoring active, rollback rehearsed,
      `product/07-operations/` complete (runbooks, SLOs, observability, DR plan).
- [ ] Effort profile confirmed in `STATE.md` — it decides **which** guardians run and at what
      cadence (`core/orchestrator.md` §Effort profiles).
- [ ] Report template available (`templates/technical/guardian-report.md.template`).

## Steps (agent → artifact → cadence)

F9 is not a single sequence: it is a **set of scheduled cycles** that the Orchestrator runs in
parallel. Each guardian runs its fixed cycle — **analyze → plan → apply → validate → document** —
and writes to `product/99-records/guardians/<dimension>-YYYY-MM-DD.md`.

**Step 0 — on opening a session in F9 (which guardian is due?):** (a) read the cadences from the
project's `CLAUDE.md` §F0 calibration; (b) for each active guardian, the last cycle's date is that
of the most recent report in `product/99-records/guardians/<dimension>-YYYY-MM-DD.md` (or "never");
(c) it is **due** if today − last cycle ≥ cadence, or if there is a pending event (CVE, anomaly,
request); (d) the due ones run in this order: security, backups, dependencies, performance, costs,
quality, documentation, value; (e) record in `STATE.md` §In progress one line per active guardian
in the format `G · security · weekly cadence · last cycle YYYY-MM-DD · next YYYY-MM-DD · state: on
track / due / running`. Without this calculation, "cadence met" (P9) is a feeling, not a gate.

| # | Guardian | Watches | Cadence | Chains / escalates to |
| --- | --- | --- | --- | --- |
| 1 | `agents/13-guardians/security-guardian.md` | CVEs, deps, containers, OS, cloud | daily + per CVE | triggers (2); `loops/L07-cves.md`, `loops/L03-security-issues.md`, `playbooks/cve-response.md` |
| 2 | `agents/13-guardians/dependency-guardian.md` | deliberate updates (non-security) | weekly + monthly (majors) | `playbooks/dependency-updates.md`, `loops/L08-technical-debt.md` |
| 3 | `agents/13-guardians/performance-guardian.md` | CPU/RAM, queries, APIs, cache, LCP/CLS/TTFB vs budgets | continuous + weekly | feeds (4) |
| 4 | `agents/13-guardians/cost-guardian.md` | infra, API and AI costs (product and development) | monthly + anomaly alert | **reads the output of (3)** |
| 5 | `agents/13-guardians/quality-guardian.md` | code smells, duplication, complexity, coverage, architecture drift | weekly + per release | `loops/L04-code-smells.md`, `loops/L08-technical-debt.md` |
| 6 | `agents/13-guardians/documentation-guardian.md` | docs↔code↔product sync | per release + weekly | `loops/L05-inconsistencies.md`, `loops/L06-outdated-documentation.md` |
| 7 | `agents/13-guardians/backup-guardian.md` | existence **and real restore** of backups | daily check + periodic drill | `workflows/W11-incident-response.md` if the restore fails |
| 8 | `agents/13-guardians/value-guardian.md` | business KPIs vs targets in `product/00-discovery/goals-and-kpis.md` | monthly + per target with a due date | missed target → product decision goes up to the user; may trigger (9) |
| 9 | `agents/13-guardians/feature-evolution-agent.md` | new requests in production | per event (request) | triggers `workflows/W10-feature-evolution.md` |

**Chaining between guardians (`agents/13-guardians/README.md`):** the Orchestrator does not run
them in silos — Security triggers Dependencies when a patch requires an update; Cost reads
Performance's output (a slow query that inflated the bill); Quality and Documentation share the
same reconciliation loops. **They all report to the Orchestrator**, which groups the questions to
the user into batches (never one by one — `core/question-engine.md`).

> **Scales with the profile:** each guardian's concrete cadences per profile live in the **single
> table** in `agents/13-guardians/README.md` §Cadences per profile — in a prototype they are all
> disabled until the decision to continue; on an enterprise platform add the periodic global
> review (`workflows/W12-global-review.md`).

## Decision points

- **Human approval** (`core/orchestrator.md` §Human approval): only the user **accepts residual
  risk** (a CVE deliberately left unfixed for now), authorizes **spending money** (an infra
  upgrade proposed by the cost guardian), approves risky dependency **majors**, or touches
  **personal data**. The guardian recommends with evidence; **it does not decide**.
- **Batch the questions.** Pending items from several guardians are grouped into one coherent
  batch per cycle, not one interruption per finding (`core/question-engine.md`); they stay visible
  in `STATE.md` → "Pending decisions" until the user answers.
- **Terminal states are mandatory.** No finding stays "under analysis" without an owner and a
  deadline: it ends **resolved** (with proof), **mitigated** (risk accepted by the user) or
  **not-applicable** (justified).

Multi-domain example: in a **B2B SaaS**, the security guardian triages a CVE in a PDF lib and,
since the product has no exploitation path, marks it **not-applicable** with justification; in an
**e-commerce**, the cost guardian detects that the search AI bill spiked and proposes a per-model
kill-switch (`modules/ai-observability.md`); in an **internal app**, the backup guardian runs the
monthly restore drill and finds a corrupted dump — which **becomes an incident**.

## Escalation: when a cycle stops being a cycle

- **Finding → incident.** When a finding outgrows the guardian's dimension (a CVE being actively
  exploited, a degradation turning into an outage, a restore that fails), it **escalates to**
  `workflows/W11-incident-response.md` — triage, mitigation, communication, blameless post-mortem
  (`checklists/post-incident.md`).
- **New request → evolution.** A feature request in production enters through
  `agents/13-guardians/feature-evolution-agent.md`, which triggers
  `workflows/W10-feature-evolution.md` — the mini-cycle that re-runs F2→F8 in miniature, with the
  gates of the phases it touches (`core/lifecycle.md` rule 4). Features are not "pushed straight
  to production" skipping the gates.
- **End of life → decommissioning.** When the user decides to retire the product or a feature with
  data from production, it follows `workflows/W13-decommissioning.md` — reversible up to the last
  step, with no orphaned data and no phantom costs; never "delete everything" nor "leave it
  running".

## Loops it opens

In F9 loops L02–L08 are **always armed** (`core/lifecycle.md` F9), triggered by the guardians:
`loops/L02-failing-tests.md`, `loops/L03-security-issues.md`, `loops/L04-code-smells.md`,
`loops/L05-inconsistencies.md`, `loops/L06-outdated-documentation.md`, `loops/L07-cves.md`,
`loops/L08-technical-debt.md`. Safeguard: three iterations without progress stop the loop and
escalate to the user (`loops/README.md`).

## Exit gate (P9 — cadences, not a phase)

F9 never closes — **it is met by cadence** (`core/quality-gates.md` P9). Each guardian cycle
"passes" when:

- [ ] The cycle report is written in `product/99-records/guardians/` **with numbers and terminal
      states** — a report without numbers and terminal states **does not close** the cycle.
- [ ] No finding was left "under analysis" without an owner and a deadline; whatever went up to
      the user is in `STATE.md`.
- [ ] Applied changes were **validated with real proof** and have a reversal path
      (`modules/feature-flags.md` when applicable).
- [ ] Non-obvious lessons went to `STATE.md` (`core/project-memory.md`); the ones that belong to
      the **framework** went to `FRAMEWORK-IMPROVEMENTS.md`, and the report went out at the
      profile's cadence (`agents/13-guardians/README.md` §Cadences per profile;
      `playbooks/report-framework-improvements.md`).

**Who verifies:** the Orchestrator, per cadence. **Who approves:** the user, **by exception**
(only when residual risk, money, data or production is at stake).

## Effort profiles

| Profile | How F9 changes |
| --- | --- |
| **Prototype** | Guardians disabled until the decision to evolve into a product; no cadences. |
| **Internal product** | Guardians on the cadences of the single table (`agents/13-guardians/README.md` §Cadences per profile); loops armed; DR verified periodically. |
| **Commercial product** | Same, on the commercial-profile column of the single table + anomaly alerts; cost guardian with anomaly detection; on-call for incidents (W11). |
| **Enterprise platform** | Same, on the enterprise-profile column of the single table + regular DR drills, periodic global review (`workflows/W12-global-review.md`), AI costs with a per-model kill-switch. |

## Anti-patterns

- ❌ "It's in production, it's done" → ✅ maintenance starts on day 0; guardians on cadence.
- ❌ A backup that exists but was never restored → ✅ a real restore drill is what counts.
- ❌ A finding "under analysis" forever → ✅ terminal state with an owner and a deadline.
- ❌ New feature pushed straight to production → ✅ `workflows/W10-feature-evolution.md` with gates.
- ❌ Machine-gunning the user with questions on every finding → ✅ batches per cycle.

## Related

- `agents/13-guardians/README.md` — cadences, shared duties and report format.
- `workflows/W10-feature-evolution.md` — new requests; `workflows/W11-incident-response.md` —
  when a finding becomes an incident; `workflows/W13-decommissioning.md` — when the product or a
  feature reaches end of life.
- `core/lifecycle.md` (F9) · `core/quality-gates.md` (P9) · `core/project-memory.md`.
- `loops/README.md` — loops L02–L08 armed in production.
- `templates/technical/guardian-report.md.template` · `checklists/post-incident.md`.
- `playbooks/report-framework-improvements.md` — the improvement report at F9's cadence.
- `agents/12-reviewers/README.md` — F7's point-in-time eyes, upstream of the guardians.
