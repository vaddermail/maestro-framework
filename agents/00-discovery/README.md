# 00 — Descoberta

A primeira categoria de agentes do produto. Trabalha toda em **F1** (`core/lifecycle.md`),
conduzida pelo `workflows/W01-discovery.md`. O seu propósito: transformar uma ideia bruta num
**dossier de descoberta aprovado** — o problema nítido, quem o vive, o que se quer alcançar e como se
saberá que se conseguiu — **sem decidir nada sobre a solução** (tecnologia, ecrãs, arquitetura ficam
para F3+). É a fase em que "nunca assumir — perguntar" (`MANIFESTO.md` §2) pesa mais: cada pressuposto
não validado aqui vira defeito caro lá à frente.

## Agentes da categoria

| Agente | Uma linha |
| --- | --- |
| `agents/00-discovery/idea-analyst.md` | Estrutura a ideia bruta numa descrição testável (é/não-é, pressupostos, perguntas-âncora). |
| `agents/00-discovery/problem-definer.md` | Isola o problema real, o público afetado e o custo de não o resolver. |
| `agents/00-discovery/stakeholder-mapper.md` | Identifica stakeholders, papéis, poder/interesse e canais de contacto. |
| `agents/00-discovery/persona-builder.md` | Personas dos utilizadores com objetivos, dores e contexto de utilização. |
| `agents/00-discovery/use-case-modeler.md` | Casos de utilização (CU-nnn) e jornadas de ponta a ponta por ator. |
| `agents/00-discovery/business-goals-analyst.md` | Objetivos de negócio mensuráveis e restrições que os limitam. |
| `agents/00-discovery/kpi-definer.md` | KPIs por objetivo, com baseline e alvo — como se prova o sucesso. |
| `agents/00-discovery/roadmap-planner.md` | Roadmap por horizontes, incluindo o que fica para futuro. |
| `agents/00-discovery/mvp-scoper.md` | Corta o MVP mínimo demonstrável e o que fica explicitamente de fora. |
| `agents/00-discovery/risk-analyst.md` | Riscos de negócio/técnicos/legais, com mitigação e dono. |
| `agents/00-discovery/cost-estimator.md` | Ordem de grandeza de custos (construção, infra, IA, operação). |
| `agents/00-discovery/prioritizer.md` | Prioriza funcionalidades (valor × esforço × risco); empates ao utilizador. |

## Ordem de trabalho recomendada

A descoberta é uma cadeia com dependências reais entre artefactos:

1. **Ideia** (`analista-da-ideia`) — o ponto de partida estruturado que todos os outros consomem.
2. **Problema** (`definidor-do-problema`) — aprofunda o problema que a ideia esboça.
3. **Stakeholders** (`mapeador-de-stakeholders`) — quem tem interesse/poder no problema.
4. **Personas** (`construtor-de-personas`) — arquétipos dos utilizadores entre esses stakeholders.
5. **Casos de utilização** (`modelador-de-casos-de-utilizacao`) — o que cada persona quer alcançar.
6. **Objetivos de negócio** (`analista-de-objetivos-de-negocio`) — o resultado que a organização quer.
7. **KPIs** (`definidor-de-kpis`) — como se mede cada objetivo (baseline → alvo).
8. **Roadmap · MVP · Riscos · Custos · Prioridade** — fecham o âmbito e a viabilidade.

Os passos 3–4 e 6–7 podem correr em paralelo dentro do mesmo lote de perguntas ao utilizador; o passo
5 precisa das personas (passo 4); o MVP (`delimitador-de-mvp`) precisa de casos de utilização
priorizados. O Orquestrador monta o grafo a partir das secções **Inputs**/**Interações** de cada ficha
(`core/extensibility.md`), não desta ordem fixa.

## Como o Orquestrador a convoca

O `workflows/W01-discovery.md` (F1) arranca esta categoria logo após F0 ter registado a ideia bruta
em `STATE.md`. O Orquestrador (`core/orchestrator.md`) invoca os agentes por dependência de
artefactos, agrupa as perguntas de vários agentes num **único lote** ao utilizador
(`core/question-engine.md`) e não deixa a fase avançar enquanto o **portão de F1**
(`core/quality-gates.md`) não passar: problema nítido, stakeholders e personas confirmados,
objetivos com KPIs, MVP delimitado e o utilizador a aprovar o dossier. Decisões de âmbito, dinheiro e
dados pessoais são sempre do humano (`MANIFESTO.md` §7). Nenhum agente desta categoria escolhe
tecnologia — isso começa só em F3 (`agents/02-architecture/README.md`).

## Relacionados

- `agents/README.md` · `agents/_template/AGENT-TEMPLATE.md`
- `workflows/W01-discovery.md` · `core/lifecycle.md` · `core/quality-gates.md`
- `agents/01-requirements/README.md` — a fase seguinte, que transforma isto em requisitos sem ambiguidade.
