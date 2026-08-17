# W02 — Requisitos (F2)

> **Fase:** F2 · **Portão de saída:** P2 · **Agentes-núcleo:** `agents/01-requirements/` (6
> especialistas) + o loop `loops/L01-ambiguous-requirements.md`, conduzidos pelo `core/orchestrator.md`.

## Objetivo

Transformar o dossier de descoberta (F1) em **requisitos rastreáveis, regras de negócio explícitas,
RNF quantificados e um glossário sem sinónimos** — de modo que a arquitetura (F3), a especificação
(F5) e os testes possam consumir **sem adivinhar**. Aqui decide-se o *quê* e as *regras*, nunca o
*como* (isso é F3, `agents/02-architecture/`). A saída é a base da rastreabilidade em cadeia
(`core/artifact-protocol.md` §4): ideia → `RF-nnn` → `RN-nnn` → critérios de aceitação →
especificação → código → teste. A condição inegociável de fecho é **zero ambiguidades críticas
abertas**.

## Pré-condições (portão de entrada)

- [ ] P1 fechado: dossier de descoberta `aprovado` em `product/00-discovery/` — casos de
      utilização, MVP e prioridades confirmados pelo utilizador.
- [ ] Utilizador disponível para lotes de perguntas (a desambiguação é intensiva em Q&A).

Se o MVP não está delimitado ou as prioridades não estão aprovadas, **não se arranca F2** — devolve-se
a F1 (`core/lifecycle.md` §2). Requisitos construídos sobre um âmbito por fechar geram retrabalho.

## Passos (agente → artefacto)

A ordem segue `agents/01-requirements/README.md`. Todos os artefactos vivem em `product/01-requirements/`.

| # | Agente | Artefacto | Depende de |
| --- | --- | --- | --- |
| 1 | `agents/01-requirements/glossary-curator.md` | `glossario.md` (linguagem ubíqua, sinónimos proibidos) | dossier (F1) |
| 2 | `agents/01-requirements/requirements-engineer.md` | `requisitos-funcionais.md` (`RF-nnn` rastreáveis a `CU-nnn`/MVP) | 1, casos de utilização (F1) |
| 3 | `agents/01-requirements/business-rules-modeler.md` | `regras-de-negocio.md` (`RN-nnn`, invariantes, esboço de máquinas de estado) | 2 |
| 4 | `agents/01-requirements/nfr-specifier.md` | `requisitos-nao-funcionais.md` (`RNF-nnn` **quantificados**) | 2, riscos e objetivos (F1) |
| 5 | `agents/01-requirements/acceptance-criteria-writer.md` | `criterios-de-aceitacao.md` (CA verificáveis por `RF`) | 2 estabilizado, 3 |
| 6 | `agents/01-requirements/ambiguity-hunter.md` | `perguntas-e-respostas.md` (lote de perguntas + marcas de ambiguidade) | corre sobre 1–5 |

**Paralelismo (`core/orchestrator.md` §Parallelism):** os passos 3 (regras) e 4 (RNF) correm em
paralelo — as regras que os `RF` têm de respeitar e os atributos de qualidade que os atravessam não
partilham artefacto de escrita. O glossário (1) **continua a crescer durante toda a fase**, não é um
passo que fecha no início. O `cacador-de-ambiguidades` (6) **não é um passo final único**: dispara
sempre que um artefacto de F2 muda, alimentando o loop L01 até fechar, e é o **último a dar OK**.

> **Escala ao perfil (`core/artifact-protocol.md`):** num protótipo, os cinco artefactos
> colapsam num único `product/01-requirements/functional-requirements.md` — mas os **títulos de secção e os IDs**
> (`RF-nnn`, `RN-nnn`, `RNF-nnn`) mantêm-se, para a rastreabilidade sobreviver ao crescimento.

Cada `RF` referencia o(s) `CU-nnn` que satisfaz; cada `RN` aponta os `RF` que restringe; cada CA
prova um `RF`. Um requisito sem critério de aceitação é detetável — e não passa o portão. Templates:
`templates/specification/functional-requirement.md.template` e
`templates/specification/business-rules.md.template`.

## Pontos de decisão

As lacunas que os agentes levantam sobem ao Orquestrador, que as agrupa em **lotes por tema** (nunca
à peça — `core/question-engine.md`). Lotes típicos de F2:

- **Regras de negócio** — quem pode fazer o quê, com que limites, que invariantes nunca se violam.
- **Casos-limite** — o que acontece no zero, no vazio, no simultâneo, no fora-de-âmbito.
- **RNF** — números concretos: latência-alvo, disponibilidade, volumes, conformidade, retenção.
- **Prioridade de requisito** — obrigatório no MVP vs desejável (realimenta o `priorizador` de F1).

**Aprovação humana obrigatória (P2):** os **requisitos funcionais, as regras de negócio e os RNF**
são aprovados pelo utilizador — fixam o contrato do produto. Qualquer requisito que toque **dados
pessoais/sensíveis** marca-se aqui para o threat model de F5 (`agents/09-security/security-coordinator.md`,
com assento transversal).

## Loops que abre

- **`loops/L01-ambiguous-requirements.md`** — aberto pelo `cacador-de-ambiguidades`: enquanto existir
  ambiguidade, contradição ou lacuna **crítica**, converte-se cada uma em `P-nnn` e pergunta-se ao
  utilizador em lote. **Condição de saída:** zero pendências críticas por responder. **Salvaguarda
  anti-loop** (`loops/README.md`): 3 iterações sem progresso → o Orquestrador para, regista o
  diagnóstico e sobe ao utilizador com opções, em vez de insistir.

## Portão de saída (P2)

`core/quality-gates.md` + `checklists/definition-of-done.md`:

- [ ] `loops/L01-ambiguous-requirements.md` fechado: **zero ambiguidades/contradições críticas** abertas.
- [ ] `RNF-nnn` **quantificados** (nenhum "deve ser rápido" — cada um com número verificável).
- [ ] Regras de negócio **numeradas** (`RN-nnn`) e aprovadas; cada `RF` do MVP tem critério de aceitação.
- [ ] Glossário cobre os termos usados nos requisitos, sem sinónimos concorrentes.
- [ ] Nenhuma decisão de solução tomada (nada de tecnologia/ecrãs — isso é F3/F4).

**Quem verifica:** o `cacador-de-ambiguidades` (pendências) + o Orquestrador (completude e
rastreabilidade). **Quem aprova:** o utilizador (requisitos, regras, RNF). Com P2 fechado, arranca
`workflows/W03-architecture.md`.

## Recuperação de falhas e bloqueios

`core/orchestrator.md` §Recovery. Agente sem input (ex.: RNF sem riscos de F1) → agenda-se o
agente a montante ou junta-se ao próximo lote de perguntas. Ambiguidade que o utilizador não resolve
→ fica em `STATE.md` → "Decisões pendentes"; só se assume por defeito quando a **regra única** o
permite (`core/question-engine.md` §When to assume by default) — ambiguidades **críticas**
nunca se assumem.
Divergência descoberta mais tarde (em F5) devolve trabalho a esta fase — regista-se a razão em
`STATE.md` e reabre-se L01 (é o ciclo a funcionar, não uma falha).

## Perfis de esforço

| Perfil | Profundidade de F2 |
| --- | --- |
| **Protótipo** | Requisitos e regras num ficheiro único; RNF só os que travam decisões; CA nos fluxos de risco. |
| **Produto interno** | Estrutura completa; RNF quantificados com o dono do sistema; L01 fechado formalmente. |
| **Produto comercial** | + conformidade explícita nos RNF; critérios de aceitação em todos os `RF` do MVP. |
| **Plataforma empresarial** | + RNF com SLAs contratuais; regras de negócio revistas por stakeholders multi-equipa. |

## Relacionados

- `agents/01-requirements/README.md` — a categoria, a ordem e o grafo de dependências.
- `workflows/W01-discovery.md` — a fase anterior (fornece o dossier).
- `workflows/W03-architecture.md` — a fase seguinte (consome requisitos e RNF).
- `workflows/W05-specification.md` — onde o `modelador-de-regras-de-negocio` reentra.
- `loops/L01-ambiguous-requirements.md` — o loop que esta fase corre até fechar.
- `core/artifact-protocol.md` — a árvore `product/01-requirements/` e a cadeia de IDs.
