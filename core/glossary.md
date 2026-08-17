# Framework Glossary

Terms with a precise meaning inside Maestro. When in doubt in another document, the definition
here prevails.

| Term | Definition |
| --- | --- |
| **Agent** | A specialized AI role with a single responsibility, defined by an agent spec (`agents/_template/AGENT-TEMPLATE.md`): objective, inputs, outputs, rules, limitations, workflow, examples, good practices, anti-patterns. |
| **Agent spec** | The document that defines an agent. The spec is the agent — there is no behavior outside it. |
| **Orchestrator** | The role the main session assumes to coordinate agents, phases and gates (`core/orchestrator.md`). |
| **Arbiter** | Agent that decides between independent specialist proposals, against explicit criteria, producing an ADR (`core/decision-engine.md`). Never one of the proponents. |
| **Reviewer** | Agent that examines someone else's work along one dimension (security, UX, …) and produces a report. Whoever produces never reviews their own work. |
| **Guardian** | Continuous-operation agent (F9) with its own cadence: monitors one dimension of the product in production and proposes/executes fixes (`agents/13-guardians/`). |
| **Coordinator** | Cross-cutting agent that follows one dimension across several phases (e.g. `agents/09-security/security-coordinator.md`). |
| **Artifact** | File with an owner, a state and consumers, produced by an agent in the `product/` tree (`core/artifact-protocol.md`). The unit of collaboration. |
| **Phase (F0–F9)** | Stage of the product lifecycle (`core/lifecycle.md`). |
| **Gate (quality gate)** | Binary, verifiable decision that guards a transition; with defined criteria, verifier and approver (`core/quality-gates.md`). |
| **Workflow (Wnn)** | Documented process that links agents and artifacts to fulfill a phase or a cross-cutting process (`workflows/`). |
| **Loop (Lnn)** | "While condition → act" cycle, with an exit condition and an anti-infinite safeguard (`loops/`). |
| **Module** | Reusable, decoupled product capability, documented stack-agnostically (`modules/`). |
| **Playbook** | Step-by-step operational procedure for a concrete situation (`playbooks/`). |
| **Checklist** | List of verifiable criteria used in gates and reviews (`checklists/`). |
| **Template** | Document ready to instantiate in a project, with `{{like-this}}` placeholders (`templates/`). |
| **ADR** | Architecture Decision Record — record of a structural decision: context, options, decision, consequences, reversal (`core/decision-engine.md`). |
| **Closed decision** | Decision validated by the user that agents do not reopen without material news — and never silently. |
| **Pending decision** | Question awaiting the user, recorded in `STATE.md` with what it blocks. |
| **Effort profile** | Calibration of the process to project size/risk (prototype → enterprise platform); it sizes gates, never removes them (`core/orchestrator.md`). |
| **Dossier** | The set of artifacts of one phase (e.g. discovery dossier = `product/00-discovery/`). |
| **Vertical slice** | Unit of build in F6: one complete feature (data → backend → frontend → tests) delivered end to end. |
| **Source of truth (SSOT)** | The single place where a fact is edited; everything else derives from it. Applies to data, labels, contracts and documentation. |
| **Invariant** | Domain property that can never be violated (e.g. "one asset, one owner"); cataloged in the spec and enforced in the server/DB. |
| **State machine** | Explicit modeling of a lifecycle: states, allowed transitions, effects; invalid transitions are rejected on the server (`modules/state-machines.md`). |
| **Expand-contract** | Reversible migration strategy: first add (expand), migrate data/code, only then remove the old (contract) (`playbooks/expand-contract-db-migration.md`). |
| **Kill-switch** | Switch that turns off a feature/model/integration without a deploy; the same primitive cuts risk and cuts cost (`modules/feature-flags.md`). |
| **Adversarial audit** | Independent verification that actively tries to refute the conclusions instead of confirming them (`playbooks/adversarial-audit.md`). |
| **Live proof** | Verification on the real running system (not just green tests) — an irreplaceable gate before declaring "it works". |
| **Provenance** | Record of the origin of a rule/datum (which defect/decision/source created it); mandatory for data touched by AI. |
| **Model tier** | AI model capability/cost level (top/standard/economy/mechanical) assigned per task (`core/model-routing.md`). |
| **Effort** | The second axis of AI cost, orthogonal to the model: how much reasoning is requested per task. |
| **Grounding** | Giving an AI the source of truth (help content, specs) as the factual basis for its answers, instead of letting it invent (`modules/single-source-of-content.md`). |
| **Ledger (credits)** | Immutable record of credit consumption/top-up movements; the balance is derived, never edited (`modules/credit-management.md`). |
| **Scoping** | Restriction of *which subset of data* a profile sees/operates on (by organizational unit, project, …). A distinct axis from **authorization** (which *actions* it may take) — collapsing them creates bugs in both directions (`modules/rbac-and-scoping.md`). |
| **Runbook** | Tested operational guide for a production procedure (deploy, restore, incident). |
| **Post-mortem** | Blameless incident analysis: timeline, causes, actions with an owner (`templates/technical/post-mortem.md.template`). |
| **RTO / RPO** | Recovery Time/Point Objective — how much downtime and how much data loss are tolerable (`agents/06-data/disaster-recovery-planner.md`). |
| **Upstream framework** | Maestro's origin repository, where the framework evolves by SemVer; projects work on copies and re-sync deliberately (`_meta/VERSION.md`, `playbooks/sync-framework.md`). |
| **Improvement report** | The consolidated, sanitized submission of a project's `FRAMEWORK-IMPROVEMENTS.md` to the upstream framework, as an issue with the `improvements` label (`playbooks/report-framework-improvements.md`). |
| **Candidate** | Lesson/pattern reported by a project, awaiting a second confirmation before being promoted into the framework (`knowledge/candidates.md`). |
| **Curation (of the framework)** | The process that turns improvement reports into curated framework evolution — triage, candidates, promotions via PR with human merge (`playbooks/framework-curation.md`, `agents/14-meta/framework-curator.md`). |
| **Genesis dossier** | The phase-by-phase record of a project's numbers (AI cost, days, findings, rework) that prove — or disprove — the framework's promise (`templates/project/GENESIS.md.template`). |
| **Learning curve (of the ecosystem)** | The aggregation of the genesis dossiers, product by product and by code, maintained by curation (`knowledge/learning-curve.md`); where you read whether each product really came out cheaper and better. |

## Related

- `_meta/STYLE-GUIDE.md` — writing conventions that use these terms.
- `core/artifact-protocol.md` — artifact IDs and states (`FR-nnn`, `BR-nnn`, `P-nnn`, …).
