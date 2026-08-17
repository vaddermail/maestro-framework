# COMEÇAR AQUI — Arrancar um projeto novo com a Maestro

Este documento tem duas partes: a primeira é para **ti, humano**; a segunda é o **protocolo que a
primeira sessão de IA executa**. Se és um agente de IA a ler isto: salta para a Parte 2 e segue-a
à letra.

---

## Parte 1 — Para o humano (5 minutos)

### O que precisas

- Um repositório novo (Git recomendado, mas não obrigatório no dia 0).
- Um assistente de IA com acesso a ficheiros (Claude Code, Cowork, ou outro — ver `adapters/`).
- A tua ideia, mesmo que vaga. **Não precisas** de requisitos, arquitetura nem conhecimentos
  técnicos — obter isso de ti através de boas perguntas é trabalho da framework.

### Passos

1. Cria a pasta/repositório do teu projeto (ex.: `minha-app/`).
2. Descarrega o **ZIP da última release** do repositório-mãe da framework (nunca cópias de `main`
   a meio de trabalho — a release é a versão estável, com o número à vista) e extrai-o para uma
   pasta `Maestro/` dentro do projeto. Em alternativa, copia a pasta `Maestro/` de uma release já
   descarregada.
3. Abre uma sessão do teu assistente de IA na pasta do projeto.
4. Escreve:

   > Lê `Maestro/START-HERE.md` e arranca o projeto. A minha ideia é: **{{descreve a tua
   > ideia em 2–10 frases — o que é, para quem, que problema resolve}}**

5. A partir daqui, a IA conduz. O que podes esperar:
   - **Perguntas em lotes** com opções e recomendações — responde ao que souberes; "não sei" é uma
     resposta válida (a framework propõe um default e regista a decisão como revisitável).
   - **Artefactos escritos em `product/`** — tudo o que se decide fica em ficheiros teus, legíveis.
   - **Portões** — em certos momentos (fim de fase, decisões de âmbito/dinheiro/produção) a IA para
     e pede a tua validação explícita. És sempre tu quem decide.

### O que nunca deve acontecer (se acontecer, aponta o dedo à framework)

- A IA inventar respostas em vez de te perguntar.
- Avançar-se para código antes de existir especificação aprovada por ti.
- Uma ação destrutiva ou irreversível sem o teu OK explícito.
- O projeto "esquecer-se" do que foi decidido entre sessões — a memória vive em `STATE.md`
  e `product/`, não na sessão.

---

## Parte 2 — Protocolo da primeira sessão de IA (executar por esta ordem)

> **Agente:** és a primeira sessão de um projeto novo. O teu papel nesta sessão é o de
> **Orquestrador** (`core/orchestrator.md`). Não assumes nada sobre o produto; não escreves uma
> linha de código de produto nesta fase.

### 2.1 Ler a framework (nesta ordem, na íntegra)

1. `MANIFESTO.md` — os princípios que te vinculam.
2. `core/orchestrator.md` — o teu papel.
3. `core/lifecycle.md` — as fases F0–F9.
4. `core/artifact-protocol.md` — onde escreves o quê.
5. `core/question-engine.md` — como perguntas ao utilizador.
6. `core/project-memory.md` — como manténs a memória do projeto.
7. `workflows/W00-project-kickoff.md` — o workflow que vais executar já a seguir.

### 2.2 Instanciar a memória do projeto (F0)

Seguindo `workflows/W00-project-kickoff.md`:

1. Cria na **raiz do projeto** (não dentro de `Maestro/`):
   - `STATE.md` a partir de `templates/project/STATE.md.template` — a memória viva.
   - `CLAUDE.md` (ou ficheiro de instruções equivalente da tua ferramenta — ver `adapters/`)
     a partir de `templates/project/CLAUDE.md.template`.
   - `FRAMEWORK-IMPROVEMENTS.md` a partir de
     `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` — o registo, desde o dia 0, do que
     este projeto ensina à framework (`knowledge/README.md` §Como o conhecimento circula).
   - A árvore `product/` conforme `core/artifact-protocol.md`.
2. Regista em `STATE.md`: data, versão da framework copiada (`_meta/VERSION.md`), ferramenta de IA
   em uso, e a ideia bruta tal como o utilizador a deu (sem editar).
3. Se estiveres num repositório Git, propõe ao utilizador o primeiro commit ("fundação do projeto").
   Não o faças sem ele confirmar.

### 2.3 Calibrar o perfil de esforço

Pergunta ao utilizador (um lote só — formato do `core/question-engine.md`):

- Dimensão da ambição: protótipo para validar / produto interno / produto comercial / plataforma
  empresarial.
- Horizonte: semanas / meses / produto para anos.
- Equipa: só o utilizador + IA / equipa pequena / várias equipas.
- Restrições duras já conhecidas: orçamento, prazos, conformidade (RGPD, setor regulado),
  integrações obrigatórias, preferências tecnológicas fortes.

Com as respostas, fixa o **perfil de esforço** (`core/orchestrator.md` §Perfis) e regista-o em
`STATE.md`. O perfil determina a profundidade dos portões — nunca salta fases, apenas as
dimensiona.

### 2.4 Arrancar a Descoberta (F1)

Inicia `workflows/W01-discovery.md`: o `agents/00-discovery/idea-analyst.md` pega na ideia
bruta e o processo segue conforme o workflow. A partir daqui, o teu guia é o ciclo de vida — fase a
fase, portão a portão.

### 2.5 Encerrar cada sessão (sempre — desde a primeira)

Antes de terminar qualquer sessão de trabalho:

- [ ] Atualizar `STATE.md`: o que ficou feito, em curso, a seguir; decisões tomadas e pendentes;
      lições não-óbvias aprendidas (com o porquê e o como aplicar).
- [ ] Lições que são da **framework** (não do produto) registadas em `FRAMEWORK-IMPROVEMENTS.md`
      — no momento, não em retrospetiva; o envio à mãe acontece nos fechos de fase
      (`playbooks/report-framework-improvements.md`).
- [ ] Confirmar que todos os artefactos tocados estão escritos em `product/` (nada só na conversa).
- [ ] `bash Maestro/_meta/verify-project.sh` — o portão mecânico do processo: fundação, rasto
      das fases fechadas, memória fresca, génese em dia, cópia íntegra.
- [ ] Se algo ficou bloqueado à espera do utilizador, listá-lo em "Decisões pendentes" com contexto
      suficiente para a próxima sessão retomar sem re-perguntar.

---

## Relacionados

- `README.md` — mapa geral da framework.
- `MANIFESTO.md` — princípios inegociáveis.
- `workflows/W00-project-kickoff.md` — o detalhe da fase F0.
- `adapters/claude-code.md` — se a ferramenta for Claude Code (subagentes, skills, memória).
- `core/model-routing.md` — que modelo de IA usar para cada tipo de tarefa.
