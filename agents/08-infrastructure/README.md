# 08 — Infrastructure

**Where the product runs.** This category decides and designs the physical/virtual foundation on
which everything else rests: hosting (cloud, on-prem or hybrid), network, TLS, storage, infra
backup and high availability. The question the category answers is "where and on which machines
does this live, at what cost, with what guarantees and with what exit path" — never "which
technology do we use in the code" (that is `agents/02-architecture/`) nor "how do we get the
commit there" (that is `agents/07-devops/`).

## Dominant phase

**F8 — launch** (`workflows/W08-launch.md`). The hosting **decision**, however, is structural and
expensive to reverse, which is why `hosting-arbiter.md` is convened as early as **F3**
(`workflows/W03-architecture.md`), alongside the architecture, and only **executed** in F8.
Storage, network and HA are revisited whenever scale or availability requirements change (F9).

## Agents in this category

| Agent | Type | What it produces |
| --- | --- | --- |
| `agents/08-infrastructure/hosting-arbiter.md` | Arbiter | Hosting ADR (cloud/on-prem/hybrid) by cost, data, team and compliance |
| `agents/08-infrastructure/aws-specialist.md` | Specialist | AWS proposal: needs → services, monthly cost, pitfalls, lock-in |
| `agents/08-infrastructure/azure-specialist.md` | Specialist | Azure proposal (strong when Entra ID / Microsoft 365 is present) |
| `agents/08-infrastructure/google-cloud-specialist.md` | Specialist | GCP proposal (data/analytics, mature Kubernetes) |
| `agents/08-infrastructure/hetzner-specialist.md` | Specialist | Hetzner proposal (European cost/benefit, dedicated servers and cloud) |
| `agents/08-infrastructure/ovh-specialist.md` | Specialist | OVH proposal (European sovereignty, bare-metal, anti-DDoS) |
| `agents/08-infrastructure/digitalocean-specialist.md` | Specialist | DigitalOcean proposal (simplicity first, managed PaaS) |
| `agents/08-infrastructure/on-premises-specialist.md` | Specialist | On-prem proposal: VMs, hypervisors, full responsibility |
| `agents/08-infrastructure/network-architect.md` | Specialist | VPN, firewall, DNS, segmentation, minimal exposure |
| `agents/08-infrastructure/tls-ssl-specialist.md` | Specialist | Certificates, automatic renewal, modern TLS everywhere |
| `agents/08-infrastructure/storage-specialist.md` | Specialist | Block/object/file storage, lifecycles, encryption at rest |
| `agents/08-infrastructure/infra-backup-specialist.md` | Specialist | Infra and configuration backup, tested restore |
| `agents/08-infrastructure/high-availability-architect.md` | Specialist | Redundancy, failover, zones, graceful degradation |

## How the arbiter uses the specialists

`hosting-arbiter.md` **sells no platform** — it applies `core/decision-engine.md`: it frames
the question with weighted criteria (total cost, team competence, compliance/data sovereignty,
reversibility/lock-in, maturity), convenes 2–4 specialists to propose **blind** the mapping of the
product's needs onto their platform (with monthly cost and honest pitfalls), compares and writes
the ADR. Each specialist **evaluates its cloud, does not defend it**: a specialist concluding "for
this case my platform is expensive or excessive" is delivering a valid proposal.

## Recommended order of work

1. **F3 —** `hosting-arbiter` runs the specialist panel → approved hosting ADR.
2. **F8 —** the chosen platform's specialist details the design (network, storage, TLS, HA) in
   coordination with `agents/07-devops/` (IaC, containers, deploy).
3. **F9 —** revisit cost (`agents/13-guardians/cost-guardian.md`) and availability when scale
   changes; any platform switch reopens the ADR (`core/decision-engine.md`).

## How the Orchestrator convenes it

`core/orchestrator.md` builds the graph from the **Inputs**/**Interactions** sections of the agent
specs. The natural entry is the F3 gate requiring an approved hosting ADR before infra
architecture, and the F8 gate (`core/quality-gates.md`) requiring the infra designed, with TLS,
backup and rollback ready, before go-live.

## Related

- `agents/07-devops/` — takes the commit to this infra (IaC, containers, CI/CD, deploy).
- `agents/02-architecture/` — decides the style/stack of the software that runs here.
- `agents/09-security/infrastructure-analyst.md` — audits the designed infra.
- `core/decision-engine.md` · `agents/README.md` · `_meta/INVENTORY.md`
