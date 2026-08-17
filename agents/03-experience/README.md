# 03 — Experiência (UX e UI antes do código)

A categoria que desenha **como o produto se usa e se parece antes de existir uma linha de código de
interface**. Traduz os requisitos e regras de negócio de F2 (`workflows/W02-requirements.md`) em fluxos,
ecrãs, tokens e componentes que o frontend (F6, `agents/04-frontend/README.md`) só tem de
**implementar** — não de inventar. É a materialização do princípio "UX antes de UI, especificação
antes de código" (`MANIFESTO.md` §4).

## Fase e âmbito

- **Fase dominante:** F4, orquestrada por `workflows/W04-experience.md`.
- **Entrada:** dossier de descoberta (F1) — personas, casos de utilização, MVP — e requisitos +
  regras de negócio (F2). Sem personas e casos de utilização aprovados, a categoria não arranca:
  desenha-se para pessoas e tarefas concretas, não para um utilizador imaginado.
- **Saída:** um **mapa de ecrãs aprovado** com fluxos, wireframes, direção visual, design system
  (tokens) e inventário de componentes — o contrato de UX/UI que atravessa o portão de F4
  (`core/quality-gates.md`).

## Agentes da categoria

| Ordem | Agente | Responsabilidade única |
| --- | --- | --- |
| 1 | `agents/03-experience/ux-researcher.md` | Fluxos, jornadas e arquitetura de informação, validados contra personas |
| 2 | `agents/03-experience/wireframer.md` | Wireframes de baixa fidelidade (texto/ASCII) por ecrã, sem cor nem estilo |
| 3 | `agents/03-experience/ui-designer.md` | Direção visual: hierarquia, densidade, tom; tema claro por defeito |
| 4 | `agents/03-experience/design-system-architect.md` | Tokens centrais (cor, tipografia, espaçamento, raio) em dois níveis, nunca hardcoded |
| 5 | `agents/03-experience/component-architect.md` | Inventário de componentes reutilizáveis, com todos os estados e workarounds encapsulados |
| 6 | `agents/03-experience/responsiveness-specialist.md` | Layout real mobile-first (≈390px) e desktop; armadilhas de grid |
| 7 | `agents/03-experience/accessibility-specialist.md` | WCAG, teclado, contraste, leitores de ecrã (`checklists/accessibility.md`) |
| — | `agents/03-experience/web-performance-specialist.md` | Orçamentos de performance web (LCP/CLS/INP), quando aplicável |
| — | `agents/03-experience/seo-specialist.md` | SEO técnico, só quando o produto tem superfície pública indexável |
| — | `agents/03-experience/internationalization-specialist.md` | i18n/l10n, quando há mais do que um locale |

Os três últimos são **condicionais**: o Orquestrador só os convoca se a descoberta indicar a
necessidade (produto público → SEO; multi-locale → i18n; superfície com orçamento de latência →
performance web). Não se desenha para requisitos que não existem.

## Ordem de trabalho recomendada

1. **Fluxos primeiro** (`investigador-de-ux`): sem o mapa de tarefas e a arquitetura de informação,
   os wireframes são adivinhação. Este agente também produz o esqueleto do **mapa de ecrãs**.
2. **Wireframes** (`wireframer`): estrutura e conteúdo de cada ecrã, ainda a preto e branco — para
   discutir o *o quê* sem a distração do *como parece*.
3. **Direção visual e tokens em paralelo** (`designer-de-ui` + `arquiteto-de-design-system`): a
   linguagem visual e os tokens que a materializam avançam juntos; o designer decide, o arquiteto
   codifica em tokens semânticos.
4. **Componentes** (`arquiteto-de-componentes`): destila os wireframes num inventário fechado de
   peças reutilizáveis, cada uma com todos os estados.
5. **Responsividade e acessibilidade** revêem tudo o que os anteriores produziram, no viewport real
   e contra a WCAG — antes do portão de F4.

## Como o Orquestrador a convoca

O Orquestrador (`core/orchestrator.md`) monta o grafo de F4 a partir das secções **Inputs** e
**Interações** destas fichas: `wireframer` espera o `fluxos-e-jornadas.md` aprovado;
`arquiteto-de-componentes` espera wireframes **e** tokens. Cada agente que fica sem input obrigatório
devolve a lacuna como lote de perguntas (`core/question-engine.md`) em vez de assumir. O portão
de F4 só passa com o mapa de ecrãs aprovado pelo utilizador — decisões de UX são revisitáveis, mas
não silenciosas.

## Relacionados

- `workflows/W04-experience.md` — o processo que encadeia estes agentes.
- `agents/04-frontend/README.md` — quem implementa o que esta categoria desenha.
- `agents/12-reviewers/ux-reviewer.md` — revê os fluxos reais contra personas em F7.
- `modules/single-source-of-content.md` — o catálogo de conteúdo que a UI consome (labels, tooltips, ajuda).
- `knowledge/origin-lessons.md` §D — as lições de frontend/conteúdo que esta categoria herda.
- `agents/_template/AGENT-TEMPLATE.md` — o molde de cada ficha.
