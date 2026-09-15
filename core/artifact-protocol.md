# Artifact Protocol

The information contract between agents. Agents do not collaborate through conversation — they
collaborate through **artifacts**: files with a known owner, location, state and consumers. This
protocol is what makes it possible to switch tool, model or person without losing anything.

## Principles

1. **Output that is not written down does not exist.** Every agent result lives in a file in the
   `product/` tree (or in the code). The conversation is ephemeral; the artifact is the truth.
2. **One artifact, one owner at a time.** The owner is the agent that writes/updates it; everyone
   else reads. Changing owner is explicit (recorded in the artifact header).
3. **Explicit states.** Every artifact declares its state in the header:
   `draft` → `in-review` → `approved` (→ `obsolete` when superseded — never deleted, only marked).
   Downstream agents only consume `approved`, unless the Orchestrator says otherwise.
4. **Traceability as a chain:** idea → discovery → requirement (`FR-nnn`) → business rule
   (`BR-nnn`) → module specification → code → test. Each artifact references the upstream IDs it
   satisfies. A requirement without a test is detectable; so is a test without a requirement.
5. **Format:** Markdown, with the standard header (below). Diagrams as text (Mermaid/ASCII) so
   they are versionable and readable by agents.

## Standard artifact header

```markdown
# {{Title}}

> **State:** draft | in-review | approved | obsolete
> **Owner:** agents/NN-category/agent-name.md
> **Phase:** F1 | … | F9 · **Updated:** YYYY-MM-DD
> **Satisfies:** FR-012, BR-003 (upstream IDs, when applicable)
> **Consumers:** (agents/phases that depend on this artifact)
```

## The project's `product/` tree

Created in F0 (`workflows/W00-project-kickoff.md`) at the root of the new project:

```
<project>/
├── CLAUDE.md                       ← stable instructions for agents (templates/project/CLAUDE.md.template)
├── STATE.md                       ← living memory (core/project-memory.md)
├── Maestro/                   ← the framework (reference, read-only during the project)
├── product/
│   ├── 00-discovery/
│   │   ├── idea.md                 ← idea-analyst
│   │   ├── problem.md              ← problem-definer
│   │   ├── stakeholders.md         ← stakeholder-mapper
│   │   ├── personas/               ← persona-builder (one file per persona)
│   │   ├── use-cases/              ← use-case-modeler (one per case, UC-nnn)
│   │   ├── goals-and-kpis.md       ← business-goals-analyst + kpi-definer
│   │   ├── risks.md                ← risk-analyst (R-nnn)
│   │   ├── costs.md                ← cost-estimator
│   │   ├── roadmap.md              ← roadmap-planner
│   │   ├── mvp.md                  ← mvp-scoper
│   │   ├── prioritization.md       ← prioritizer
│   │   └── existing-system.md      ← existing-system-analyst (only when the product replaces/extends a system in use)
│   ├── 01-requirements/
│   │   ├── functional-requirements.md    ← requirements-engineer (FR-nnn)
│   │   ├── nfr.md                        ← nfr-specifier (NFR-nnn)
│   │   ├── business-rules.md             ← business-rules-modeler (BR-nnn)
│   │   ├── acceptance-criteria.md        ← acceptance-criteria-writer (ACs per FR)
│   │   ├── glossary.md                   ← glossary-curator
│   │   └── questions-and-answers.md      ← question engine (Q&A history with the user)
│   ├── 02-architecture/
│   │   ├── architecture-vision.md  ← architecture-arbiter (chosen style + why)
│   │   ├── proposals/              ← blind proposals from the style specialists (one per specialist)
│   │   ├── decisions/              ← ADR-nnn-title.md (decision engine; never deleted) — the ONLY home of ADRs
│   │   ├── stack.md                ← stack-selector (technologies + pinned versions)
│   │   └── integrations.md         ← stack-selector (F3: inventory — system, protocol, authn, SLA, external owner, status); detailed contracts by api-designer (F5) (modules/readonly-external-integrations.md)
│   ├── 03-experience/
│   │   ├── flows-and-journeys.md   ← ux-researcher
│   │   ├── wireframes/             ← wireframer (one per screen/flow)
│   │   ├── visual-direction.md     ← ui-designer
│   │   ├── design-system.md        ← design-system-architect (tokens)
│   │   ├── components.md           ← component-architect
│   │   ├── screen-map.md           ← ux-researcher + ui-designer
│   │   ├── accessibility.md        ← accessibility-specialist
│   │   ├── responsiveness.md       ← responsiveness-specialist
│   │   ├── web-performance.md      ← web-performance-specialist (budgets per route)
│   │   ├── seo.md                  ← seo-specialist (when applicable)
│   │   └── internationalization.md ← internationalization-specialist (when applicable)
│   ├── 04-specification/           ← the functional source of truth (survives the code)
│   │   ├── README.md               ← index of the specified modules
│   │   ├── modules/<module>.md     ← spec per module: rules, flows, states, permissions
│   │   ├── state-machines.md       ← critical flows as states/transitions/effects
│   │   ├── logical-data-model.md   ← data-modeler (database-agnostic)
│   │   ├── backend-contract.md     ← authorization-specialist (authz/scoping/integrity on the server; sensitive fields flagged by api-designer)
│   │   ├── api-contract.md         ← api-designer + REST/GraphQL/gRPC specialists (the exposed API)
│   │   ├── api/                    ← endpoint specifications per module (when the detail demands it)
│   │   ├── backend/                ← server engineering: logging.md, events.md, queues.md, observability.md, metrics.md, scalability.md, api-versioning.md, caching.md, product-analytics.md (← agents/05-backend)
│   │   └── frontend/               ← client engineering: frontend-conventions.md and the like (← agents/04-frontend)
│   ├── 05-security/
│   │   ├── risk-profile.md         ← security-coordinator (F1; calibrates the dimension's effort)
│   │   ├── threat-model.md         ← threat-modeler
│   │   ├── asvs-requirements.md    ← asvs-specialist (chosen level + verifications)
│   │   ├── asvs-level.md           ← asvs-specialist (target level + verified ASVS version)
│   │   ├── asvs-verification.md    ← asvs-specialist (verdict per requirement, with evidence)
│   │   ├── owasp-top10.md          ← owasp-top10-specialist (verdicts per category)
│   │   ├── personal-data-map.md    ← privacy-specialist (record of processing + legal bases)
│   │   ├── dpia.md                 ← privacy-specialist (when the triggers fire)
│   │   ├── data-subject-rights.md  ← privacy-specialist (flows with deadlines, testable)
│   │   ├── ai-security.md          ← ai-security-specialist (trust boundaries and guardrails for LLM features)
│   │   ├── (policies and states)   ← tls-policy.md · waf-policy.md · least-privilege.md · supply-chain.md · dependencies.md · secrets-inventory.md · exposed-secrets.md · sast-findings.md · infrastructure.md (← 09-security specialists)
│   │   ├── sbom/                   ← sbom-manager (SBOM + VEX per artifact — the triage verdict the scanner reads)
│   │   └── residual-risk.md        ← security-coordinator (accepted by the user)
│   ├── 06-tests/
│   │   ├── test-strategy.md        ← test-strategist (written before slice 0 — W06 §Preconditions)
│   │   ├── test-plan.md            ← test-strategist (separate risk→level map, when volume justifies it; links FR/BR → tests)
│   │   └── test-plans/             ← plans per slice/module, when a single file is not enough
│   ├── 07-operations/
│   │   ├── runbooks/               ← one per operational procedure (includes the devops specialists')
│   │   ├── slos.md                 ← observability-architect (F8): service objectives + alert policy
│   │   ├── observability.md        ← observability-architect (F8): what is measured and where to see it (includes AI costs); read by the value, cost and performance guardians
│   │   ├── dr-plan.md              ← disaster-recovery-planner (RTO/RPO + drills) — the ONLY home of the DR plan
│   │   ├── git-workflow.md         ← github-specialist (branches, protections, releases)
│   │   ├── container-image.md      ← docker-specialist
│   │   ├── github-pipelines.md / azure-pipelines.md / gitlab-pipelines.md ← one, per the chosen platform
│   │   ├── ansible.md / kubernetes.md ← when the infra decision calls for them
│   │   ├── secrets/                ← secrets-manager (inventory and rotation; never values)
│   │   ├── flags/                  ← feature-flag catalog (feature-flags-specialist)
│   │   ├── data/                   ← data engineering in operation: backups.md, migrations/, seeds/, indexes/, retention.md, environments.md, quality.md, performance/, audit.md (← agents/06-data)
│   │   ├── infra/                  ← infrastructure design and proposals: hosting proposals (aws.md, azure.md, …), network.md, dns.md, vpn.md, storage.md, certificates.md, iac/, runbooks/, … (← agents/08-infrastructure)
│   │   └── (edge, per the infra)   ← proxy/ · cdn/ · edge/ · load-balancing/ · deploy/ (← respective specialists)
│   ├── 08-documentation/           ← the product's living knowledge (agents/11-documentation)
│   │   ├── documentation-map.md    ← single source of what exists, where it lives and when it was reviewed
│   │   └── (help, API reference, guides — per the product)
│   └── 99-records/                 ← auditable history
│       ├── reviews/                ← reviewer reports + consolidation (by date)
│       ├── audits/                 ← adversarial audits
│       ├── guardians/              ← periodic guardian reports (F9)
│       ├── evolutions/             ← one record per feature evolution (workflows/W10-feature-evolution.md)
│       ├── incidents/              ← incident record + blameless post-mortem (workflows/W11-incident-response.md)
│       ├── quality/ · data/ · backups/ · security/ · ha/ ← per-dimension cycle reports outside the guardians: coverage and data audits, restore proofs, security and high-availability checks (← specs from 06-data, 08-infrastructure, 09-security, 10-quality)
│       ├── gates/                  ← Orchestrator: one record per closed gate — Pn-YYYY-MM-DD.md, or W13-YYYY-MM-DD.md for cross-cutting ones with their own closing condition (templates/project/GATE.md.template): items, evidence, who verified, who approved, waivers
│       ├── genesis.md              ← genesis dossier: the promise's numbers, phase by phase (templates/project/GENESIS.md.template)
│       └── pending-decisions.md    ← Orchestrator: OPTIONAL mirror of pending items — the single source is STATE.md §Pending decisions; if it exists, synced at each phase close
└── (code per the architecture: apps/, packages/, infra/, …)
```

> **Scales with the effort profile:** in a prototype, several subfolders collapse into a single
> file per phase (e.g. `product/00-discovery/dossier.md`). The tree above is the maximum, not the
> minimum — but the **names and IDs** stay, so traceability is not lost when the project grows.

## Flow between phases (who produces → who consumes)

| Artifact | Produced in | Consumed by |
| --- | --- | --- |
| Discovery dossier | F1 | All F2–F4 agents; `cost-estimator` feeds back into F3/F8 |
| Requirements + rules + criteria | F2 | Architecture (F3), Specification (F5), Tests (F6/F7), Reviewers |
| ADRs + stack | F3 | Build (F6), DevOps/Infra (F8), Guardians (F9) |
| Wireframes + design system | F4 | Frontend (F6), ux-reviewer (F7) |
| Functional specification | F5 | **Everything** downstream — it is the source of truth; divergence → spec wins |
| Threat model | F5/F7 | Backend, DevOps, Pentester, Security Guardian |
| Code + tests | F6 | Reviewers (F7), Pipelines (F8), Guardians (F9) |
| Runbooks + SLOs | F8 | Operation (F9), incident response (W11) |
| Guardian reports | F9 | Orchestrator → user; feed back into loops and evolution (W10) |
| Gate records (`product/99-records/gates/`) | each Pn | Reviewers (F7), adversarial audit, `agents/13-guardians/quality-guardian.md`, framework curation; the genesis "1st?" column reads from here |

## Handling rules

Numbered **H1–H6** (not plain §1–§6) precisely because `## Principles` above is also a numbered
list of 5 — two independent lists sharing plain digits made `§4`, say, mean two different things
depending on which list the citing document had in mind. `§N` always means Principles; `§HN`
always means these.

- **H1. Never delete approved artifacts** — they are marked `obsolete` with a pointer to the
  replacement. (Reversibility by default; history is part of the product.)
- **H2. Updating belongs to the owner.** Another agent that needs a change in someone else's
  artifact asks the Orchestrator for it — it does not edit over it.
- **H3. IDs are eternal:** `FR-012` is never reused for another requirement, even if the original
  dies.
- **H4. Code↔spec divergence:** the spec wins. If the code is right and the spec wrong, update the
  spec **first** (with approval) and then the reference code. Record it in `STATE.md`.
- **H5. No secrets in artifacts** — secrets live outside version control
  (`playbooks/secrets-management.md`); artifacts reference them by path, never by value.
- **H6. A spec declares as Output only an artifact it owns in this tree.** Contributions to
  someone else's artifact (a residual risk, an R-nnn risk, a new requirement) are declared as
  "delivered to owner X via the Orchestrator" — only the owner writes. In F7, six specialists
  writing to the same `residual-risk.md` produced duplicate entries and risks without the user's
  sign-off.

## Related

- `core/project-memory.md` — STATE.md and the handover.
- `core/orchestrator.md` — who enforces this protocol.
- `templates/README.md` — templates that instantiate these artifacts.
- `core/quality-gates.md` — states required at each gate.
- `templates/project/GATE.md.template` — the record of every gate passed.
- `templates/technical/agent-briefing.md.template` — the contract between the Orchestrator and an
  agent (briefing/return).
