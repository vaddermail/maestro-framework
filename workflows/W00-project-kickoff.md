# W00 — Arranque de Projeto (F0)

> **Fase:** F0 · **Portão de saída:** P0 · **Agente-núcleo:** o Orquestrador em pessoa
> (`core/orchestrator.md`) — nenhum especialista de produto trabalha ainda.

## Objetivo

Pôr a fundação de pé: a framework instalada no repositório do projeto, a **memória do projeto**
instanciada (`STATE.md`, `CLAUDE.md`, `FRAMEWORK-IMPROVEMENTS.md`, árvore `product/`), o
**perfil de esforço** calibrado e a **ideia bruta** registada sem edição. No fim de F0 o projeto tem onde escrever tudo o que se decidir
a seguir — e não decidiu ainda nada sobre o produto.

## Pré-condições (portão de entrada)

Não há portão a montante (é a primeira fase). Exige-se apenas:

- [ ] Uma pasta/repositório do projeto, com `Maestro/` copiada para dentro a partir do ZIP de uma
      **release** (`START-HERE.md` §Part 1).
- [ ] Auto-verificação da cópia instalada **verde**: `bash Maestro/_meta/verify.sh` — uma cópia
      corrompida ou parcial descobre-se aqui, não a meio de F5.
- [ ] Uma sessão de IA com acesso a ficheiros, na raiz do projeto.
- [ ] A ideia do utilizador em 2–10 frases (mesmo vaga — refiná-la é trabalho de F1, não pré-requisito).
- [ ] Ambiente confirmado (a ferramenta de IA lê/escreve ficheiros; se for Claude Code, ver o
      protocolo de arranque de `adapters/claude-code.md`).

## Passos (agente → artefacto)

| # | Quem | Ação | Artefacto |
| --- | --- | --- | --- |
| 1 | Orquestrador | Ler a framework pela ordem de `START-HERE.md` §2.1 (Manifesto → orquestrador → ciclo → protocolo → perguntas → memória → este workflow) | — (só leitura) |
| 2 | Orquestrador | Criar `STATE.md` na raiz a partir de `templates/project/STATE.md.template` | `STATE.md` |
| 3 | Orquestrador | Criar `CLAUDE.md` (ou equivalente da ferramenta) a partir de `templates/project/CLAUDE.md.template`, incluindo o mapeamento camadas→modelos (`core/model-routing.md`) | `CLAUDE.md` |
| 4 | Orquestrador | Criar `FRAMEWORK-IMPROVEMENTS.md` na raiz (de `templates/project/FRAMEWORK-IMPROVEMENTS.md.template`) e o dossier de génese em `product/99-records/genesis.md` (de `templates/project/GENESIS.md.template`) — o que o projeto ensina à framework, e os números que provam a promessa | `FRAMEWORK-IMPROVEMENTS.md`, `product/99-records/genesis.md` |
| 5 | Orquestrador | Criar a árvore `product/` conforme `core/artifact-protocol.md` (colapsada ao perfil — ver §Perfis) | `product/` |
| 6 | Orquestrador | Registar em `STATE.md`: data, versão da framework (`_meta/VERSION.md`), **repositório da framework-mãe** (org/repo ou URL de origem da cópia — o destino dos reportes de melhorias e a fonte das sincronizações), ferramenta de IA, e a **ideia bruta tal como o utilizador a deu** (sem editar) | `STATE.md` |
| 7 | Orquestrador | Colocar o lote único de calibração (§Pontos de decisão) e fixar o **perfil de esforço** | `STATE.md` |
| 8 | Orquestrador | Propor o primeiro commit ("fundação do projeto") — só executar se o utilizador confirmar (`START-HERE.md` §2.2) | — |

Nada aqui consome artefactos a montante (não os há); tudo é escrita de fundação. O passo 7 depende
das respostas do utilizador — se ele não responder, os passos seguintes ficam bloqueados e a pendência
fica em `STATE.md` → "Decisões pendentes" (`core/orchestrator.md` §Recovery).

## Pontos de decisão

Um **único lote** de calibração ao utilizador (formato de `core/question-engine.md`,
`START-HERE.md` §2.3):

- **Dimensão da ambição** → escolhe o perfil de esforço: protótipo / produto interno / produto
  comercial / plataforma empresarial (`core/orchestrator.md` §Effort profiles). **Decisão do utilizador**
  (dimensiona todos os portões seguintes).
- **Horizonte** (semanas / meses / anos) e **equipa** (só utilizador+IA / equipa pequena / várias
  equipas) — afinam a profundidade e a disciplina de Git.
- **Restrições duras já conhecidas** — orçamento, prazos, conformidade (ex.: RGPD, setor regulado),
  integrações obrigatórias, preferências tecnológicas fortes. Registam-se como **entrada** para F1/F3,
  não como decisões fechadas ainda.
- **Limiares de qualidade** — aceitar os defaults do perfil para code smells e dívida técnica
  (tabelas em `loops/L04-code-smells.md` e `loops/L08-technical-debt.md`) ou fixar valores próprios;
  o acordado regista-se no `CLAUDE.md`.

Aprovação humana obrigatória: **o perfil de esforço** (afeta custo e profundidade de tudo o resto).

## Loops que abre

Nenhum loop de fase. F0 é uma sequência curta e determinística. O único mecanismo iterativo é o
motor de perguntas do lote de calibração, que fecha assim que o perfil está fixado.

## Portão de saída (P0)

`core/quality-gates.md`:

- [ ] `STATE.md`, `CLAUDE.md`, `FRAMEWORK-IMPROVEMENTS.md` e árvore `product/` criados na raiz
      (fora de `Maestro/`).
- [ ] Ideia bruta registada sem edição; versão da framework, **repositório da framework-mãe** e
      ferramenta de IA anotados.
- [ ] Perfil de esforço **confirmado pelo utilizador** e registado.
- [ ] Mapeamento camadas→modelos preenchido no `CLAUDE.md`.

**Quem aprova:** o utilizador (perfil de esforço). **Quem verifica:** o Orquestrador (existência e
formato dos ficheiros). Com P0 fechado, arranca `workflows/W01-discovery.md`.

## Perfis de esforço

O perfil calibrado aqui **dimensiona todas as fases seguintes** — mas F0 em si é praticamente
constante:

| Perfil | Efeito em F0 |
| --- | --- |
| **Protótipo** | Árvore `product/` colapsada (um ficheiro por fase, ex.: `product/00-discovery/dossier.md`); guardiões marcados como desativados no `CLAUDE.md`. Os **nomes e IDs** mantêm-se para não perder rastreabilidade se crescer (`core/artifact-protocol.md`). |
| **Produto interno** | Árvore completa; guardiões em cadência mensal anotada no `CLAUDE.md`. |
| **Produto comercial** | Árvore completa; nota no `CLAUDE.md` de auditoria adversarial antes do go-live e pentest obrigatório. |
| **Plataforma empresarial** | Como o comercial + registo de que toda a decisão estrutural exige ADR e de que a revisão global (`workflows/W12-global-review.md`) é periódica. |

Mudar de perfil mais tarde é legítimo (regista-se em `STATE.md` e executam-se os portões que o novo
perfil exige — `core/orchestrator.md` §Effort profiles).

## Relacionados

- `START-HERE.md` — o protocolo humano+IA de que este workflow é o detalhe.
- `core/project-memory.md` — o que `STATE.md` e a memória em ficheiros garantem.
- `core/artifact-protocol.md` — a árvore `product/` a criar.
- `templates/project/STATE.md.template` · `templates/project/CLAUDE.md.template` ·
  `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` — os instanciáveis.
- `workflows/W01-discovery.md` — a fase que arranca a seguir.
- `adapters/claude-code.md` — arranque de sessão e memória na ferramenta concreta.
