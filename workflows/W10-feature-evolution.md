# W10 — Evolução de Feature (reentra F2→F8)

> **Disparo:** pedido novo sobre um produto **já em produção** (F9) · **Coordena:**
> `agents/13-guardians/feature-evolution-agent.md` · **Portão de saída:** os portões das
> fases que a fatia tocar (P2…P8), dimensionados ao risco.

## Objetivo

Levar um pedido novo — uma funcionalidade, uma mudança de regra, um campo a mais — da ideia à
produção **reexecutando F2→F8 em miniatura** (`core/lifecycle.md` §regra 4), sem repetir a
descoberta inteira nem partir o que já corre. O produto vivo não pára para cada pedido: cada
evolução é uma **fatia vertical** que atravessa só as fases que precisa, com o rigor proporcional ao
risco que carrega.

## Gatilho e pré-condições (portão de entrada)

- [ ] Produto em F9 (`workflows/W09-continuous-operation.md`) — há uma base estável a evoluir.
- [ ] Pedido registado (não em memória): quem pede, o que quer, porquê. O `agente-de-evolucao-de-features`
      abre `product/99-records/evolutions/EV-nnn.md` com o pedido em bruto.
- [ ] Especificação-mãe (`product/04-specification/`) e `STATE.md` atualizados — é contra eles que se
      mede o impacto. Se a spec está atrasada face ao código, reconcilia-se primeiro
      (`loops/L05-inconsistencies.md`).

## O princípio: proporcionalidade (não são sempre as 6 etapas)

Um pedido pequeno **não** percorre as seis etapas com igual peso. A etapa 1 (impacto) é o que calibra
as restantes: define quantas etapas correm e a que profundidade. A regra de calibração:

| Tamanho | Exemplo | Etapas que corre |
| --- | --- | --- |
| **Trivial** | mudar um label, ajustar um limiar de alerta (SSOT, `modules/single-source-of-content.md`) | 1 (impacto confirma que é trivial) → 4 (fatia) → 6 (release). Sem ADR, sem revisão em painel. |
| **Pequeno** | novo campo opcional num formulário; novo filtro numa lista | 1 → 3 (delta de spec) → 4 → 5 (revisão pelo próprio Orquestrador) → 6. |
| **Médio** | novo tipo de relatório num SaaS; código de cupão num e-commerce | as 6 etapas; revisão em painel parcial (as dimensões tocadas). |
| **Grande / estrutural** | nova fonte de ingestão numa plataforma de dados; mudar a máquina de estados de um fluxo crítico | as 6 + **ADR** (etapa 2) + revisão em painel completo (etapa 5); pode exigir voltar a F3 (arquitetura). |

**Quem classifica não é quem pediu:** o `agente-de-evolucao-de-features` propõe o tamanho no relatório
de impacto e o Orquestrador confirma-o. Em dúvida entre dois tamanhos, sobe-se um (`MANIFESTO.md` §9 —
o máximo escrutínio vai para correção, autorização, dinheiro, dados pessoais e fluxos irreversíveis).

## Passos (etapa → agente → artefacto)

Todos os artefactos de rasto vivem em `product/99-records/evolutions/EV-nnn.md`; os deltas de
conhecimento vivem nas árvores canónicas (`product/01-requirements/`, `product/02-architecture/`,
`product/04-specification/`).

| # | Etapa | Agente | Artefacto | Depende de |
| --- | --- | --- | --- | --- |
| 1 | **Impacto** | `agents/13-guardians/feature-evolution-agent.md` (coordena) + `agents/12-reviewers/architecture-reviewer.md` (fronteiras tocadas) | `EV-nnn.md` §impacto: que **módulos/dados/fluxos** toca, o que pode quebrar, tamanho proposto | pedido |
| 2 | **Decisão** | Orquestrador + utilizador; `core/decision-engine.md` | veredicto (avança / adia / recusa) em `EV-nnn.md`; **ADR** em `product/02-architecture/` se muda arquitetura (`templates/project/ADR-DECISION.md.template`) | 1 |
| 3 | **Especificação (mini-W05)** | `agents/01-requirements/business-rules-modeler.md`, `agents/06-data/data-modeler.md`, `agents/05-backend/api-designer.md` — **só a fatia** | delta em `product/04-specification/` + requisito rastreável em `product/01-requirements/` | 2 |
| 4 | **Implementação (mini-W06)** | `agents/04-frontend/`, `agents/05-backend/`, `agents/06-data/`, `agents/10-quality/` | código + testes da **fatia vertical** (dados→backend→frontend); migração expand-contract se toca dados | 3 |
| 5 | **Revisão proporcional** | painel de `agents/12-reviewers/` **dimensionado ao risco** (etapa 1) | relatórios em `product/99-records/reviews/` + veredicto | 4 |
| 6 | **Release** | `agents/07-devops/deployment-strategist.md` via `playbooks/release-and-rollback.md` | release em produção + `STATE.md` atualizado | 5 |

**Miniaturas, não atalhos.** A etapa 3 é um `workflows/W05-specification.md` reduzido à fatia; a
etapa 4 é um `workflows/W06-build.md` de uma só fatia (as suas regras inegociáveis mantêm-se: a
spec ganha, invariantes na BD, authz no servidor, reversibilidade por fatia). Reduz-se o **âmbito**,
nunca o **rigor** dos portões que se atravessam.

## Pontos de decisão (aprovação humana)

O Orquestrador **para e pergunta** (`core/orchestrator.md` §Aprovação humana):

- **Etapa 2 — vale a pena?** A decisão de avançar/adiar/recusar é do utilizador: é âmbito e é dinheiro
  (esforço). Um "já agora" do agente não vira feature (`knowledge/ai-pitfalls.md` §5).
- **Etapa 2 — reabre decisão fechada?** Se o pedido contraria uma decisão fechada
  (`core/decision-engine.md` §Decisões fechadas), avisa-se **porquê está fechada** antes de reabrir.
- **Etapa 4 — toca dados pessoais/sensíveis** de forma nova, ou exige migração destrutiva → aprovação
  explícita com plano item a item (`core/quality-gates.md`).
- **Etapa 6 — produção** → aprovação humana sempre (P8), nunca delegável.

Perguntas em **lote** por etapa, nunca à peça (`core/question-engine.md`).

## Loops que abre

- `loops/L02-failing-tests.md` e `loops/L04-code-smells.md` — dentro da etapa 4 (idênticos a F6).
- `loops/L05-inconsistencies.md` — se a etapa 1 revela que a spec-mãe já diverge do código, reconcilia-se
  **antes** de medir impacto sobre uma base falsa.
- `loops/L08-technical-debt.md` — o que se decide não fazer nesta evolução regista-se como dívida, não
  se esconde (`core/quality-gates.md`).

## Portão de saída (condição de fecho verificável)

A evolução **fecha** quando:

- [ ] A fatia passou os portões das fases que tocou (P2/P5 se houve delta de spec; **P6** por fatia —
      `checklists/definition-of-done.md` + `checklists/pre-merge.md`; P8 no release).
- [ ] **Prova-live real** em produção: o pedido original foi exercitado e observado a funcionar
      (`knowledge/ai-pitfalls.md` §2 — "testes verdes" não é prova).
- [ ] Rollback ensaiado e disponível (`playbooks/release-and-rollback.md`); mudança de risco atrás de
      flag desligável (`modules/feature-flags.md`).
- [ ] `EV-nnn.md` fechado (o que se fez, o que ficou para trás e porquê) e `STATE.md` atualizado.

**Quem verifica:** o Orquestrador (portões formais) + o painel da etapa 5 (substância). **Quem aprova
o release:** o utilizador.

## Recuperação de falhas

| Situação | Resposta |
| --- | --- |
| Etapa 1 revela impacto muito maior do que o pedido sugeria (estrutural) | Reclassificar como **grande**; se toca arquitetura, devolver a F3 (`workflows/W03-architecture.md`) com ADR — voltar atrás é normal (`core/lifecycle.md` §2). |
| Ao construir (etapa 4) descobre-se que a spec da fatia está errada | Parar, corrigir a spec primeiro (etapa 3), **depois** o código — nunca corrigir contra a spec em silêncio (`knowledge/ai-pitfalls.md` §7). |
| Release (etapa 6) degrada produção | Reverter primeiro (flag/rollback), diagnosticar depois: abre-se `workflows/W11-incident-response.md`. |
| Pedidos a acumular mais depressa do que se entregam | Não paralelizar fatias que partilham a entidade central; priorizar com o utilizador (valor × esforço × risco). |

## Perfis de esforço

| Perfil | Como muda |
| --- | --- |
| **Protótipo** | Quase tudo é "trivial/pequeno"; etapa 5 pelo próprio Orquestrador; prova-live continua obrigatória. |
| **Produto interno** | Médios em painel parcial; ADR só para estrutural. |
| **Produto comercial / Plataforma** | Estruturais sempre com ADR + painel completo; registo de consumo de IA por fatia; auditoria adversarial se a evolução toca um fluxo crítico. |

## Relacionados

- `agents/13-guardians/feature-evolution-agent.md` — o coordenador desta reentrada.
- `core/lifecycle.md` — a regra 4 (F9 → reentrada F2→F8 em miniatura).
- `workflows/W05-specification.md` · `workflows/W06-build.md` — as fases que se miniaturizam.
- `workflows/W08-launch.md` · `playbooks/release-and-rollback.md` — o release da fatia.
- `workflows/W11-incident-response.md` — quando um release corre mal.
- `core/decision-engine.md` — a decisão da etapa 2 e as decisões fechadas.
