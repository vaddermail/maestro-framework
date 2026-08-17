# W08 — Lançamento (Fase F8)

Pôr o produto em produção **com rede**: infra provisionada por código, pipelines a correr verdes,
backups verificados, rollback ensaiado e monitorização ligada — para que o go-live seja um evento
**reversível e observável**, não um salto de fé. É a fase onde a `knowledge/permanent-rules.md`
§reversibilidade pesa mais: nada vai para produção sem caminho de volta e sem backup prévio.

> **Fase:** F8 · **Portão de entrada:** P7 (qualidade & segurança limpas; risco residual assinado)
> · **Portão de saída:** P8 (produção com rollback ensaiado — **aprovação humana sempre**)
> · **Workflow anterior:** `workflows/W07-quality-and-security.md` · **seguinte:** `workflows/W09-continuous-operation.md`

## Objetivo

Levar o MVP verificado a produção de forma controlada e documentada: infra como código, entrega
automatizada, operação pronta a receber a fase F9. No fim, o produto está **vivo, monitorizado e
reversível**, e a equipa tem runbooks para o operar.

## Pré-condições (portão de entrada)

- [ ] P7 passou: plano consolidado limpo, `checklists/pre-production-security.md` completa,
      `product/05-security/residual-risk.md` assinado.
- [ ] ADRs de F3 fixados, incluindo a **decisão de alojamento** (`agents/08-infrastructure/hosting-arbiter.md`)
      e a stack em versões estáveis (`product/02-architecture/stack.md`).
- [ ] Pipelines de qualidade e segurança já verdes desde F6 (`pipelines/ci-quality.md`,
      `pipelines/ci-security.md`).
- [ ] Segredos de produção **fora do Git**, num vault ou store próprio (`playbooks/secrets-management.md`).

## Passos (agente → artefacto)

Infra primeiro, depois entrega, depois operação, e só então o go-live. Artefactos de operação vivem em
`product/07-operations/`; a infra como código vive no repositório (`infra/`).

| # | Agente | Artefacto | Depende de |
| --- | --- | --- | --- |
| 1 | `agents/08-infrastructure/` (o especialista da cloud/on-prem decidida: `especialista-aws.md` / `especialista-azure.md` / `especialista-hetzner.md` / `especialista-on-premises.md` …) + `agents/07-devops/terraform-specialist.md` | infra como código em `infra/`; rede, TLS e storage (`arquiteto-de-rede.md`, `especialista-tls-ssl.md`, `especialista-de-storage.md`) | decisão de alojamento (F3) |
| 2 | `agents/06-data/backup-specialist.md` + `agents/08-infrastructure/infra-backup-specialist.md` + `agents/06-data/disaster-recovery-planner.md` | `product/07-operations/dr-plan.md` (RTO/RPO) + backups configurados **e restauro testado** | 1 |
| 3 | `agents/07-devops/` (`especialista-github-actions.md` / `especialista-gitlab-ci.md` / `especialista-azure-devops.md`) | `pipelines/cd-delivery.md` instanciada: ambientes, aprovações, blue-green/canary, rollback automático | 1 |
| 4 | `agents/05-backend/observability-architect.md` (+ `especialista-de-metricas.md`, `especialista-de-logging.md`) | `product/07-operations/observability.md` + `slos.md`; alertas acionáveis ligados | 1 |
| 5 | `agents/11-documentation/documentation-architect.md` + `redator-tecnico.md` | `product/07-operations/runbooks/` (molde `templates/technical/runbook.md.template`) | 2–4 |
| 6 | `agents/07-devops/deployment-strategist.md` conduz o **go-live**: `checklists/go-live.md` + `playbooks/release-and-rollback.md` | release em produção + registo em `STATE.md` | 1–5 |

**Regra de ouro do passo 6 (`playbooks/release-and-rollback.md`, `agents/07-devops/deployment-strategist.md`):**
**backup antes**, estado de reversão pronto, **rollback ensaiado** (não só documentado — executado em
staging), e **hard-block contra a infra errada** — a pipeline recusa aplicar se o alvo não bate certo,
para não se lançar produção sobre o ambiente enganado. A migração de BD que acompanhe o release é
**expand-contract** (`playbooks/expand-contract-db-migration.md`): aditiva primeiro, nunca largar o
que está em uso no mesmo passo.

> **Escala ao perfil:** num protótipo pode não haver produção real (o "lançamento" é publicar o
> ficheiro estático) e o passo 3 reduz-se a um deploy manual documentado; numa plataforma empresarial
> há blue-green/canary, DR **exercitado** e alta disponibilidade (`agents/08-infrastructure/high-availability-architect.md`).

## Pontos de decisão

- **Aprovação humana obrigatória (P8) — sempre, nunca delegável a agentes:** ir para produção é
  decisão do utilizador (`core/orchestrator.md` §Aprovação humana, `core/quality-gates.md`).
  O Orquestrador prepara tudo e **para** à porta da produção.
- **Gastar dinheiro / assumir compromissos:** provisionar infra paga, contratar serviços ou domínios
  é decisão do utilizador — apresenta-se o custo em linguagem simples antes de aplicar.
- **Janela e estratégia de release:** blue-green vs canary vs big-bang, e a janela de menor impacto,
  sobem ao utilizador (`core/decision-engine.md`) quando afetam disponibilidade.

Exemplo multi-domínio: um **e-commerce** escolhe canary a 5% do tráfego numa janela fora do pico e um
kill-switch por feature flag para a nova checkout; um **SaaS B2B** faz blue-green com migração
expand-contract para não haver downtime por tenant; uma **app interna** aceita uma janela de manutenção
anunciada e um deploy simples, desde que o backup e o rollback estejam prontos.

## Loops que abre

- `loops/L03-security-issues.md` — se um scan de última hora (headers, TLS, segredos) acusar,
  resolve-se por severidade **antes** do go-live; não se lança com bloqueador de segurança aberto.
- `loops/L02-failing-tests.md` — o smoke test pós-deploy tem de ficar verde; vermelho aciona rollback,
  não "vê-se amanhã".

## Portão de saída (P8)

`core/quality-gates.md`:

- [ ] `checklists/go-live.md` **completa**: backups verificados, **rollback ensaiado**, monitorização e
      alertas ativos, donos contactáveis, runbooks escritos.
- [ ] Infra como código aplicada e reprodutível; segredos injetados em runtime, nunca no repositório.
- [ ] **Smoke test live real** verde em produção (`knowledge/ai-pitfalls.md` §2 — testado ≠
      "funciona"; anexa-se o output).
- [ ] `product/07-operations/` completo (runbooks, SLOs, observabilidade, plano DR).
- [ ] **Aprovação humana explícita para produção** registada em `STATE.md`.

**Quem verifica:** o Orquestrador (completude) + a pipeline (verde). **Quem aprova:** o utilizador,
**sempre**. Com P8 fechado, o produto entra em `workflows/W09-continuous-operation.md` (F9) e os guardiões
ativam-se.

## Perfis de esforço

| Perfil | Como muda |
| --- | --- |
| **Protótipo** | Sem produção real ou deploy manual documentado; backup/rollback triviais mas presentes; guardiões desativados até decisão de continuar. |
| **Produto interno** | Pipeline de entrega simples; backups diários com um restauro testado; monitorização essencial e alertas básicos. |
| **Produto comercial** | Blue-green/canary; rollback automático; SLOs formais; on-call definido antes do go-live. |
| **Plataforma empresarial** | + alta disponibilidade multi-zona, **DR exercitado** (não só planeado), IaC revista em PR, aprovações de ambiente na pipeline. |

## Anti-padrões

- ❌ Deploy sem backup nem rollback ("depois vê-se") → ✅ backup antes, reversão ensaiada.
- ❌ Segredos no repositório ou nos logs → ✅ vault + injeção em runtime (`playbooks/secrets-management.md`).
- ❌ Migração que larga/renomeia o que está em uso no mesmo passo → ✅ expand-contract.
- ❌ "Deploy verde na pipeline, logo está bom" sem smoke live → ✅ prova real em produção é gate.
- ❌ Agente a declarar produção sozinho → ✅ aprovação humana explícita, sempre.

## Relacionados

- `agents/08-infrastructure/README.md` — onde corre; a decisão de alojamento.
- `agents/07-devops/README.md` — do commit à produção; deploy/rollback/segredos.
- `pipelines/README.md` · `pipelines/ci-quality.md` · `pipelines/ci-security.md` · `pipelines/cd-delivery.md`
- `checklists/go-live.md` · `playbooks/release-and-rollback.md` · `playbooks/expand-contract-db-migration.md`
- `core/quality-gates.md` — P8 em detalhe.
- `workflows/W07-quality-and-security.md` (de onde vem) · `workflows/W09-continuous-operation.md` (para onde vai).
