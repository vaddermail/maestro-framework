# Ciclo de Vida do Produto (F0–F9)

O ciclo de vida é a espinha dorsal da framework: dez fases, da ideia à operação perpétua. Cada fase
tem um **workflow** que a executa, **agentes** que trabalham nela, **artefactos** que produz e um
**portão de qualidade** que decide a passagem à seguinte (`core/quality-gates.md`).

```
F0 Arranque
└─▶ F1 Descoberta ─▶ F2 Requisitos ─▶ F3 Arquitetura ─▶ F4 Experiência ─▶ F5 Especificação
                                                                              │
        ┌─────────────────────────────────────────────────────────────────────┘
        ▼
    F6 Construção ─▶ F7 Qualidade & Segurança ─▶ F8 Lançamento ─▶ F9 Operação contínua ──▶ ∞
                                                                        │
                                              (pedidos novos) ◀─────────┘
                                              W10-evolucao-de-feature reentra em F2–F8 em miniatura
```

## Regras do ciclo

1. **Sem saltos.** Nenhuma fase se salta — dimensiona-se. O perfil de esforço
   (`core/orchestrator.md` §Perfis) decide a profundidade: num protótipo, F1–F5 podem caber num
   dia; numa plataforma empresarial, são semanas. Mas um portão nunca se atravessa por pressa.
2. **Voltar atrás é normal; avançar sem portão não é.** Descobrir em F5 que falta um requisito
   devolve trabalho a F2 — isso é o processo a funcionar. Registar a razão em `STATE.md`.
3. **Iteração dentro da fase é livre.** Os loops (`loops/`) correm dentro das fases até a condição
   de saída fechar.
4. **F9 não acaba.** A operação contínua dura a vida do produto. Pedidos novos entram por
   `workflows/W10-feature-evolution.md`, que reexecuta F2→F8 em miniatura para cada feature.
5. **Transversais sempre ativos:** memória (`core/project-memory.md`), motor de perguntas
   (`core/question-engine.md`), segurança (o `agents/09-security/security-coordinator.md`
   tem assento em todas as fases — segurança não é uma fase, é uma dimensão).

## As fases

### F0 — Arranque

- **Objetivo:** fundação do projeto: memória instanciada, perfil de esforço calibrado, ideia bruta registada.
- **Workflow:** `workflows/W00-project-kickoff.md`
- **Agentes:** o Orquestrador em pessoa (`core/orchestrator.md`).
- **Artefactos:** `STATE.md`, `CLAUDE.md` (ou equivalente), árvore `product/`.
- **Portão:** memória criada + perfil de esforço confirmado pelo utilizador.

### F1 — Descoberta

- **Objetivo:** perceber o problema antes da solução: stakeholders, personas, casos de utilização,
  objetivos, KPIs, riscos, custos, roadmap, MVP.
- **Workflow:** `workflows/W01-discovery.md`
- **Agentes:** `agents/00-discovery/` (12 especialistas).
- **Artefactos:** `product/00-discovery/` (dossier completo).
- **Portão:** dossier de descoberta validado pelo utilizador; MVP e prioridades aprovados;
  nenhuma lacuna crítica aberta.

### F2 — Requisitos

- **Objetivo:** transformar a descoberta em requisitos rastreáveis, regras de negócio explícitas e
  critérios de aceitação verificáveis — **sem ambiguidades**.
- **Workflow:** `workflows/W02-requirements.md`
- **Agentes:** `agents/01-requirements/` (6 especialistas); loop `loops/L01-ambiguous-requirements.md`.
- **Artefactos:** `product/01-requirements/`.
- **Portão:** zero ambiguidades **críticas** (não-críticas registadas com risco aceite); RNF
  quantificados; regras de negócio numeradas e aprovadas.

### F3 — Arquitetura

- **Objetivo:** decidir como se constrói: estilo arquitetural (em painel de especialistas com
  árbitro), stack concreta (versões estáveis), integrações e fronteiras.
- **Workflow:** `workflows/W03-architecture.md`
- **Agentes:** `agents/02-architecture/` (árbitro + 11 especialistas + selecionador de stack);
  motores em `core/decision-engine.md`.
- **Artefactos:** `product/02-architecture/` (visão + ADRs + stack).
- **Portão:** ADRs escritos com alternativas e reversibilidade; stack fixada; utilizador validou
  custos e trade-offs em linguagem simples.

### F4 — Experiência (UX/UI)

- **Objetivo:** desenhar a experiência antes do código: fluxos, wireframes, design system (tokens),
  mapa de ecrãs, acessibilidade e responsividade planeadas.
- **Workflow:** `workflows/W04-experience.md`
- **Agentes:** `agents/03-experience/` (10 especialistas).
- **Artefactos:** `product/03-experience/`.
- **Portão:** utilizador validou wireframes dos fluxos críticos; design system com tokens definidos;
  requisitos de acessibilidade aceites.

### F5 — Especificação

- **Objetivo:** a fonte de verdade funcional canónica, agnóstica de tecnologia: regras de negócio
  por módulo, fluxos críticos, máquinas de estado, modelo de dados lógico, contrato do backend.
  É o documento que sobrevive a reescritas do código.
- **Workflow:** `workflows/W05-specification.md`
- **Agentes:** `agents/01-requirements/business-rules-modeler.md`,
  `agents/06-data/data-modeler.md`, `agents/05-backend/api-designer.md`,
  `agents/09-security/threat-modeler.md`, coordenados pelo Orquestrador.
- **Artefactos:** `product/04-specification/` (specs por módulo + transversais).
- **Portão:** especificação revista pelo `agents/12-reviewers/review-consolidator.md` (painel
  mínimo: arquitetura + segurança + UX) e aprovada pelo utilizador. **Só aqui se desbloqueia código.**

### F6 — Construção

- **Objetivo:** construir em fatias verticais (dados → backend → frontend por funcionalidade),
  cada fatia com testes, seguindo a especificação. Divergência da spec → a spec ganha ou
  atualiza-se a spec primeiro.
- **Workflow:** `workflows/W06-build.md`
- **Agentes:** `agents/04-frontend/`, `agents/05-backend/`, `agents/06-data/`,
  `agents/10-quality/`; loops L02/L04/L05.
- **Artefactos:** código + testes + `product/99-records/` (progresso por fatia em `STATE.md`).
- **Portão por fatia:** `checklists/definition-of-done.md` + `checklists/pre-merge.md`.
- **Portão da fase:** MVP completo contra a especificação; harness de regressão verde.

### F7 — Qualidade & Segurança

- **Objetivo:** escrutínio independente antes do mundo real: painel de revisores, auditoria
  adversarial, pentest, verificação de performance e acessibilidade.
- **Workflow:** `workflows/W07-quality-and-security.md` (usa `workflows/W12-global-review.md`)
- **Agentes:** `agents/12-reviewers/` (painel completo), `agents/09-security/pentester.md`,
  `playbooks/adversarial-audit.md`.
- **Artefactos:** `product/99-records/reviews/` + plano consolidado de correções.
- **Portão:** zero achados críticos/altos por resolver; `checklists/pre-production-security.md`
  completa; decisões de risco residual assinadas pelo utilizador.

### F8 — Lançamento

- **Objetivo:** pôr em produção com rede: infra provisionada, pipelines a funcionar, backups e
  rollback ensaiados, monitorização ligada.
- **Workflow:** `workflows/W08-launch.md`
- **Agentes:** `agents/07-devops/`, `agents/08-infrastructure/`; pipelines de `pipelines/`.
- **Artefactos:** `product/07-operations/` (runbooks, SLOs, plano DR) + infra como código.
- **Portão:** `checklists/go-live.md` completa; **aprovação humana explícita para produção**
  (nunca delegável a agentes).

### F9 — Operação contínua

- **Objetivo:** manter o produto saudável para sempre: guardiões em cadência, loops de manutenção,
  resposta a incidentes, evolução de features.
- **Workflow:** `workflows/W09-continuous-operation.md` (+ W10 evolução, W11 incidentes)
- **Agentes:** `agents/13-guardians/` (equipa permanente de 8).
- **Artefactos:** relatórios de guardiões em `product/99-records/guardians/`, post-mortems,
  `STATE.md` sempre vivo.
- **Portão:** não há — há **cadências** (diária/semanal/mensal, definidas em
  `agents/13-guardians/README.md`) e os loops L02–L08 sempre armados.

## Relacionados

- `core/orchestrator.md` — quem conduz o ciclo.
- `core/quality-gates.md` — o detalhe dos portões.
- `core/artifact-protocol.md` — a árvore `product/` completa.
- `workflows/README.md` — convenções dos workflows.
