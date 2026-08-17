# W01 — Descoberta (F1)

> **Fase:** F1 · **Portão de saída:** P1 · **Agentes-núcleo:** `agents/00-discovery/` (12
> especialistas), conduzidos pelo `core/orchestrator.md`.

## Objetivo

Transformar a ideia bruta (registada em F0) num **dossier de descoberta aprovado**: o problema
nítido, quem o vive, o que se quer alcançar, como se mede o sucesso, o que custa, o que arrisca e o
que entra no MVP. **Sem decidir nada sobre a solução** — tecnologia, ecrãs e arquitetura ficam para
F3+. É a fase em que "nunca assumir — perguntar" (`MANIFESTO.md` §2) pesa mais: cada pressuposto não
validado aqui vira defeito caro adiante (`knowledge/ai-pitfalls.md` §3).

## Pré-condições (portão de entrada)

- [ ] P0 fechado: memória instanciada, perfil de esforço fixado, ideia bruta em `STATE.md`.
- [ ] Utilizador disponível para responder a lotes de perguntas (a descoberta é intensiva em Q&A).

## Passos (agente → artefacto)

A descoberta é uma cadeia com dependências reais (`agents/00-discovery/README.md` §Ordem). Todos os
artefactos vivem em `product/00-discovery/`.

| # | Agente | Artefacto | Depende de |
| --- | --- | --- | --- |
| 1 | `agents/00-discovery/idea-analyst.md` | `ideia.md` (é/não-é, pressupostos, perguntas-âncora) | ideia bruta (F0) |
| 2 | `agents/00-discovery/problem-definer.md` | `problema.md` (problema real, público, custo de não resolver) | 1 |
| 3 | `agents/00-discovery/stakeholder-mapper.md` | `stakeholders.md` (papéis, poder/interesse, canais) | 2 |
| 4 | `agents/00-discovery/persona-builder.md` | `personas/` (uma por persona) | 3 |
| 5 | `agents/00-discovery/use-case-modeler.md` | `casos-de-utilizacao/` (`CU-nnn`, jornadas ponta a ponta) | 4 |
| 6 | `agents/00-discovery/business-goals-analyst.md` | `objetivos-e-kpis.md` (objetivos + restrições) | 2 |
| 7 | `agents/00-discovery/kpi-definer.md` | `objetivos-e-kpis.md` (KPIs por objetivo, baseline→alvo) | 6 |
| 8 | `agents/00-discovery/roadmap-planner.md` | `roadmap.md` (horizontes, incl. futuro) | 5,7 |
| 9 | `agents/00-discovery/risk-analyst.md` | `riscos.md` (`R-nnn`, mitigação e dono) | 2,5 |
| 10 | `agents/00-discovery/cost-estimator.md` | `custos.md` (construção, infra, IA, operação — ordem de grandeza) | 8 |
| 11 | `agents/00-discovery/mvp-scoper.md` | `mvp.md` (mínimo demonstrável + cortes explícitos) | 5,12 |
| 12 | `agents/00-discovery/prioritizer.md` | `prioridades.md` (valor × esforço × risco) | 5,9 |

**Paralelismo (`core/orchestrator.md` §Paralelismo):** os passos 3–4 (stakeholders/personas) e 6–7
(objetivos/KPIs) podem correr no mesmo lote de perguntas; riscos (9) corre em paralelo com objetivos.
O MVP (11) precisa de casos de utilização priorizados (12). O Orquestrador monta o grafo pelas
secções **Inputs**/**Interações** das fichas, não pela numeração cega.

> **Escala ao perfil:** num protótipo, todos estes artefactos colapsam num único
> `product/00-discovery/dossier.md` — os **títulos de secção e os IDs** (`CU-nnn`, `R-nnn`)
> mantêm-se (`core/artifact-protocol.md`).

## Pontos de decisão

Todas as lacunas sobem ao Orquestrador, que as agrupa em **lotes por tema** (nunca à peça —
`core/question-engine.md`). Lotes típicos de F1:

- **Problema e público** — quem sente a dor, com que frequência, quanto custa hoje não resolver.
- **Âmbito e prioridade** — o que é essencial vs desejável; o MVP.
- **Objetivos e sucesso** — o que a organização quer alcançar e como saberá que conseguiu (baseline).
- **Restrições e riscos** — orçamento, prazos, conformidade, dependências externas.

**Aprovação humana obrigatória (P1):** o **âmbito e as prioridades** são do utilizador — o produto é
dele (`core/orchestrator.md` §Aprovação humana). Qualquer envolvimento de **dados pessoais** já se
sinaliza aqui, mesmo que o tratamento se decida em fases seguintes.

## Loops que abre

- **Motor de perguntas em contínuo** (`core/question-engine.md`): cada lacuna vira `P-nnn` em
  `product/01-requirements/questions-and-answers.md`; respostas provisórias (assumidas por defeito)
  ficam marcadas para confirmação antes de P1. Não é ainda o `loops/L01-ambiguous-requirements.md`
  formal (esse é de F2) — mas a mecânica de lote é a mesma.

## Portão de saída (P1)

`core/quality-gates.md`:

- [ ] Dossier de descoberta completo: problema nítido, stakeholders e personas confirmados, casos de
      utilização, objetivos com KPIs (baseline→alvo), roadmap, MVP delimitado, riscos com dono.
- [ ] MVP e prioridades **aprovados pelo utilizador**.
- [ ] Nenhuma lacuna crítica aberta (respostas provisórias críticas confirmadas).
- [ ] Zero decisões de solução tomadas (nenhuma escolha de tecnologia/ecrãs — isso é F3/F4).

**Quem aprova:** o utilizador (âmbito, MVP, prioridades). **Quem verifica:** o Orquestrador
(completude do dossier). Com P1 fechado, arranca `workflows/W02-requirements.md`.

## Perfis de esforço

| Perfil | Profundidade de F1 |
| --- | --- |
| **Protótipo** | Dossier único e curto; personas e casos de utilização mínimos; custos em ordem de grandeza grosseira. Basta o suficiente para validar a ideia. |
| **Produto interno** | Dossier completo; personas reais dos utilizadores conhecidos; riscos com dono nomeado. |
| **Produto comercial** | + análise de mercado/concorrência informal nas restrições; KPIs com baseline medido, não estimado. |
| **Plataforma empresarial** | + stakeholders multi-equipa e conformidade explícita nas restrições; roadmap por horizontes formais que alimenta a arquitetura (F3). |

## Relacionados

- `agents/00-discovery/README.md` — a categoria, a ordem e o grafo de dependências.
- `workflows/W00-project-kickoff.md` — a fase anterior (fornece a ideia bruta).
- `workflows/W02-requirements.md` — a fase seguinte (consome o dossier).
- `core/question-engine.md` — como se colocam os lotes desta fase.
- `core/artifact-protocol.md` — a árvore `product/00-discovery/` e os IDs.
- `templates/discovery/idea.md.template` — o molde do primeiro artefacto.
