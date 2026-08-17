# W04 — Experiência (F4)

> **Fase:** F4 · **Portão de saída:** P4 · **Agentes-núcleo:** `agents/03-experience/` (7
> essenciais + 3 condicionais), conduzidos pelo `core/orchestrator.md`.

## Objetivo

Desenhar **como o produto se usa e se parece antes de existir uma linha de código de interface**:
fluxos e jornadas, wireframes, direção visual, design system em tokens, inventário de componentes,
responsividade e acessibilidade — consolidados num **mapa de ecrãs aprovado**. É a materialização de
"UX antes de UI, especificação antes de código" (`MANIFESTO.md` §4): o frontend (F6) só terá de
**implementar** o que aqui se decide, não de inventar.

## Pré-condições (portão de entrada)

- [ ] P2 fechado: requisitos, `RN-nnn` e critérios de aceitação `aprovado` (`product/01-requirements/`).
- [ ] Personas e casos de utilização de F1 `aprovado` (`product/00-discovery/personas/`,
      `casos-de-utilizacao/`) — desenha-se para pessoas e tarefas concretas, não para um utilizador
      imaginado.
- [ ] ADRs de F3 `aprovado` — a arquitetura condiciona o que a UI pode assumir (SSR, tempo real,
      offline).

Sem personas e casos de utilização aprovados, a categoria **não arranca** (`agents/03-experience/README.md`).

## Passos (agente → artefacto)

A ordem segue `agents/03-experience/README.md`. Artefactos em `product/03-experience/`.

| # | Agente | Artefacto | Depende de |
| --- | --- | --- | --- |
| 1 | `agents/03-experience/ux-researcher.md` | `fluxos-e-jornadas.md` + esqueleto do `mapa-de-ecras.md` | personas + casos de utilização (F1), `RF` (F2) |
| 2 | `agents/03-experience/wireframer.md` | `wireframes/` (um por ecrã/fluxo, texto/ASCII, sem cor) | 1 |
| 3a | `agents/03-experience/ui-designer.md` | direção visual (hierarquia, densidade, **tema claro por defeito**) | 2 |
| 3b | `agents/03-experience/design-system-architect.md` | `design-system.md` (tokens de cor/tipografia/espaçamento/raio, nunca hardcoded) | 2 (paralelo com 3a) |
| 4 | `agents/03-experience/component-architect.md` | `componentes.md` (inventário fechado, todos os estados) | 2, 3b |
| 5a | `agents/03-experience/responsiveness-specialist.md` | revisão do `mapa-de-ecras.md` (mobile-first ≈390px **e** desktop) | 2–4 |
| 5b | `agents/03-experience/accessibility-specialist.md` | `acessibilidade.md` (WCAG, teclado, contraste, `checklists/accessibility.md`) | 2–4 |

**Condicionais (só quando a descoberta o indica):**
`agents/03-experience/web-performance-specialist.md` (superfície com orçamento de latência),
`-de-seo.md` (produto público indexável), `-de-internacionalizacao.md` (mais do que um locale). **Não
se desenha para requisitos que não existem** — o Orquestrador só os convoca se necessário.

**Paralelismo (`core/orchestrator.md` §Paralelismo):** direção visual (3a) e tokens (3b) avançam
juntos — o designer decide, o arquiteto codifica em tokens semânticos; responsividade (5a) e
acessibilidade (5b) revêem tudo o que os anteriores produziram, no viewport real e contra a WCAG,
antes do portão. Conteúdo (labels, tooltips, ajuda) sai do catálogo único
(`modules/single-source-of-content.md`), nunca duplicado no ecrã.

> **Escala ao perfil:** num protótipo, wireframes e mapa de ecrãs colapsam num único
> `product/03-experience/ux.md` com ASCII; os tokens ficam mínimos mas **existem** (nunca cores
> hardcoded, mesmo em protótipo).

## Pontos de decisão

Lacunas sobem em **lotes** ao Orquestrador (`core/question-engine.md`). Lotes típicos de F4:

- **Prioridade de ecrã** — o que é fluxo principal vs secundário; o que fica fora do MVP visual.
- **Tom visual** — densidade (informação vs respiração), formalidade, marca (se existir).
- **Acessibilidade-alvo** — nível WCAG a cumprir; suporte de teclado e leitores de ecrã.
- **Responsividade** — que breakpoints, o que colapsa/reordena no telemóvel.

**Aprovação humana obrigatória (P4):** o **mapa de ecrãs** e os **wireframes dos fluxos críticos**
são validados pelo utilizador — decisões de UX são revisitáveis, mas **não silenciosas**
(`agents/03-experience/README.md`). O produto é dele.

## Loops que abre

- F4 não corre um loop numerado dedicado; a sua iteração é o **ciclo de revisão de wireframes** com
  o utilizador (fluxo por fluxo) até o mapa de ecrãs estabilizar. **Salvaguarda** (`loops/README.md`):
  3 rondas sem convergência num ecrã → o Orquestrador isola a decisão em aberto e sobe-a como pergunta
  única, em vez de redesenhar às cegas. Achados de acessibilidade que impliquem retrabalho de fluxo
  reabrem o passo 1 — regista-se em `STATE.md`.

## Portão de saída (P4)

`core/quality-gates.md` + `checklists/definition-of-done.md`:

- [ ] **Mapa de ecrãs aprovado pelo utilizador**, com os wireframes dos **fluxos críticos** validados.
- [ ] Design system com **tokens definidos** (dois níveis, nunca hardcoded); tema claro por defeito.
- [ ] Inventário de componentes com todos os estados (vazio, carregamento, erro, sucesso).
- [ ] Plano de **acessibilidade** aceite (`checklists/accessibility.md`) e responsividade real
      verificada em viewport pequeno e grande.

**Quem verifica:** o Orquestrador (completude) + `especialista-de-acessibilidade` e
`-de-responsividade` (substância). **Quem aprova:** o utilizador (mapa de ecrãs). O
`agents/12-reviewers/ux-reviewer.md` só audita contra personas em F7. Com P4 fechado, arranca
`workflows/W05-specification.md`.

## Recuperação de falhas e bloqueios

`core/orchestrator.md` §Recuperação. `wireframer` sem `fluxos-e-jornadas.md` aprovado, ou
`arquiteto-de-componentes` sem tokens → devolve a lacuna como lote de perguntas, **não assume**.
Utilizador indisponível para validar o mapa de ecrãs → o mapa fica em `em-revisao`, a pendência em
`STATE.md` → "Decisões pendentes"; F5 **não arranca** sem P4 fechado. Divergência descoberta em F6
(um ecrã impossível de implementar como desenhado) devolve trabalho a F4 — regista-se a razão em
`STATE.md`.

## Perfis de esforço

| Perfil | Profundidade de F4 |
| --- | --- |
| **Protótipo** | Wireframes ASCII dos fluxos principais; tokens mínimos; acessibilidade básica (contraste + teclado). |
| **Produto interno** | Mapa de ecrãs completo; design system com tokens; WCAG AA nos fluxos críticos. |
| **Produto comercial** | + performance web orçamentada; i18n se multi-locale; acessibilidade auditada. |
| **Plataforma empresarial** | + SEO técnico se houver superfície pública; WCAG AA/AAA conforme conformidade; design system versionado. |

## Relacionados

- `agents/03-experience/README.md` — a categoria, a ordem e os agentes condicionais.
- `workflows/W03-architecture.md` — a fase anterior (fornece os ADRs que condicionam a UI).
- `workflows/W05-specification.md` — a fase seguinte (consome fluxos e regras).
- `agents/04-frontend/README.md` — quem implementa, em F6, o que esta fase desenha.
- `modules/single-source-of-content.md` — o catálogo de conteúdo que a UI consome.
- `checklists/accessibility.md` — a verificação WCAG prática por ecrã.
