# Adaptador: outros assistentes de código

Como executar a framework `Maestro` em assistentes **sem** subagentes nativos ou com orquestração
mais pobre que o Claude Code — **Cursor**, **GitHub Copilot**, **Codex CLI**, **aider** e afins. Não é
um mapeamento fechado por ferramenta (mudam depressa demais); são os **princípios de adaptação** e o
**mínimo viável** que fazem a framework funcionar em qualquer uma. O contrato da framework são os
**artefactos e os portões**, não a mecânica — por isso o essencial transporta-se; o que muda é o
conforto.

## O que a framework exige de qualquer ferramenta

Independentemente da ferramenta, três coisas têm de existir. Sem elas, não é a framework que corre —
é improviso:

1. **Memória em ficheiros versionados.** `CLAUDE.md` (ou o equivalente da ferramenta) para as regras
   estáveis + `STATE.md` para o estado vivo + `product/` para os artefactos canónicos. É isto que
   permite passar o testemunho entre sessões, pessoas e ferramentas (`core/project-memory.md`).
2. **Disciplina de portões manual.** Onde o Claude Code segura os portões pela sessão orquestradora,
   noutra ferramenta o humano (ou a sessão) segura-os **conscientemente**: os pontos de aprovação
   não-delegável do `core/orchestrator.md` §Human approval não desaparecem por a ferramenta não
   os impor.
3. **Roteamento de modelos, mesmo que grosseiro.** As camadas de `core/model-routing.md`
   aplicam-se mesmo quando a escolha é só "modelo forte" vs "modelo rápido": usar o forte no
   raciocínio distintivo, o rápido no mecânico.

Se a ferramenta oferecer isto, tem-se o **mínimo viável**. Tudo o resto é ganho de ergonomia.

## Onde cada ferramenta guarda as regras estáveis

O equivalente do `CLAUDE.md` — o ficheiro de instruções de projeto carregado automaticamente — existe
na maioria das ferramentas, com nome diferente. Instanciar sempre a partir de
`templates/project/CLAUDE.md.template` e ajustar o nome do ficheiro à ferramenta:

| Ferramenta | Onde vivem as regras estáveis de projeto |
| --- | --- |
| **Cowork** | Ficheiro de instruções de projeto (o equivalente do `CLAUDE.md`) na pasta partilhada do projeto; portões e lotes de perguntas correm na conversa — sem fan-out de subagentes, o painel de revisores corre sequencialmente |
| **Cursor** | Regras de projeto (`.cursor/rules/…`, ou o ficheiro de regras único do workspace) |
| **GitHub Copilot** | Ficheiro de instruções do repositório para o Copilot |
| **Codex CLI** | Ficheiro de instruções do agente na raiz do repo |
| **aider** | Ficheiro de convenções apontado à sessão + o `read`/contexto inicial |

Qualquer que seja o nome, a **fonte de verdade é o repositório** — o `STATE.md` e o `product/` são
partilhados e agnósticos de ferramenta; só o ficheiro de regras muda de rótulo. Duas pessoas em
ferramentas diferentes partilham contexto com um `git pull`.

## Simular subagentes quando não existem

O maior défice destas ferramentas é a **ausência de subagentes reais** — não há fan-out de N
especialistas às cegas + consolidador (`core/orchestrator.md` §Parallelism). Compensa-se com
**sessões sequenciais que comunicam por artefactos em ficheiro**:

- **Painel de arquitetura (F3) / revisores (F7):** em vez de N subagentes em paralelo, correr N
  **sessões/passagens sequenciais**, cada uma com o papel de um especialista, **escrevendo o seu
  relatório num ficheiro próprio** em `product/…` (formato de `templates/technical/review-report.md.template`).
  Só depois uma passagem de **consolidação** lê todos os ficheiros e produz o plano único. O
  isolamento "às cegas" consegue-se **não dando** a uma passagem os relatórios das outras até à
  consolidação.
- **Fatias verticais (F6):** correm uma de cada vez; a coordenação vive no `STATE.md` (o que está
  feito, o que está em curso), não na memória da sessão.
- **Loops (`loops/…`):** a mesma sessão itera, com a **condição de saída explícita** e a salvaguarda
  de parar às 3 iterações sem progresso — o registo de cada volta vai para `STATE.md`.

O artefacto em ficheiro **é** o mecanismo de passagem de contexto que os subagentes fariam em memória.
Mais lento, igualmente correto.

## O que se perde sem orquestração nativa — e como compensar

| Perda | Compensação |
| --- | --- |
| **Fan-out paralelo real** | Sequencial + artefactos em ficheiro (acima). Mais lento; o resultado tem de ser o mesmo. |
| **Portões impostos pela ferramenta** | Checklists explícitas em cada portão (`checklists/`), validadas à mão; o humano confirma antes de avançar. |
| **Roteamento automático de modelos** | Escolha manual consciente por tarefa; registar desvios em `STATE.md`. |
| **Toolset versionado para a equipa** | Documentar no `STATE.md`/README as extensões/MCP que a ferramenta usa, para paridade entre pessoas — mesmo que a ferramenta não as versione sozinha. |
| **Hook de arranque de sessão** | Protocolo de arranque **manual** e disciplinado (`workflows/W00-project-kickoff.md`): sincronizar, ler `STATE.md`, confirmar ambiente — todas as sessões, sem exceção. |
| **Memória automática da ferramenta** | Nenhuma perda real: a framework nunca dependeu dela — a memória canónica são os ficheiros versionados (`core/project-memory.md`). |

## Princípio de fundo

Uma ferramenta mais pobre **não baixa a fasquia** — só transfere para o humano e para a disciplina de
ficheiros o que o Claude Code automatiza. A framework foi desenhada agnóstica precisamente para isto:
os documentos de papéis e processos leem-se igual em qualquer assistente; muda só este adaptador. Se
uma ferramenta nova ganhar subagentes ou hooks, promove-se o seu mapeamento a um adaptador dedicado
(`core/extensibility.md`), sem tocar no resto.

## Relacionados

- `adapters/README.md` — a regra do acoplamento e o índice de adaptadores.
- `adapters/claude-code.md` — o mapeamento completo na ferramenta de referência (o alvo a imitar).
- `core/project-memory.md` — o mínimo viável: memória em ficheiros versionados.
- `core/orchestrator.md` — os portões e o paralelismo que se simulam à mão.
- `workflows/W00-project-kickoff.md` — o protocolo de arranque a executar manualmente.
- `core/extensibility.md` — como promover uma ferramenta nova a adaptador dedicado.
