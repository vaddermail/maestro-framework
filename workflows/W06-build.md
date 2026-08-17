# W06 — Construção (Fase F6)

Como se transforma a especificação aprovada em código a funcionar, **fatia vertical a fatia
vertical**, sem que a fase se torne um mega-lote onde tudo depende de tudo. É a fase mais longa do
ciclo (`core/lifecycle.md`) e a que mais defeitos gera se a disciplina se perder — por isso o
portão é **por fatia** (P6), não só no fim.

> **Fase:** F6 · **Portão de entrada:** P5 (especificação aprovada — só aqui se desbloqueia código)
> · **Portão de saída:** P6b (MVP completo vs spec; harness de regressão verde)
> · **Workflow anterior:** `workflows/W05-specification.md` · **seguinte:** `workflows/W07-quality-and-security.md`

## Objetivo

Transformar a especificação aprovada em produto a funcionar, fatia vertical a fatia vertical — cada
fatia entregue de ponta a ponta (dados → backend → frontend → testes), verificada com prova-live
real e fechada pelo portão P6, até o MVP completo passar P6b com a aceitação do utilizador.

## Pré-condições (verificar antes de escrever a primeira linha)

- [ ] `product/04-specification/` em estado `aprovado` (P5 passou) — regras, máquinas de estado,
      modelo de dados lógico e contrato de backend existem e foram revistos.
- [ ] ADRs de F3 fixados e stack escolhida em versões estáveis (`product/02-architecture/stack.md`).
- [ ] Design system com tokens e wireframes dos fluxos críticos validados (`product/03-experience/`).
- [ ] `product/06-tests/test-strategy.md` escrita pelo
      `agents/10-quality/test-strategist.md` — a fatia 0 e o plano de testes derivam dela, e
      o `agents/12-reviewers/test-reviewer.md` exige-a como input em F7.
- [ ] Repositório com esqueleto criado, CI de qualidade e de segurança armados
      (`pipelines/ci-quality.md`, `pipelines/ci-security.md`) — o primeiro merge já corre verde.
      Se existir um **starter validado** para a stack escolhida em F3, o esqueleto arranca dele
      (`starters/README.md`) em vez de se construir à mão — mesma exigência, custo de fatia 0 ~zero.

Se algo falta, **não se começa a construir** — devolve-se a fase que o produz (regra 2 do ciclo).

## O princípio: fatia vertical, não camada horizontal

Uma **fatia vertical** entrega uma funcionalidade de ponta a ponta — dados → backend → frontend →
testes — pequena o suficiente para caber num portão e grande o suficiente para ser demonstrável. Não
se constrói "toda a base de dados", depois "todo o backend": constrói-se *uma* funcionalidade
completa, prova-se, integra-se, e só então a seguinte.

- **Porquê:** camadas horizontais só se validam no fim (integração big-bang), quando corrigir é
  caro; fatias verticais dão prova-live cedo e isolam a regressão à fatia (`knowledge/origin-lessons.md` A4, E1).
- **Ordem das fatias:** primeiro as que sustentam o esqueleto de risco (autenticação, autorização/scoping,
  a entidade central e a sua máquina de estados); depois as que dependem delas. O `priorizador`
  (`agents/00-discovery/prioritizer.md`) já deu a ordem de valor; o Orquestrador ordena por
  dependência técnica dentro dela.
- **Fatias independentes correm em paralelo** (`core/orchestrator.md` §Paralelismo); fatias que
  partilham a mesma entidade central, não.

## Anatomia de uma fatia (a sequência interna)

| Passo | Quem | Input → Output | Camada de modelo |
| --- | --- | --- | --- |
| 1. Plano da fatia | Orquestrador | Spec do módulo → plano autocontido (RF/RN cobertos, ficheiros a tocar, testes a escrever) | Padrão |
| 2. Dados | `agents/06-data/data-modeler.md` + `agents/06-data/migration-engineer.md` | Modelo lógico → migração expand-contract + invariantes na BD | Topo (migração/invariantes) |
| 3. Backend | `agents/05-backend/` (autorização, regra de negócio, contrato) | Contrato de backend → caso-de-uso transacional + endpoint | Padrão (Topo se RBAC/estado/fluxo crítico) |
| 4. Contrato/tipos | `agents/05-backend/api-designer.md` | Schema único → snapshot (OpenAPI/equivalente) regenerado por comando | Económico |
| 5. Frontend | `agents/04-frontend/` (ecrã, integração de API, estado) | Wireframe + design system + snapshot → ecrã com tooltips, filtros, estados de erro | Económico (Padrão em lógica de cliente) |
| 6. Testes | `agents/10-quality/` | Critérios de aceitação → unitários (regra), integração (BD real), smoke E2E | Económico (Padrão na lógica de risco) |
| 7. Prova-live + registo | Orquestrador (verificação independente) | Fatia → evidência real + `STATE.md` atualizado | Padrão |

**Dar a spec completa à cabeça** de cada passo (A4/roteamento §6): um plano autocontido corta turnos
de ida-e-volta e reduz o custo de IA.

## Regras inegociáveis durante a construção

1. **A spec ganha.** Se ao construir se descobre que a spec está errada ou incompleta, **para-se e
   atualiza-se a spec primeiro** (com aprovação, `core/artifact-protocol.md` regra 4), depois
   o código. Nunca se "corrige em código" contra a spec em silêncio — isso cria a segunda fonte de
   verdade (`knowledge/ai-pitfalls.md` §7).
2. **Sem scope creep.** A fatia entrega o que o plano diz. "Já agora refiz também…" é decisão do
   utilizador, não iniciativa do agente (`knowledge/ai-pitfalls.md` §5). Aditivo dentro do
   plano avança; lateral/destrutivo pergunta.
3. **Invariantes duros na BD + guards na app** (`knowledge/proven-patterns.md` §5): a
   constraint é a última linha; a app dá o erro amigável. Um teste insere a linha ilegal e afirma a
   violação **pelo nome**.
4. **Autorização, scoping e ocultação de sensíveis 100% no servidor** (`modules/rbac-and-scoping.md`):
   o cliente declara, o servidor confirma; fail-closed; fora-de-scope → 404.
5. **Reversibilidade por fatia:** migração com plano de *down* (`playbooks/expand-contract-db-migration.md`);
   mudança de risco atrás de flag (`modules/feature-flags.md`); nunca largar o que está em uso no
   mesmo passo.
6. **SSOT de conteúdo e de contrato:** labels/tooltips/ajuda do catálogo único
   (`modules/single-source-of-content.md`); tipos e doc derivam do schema único, regenerados por
   comando, nunca à mão (`knowledge/origin-lessons.md` E4).

## Pontos de decisão

As aprovações humanas de F6, consolidadas (formato do `core/question-engine.md`, em lotes por
fatia — nunca uma interrupção à peça):

- **Aceitação do MVP (P6b)** — só o utilizador aceita; regista-se em `STATE.md`.
- **Âmbito novo a meio da fase** — funcionalidade não especificada volta a F5 pelo motor de
  perguntas; nunca se implementa por iniciativa do agente.
- **Alteração à especificação** — quando o código e a spec divergem, a spec ganha: muda-se a spec
  às claras primeiro (aprovada pelo utilizador) e só depois o código.
- **Dívida técnica assumida** — registá-la em `loops/L08-technical-debt.md` é decisão visível, com
  o utilizador ciente do juro.

## Loops ativos nesta fase

- `loops/L02-failing-tests.md` — enquanto houver teste vermelho, corrige-se a **causa** (nunca o
  teste, salvo teste provadamente errado). Não se integra vermelho.
- `loops/L04-code-smells.md` — smells acima do limiar melhoram-se sem mudar comportamento.
- `loops/L05-inconsistencies.md` — divergência docs↔código↔dados reconcilia-se com a fonte de verdade.

## O portão por fatia (P6) e o da fase (P6b)

**P6 (cada fatia → merge):** `checklists/definition-of-done.md` + `checklists/pre-merge.md` —
testes verdes (front **e** back, correm separados), spec respeitada, revisão de PR
(`checklists/pr-review.md`), sem segredos, reversível, **prova-live real** feita. Verificação
independente: quem escreveu a fatia não é quem a dá por pronta (`core/quality-gates.md`).

**P6b (F6 → F7):** MVP completo confrontado com a especificação (todos os RF do MVP têm código e
teste rastreável); harness de regressão verde no ambiente-alvo; dívida técnica não resolvida
**registada** (`loops/L08-technical-debt.md`), não escondida. É aqui que o utilizador **aceita o
MVP**.

## Escala ao perfil de esforço

| Perfil | Como muda |
| --- | --- |
| Protótipo | Fatias maiores, testes só na lógica de risco, revisão P6 pelo próprio Orquestrador; prova-live continua obrigatória. |
| Produto interno | Estrutura completa; revisão em painel nos fluxos críticos. |
| Produto comercial / Plataforma | Fatias pequenas e frequentes; paridade real de BD a cada fatia que mexe em dados (`knowledge/ai-pitfalls.md` §15); registo de consumo de IA por fatia. |

## Anti-padrões

- ❌ Construir por camadas (toda a BD → todo o backend) e integrar no fim → ✅ fatias verticais demonstráveis.
- ❌ Corrigir a spec em código sem atualizar a spec → ✅ spec primeiro, com aprovação.
- ❌ "Testes verdes, logo funciona" → ✅ prova-live real é gate insubstituível (`knowledge/ai-pitfalls.md` §2).
- ❌ Migração que larga/renomeia o que está em uso no mesmo passo → ✅ expand-contract.
- ❌ Fatia gigante que nunca fecha o portão → ✅ se não cabe num P6, parte-se em duas.

## Relacionados

- `core/lifecycle.md` — F6 no mapa geral.
- `core/quality-gates.md` — P5, P6, P6b em detalhe.
- `checklists/definition-of-done.md` · `checklists/pre-merge.md` · `checklists/pr-review.md`
- `playbooks/expand-contract-db-migration.md` · `pipelines/ci-quality.md`
- `knowledge/proven-patterns.md` — os padrões que cada fatia aplica.
- `workflows/W07-quality-and-security.md` — o escrutínio que se segue ao MVP.
