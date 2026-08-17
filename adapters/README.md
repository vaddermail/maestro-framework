# Adaptadores

Onde a framework **agnóstica** encosta a uma **ferramenta concreta**. Todo o resto da framework
descreve **papéis e processos** — o que um agente faz, que artefactos produz, que portão o guarda —
sem nunca assumir com que ferramenta esse trabalho é executado. Um adaptador faz a ponte: diz **como
uma ferramenta específica** (Claude Code, Cursor, Copilot, …) realiza esses papéis e processos.

Esta separação é o princípio 18 do `_meta/STYLE-GUIDE.md`: a framework não executa nada sozinha;
o acoplamento a ferramentas vive **só aqui**.

## A regra do acoplamento

**Nenhum documento fora de `adapters/` pode assumir uma ferramenta.** Concretamente:

- Um documento de agente (`agents/…`) descreve um **papel** (inputs, responsabilidade, outputs,
  interações) — nunca "corre o subagente X" nem "usa o plugin Y". A mecânica de execução é do
  adaptador.
- Um workflow (`workflows/…`) descreve uma **sequência de passos e portões** — não "invoca a skill
  Z". Como cada passo é despoletado é do adaptador.
- O `core/` descreve **contratos** (memória em ficheiros, camadas de modelo abstratas, portões) —
  os nomes concretos (`CLAUDE.md`, um modelo específico, um ficheiro de settings) entram no adaptador.

Se um documento do núcleo, dos agentes ou dos workflows precisar de mencionar uma ferramenta, o
lugar certo é remetê-lo para o adaptador respetivo — como fazem o `core/orchestrator.md` e o
`core/model-routing.md`, que apontam para `adapters/claude-code.md` em vez de embeberem
mecânica de ferramenta. Assim, trocar de ferramenta muda **um** ficheiro, não a framework toda.

## O que um adaptador tem de mapear

Cada adaptador responde às mesmas perguntas, para a sua ferramenta:

| Papel/processo da framework | O adaptador diz… |
| --- | --- |
| **Orquestrador** (`core/orchestrator.md`) | quem assume o papel de maestro (a sessão principal? um agente dedicado?) |
| **Fichas de agente** (`agents/…`) | como um papel vira execução (subagente dedicado, sessão sequencial, skill) |
| **Workflows/loops** (`workflows/`, `loops/`) | como uma sequência é conduzida e onde fica o registo de progresso |
| **Memória** (`core/project-memory.md`) | onde vivem as regras estáveis e o estado vivo, e como a ferramenta os carrega |
| **Roteamento de modelos** (`core/model-routing.md`) | que modelos concretos preenchem as camadas topo/padrão/económico/mecânico |
| **Portões e aprovação humana** (`core/quality-gates.md`) | como o modo de autonomia da ferramenta respeita os portões que exigem o humano |
| **Ferramentas de apoio** | que plugins/integrações a ferramenta oferece, versionados para toda a equipa |

## Os adaptadores desta framework

| Adaptador | Ferramenta | Estado |
| --- | --- | --- |
| `adapters/claude-code.md` | **Claude Code** — CLI/IDE com subagentes, skills, plugins, MCP e hooks | Mapeamento completo e testado (é a ferramenta do projeto-mãe) |
| `adapters/other-assistants.md` | **Outros assistentes** — Cursor, Copilot, Codex CLI, aider e afins | Princípios de adaptação e mínimo viável |

Adicionar um adaptador novo segue o `core/extensibility.md`: cria-se o ficheiro aqui, regista-se
no `_meta/INVENTORY.md` no mesmo passo, e **não se toca** em nenhum documento agnóstico — se o
mapeamento exigir mexer no núcleo, é sinal de que o acoplamento fugiu do adaptador.

## Relacionados

- `_meta/STYLE-GUIDE.md` — princípio 18 (o acoplamento vive só em adaptadores).
- `adapters/claude-code.md` — mapeamento concreto para Claude Code.
- `adapters/other-assistants.md` — adaptação a outros assistentes de código.
- `core/orchestrator.md` — o papel que cada adaptador materializa numa ferramenta.
- `core/extensibility.md` — como acrescentar um adaptador sem tocar nos existentes.
