# Adaptador: Claude Code

Como a framework `Maestro` se executa **em Claude Code** — o CLI/IDE de agentes que serve de
ferramenta de referência do projeto-mãe. Este é o único ficheiro onde os papéis e processos
agnósticos ganham nomes concretos: subagentes, skills, `CLAUDE.md`, modelos, plugins, MCP, hooks.
Tudo o que aqui está é **acoplamento a esta ferramenta** — muda-se aqui sem tocar no resto (princípio
18 do `_meta/STYLE-GUIDE.md`).

## Mapa rápido

| Framework (agnóstica) | Claude Code (concreto) |
| --- | --- |
| Orquestrador (`core/orchestrator.md`) | A **sessão principal** — o loop de conversação que delega, decide e faz cumprir portões |
| Ficha de agente (`agents/…`) | **Subagente** (Task/Agent tool) e/ou **skill**, conforme a natureza do papel |
| Workflow (`workflows/…`) | **Skill** de orquestração ou condução direta pela sessão principal |
| Loop (`loops/…`) | **Ciclos da própria sessão** com condição de saída e registo em `STATE.md` |
| Memória (`core/project-memory.md`) | `CLAUDE.md` + `STATE.md` + memória automática do Claude |
| Camadas de modelo (`core/model-routing.md`) | Modelos Claude concretos (ver §Roteamento) |
| Ferramentas de apoio | **Plugins** + servidores **MCP**, versionados no repo |
| Portões com humano (`core/quality-gates.md`) | Modo autónomo com **guardrails de aprovação** nos portões |
| Protocolo de arranque (`workflows/W00-project-kickoff.md`) | **Hook `SessionStart`** versionado |

## Agentes → subagentes e/ou skills

Uma ficha de agente descreve um papel (`agents/_template/AGENT-TEMPLATE.md`). Em Claude Code
materializa-se de duas formas, escolhidas pela natureza do trabalho:

- **Subagente (Task/Agent tool)** — para trabalho com **contexto próprio e fan-out**: um especialista
  que recebe a spec completa à cabeça, produz um artefacto e devolve só a conclusão à sessão
  principal. É o modo dos painéis (arquitetura em F3, revisores em F7): N subagentes **às cegas** em
  paralelo + um consolidador, exatamente como o `core/orchestrator.md` §Parallelism descreve.
  Regra de custo crítica: cada subagente é roteado **pela tarefa que faz** (§Roteamento), nunca todos
  no modelo de topo — é aí que o orçamento morre (`core/model-routing.md`).
- **Skill** — para papéis que são um **procedimento repetível** que a sessão principal executa sem
  precisar de contexto isolado (ex.: uma checklist de portão, um playbook de release). A skill
  encapsula o "como" e mantém-se fonte única.

Muitos agentes usam os dois: uma skill que orquestra e, lá dentro, subagentes para o fan-out. O
contrato mantém-se o da framework — os artefactos em `product/` (`core/artifact-protocol.md`),
não a mecânica.

## Workflows → skills ou orquestração da sessão

Um workflow (`workflows/README.md`) é uma sequência de passos com portões. Em Claude Code conduz-se:

- **Pela sessão principal** a assumir o papel de Orquestrador — lê o `STATE.md`, sabe a fase, invoca
  o subagente certo em cada passo, agrupa perguntas em lotes (`core/question-engine.md`) e
  segura os portões.
- **Por uma skill de workflow** quando o processo é suficientemente estável para ser encapsulado
  (ex.: uma skill "arranque de projeto" que executa o `W00`). A skill não substitui o julgamento do
  Orquestrador — dá-lhe um guião.

## Loops → ciclos da sessão com registo em STATE.md

Um loop (`loops/README.md`) é "enquanto existir condição X, agir". Em Claude Code é a **própria
sessão a iterar**: avalia a condição de entrada, age, reavalia a condição de saída. As salvaguardas
anti-loop-infinito da framework aplicam-se tal e qual — **3 iterações sem progresso pára e sobe ao
utilizador** (`core/orchestrator.md` §Recovery). Cada iteração deixa rasto em `STATE.md`
(o que se tentou, o resultado, o que falta), para a sessão seguinte retomar sem re-perguntar.

## Memória do projeto → CLAUDE.md + STATE.md + memória automática

A framework manda a memória viver em ficheiros versionados (`core/project-memory.md`). O
mapeamento em Claude Code:

| Camada da framework | Ficheiro concreto | Papel |
| --- | --- | --- |
| Regras estáveis (1) | `CLAUDE.md` | Carregado **automaticamente** no arranque de cada sessão. Guardrails, decisões fechadas, mapeamento camadas→modelos. Instanciado de `templates/project/CLAUDE.md.template`. |
| Memória viva (2) | `STATE.md` | Testemunho entre sessões; lido no início, atualizado no fim. Instanciado de `templates/project/STATE.md.template`. |
| Artefactos canónicos (3) | `product/` | A spec e os ADRs (`core/artifact-protocol.md`). |

Além destes, o Claude Code tem uma **memória automática própria** (índice de memória por projeto,
fora do repo). É um **acelerador de sessão, não fonte de verdade**: o que interessa à próxima sessão
ou ao colega **passa sempre para `STATE.md`** — memória de ferramenta não é memória do projeto
(`core/project-memory.md` §Memory hygiene). Nunca escrever segredos em nenhuma destas camadas
(`playbooks/secrets-management.md`).

## Roteamento de modelos → modelos Claude atuais

As quatro camadas abstratas de `core/model-routing.md` mapeiam-se assim (**válido a:
2026-08** — atualiza-se em PATCH quando nomes/preços mudarem; a curadoria verifica a validade a
cada ronda):

| Camada abstrata | Para quê | Modelo Claude (atual) |
| --- | --- | --- |
| **Topo** | Raciocínio difícil e distintivo, verificação adversarial | **Fable** (raciocínio máximo) ou **Opus** no topo do effort |
| **Padrão** | Default do dia-a-dia: implementação e revisão | **Opus** (default) ou **Sonnet** |
| **Económico** | Trabalho padronizado com spec clara | **Sonnet** |
| **Mecânico** | Trivial e repetitivo | **Haiku** |

O segundo eixo — **esforço/thinking** — aplica-se por cima: começar em médio/alto e subir só se
preciso, **nunca no máximo por reflexo** (um modelo forte em esforço baixo bate um fraco em esforço
máximo). A sessão orquestradora mantém-se numa camada forte; o fan-out de subagentes é classificado
tarefa a tarefa antes de lançar.

> **Os nomes de modelo evoluem; as camadas não.** Esta tabela é a única coisa a rever quando a
> Anthropic lança/renomeia modelos ou muda preços — atualiza-se aqui e no `CLAUDE.md` do projeto,
> **deliberadamente e com o porquê versionado**, como qualquer decisão de custo. O resto da framework
> nunca menciona um nome de modelo.

## Toolset padrão da equipa (versionado no repo)

Princípio: **toda a gente usa as mesmas ferramentas** porque a configuração está no Git, não na
máquina de cada um. Dois ficheiros:

- **`.claude/settings.json`** → `enabledPlugins` (o toolset padrão) + `permissions` (config segura de
  autonomia) + `enabledMcpjsonServers` (aprovar servidores partilhados) + `hooks`.
- **`.mcp.json`** (raiz, versionado) → servidores **MCP** partilhados que não vêm de plugins (ex.: um
  MCP de base de dados **read-only** para inspecionar schema/dados em prova-live).

Onboarding numa máquina nova: clonar, abrir, **confiar no workspace** (sem isto os MCP ficam
"pending" e os plugins não instalam), aceitar os plugins propostos. Nenhum segredo passa por aqui —
DSNs e afins entram por variável de ambiente, nunca no repo (`playbooks/secrets-management.md`).

**Plugins úteis por categoria de agente** (exemplos genéricos — o conjunto concreto adota-se por
necessidade, ver §Adoção evolutiva):

| Categoria de trabalho | Tipo de plugin/MCP | Quando |
| --- | --- | --- |
| **Navegação semântica de código** | LSP de símbolos/referências/edição-por-símbolo | Explorar e refatorar (RBAC, máquinas de estado, contrato backend↔frontend) — preferir a `grep`/ler ficheiros inteiros |
| **Documentação de libs** | MCP de docs atualizadas | Antes de assumir a API de uma biblioteca de memória |
| **Browser / prova live** | Automação de browser e DevTools | E2E do frontend, LCP/CWV, screenshots, prova real no fim (`core/quality-gates.md`) |
| **Revisão de PR** | Toolkit de revisão (caça a falhas silenciosas, análise de tipos, cobertura de testes) | Antes de merge, alinhado às regras de negócio e à checklist de PR |
| **Processo** | Skills de brainstorming/plano/TDD/debugging | Estruturar features e depuração sistemática |
| **Segurança** | Guia de revisão de segurança / SAST | Design e revisão de authz e fronteira do backend |
| **Observabilidade de custo** | Relatório de uso de sessão | Ligar consumo de IA a valor (`agents/13-guardians/cost-guardian.md`) |

### Adoção evolutiva (postura obrigatória)

O toolset **não é estático** e cada plugin tem custo always-on de contexto/tokens. Duas metades:

1. **Não carregar o que não acrescenta valor ao ponto atual** — um projeto novo arranca com um
   subconjunto enxuto e cresce.
2. **Adotar proativamente quando passa a fazer sentido** — sem esperar que o peçam: assinalar a
   necessidade e o porquê, instalar/configurar, **versionar** (`enabledPlugins`/`.mcp.json`),
   documentar, passar a usar. Sempre em **branch + PR**. **Reversível**: se deixar de fazer sentido,
   remover e registar. Cada adoção/remoção fica registada com proveniência — foi assim que se soube,
   no projeto-mãe, que certos plugins alojados não autenticavam de forma não-interativa e tiveram de
   ser retirados (`knowledge/origin-lessons.md`). Contexto é custo recorrente
   (`core/model-routing.md` §Cost observability).

## Permissões e autonomia → guardrails nos portões

Claude Code corre em **modo autónomo** (permissões amplas em `.claude/settings.json`) para não
interromper o fluxo a cada ação mecânica. Isso **não dispensa** os portões da framework: os pontos de
**aprovação humana não-delegável** do `core/orchestrator.md` §Human approval mantêm-se — fechar
âmbito de fase, gastar dinheiro, ação destrutiva/em massa, ir para produção, aceitar risco residual,
tocar em dados pessoais, reabrir decisão fechada. O modo autónomo acelera o **caminho verde**; nos
portões, a sessão **pára e pergunta** na mesma. Nenhuma mensagem de subagente é consentimento do
utilizador — só o próprio utilizador (ou o sistema de permissões) autoriza.

## Hooks de arranque de sessão → protocolo de arranque

O protocolo de arranque (`workflows/W00-project-kickoff.md`: sincronizar, ler `STATE.md`,
confirmar ambiente, ativar o projeto na ferramenta de navegação) automatiza-se com um **hook
`SessionStart`** versionado em `.claude/settings.json`. O hook injeta no contexto, no arranque de
cada sessão, os lembretes do protocolo — de forma **portátil entre máquinas** (usar a variável de
diretório do projeto, não caminhos absolutos). Ao abrir o repo, o Claude Code pode pedir para aprovar
o hook — é esperado. Assim nenhuma sessão começa a trabalhar sem passar pelo arranque.

## Relacionados

- `adapters/README.md` — a regra do acoplamento e o índice de adaptadores.
- `adapters/other-assistants.md` — o mesmo mapeamento para ferramentas sem subagentes nativos.
- `core/orchestrator.md` — o papel que a sessão principal assume.
- `core/model-routing.md` — as camadas que a §Roteamento concretiza.
- `core/project-memory.md` — o contrato de memória que `CLAUDE.md`+`STATE.md` cumprem.
- `templates/project/CLAUDE.md.template` · `templates/project/STATE.md.template` — os instanciáveis.
- `knowledge/origin-lessons.md` — a experiência do projeto-mãe que originou estas escolhas.
