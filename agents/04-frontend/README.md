# 04 — Frontend (engenharia do cliente)

A categoria que constrói a **aplicação cliente**: a estrutura da app, os ecrãs, a ligação à API, o
estado/cache e os testes de UI. Trabalha na fase **F6** (construção — `workflows/W06-build.md`),
a jusante da experiência (F4, `agents/03-experience/`) e em paralelo com o backend
(`agents/05-backend/`) e os dados (`agents/06-data/`), sob o contrato de API que o servidor publica.

> Princípio da categoria: o **cliente é não-fiável** (`knowledge/proven-patterns.md` §6).
> O frontend assume que só recebe o que o perfil ativo pode ver e que o servidor confirma toda a
> autoridade — a UI pode esconder e desabilitar por UX, nunca por segurança. E todo o texto que chega
> ao utilizador vem da **fonte única de conteúdos** (`modules/single-source-of-content.md`), nunca
> hardcoded no ecrã.

## Agentes desta categoria

| Agente | Uma linha |
| --- | --- |
| `agents/04-frontend/frontend-architect.md` | Estrutura da app cliente: routing, camadas, convenções, arranque da camada de conteúdos (SSOT) e dos tokens. |
| `agents/04-frontend/screen-implementer.md` | Constrói cada ecrã a partir do wireframe + design system, com **tooltip em toda a ação** e **filtros/ordenação em toda a lista**. |
| `agents/04-frontend/api-integrator.md` | Cliente de API tipado gerado do contrato, **mocks que espelham o servidor** (MSW ou equivalente), erros normalizados (RFC 7807). |
| `agents/04-frontend/state-and-cache-specialist.md` | Estado do cliente, cache de dados do servidor, sincronização e invalidação; camadas base+overlay. |
| `agents/04-frontend/frontend-test-engineer.md` | Testes de componentes/ecrãs (com axe) e smoke E2E do cliente em viewport pequeno **e** grande. |

## Ordem de trabalho recomendada

1. **Arquiteto de Frontend** monta o esqueleto: routing, camadas, convenções e a **camada de
   conteúdos tipada** + consumo dos tokens do design system — *antes* de existir qualquer ecrã.
2. **Integrador de API** gera o cliente tipado e os mocks a partir do contrato, para que os ecrãs
   tenham dados coerentes desde o primeiro dia (dev + testes).
3. **Especialista de Estado e Cache** define a política de cache/invalidação e as camadas de estado
   que os ecrãs vão reutilizar.
4. **Implementador de Ecrãs** constrói ecrã a ecrã sobre estas fundações (tooltips, filtros, estados
   de carregamento/erro/vazio).
5. **Engenheiro de Testes Frontend** cobre componentes e ecrãs e corre o smoke E2E; acompanha em
   paralelo, não só no fim.

> Os passos 2–4 iteram por **fatia vertical** (`workflows/W06-build.md`): um ecrã de cada vez,
> com o seu cliente, mocks, estado e testes — nunca "todos os ecrãs primeiro, integração depois".

## Como o Orquestrador a convoca

O `core/orchestrator.md` ativa a categoria quando o portão de F4 passou (wireframes + design system
aprovados) e o contrato de API existe (do `agents/05-backend/api-designer.md`). Monta o grafo
de dependências a partir das secções **Inputs**/**Interações** das fichas: o arquiteto primeiro, depois
os restantes em fatias. Devolve controlo aos revisores de F7 (`agents/12-reviewers/frontend-reviewer.md`,
`agents/12-reviewers/ux-reviewer.md`) e, em produção, ao `agents/13-guardians/performance-guardian.md`.

## Fase(s)

**F6 (construção)** é a fase dominante. A categoria **consome** F4 (experiência) e o contrato de F5, e
**alimenta** F7 (revisão/qualidade). Em F9, os ecrãs e o cliente evoluem via
`workflows/W10-feature-evolution.md`.

## Relacionados

- `agents/README.md` — índice global e tipos de agente.
- `agents/03-experience/README.md` — o que esta categoria recebe (wireframes, design system, tokens).
- `agents/05-backend/README.md` — o outro lado do contrato de API.
- `agents/10-quality/README.md` — a estratégia de testes e o E2E multi-perfil de sistema completo.
- `modules/single-source-of-content.md` · `modules/rbac-and-scoping.md` — os módulos que a categoria aplica.
- `workflows/W06-build.md` — o processo de fatia vertical em que a categoria vive.
