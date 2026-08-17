# W03 — Arquitetura (F3)

> **Fase:** F3 · **Portão de saída:** P3 · **Agentes-núcleo:** `agents/02-architecture/` (árbitro +
> especialistas de estilo convocados conforme o contexto + selecionador de stack), com o
> `agents/08-infrastructure/hosting-arbiter.md` quando aplicável, conduzidos pelo
> `core/orchestrator.md`.

## Objetivo

Decidir **como se constrói** — estilo arquitetural, stack concreta em versões estáveis, fronteiras e
integrações — antes de escrever uma linha de código de produto. As decisões estruturais **não se
tomam por moda nem pela opinião do agente mais falador**: geram-se em painel às cegas, decidem-se por
árbitro, registam-se em **ADR** e fecham-se (`core/decision-engine.md`). Reverter uma escolha de
estilo custa meses — por isso é das decisões mais formais da framework.

## Pré-condições (portão de entrada)

- [ ] P2 fechado: `product/01-requirements/` `aprovado` — requisitos, `RN-nnn` e **RNF quantificados**
      existem (são os critérios pesados que decidem a arquitetura).
- [ ] Riscos e custos de F1 disponíveis (`product/00-discovery/risks.md`, `custos.md`) — alimentam
      os pesos dos critérios e a validação de custo do utilizador.

Sem RNF quantificados **não se decide arquitetura**: escala esperada, disponibilidade e volumes são o
que separa um monólito de microserviços. Faltando, devolve-se a F2 (`core/lifecycle.md` §2).

## Passos (agente → artefacto)

O processo é o do `core/decision-engine.md` §"decisões estruturais". Artefactos em
`product/02-architecture/`.

| # | Passo | Quem | Artefacto |
| --- | --- | --- | --- |
| 1 | **Enquadrar** a decisão e os critérios com pesos (escala, nº de equipas, operação, reversibilidade, custo, prazo, lock-in) | Orquestrador | pergunta de decisão + critérios (rascunho da `visao-arquitetural.md`) |
| 2 | **Propor em painel, às cegas** — 2–4 especialistas de estilo *relevantes* | `agents/02-architecture/` (estilo) | uma proposta independente por especialista |
| 3 | **Arbitrar** — comparar contra os critérios, fundir ideias, escrever a decisão | `agents/02-architecture/architecture-arbiter.md` | `decisoes/ADR-nnn-titulo.md` + `visao-arquitetural.md` |
| 4 | **Validar** em linguagem simples e **fixar a stack** (só depois do estilo) | utilizador → `agents/02-architecture/stack-selector.md` | ADR `aprovado` + `stack.md` (versões fixadas) |
| 5 | **Decidir alojamento** (cloud/on-prem/híbrido), quando aplicável | `agents/08-infrastructure/hosting-arbiter.md` | `ADR-nnn` de alojamento |
| 6 | **Fixar contratos externos** (sistemas read-only, identidade) | Orquestrador + especialistas | `integracoes.md` (`modules/readonly-external-integrations.md`) |

**Convocação seletiva (`agents/02-architecture/README.md`):** o Orquestrador convoca **só os
especialistas de estilo relevantes** ao problema (`especialista-monolito`, `-monolito-modular`,
`-microservicos`, `-event-driven`, `-cqrs`, `-clean-architecture`, `-hexagonal`, `-ddd`,
`-vertical-slice`, `-serverless`, `-edge-computing`) — **nunca todos por reflexo**. Uma proposta "o
meu estilo não serve aqui" é válida e poupa ao árbitro descartar uma opção má. O árbitro **nunca é um
dos proponentes** (separar quem propõe de quem decide).

**Paralelismo:** as propostas do painel (passo 2) correm em paralelo e **às cegas** — sem se verem
umas às outras (`core/orchestrator.md` §Paralelismo). A stack (4) **nunca** se escolhe antes do
estilo: a tecnologia serve a arquitetura, não o contrário.

## Pontos de decisão

Este é o workflow do **motor de decisão** — quase tudo aqui é decisão registada:

- **Estilo arquitetural (ADR obrigatório):** proposta do árbitro → **validação do utilizador** em
  linguagem simples (o que se escolheu, o que se rejeitou e porquê, o que custa, como se reverte).
- **Stack (versões estáveis):** LTS / majors GA por defeito; `alpha`/`beta`/`RC` só com razão
  registada (`knowledge/permanent-rules.md` §versões estáveis). Lockfiles fixados.
- **Alojamento:** custo, residência de dados, competência da equipa e conformidade — se envolve
  **dinheiro/compromisso** (infra paga), é aprovação humana obrigatória.

**Aprovação humana obrigatória (P3):** os **ADRs e os custos**. O Orquestrador para e pergunta antes
de assumir qualquer compromisso pago (`core/orchestrator.md` §Aprovação humana). Cada ADR aprovado
fica **fechado** — não se reabre sem novidade material (`core/decision-engine.md` §Decisões
fechadas); a lista de decisões fechadas vai para o `CLAUDE.md` do projeto.

## Loops que abre

- F3 não corre um loop dos `loops/` numerados; a sua iteração é o **ciclo de arbitragem**: se
  nenhuma proposta satisfaz os critérios, o Orquestrador reformula os pesos (ou pede uma proposta
  extra) e volta ao passo 2. **Salvaguarda:** 3 rondas sem convergência → subir ao utilizador com o
  trade-off por decidir, em vez de arbitrar no vazio (`core/orchestrator.md` §Recuperação).

## Portão de saída (P3)

`core/quality-gates.md` + `checklists/definition-of-done.md`:

- [ ] ADRs escritos com **opções consideradas** (incl. o status quo), decisão, consequências e
      **caminho de reversão** (`core/decision-engine.md` §"ADR — o que tem de conter").
- [ ] Stack **fixada** em versões estáveis, com lockfiles (`stack.md`).
- [ ] Integrações externas com contrato assumido (read-only, sincronização, campos geridos fora).
- [ ] Utilizador **validou custos e trade-offs** em linguagem simples.

**Quem verifica:** o Orquestrador (completude do ADR) — o `agents/12-reviewers/architecture-reviewer.md`
só audita a *aderência* em F7. **Quem aprova:** o utilizador (ADRs + custos). Com P3 fechado, arranca
`workflows/W04-experience.md`.

## Recuperação de falhas e bloqueios

`core/orchestrator.md` §Recuperação. Propostas contraditórias entre especialistas → **não se
escolhe em silêncio**: confronta-se contra os critérios pesados ou sobe-se ao utilizador se for
decisão de produto. Utilizador indisponível para validar custos → o ADR fica em `rascunho`, a
pendência em `STATE.md` → "Decisões pendentes", e **não se fixa stack nem se contrata infra** por
assunção. Decisão fechada que o utilizador queira reabrir → avisa-se do porquê original antes de
executar; se reabrir, o ADR antigo marca-se `substituída por ADR-nnn` (nunca se apaga).

## Perfis de esforço

| Perfil | Profundidade de F3 |
| --- | --- |
| **Protótipo** | ADR curto (1 página) do estilo óbvio; stack mínima estável; alojamento adiado; painel de 2 pode ser o próprio Orquestrador a esboçar as opções. |
| **Produto interno** | Painel real de 2–3 estilos; ADRs para as decisões estruturais; alojamento decidido. |
| **Produto comercial** | + ADR de alojamento com custos validados; stack com política de atualização. |
| **Plataforma empresarial** | **ADR para toda a decisão estrutural**; painel completo; conformidade e residência de dados explícitas no alojamento. |

## Relacionados

- `core/decision-engine.md` — o processo painel→árbitro→ADR que esta fase encarna.
- `agents/02-architecture/README.md` — a categoria e a convocação seletiva de especialistas.
- `agents/08-infrastructure/hosting-arbiter.md` — a arbitragem de alojamento.
- `templates/project/ADR-DECISION.md.template` — o formato do registo de decisão.
- `workflows/W02-requirements.md` — a fase anterior (fornece requisitos e RNF).
- `workflows/W05-specification.md` — consome os ADRs e a stack para a especificação.
