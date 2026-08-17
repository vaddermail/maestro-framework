# Template de Agente — `TEMPLATE-AGENTE`

> **Como usar:** copia este ficheiro para a categoria certa (`agents/NN-categoria/nome-do-agente.md`),
> preenche **todas** as secções e regista o novo agente no índice da categoria (`README.md` da pasta)
> e no inventário global (`_meta/INVENTORY.md`). Nenhuma secção é opcional — se uma não se aplicar,
> escreve explicitamente "Não aplicável, porque …". Ver `playbooks/add-an-agent.md` para o
> processo completo e `core/extensibility.md` para as garantias de compatibilidade.

---

## Identificação

| Campo | Valor |
| --- | --- |
| **Nome** | Nome do agente em PT-PT (ex.: Guardião de Segurança) |
| **Alias** | Nome internacional, se existir (ex.: Security Guardian) |
| **Categoria** | `NN-categoria` (pasta onde vive) |
| **Fases** | Fases do ciclo de vida em que atua (ver `core/lifecycle.md`) — ex.: F1, F9 |
| **Tipo** | `especialista` \| `árbitro` \| `revisor` \| `guardião` \| `coordenador` |
| **Modelo sugerido** | Camada de modelo + esforço, segundo `core/model-routing.md` (ex.: `padrão` / `topo, effort medium`) |

## Objetivo

Um parágrafo: a **única responsabilidade** deste agente. Se precisares de "e" para descrever duas
responsabilidades independentes, são dois agentes.

## Quando inicia

Condições concretas de ativação: que fase, que evento, que artefacto ficou disponível, quem o invoca
(normalmente o Orquestrador — ver `core/orchestrator.md`). Um agente nunca se auto-invoca fora
destas condições.

## Quando termina

Critérios verificáveis de conclusão (não "quando estiver bom"): que artefactos existem, que checklist
passou, que portão de qualidade foi cumprido. Se o agente pode terminar **bloqueado** (à espera de
resposta do utilizador), diz como regista o bloqueio (`STATE.md` → decisões pendentes).

## Inputs

| Artefacto | Origem (agente/fase) | Obrigatório? | Notas |
| --- | --- | --- | --- |
| `product/…/exemplo.md` | Agente X (F1) | Sim | O que precisa de conter para ser utilizável |

Se um input obrigatório não existir ou estiver incompleto, o agente **não avança com pressupostos**:
devolve ao Orquestrador a lista de lacunas e as perguntas a fazer (ver `core/question-engine.md`).

## Outputs

| Artefacto | Destino (localização no projeto) | Consumidores |
| --- | --- | --- |
| `product/…/exemplo.md` | Onde fica escrito | Agentes que o vão ler a jusante |

Todo o output é **escrito em ficheiro** no projeto (nunca apenas "dito" na conversa) — é assim que a
memória do projeto se mantém auditável (ver `core/project-memory.md`).

## Perguntas ao utilizador

As perguntas-tipo que este agente coloca quando falta informação, no formato do
`core/question-engine.md`: contexto → pergunta → porque importa → opções com prós/contras em
linguagem simples → recomendação por defeito. Perguntas agrupadas em lotes; nunca uma metralhadora
de perguntas soltas.

## Regras

Regras inegociáveis que o agente cumpre sempre. Numeradas, verificáveis, com o porquê quando não for
óbvio. Ex.: "1. Nunca declara a análise concluída com requisitos ambíguos por resolver — abre o loop
`loops/L01-ambiguous-requirements.md`."

## Limitações (o que este agente NÃO faz)

Fronteiras explícitas com os agentes vizinhos, para evitar sobreposição e trabalho duplicado. Nomear
o agente responsável por cada coisa excluída. Ex.: "Não escolhe tecnologias — isso é do
`agents/02-architecture/stack-selector.md`."

## Workflow

Passo-a-passo numerado do trabalho do agente, do primeiro input ao último output. Incluir os pontos
de decisão, os loops que pode abrir e os momentos em que devolve controlo ao Orquestrador. Se o passo
produz artefacto, indicar qual.

## Exemplos

Pelo menos **um exemplo concreto e realista** de ponta a ponta: input recebido → raciocínio → perguntas
feitas (se aplicável) → output produzido (excerto). Preferir exemplos de domínios variados (e-commerce,
SaaS B2B, app interna) para mostrar que o agente é agnóstico de domínio.

## Boas práticas

O que distingue um resultado excelente de um aceitável neste papel. Destilado da experiência
(ver `knowledge/`), não teoria genérica.

## Anti-padrões

Erros típicos que este agente deve recusar-se a cometer, cada um com o sintoma e a alternativa correta.
Ex.: "❌ Assumir a resposta em vez de perguntar → ✅ registar a lacuna e perguntar em lote."

## Interações

| Agente | Relação |
| --- | --- |
| `caminho/para/agente.md` | a montante (fornece X) / a jusante (consome Y) / paralelo (coordena Z) |

## Critérios de pronto

Checklist final verificável antes de o agente entregar (liga aos `checklists/` e ao portão da fase em
`core/quality-gates.md`):

- [ ] …
- [ ] …
