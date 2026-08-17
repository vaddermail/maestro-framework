# 07 — DevOps (do commit à produção)

Categoria da **fase F8 (Lançamento)** — e presente em F6 (empacotamento) e F9 (operação). Reúne os
especialistas que transformam código verde e revisto num sistema **entregue, repetível e reversível**:
empacotamento em containers, infraestrutura como código, configuração de servidores, fluxo de Git e
pipelines de CI/CD em cada plataforma. Tudo o que aqui se produz é **código versionado** (Dockerfile,
manifests, módulos Terraform, playbooks, workflows de pipeline) — nunca cliques manuais numa consola
que ninguém consegue reproduzir.

Estes agentes decidem **como se constrói, empacota e entrega**; **onde corre** (cloud vs on-prem,
rede, storage, HA) é da `agents/08-infrastructure/README.md`, e **se é seguro** é da
`agents/09-security/README.md`. A fronteira mantém-se nítida para não haver trabalho duplicado.

## Agentes desta categoria

| Agente | Responsabilidade única |
| --- | --- |
| `agents/07-devops/docker-specialist.md` | Imagens mínimas, multi-stage, non-root, reprodutíveis |
| `agents/07-devops/kubernetes-specialist.md` | Workloads, probes, limits, RBAC do cluster — e quando **não** usar k8s |
| `agents/07-devops/terraform-specialist.md` | IaC declarativa: estado, módulos, `plan` revisto antes de `apply` |
| `agents/07-devops/ansible-specialist.md` | Configuração idempotente de servidores; inventários e vault |
| `agents/07-devops/github-specialist.md` | Fluxo Git: branches, PRs, proteções, CODEOWNERS, releases por tag |
| `agents/07-devops/github-actions-specialist.md` | Pipelines no GitHub Actions: caching, matrizes, segredos, ambientes |
| `agents/07-devops/azure-devops-specialist.md` | Azure Pipelines/Boards/Repos: equivalências e especificidades |
| `agents/07-devops/gitlab-ci-specialist.md` | GitLab CI: stages, runners, environments, review apps |
| `agents/07-devops/deployment-strategist.md` | Estratégia de entrega: blue-green/canary/rolling, gates, rollback ensaiado |
| `agents/07-devops/secrets-manager.md` | Segredos em pipelines e runtime: injeção, rotação, zero no Git |
| `agents/07-devops/feature-flags-specialist.md` | Flags de lançamento: exposição gradual, kill-switch, limpeza de flags mortas |
| `agents/07-devops/nginx-specialist.md` | nginx: reverse proxy, TLS, caching, limites e timeouts |
| `agents/07-devops/apache-specialist.md` | Apache httpd: vhosts, proxies, TLS, hardening |
| `agents/07-devops/cdn-specialist.md` | CDN: cache por tipo de rota, invalidação, edge |
| `agents/07-devops/cloudflare-specialist.md` | Cloudflare: DNS, proxy, WAF, regras e page rules |
| `agents/07-devops/load-balancing-specialist.md` | Balanceamento de carga: algoritmos, health checks, sessões |

## Ordem de trabalho recomendada

1. **Empacotar** — `especialista-docker` produz a imagem reprodutível (base do resto).
2. **Escolher plataforma de entrega** — com o utilizador, via `core/decision-engine.md`: a
   plataforma de pipeline (`github-actions` / `azure-devops` / `gitlab-ci`) segue quase sempre o
   alojamento do repositório (decisão do `especialista-github` e da infra escolhida em F3/F8).
3. **Definir o fluxo Git** — `especialista-github` fixa branches, proteções e releases; é pré-requisito
   de qualquer pipeline (a pipeline reage a eventos de Git).
4. **Provisionar** — `especialista-terraform` (recursos cloud/on-prem) e/ou `especialista-ansible`
   (configuração de servidores existentes), consoante o alvo decidido pela `08-infraestrutura/`.
5. **Orquestrar workloads** — `especialista-kubernetes` **só se** a decisão de arquitetura o justificar
   (ver a própria ficha: quando **não** usar k8s).
6. **Automatizar** — a pipeline concreta (`github-actions` / `azure-devops` / `gitlab-ci`) liga
   build → testes → segurança → entrega, consumindo `pipelines/ci-quality.md`, `pipelines/ci-security.md`
   e `pipelines/cd-delivery.md` (que são **agnósticos** de plataforma; estes agentes materializam-nos).

## Como o Orquestrador a convoca

Na fase F8 (`workflows/W08-launch.md`), o `core/orchestrator.md` ativa **apenas** os especialistas
correspondentes às decisões já fechadas em F3 (`product/02-architecture/`) — não se instancia Kubernetes
nem Terraform "por defeito". A escolha entre plataformas concorrentes (GitHub Actions vs Azure DevOps vs
GitLab CI; Terraform vs Ansible vs ambos) faz-se com o utilizador pelo `core/decision-engine.md`, com
ADR (`templates/project/ADR-DECISION.md.template`). A aprovação humana para produção é **indelegável**
(`core/quality-gates.md`).

## Relacionados

- `agents/08-infrastructure/README.md` — onde corre (cloud/on-prem, rede, storage, HA).
- `agents/09-security/README.md` — hardening, scan de containers/infra, segredos.
- `pipelines/README.md` — os pipelines de referência que estes agentes materializam por plataforma.
- `agents/12-reviewers/devops-reviewer.md` — revê pipelines, deploys, rollback e segredos.
- `workflows/W08-launch.md` — o processo de fase que os coordena.
