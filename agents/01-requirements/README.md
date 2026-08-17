# 01 — Requisitos (F2): o quê, sem ambiguidade

A categoria que transforma o **dossier de descoberta** (F1) numa especificação de intenção que a
arquitetura, a construção e os testes podem consumir **sem adivinhar**. Aqui decide-se *o quê* e as
*regras* — nunca *o como* (isso é F3, `agents/02-architecture/`). O produto desta fase é a base da
rastreabilidade em cadeia (`core/artifact-protocol.md` §4): ideia → `RF-nnn` → `RN-nnn` →
critérios de aceitação → especificação → código → teste.

Fase dominante: **F2** (`workflows/W02-requirements.md`), com o `modelador-de-regras-de-negocio` a
reentrar em **F5** (`workflows/W05-specification.md`). O portão que esta categoria tem de fazer
passar é **P2** (`core/quality-gates.md`): zero ambiguidades críticas abertas, RNF
quantificados, regras de negócio numeradas e aprovadas.

## Agentes desta categoria

| Agente | Uma frase | Produz |
| --- | --- | --- |
| `agents/01-requirements/requirements-engineer.md` | Levanta e estrutura os requisitos funcionais rastreáveis a partir da descoberta | `RF-nnn` |
| `agents/01-requirements/glossary-curator.md` | Fixa a linguagem ubíqua do domínio e os sinónimos proibidos | glossário |
| `agents/01-requirements/business-rules-modeler.md` | Torna explícitas as regras, invariantes e máquinas de estado | `RN-nnn` |
| `agents/01-requirements/nfr-specifier.md` | Quantifica desempenho, disponibilidade, segurança e conformidade | `RNF-nnn` |
| `agents/01-requirements/acceptance-criteria-writer.md` | Escreve, por requisito, os critérios verificáveis que provam que ficou feito | CA por `RF` |
| `agents/01-requirements/ambiguity-hunter.md` | Deteta ambiguidade, contradição e lacuna; abre o loop `loops/L01-ambiguous-requirements.md` | lote de perguntas + marcas |

## Ordem de trabalho recomendada

1. **Glossário primeiro** (`curador-do-glossario`) — mesmo que fino: sem termos fixados, todos os
   outros escrevem em dialetos diferentes. Continua a crescer durante toda a fase.
2. **Requisitos funcionais** (`engenheiro-de-requisitos`) — a espinha `RF-nnn` a partir dos casos de
   utilização e do MVP.
3. **Regras de negócio + RNF em paralelo** (`modelador-de-regras-de-negocio`,
   `especificador-de-requisitos-nao-funcionais`) — as regras que os `RF` têm de respeitar e os
   atributos de qualidade que os atravessam.
4. **Critérios de aceitação** (`redator-de-criterios-de-aceitacao`) — assim que um `RF` estabiliza.
5. **Caça a ambiguidades em contínuo** (`cacador-de-ambiguidades`) — corre sobre tudo o que os
   outros produzem e é o **último a dar OK**: enquanto houver ambiguidade crítica, P2 não passa.

O `cacador-de-ambiguidades` não é um passo final único — dispara sempre que um artefacto de F2 muda,
alimentando o `loops/L01-ambiguous-requirements.md` até fechar.

## Como o Orquestrador a convoca

O `core/orchestrator.md` inicia F2 quando P1 passa (dossier de descoberta aprovado). Monta o grafo
a partir das secções **Inputs**/**Interações** das fichas, agrupa em lotes as perguntas que os
agentes levantam (`core/question-engine.md`) e só declara P2 quando o `cacador-de-ambiguidades`
confirma zero pendências críticas e o utilizador aprovou requisitos, regras e RNF. Divergências que
só aparecem em F5 devolvem trabalho a esta categoria — é o ciclo a funcionar
(`core/lifecycle.md` §2).

## Relacionados

- `agents/00-discovery/README.md` — a montante: fornece casos de utilização, MVP e prioridades.
- `agents/02-architecture/README.md` — a jusante: consome requisitos e RNF para decidir o *como*.
- `workflows/W02-requirements.md` · `workflows/W05-specification.md` — os processos que executam a fase.
- `core/artifact-protocol.md` — a árvore `product/01-requirements/` e a cadeia de IDs.
