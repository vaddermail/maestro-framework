# Workflows — os processos que ligam agentes

Um workflow é a **receita de execução de uma fase** do ciclo de vida (`core/lifecycle.md`):
diz que agentes trabalham, por que ordem, que artefactos produzem, que perguntas se colocam ao
utilizador, que loops abrem e qual o portão que fecha a fase. Se o `core/orchestrator.md` é o
maestro e as fichas de agente são os músicos, os workflows são a **partitura**.

O Orquestrador não improvisa: em cada momento sabe em que fase o projeto está (lendo `STATE.md`,
nunca de memória) e executa o workflow correspondente até o seu portão passar. Um workflow nunca
substitui os portões (`core/quality-gates.md`) nem o motor de perguntas
(`core/question-engine.md`) — apenas os sequencia.

## Convenção de nomes

| Prefixo | Significado | Exemplo |
| --- | --- | --- |
| `Wnn` | Workflow de fase, numerado pela ordem do ciclo de vida | `W00`–`W09` |
| `W10`–`W12` | Workflows transversais, disparados sob condição (não por ordem de fase) | evolução, incidente, revisão global |

Correspondência workflow ↔ fase ↔ portão (o mapa de leitura obrigatório):

| Workflow | Fase | Portão de saída | Agentes-núcleo |
| --- | --- | --- | --- |
| `workflows/W00-project-kickoff.md` | F0 Arranque | P0 | Orquestrador |
| `workflows/W01-discovery.md` | F1 Descoberta | P1 | `agents/00-discovery/` |
| `workflows/W02-requirements.md` | F2 Requisitos | P2 | `agents/01-requirements/` + `loops/L01-ambiguous-requirements.md` |
| `workflows/W03-architecture.md` | F3 Arquitetura | P3 | `agents/02-architecture/` |
| `workflows/W04-experience.md` | F4 Experiência | P4 | `agents/03-experience/` |
| `workflows/W05-specification.md` | F5 Especificação | P5 (desbloqueia código) | modeladores + desenhador de APIs + modelador de ameaças |
| `workflows/W06-build.md` | F6 Construção | P6/P6b | `agents/04-frontend/`, `agents/05-backend/`, `agents/06-data/`, `agents/10-quality/` |
| `workflows/W07-quality-and-security.md` | F7 Qualidade & Segurança | P7 | `agents/12-reviewers/`, `agents/09-security/` |
| `workflows/W08-launch.md` | F8 Lançamento | P8 | `agents/07-devops/`, `agents/08-infrastructure/` |
| `workflows/W09-continuous-operation.md` | F9 Operação | cadências (P9) | `agents/13-guardians/` |
| `workflows/W10-feature-evolution.md` | reentra F2→F8 | portões das fases tocadas | `agents/13-guardians/feature-evolution-agent.md` |
| `workflows/W11-incident-response.md` | transversal a F9 | `checklists/post-incident.md` | resposta + post-mortem |
| `workflows/W12-global-review.md` | sob pedido | consolidação | painel completo de revisores |

## Estrutura de cada workflow (secções fixas)

Todo o `Wnn` segue a mesma anatomia, para o Orquestrador saltar de um para outro sem reaprender o
formato:

1. **Objetivo** — o que a fase entrega, numa frase.
2. **Pré-condições (portão de entrada)** — que artefactos têm de estar `aprovado` para arrancar.
3. **Passos (agente → artefacto)** — a sequência, com dependências e o que cada passo escreve.
4. **Pontos de decisão** — o que sobe ao utilizador (`core/question-engine.md`) ou ao motor de
   decisão (`core/decision-engine.md`); onde há aprovação humana obrigatória.
5. **Loops que abre** — os `loops/` que correm dentro da fase e a sua condição de saída.
6. **Portão de saída** — os critérios verificáveis de `core/quality-gates.md` e quem aprova.
7. **Perfis de esforço** — como o perfil (`core/orchestrator.md` §Perfis) dimensiona a fase.
8. **Relacionados** — para onde o leitor segue.

## Como se executa um workflow

1. **Ler o estado.** O Orquestrador lê `STATE.md` e confirma a fase ativa e o perfil de esforço.
2. **Confirmar a pré-condição.** Os artefactos de entrada existem e estão `aprovado`? Se não, o
   workflow anterior não fechou — não se arranca este (`core/lifecycle.md` §1, sem saltos).
3. **Percorrer os passos por dependência**, não pela numeração cega: um passo arranca quando os seus
   inputs existem (grafo montado a partir das fichas, `core/orchestrator.md`). Passos independentes
   podem correr em paralelo; painéis correm às cegas (`core/orchestrator.md` §Paralelismo).
4. **Agrupar as perguntas em lotes** por fase, nunca à peça (`core/question-engine.md`).
5. **Fechar os loops** abertos antes de tentar o portão.
6. **Passar o portão** — verificação independente + aprovação humana onde é obrigatória — e registar
   em `STATE.md`. Só então o próximo workflow arranca.

## Regras transversais a todos os workflows

- **Voltar atrás é normal.** Descobrir num workflow tardio que falta trabalho a montante devolve à
  fase anterior — regista-se a razão em `STATE.md` (`core/lifecycle.md` §2). Isso não é falha
  do processo; avançar sem portão é que é.
- **Cada passo escreve.** Output que não fica num artefacto de `product/` não existe
  (`core/artifact-protocol.md` §1). Um workflow "corrido" sem artefactos escritos não correu.
- **Routing por tarefa.** O Orquestrador escolhe a camada de modelo de cada passo
  (`core/model-routing.md`) — nunca o modelo de topo por reflexo em toda a fila de agentes.
- **Segurança é transversal.** O `agents/09-security/security-coordinator.md` tem assento em
  todos os workflows; segurança não é uma fase, é uma dimensão (`core/lifecycle.md` §5).

## Relacionados

- `core/lifecycle.md` — as fases que estes workflows executam.
- `core/orchestrator.md` — quem os conduz.
- `core/quality-gates.md` — os portões que fecham cada fase.
- `core/artifact-protocol.md` — a árvore `product/` que os workflows preenchem.
- `agents/README.md` — as fichas dos agentes que cada passo invoca.
- `loops/README.md` — os loops que correm dentro das fases.
