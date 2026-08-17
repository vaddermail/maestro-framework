# Arquitetura (F3)

A categoria que decide **como se constrói** — o estilo arquitetural e a stack concreta — antes de
escrever uma linha de código de produto. Trabalha na fase **F3** do ciclo de vida
(`core/lifecycle.md`), entre os requisitos fechados (F2) e o desenho da experiência (F4), e o
seu produto (visão de arquitetura + ADRs + stack fixada) é a base de toda a especificação (F5) e
construção (F6).

O princípio central desta categoria: **decisões estruturais não se tomam por moda nem por opinião do
agente mais falador — geram-se em painel, decidem-se por árbitro, registam-se em ADR e fecham-se**
(`core/decision-engine.md`). Reverter uma escolha de estilo arquitetural custa meses; por isso é
das decisões mais formais da framework.

## Agentes da categoria

| Agente | Tipo | O que faz |
| --- | --- | --- |
| `agents/02-architecture/architecture-arbiter.md` | Árbitro | Compara as propostas do painel contra critérios pesados e decide com ADR justificado |
| `agents/02-architecture/stack-selector.md` | Especialista | Escolhe as tecnologias concretas depois do estilo decidido (versões estáveis/LTS, lockfiles) |
| `agents/02-architecture/monolith-specialist.md` | Especialista | Propõe e justifica um monólito clássico (um só deployable) |
| `agents/02-architecture/modular-monolith-specialist.md` | Especialista | Propõe monólito com fronteiras internas explícitas e caminho de migração |
| `agents/02-architecture/microservices-specialist.md` | Especialista | Propõe serviços independentes; expõe honestamente o custo operacional |
| `agents/02-architecture/event-driven-specialist.md` | Especialista | Propõe comunicação por eventos; brokers, garantias de entrega, idempotência |
| `agents/02-architecture/cqrs-specialist.md` | Especialista | CQRS (com/sem event sourcing): quando compensa a complexidade |
| `agents/02-architecture/clean-architecture-specialist.md` | Especialista | Clean Architecture: camadas, regra de dependência, custos |
| `agents/02-architecture/hexagonal-specialist.md` | Especialista | Ports & Adapters: isolamento do domínio e testabilidade |
| `agents/02-architecture/ddd-specialist.md` | Especialista | DDD estratégico e tático: bounded contexts, agregados |
| `agents/02-architecture/vertical-slice-specialist.md` | Especialista | Vertical slices: organização por funcionalidade |
| `agents/02-architecture/serverless-specialist.md` | Especialista | Serverless/FaaS: custos, cold starts, lock-in |
| `agents/02-architecture/edge-computing-specialist.md` | Especialista | Edge: latência, dados na borda, restrições de runtime |

> O Orquestrador convoca **só os especialistas relevantes** ao problema — nunca todos por reflexo.

## Como o árbitro usa os especialistas (painel + ADR)

O processo é o do `core/decision-engine.md`, secção "decisões estruturais", aplicado a esta
categoria:

1. **Enquadrar.** O Orquestrador formula a pergunta de decisão ("que estilo arquitetural para este
   produto?") e os **critérios com pesos**, derivados dos requisitos e RNF de F2 (escala esperada,
   nº de equipas, maturidade de operação, reversibilidade, custo, prazo).
2. **Propor em painel, às cegas.** Convoca 2–4 especialistas de estilo relevantes. Cada um produz
   uma proposta **independente**, sem ver as dos outros, com desenho, prós/contras honestos contra os
   critérios, custo, riscos e caminho de reversão. **Uma proposta "o meu estilo não serve aqui" é
   válida e valiosa** — poupa ao árbitro descartar uma opção má e mostra que o especialista pensou.
3. **Arbitrar.** O `arbitro-de-arquitetura` — que **nunca é um dos proponentes** — compara contra os
   critérios pesados, pode fundir ideias, e escreve o ADR fundamentado, incluindo as opções rejeitadas
   e o "não fazer nada" (o status quo).
4. **Validar e fixar a stack.** O utilizador valida em linguagem simples; só depois o ADR fica
   `aprovado`. Com o estilo fechado, o `selecionador-de-stack` escolhe as tecnologias concretas.

Este desenho separa deliberadamente **quem propõe** de **quem decide**: um painel de fachada (onde os
especialistas validam uma escolha já feita) é um anti-padrão que o motor de decisão proíbe.

## Ordem de trabalho recomendada

Estilo primeiro, stack depois. `especialistas de estilo (em paralelo) → arbitro-de-arquitetura (ADR)
→ validação do utilizador → selecionador-de-stack`. A stack **nunca** se escolhe antes do estilo: a
tecnologia serve a arquitetura, não o contrário.

## Portão de saída da fase

`core/quality-gates.md` (F3): ADRs escritos com alternativas consideradas e caminho de
reversão; stack fixada com versões e lockfiles; utilizador validou custos e trade-offs. Só com o
portão fechado se avança para F4/F5.

## Relacionados

- `core/decision-engine.md` — o processo painel→árbitro→ADR que esta categoria encarna.
- `workflows/W03-architecture.md` — o workflow que executa a fase.
- `templates/project/ADR-DECISION.md.template` — o formato do registo de decisão.
- `agents/08-infrastructure/hosting-arbiter.md` — o mesmo padrão de arbitragem para a infra.
- `agents/12-reviewers/architecture-reviewer.md` — quem, em F7, verifica a aderência ao decidido.
