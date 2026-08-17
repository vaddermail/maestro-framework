# Starters

Onde a framework **agnóstica** encosta a uma **stack concreta**. Pelo mesmo padrão de
`adapters/README.md` — que confina o acoplamento a ferramentas — esta pasta confina o
acoplamento a stacks: o **contrato** do starter define-se aqui, agnóstico; as **implementações**
vivem em `starters/starter-<stack>/` (nesta pasta ou como repositórios irmãos), são opcionais e
nascem de projetos reais. O motivo é o maior custo evitável de arranque: a fatia 0
(`checklists/definition-of-done.md` §F6 — Esqueleto (fatia 0)) exige o **resultado** — runners,
guardrails e pipeline verdes antes da primeira fatia — mas cada projeto paga a **construção** do
zero. Um starter pré-paga essa construção sem casar a framework a stack nenhuma.

## O que um starter é — e o que não é

Um starter é um esqueleto de código para uma stack concreta que entrega a fatia 0 **cumprida no
primeiro commit**: testes a correr em CI, guardas ligadas e pipeline verde antes de existir
qualquer funcionalidade.

O que **não** é:

- **Não é a framework.** A Maestro continua a ser documentação executável, agnóstica de stack
  (`README.md` §Perguntas frequentes). Um starter é código, acoplado por natureza — e por isso
  vive só aqui, como o acoplamento a ferramentas vive só em `adapters/`.
- **Não é obrigatório.** Um projeto sem starter para a sua stack constrói a fatia 0 à mão, como
  sempre — o portão é exatamente o mesmo; o starter só muda quem paga a construção.
- **Não é um template de produto.** Zero decisões de domínio: o mesmo starter serve uma loja
  online, um SaaS B2B de faturação ou uma app interna de RH. Traz engenharia de base — nunca
  ecrãs, regras de negócio ou modelo de dados do produto.
- **Não dispensa o processo.** A estratégia de testes escreve-se antes da fatia 0
  (`workflows/W06-build.md` §Pré-condições) e a checklist do esqueleto confirma-se item a
  item na mesma — usar um starter é verificar mais depressa, não verificar menos.

## O contrato — o que todo o starter entrega no primeiro commit

Tudo abaixo é verificável; um starter que falhe um item não entra nesta pasta:

- [ ] **Runner de testes por superfície** (frontend, backend, …) configurado e **a correr em CI**,
      com pelo menos um teste real a passar por superfície — typecheck e build a passar não
      contam como testado (`checklists/pre-merge.md`).
- [ ] **Guardrails ligados** no CI desde o primeiro commit: lint, análise estática, fronteiras de
      arquitetura e varrimento de segredos.
- [ ] **Pipeline verde no dia 0**, com as superfícies a correr separadas — sem passos manuais não
      documentados entre a cópia limpa e o verde.
- [ ] **Fatia 0 cumprida**: o bloco "F6 — Esqueleto (fatia 0)" da
      `checklists/definition-of-done.md` confirmado item a item no README do starter, com a
      evidência de cada um.
- [ ] **Estrutura compatível com o protocolo de artefactos**: o starter não cria, não ocupa nem
      colide com `product/`, `CLAUDE.md`, `STATE.md` ou a pasta da framework — esses caminhos
      são do projeto (`core/artifact-protocol.md` §The project's `product/` tree). O código segue a forma
      prevista no fim dessa árvore (apps/, packages/, infra/, … conforme a arquitetura).
- [ ] **Zero segredos**: nenhum valor real no repositório nem no histórico; configuração sensível
      por `*.example` documentado e injeção em runtime (`playbooks/secrets-management.md`).
- [ ] **Versões estáveis fixadas**: runtime LTS, majors GA, lockfile em controlo de versões
      (`knowledge/permanent-rules.md` §6 — Versões estáveis por defeito).
- [ ] **Um comando único de arranque** documentado no README do starter: de cópia limpa até
      pipeline local verde com um comando (ou um script que encadeia os passos).
- [ ] **Proveniência declarada** no README do starter: versão da framework com que foi validado
      (`_meta/VERSION.md`), data da validação e código do projeto de origem (P2, P3, … — a mesma
      regra de anonimato de `knowledge/candidates.md`).

## A regra-espelho do isolamento

O princípio 19 do `_meta/STYLE-GUIDE.md` diz que nenhum documento assume stack. Os starters são
a exceção confinada — e o isolamento corta nos dois sentidos:

- **Nada fora de `starters/` pode assumir stack.** Nenhum documento do núcleo, agente, workflow,
  checklist ou template pode depender de existir um starter, referir um starter concreto ou
  tratar uma tecnologia como dada. Um documento agnóstico que precise de falar de arranque
  acelerado remete para esta pasta — como remete para `adapters/` quando o assunto é
  ferramenta.
- **Nada num starter pode alterar contratos da framework.** Um starter cumpre o contrato acima;
  não redefine portões, checklists, protocolo de artefactos nem workflows. Se cumprir o contrato
  parecer exigir mexer num documento agnóstico, o acoplamento fugiu do sítio — é o starter que
  está errado (o espelho exato da regra de `adapters/README.md`).

Consequência prática, e critério de auditoria: apagar `starters/` inteiro não muda uma vírgula no
resto da framework.

## Como nasce um starter

Nunca de imaginação. Um starter **destila-se de um projeto real** que provou o esqueleto — CI
verde ao longo da construção, guardas a apanhar problemas a sério — e entra pelo mesmo circuito
que todo o conhecimento da framework:

1. O projeto regista, durante a construção, o que o seu esqueleto ensinou — categoria `bloco` do
   `templates/project/FRAMEWORK-IMPROVEMENTS.md.template`.
2. No fecho de um marco, reporta à framework-mãe (`playbooks/report-framework-improvements.md`),
   incluindo a destilação: o esqueleto extraído do produto, sem código de domínio, sem dados e
   sem segredos.
3. O `agents/14-meta/framework-curator.md` trata a proposta como candidata, com as regras de
   promoção de `knowledge/candidates.md` §Regras de entrada e saída. A promoção entra por PR
   de curadoria (`playbooks/framework-curation.md` §Passos) como **MINOR** em
   `_meta/VERSION.md` — criando `starters/starter-<stack>/` (ou o apontador para o repositório
   irmão), a linha na tabela desta pasta e o registo em `_meta/INVENTORY.md`, tudo no mesmo
   passo (`core/extensibility.md`).

## Como se mantém — e como apodrece à vista

Stacks movem-se mais depressa do que processos; um starter parado mente por omissão. A mesma
lógica de expiração de `knowledge/candidates.md` aplica-se aqui:

- Cada starter **declara a versão da framework com que foi validado** e a data — no seu README e
  na tabela desta pasta.
- **Confirmação:** cada projeto novo que use o starter e feche a fatia 0 verde com ele reporta-o
  como issue `melhorias` — a confirmação é contável e rastreável, nunca subjetiva.
- **Expiração:** 12 meses (ou 3 rondas de curadoria) sem confirmação nova, ou um MAJOR da
  framework publicado depois da validação, e o curador marca o starter como `por-revalidar` na
  tabela desta pasta, na ronda seguinte. Continua utilizável — mas quem o copiar fica avisado de
  que o dia 0 verde já não está garantido e de que a fatia 0 tem de se verificar por inteiro.
- **Revalidar** = correr o comando de arranque contra a versão atual da framework e confirmar o
  contrato item a item; regista-se a nova data e versão.

## Como um projeto usa um starter

A opção entra no arranque (`workflows/W00-project-kickoff.md`) quando a stack já é uma
restrição dura declarada pelo utilizador — muitos projetos chegam assim
(`workflows/W00-project-kickoff.md` §Pontos de decisão). Quando a stack ainda está em aberto,
a decisão pertence a F3 e o momento natural do starter passa a ser a entrada de F6, imediatamente
antes da fatia 0. Em qualquer dos casos, a sequência é a mesma:

1. Copiar o starter para a raiz do projeto **depois** de copiar a framework (`START-HERE.md`
   §Parte 1) — e confirmar que não tocou na pasta da framework, em `CLAUDE.md`, `STATE.md` nem
   em `product/`.
2. Correr o comando único de arranque documentado no README do starter.
3. Verificar a fatia 0 **verde**: pipeline a correr nas superfícies, guardrails ativos — item a
   item pela `checklists/definition-of-done.md` §F6 — Esqueleto (fatia 0), nunca por confiança.
4. Registar em `STATE.md`: starter usado, versão do starter e da framework validada, e a escolha
   de stack como decisão a formalizar em ADR (`product/02-architecture/decisions/`).

Um projeto **sem** starter para a sua stack não perde nada de contratual: constrói a fatia 0 à
mão, como sempre — e, fechado o MVP, é o candidato natural a destilar o próximo starter.

## Os starters desta pasta

| Starter | Stack | Validado com | Estado |
| --- | --- | --- | --- |
| *(nenhum ainda)* | — | — | — |

Estado honesto: **ainda não existe nenhum `starter-<stack>`**. O primeiro candidato natural é a
destilação de um produto real do ecossistema — a candidata "starter corrível" registada em
`knowledge/candidates.md` (tipo `bloco`, P2, promovida em parte: este contrato; a parte
"guardas à entrada" já subiu como fatia 0). Este contrato existe primeiro de propósito: quando
essa destilação chegar, entra por medida — em vez de inventar a forma ao mesmo tempo que o
conteúdo.

## Relacionados

- `adapters/README.md` — o padrão de isolamento que esta pasta replica, de ferramentas para
  stacks.
- `checklists/definition-of-done.md` — o bloco F6 — Esqueleto (fatia 0), o resultado que o
  contrato garante.
- `workflows/W00-project-kickoff.md` — o arranque onde a opção de usar um starter entra.
- `workflows/W06-build.md` — a fase cuja fatia 0 o starter pré-paga.
- `playbooks/framework-curation.md` — a porta única de entrada e manutenção de starters.
- `knowledge/candidates.md` — a sala de espera onde a implementação do primeiro starter
  aguarda destilação.
- `knowledge/permanent-rules.md` — segredos fora do controlo de versões e versões estáveis.
- `core/artifact-protocol.md` — a árvore do projeto com que todo o starter é compatível.
