# Loops — persistência inteligente

Um **loop** é um processo de convergência: repete uma ação enquanto uma condição indesejável persistir,
até essa condição desaparecer **ou** até uma salvaguarda decidir que não está a convergir e subir ao
utilizador. Onde um workflow (`workflows/README.md`) é uma sequência que termina quando o último passo
corre, um loop termina quando o **estado do mundo** atinge o alvo — ou quando prova que não vai atingir.

Os loops existem porque a maioria dos problemas de software não se resolve num passo: requisitos
ambíguos geram mais perguntas, um teste corrigido revela outro a falhar, um CVE tratado destapa um
seguinte. A framework não deixa isto ao improviso da sessão: cada tipo de problema recorrente tem um
loop com regras explícitas de entrada, saída e **anti-teimosia** — porque um agente de IA, deixado a
insistir, tanto converge como entra num ciclo interminável a "corrigir" a mesma coisa (ver
`knowledge/ai-pitfalls.md`).

## Anatomia de um loop (secções fixas)

Todo o `Lnn` segue a mesma estrutura, para o Orquestrador saltar de um para outro sem reaprender o
formato:

| Secção | O que responde | Regra |
| --- | --- | --- |
| **Identificação** | Nome, quando corre, que agente(s) executa a ação, modelo sugerido | Tabela no topo |
| **Métrica de progresso** | O número mensurável que o loop faz baixar | Tem de ser **contável e comparável** entre iterações — não "sensação de melhoria" |
| **Condição de entrada** | O que abre o loop | Um facto verificável (`há N itens no estado X`), não uma intenção |
| **Ação (o corpo da iteração)** | O que se faz **uma vez** por iteração | Um passo pequeno e reversível; delega no agente dono do problema |
| **Condição de saída (sucesso)** | Quando o loop fecha por ter resolvido | Métrica a zero (ou ≤ limiar acordado) e verificado por quem não produziu |
| **Salvaguarda anti-loop-infinito** | Quando o loop para **sem** ter resolvido | Regra dos 3 (abaixo) + tetos duros; sobe ao utilizador com diagnóstico |
| **Registo em STATE.md** | O rasto que fica | Linha de *ledger* do loop, atualizada a cada iteração |
| **Relacionados** | Para onde o leitor segue | 3–8 caminhos que existam no `_meta/INVENTORY.md` |

## A salvaguarda anti-loop-infinito (a "regra dos 3")

Nenhum loop corre indefinidamente. A salvaguarda base, obrigatória em **todos** os loops:

> **3 iterações consecutivas sem progresso → parar o loop, registar o diagnóstico e subir ao utilizador
> com opções.** "Sem progresso" = a métrica de progresso do loop não desceu estritamente entre iterações.

Isto operacionaliza a linha do `core/orchestrator.md` §Recovery ("loop que não converge → parar").
Cada loop especializa a regra com três defesas complementares:

1. **Estagnação** — a métrica não desce em 3 iterações seguidas (o caso base acima).
2. **Oscilação** — a métrica desce e volta a subir para o mesmo valor (ex.: corrigir A parte B, corrigir
   B parte A). Detetada por *fingerprint* do estado: se um estado já visto se repete, é ciclo, não
   progresso — parar de imediato, não esperar pela 3.ª iteração.
3. **Teto duro** — um número máximo absoluto de iterações por loop (definido em cada `Lnn`),
   independentemente de haver ou não progresso, para o caso patológico de "progresso" infinitesimal.

Quando uma salvaguarda dispara, o Orquestrador **não insiste nem inventa** (`knowledge/ai-pitfalls.md`
#3, #20): escreve em `STATE.md` → "Decisões pendentes" o que tentou, porque não convergiu e que opções
existem (mudar de abordagem, aceitar risco residual, cortar âmbito), e devolve a decisão a quem a pode
tomar. Uma corrida abortada por salvaguarda **não é falha do loop** — é o loop a fazer o seu trabalho.

## Convenção `Lnn` e ledger em STATE.md

- Loops numerados `Lnn-nome.md` (`_meta/STYLE-GUIDE.md` §6). A numeração não implica ordem de
  execução: os loops disparam por **condição**, não por sequência.
- Cada loop ativo tem **uma linha de ledger** em `STATE.md` (secção "Em curso"), atualizada a cada
  iteração, no formato:

  ```
  L02 · testes falhados · métrica 12→7→7 · iter 3 (teto 6) · último progresso: iter 2 · estado: EM RISCO
  ```

  Regista: a métrica ao longo das iterações (para se ver a tendência), a iteração atual e o teto, quando
  houve progresso pela última vez, e o estado (`em curso` / `em risco` / `parado — subiu ao utilizador`
  / `fechado`). Ao fechar, colapsa-se para uma linha no "Registo histórico" (`core/project-memory.md`
  §Higiene). Isto garante que a próxima sessão retoma um loop a meio **sem re-perguntar**.

## Quem abre, quem corre, quem fecha

- **Abre:** o Orquestrador, quando um workflow o dita (ex.: `W02` abre `L01`) ou quando um agente/guardião
  reporta a condição de entrada. Loops de operação (L03/L05/L06/L07/L08) também disparam por cadência ou
  evento em F9 (`workflows/W09-continuous-operation.md`).
- **Corre:** o agente dono do problema executa a ação de cada iteração (nomeado na Identificação de cada
  `Lnn`); o Orquestrador coordena, mede a métrica e aplica a salvaguarda. O modelo escolhe-se por tarefa
  (`core/model-routing.md`): a **ação** pode ser económica; a **decisão de aceitar risco ou
  parar** pede juízo (topo).
- **Fecha:** o portão (`core/quality-gates.md`) ou o guardião, com **verificação independente** —
  quem produziu a correção nunca é quem declara o loop fechado (`knowledge/ai-pitfalls.md` #20).

## Princípios transversais (não repetir, referenciar)

- **Corrigir a causa, nunca o sintoma nem o detetor.** Não se apaga o teste que falha nem se sobe o
  limiar para o smell passar — isso é fraudar a métrica. Detalhe por loop (L02, L04).
- **Cada iteração é reversível** (`knowledge/permanent-rules.md` §3): um passo de loop que não se
  pode desfazer exige aprovação humana antes de correr.
- **Prioridade por severidade/risco**, não por ordem de deteção (L03, L07): resolve-se primeiro o que
  mais dói.
- **Honestidade da métrica** (`knowledge/permanent-rules.md` §2): a métrica reporta-se com o valor
  real; um loop declarado fechado tem de o provar (métrica verificada, não afirmada).

## Os loops da framework

| Loop | Condição que persegue | Agente/dono | Fase típica |
| --- | --- | --- | --- |
| `loops/L01-ambiguous-requirements.md` | Requisitos ambíguos/contraditórios/em falta | `agents/01-requirements/ambiguity-hunter.md` | F2 (e onde surja ambiguidade) |
| `loops/L02-failing-tests.md` | Testes a falhar | `agents/10-quality/` | F6 (contínuo) |
| `loops/L03-security-issues.md` | Achados de segurança abertos | `agents/09-security/security-coordinator.md` | F7, F9 |
| `loops/L04-code-smells.md` | Code smells acima do limiar | `agents/13-guardians/quality-guardian.md` | F6, F9 |
| `loops/L05-inconsistencies.md` | Divergência docs↔código↔dados | Agente dono da fonte de verdade | Contínuo |
| `loops/L06-outdated-documentation.md` | Documentação fora de sincronia | `agents/13-guardians/documentation-guardian.md` | F9 (e após cada mudança) |
| `loops/L07-cves.md` | CVEs por triar | `agents/13-guardians/security-guardian.md` | F9 (cadência + evento) |
| `loops/L08-technical-debt.md` | Dívida técnica registada | Orquestrador + agente relevante | F9 (planeado) |

## Relacionados

- `core/orchestrator.md` — quem abre/coordena/fecha os loops (§Recuperação: a origem da regra dos 3).
- `workflows/README.md` — os processos que abrem loops dentro das fases.
- `core/quality-gates.md` — o que um loop tem de satisfazer para fechar.
- `core/project-memory.md` — onde vive o ledger de cada loop (`STATE.md`).
- `knowledge/ai-pitfalls.md` — a teimosia e a auto-validação que os loops travam.
- `core/model-routing.md` — que modelo executa a ação vs. decide parar.
