# 07 — DevOps (from commit to production)

Category of **phase F8 (Launch)** — also present in F6 (packaging) and F9 (operation). It gathers
the specialists who turn green, reviewed code into a system that is **delivered, repeatable and
reversible**: packaging into containers, infrastructure as code, server configuration, Git flow and
CI/CD pipelines on each platform. Everything produced here is **versioned code** (Dockerfile,
manifests, Terraform modules, playbooks, pipeline workflows) — never manual clicks in a console
nobody can reproduce.

These agents decide **how it is built, packaged and delivered**; **where it runs** (cloud vs
on-prem, network, storage, HA) belongs to `agents/08-infrastructure/README.md`, and **whether it is
secure** belongs to `agents/09-security/README.md`. The boundary stays sharp so no work is
duplicated.

## Agents in this category

| Agent | Single responsibility |
| --- | --- |
| `agents/07-devops/docker-specialist.md` | Minimal, multi-stage, non-root, reproducible images |
| `agents/07-devops/kubernetes-specialist.md` | Workloads, probes, limits, cluster RBAC — and when **not** to use k8s |
| `agents/07-devops/terraform-specialist.md` | Declarative IaC: state, modules, `plan` reviewed before `apply` |
| `agents/07-devops/ansible-specialist.md` | Idempotent server configuration; inventories and vault |
| `agents/07-devops/github-specialist.md` | Git flow: branches, PRs, protections, CODEOWNERS, tag-based releases |
| `agents/07-devops/github-actions-specialist.md` | GitHub Actions pipelines: caching, matrices, secrets, environments |
| `agents/07-devops/azure-devops-specialist.md` | Azure Pipelines/Boards/Repos: equivalences and specifics |
| `agents/07-devops/gitlab-ci-specialist.md` | GitLab CI: stages, runners, environments, review apps |
| `agents/07-devops/deployment-strategist.md` | Delivery strategy: blue-green/canary/rolling, gates, rehearsed rollback |
| `agents/07-devops/secrets-manager.md` | Secrets in pipelines and runtime: injection, rotation, zero in Git |
| `agents/07-devops/feature-flags-specialist.md` | Launch flags: gradual exposure, kill switch, dead-flag cleanup |
| `agents/07-devops/nginx-specialist.md` | nginx: reverse proxy, TLS, caching, limits and timeouts |
| `agents/07-devops/apache-specialist.md` | Apache httpd: vhosts, proxies, TLS, hardening |
| `agents/07-devops/cdn-specialist.md` | CDN: caching per route type, invalidation, edge |
| `agents/07-devops/cloudflare-specialist.md` | Cloudflare: DNS, proxy, WAF, rules and page rules |
| `agents/07-devops/load-balancing-specialist.md` | Load balancing: algorithms, health checks, sessions |

## Recommended order of work

1. **Package** — the `docker-specialist` produces the reproducible image (the base for the rest).
2. **Choose the delivery platform** — with the user, via `core/decision-engine.md`: the pipeline
   platform (`github-actions` / `azure-devops` / `gitlab-ci`) almost always follows the repository
   hosting (a decision of the `github-specialist` and of the infra chosen in F3/F8).
3. **Define the Git flow** — the `github-specialist` fixes branches, protections and releases; it
   is a prerequisite for any pipeline (the pipeline reacts to Git events).
4. **Provision** — `terraform-specialist` (cloud/on-prem resources) and/or `ansible-specialist`
   (configuration of existing servers), depending on the target decided by `08-infrastructure/`.
5. **Orchestrate workloads** — `kubernetes-specialist` **only if** the architecture decision
   justifies it (see its own spec: when **not** to use k8s).
6. **Automate** — the concrete pipeline (`github-actions` / `azure-devops` / `gitlab-ci`) wires
   build → tests → security → delivery, consuming `pipelines/ci-quality.md`,
   `pipelines/ci-security.md` and `pipelines/cd-delivery.md` (which are platform-**agnostic**;
   these agents materialize them).

## How the Orchestrator convenes it

In phase F8 (`workflows/W08-launch.md`), the `core/orchestrator.md` activates **only** the
specialists matching the decisions already closed in F3 (`product/02-architecture/`) — Kubernetes
and Terraform are not instantiated "by default". The choice between competing platforms (GitHub
Actions vs Azure DevOps vs GitLab CI; Terraform vs Ansible vs both) is made with the user through
`core/decision-engine.md`, with an ADR (`templates/project/ADR-DECISION.md.template`). Human
approval for production is **non-delegable** (`core/quality-gates.md`).

## Related

- `agents/08-infrastructure/README.md` — where it runs (cloud/on-prem, network, storage, HA).
- `agents/09-security/README.md` — hardening, container/infra scanning, secrets.
- `pipelines/README.md` — the reference pipelines these agents materialize per platform.
- `agents/12-reviewers/devops-reviewer.md` — reviews pipelines, deploys, rollback and secrets.
- `workflows/W08-launch.md` — the phase process that coordinates them.
