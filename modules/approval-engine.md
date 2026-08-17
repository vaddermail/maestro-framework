# Motor de Aprovações · escalões configuráveis por valor ou risco

Um módulo para **quem tem de autorizar o quê, e por que ordem**, quando uma ação precisa de aprovação
antes de produzir efeito — uma despesa, um reembolso, a publicação de conteúdo, a concessão de um
acesso, a alteração de um contrato. O escalão de aprovação é **proporcional a um valor ou risco** e
**configurável em dados**, nunca fixo por perfil nem no código. Antes da aprovação por escalão, um
**gate de validação de necessidade** decide se o pedido sequer pode entrar no fluxo — e é um mecanismo
**separado**, que não substitui a aprovação. Tudo o que se aprova deixa um **trilho auditável** de quem
aprovou o quê e por que via.

## O problema que resolve

As aprovações são um foco recorrente de defeitos porque três mecanismos distintos são frequentemente
**colapsados num só** (`knowledge/origin-lessons.md` B1):

- **"O finance aprova tudo até X, acima disso o diretor."** Cravado no código, isto quebra à primeira
  reorganização: muda o organigrama, muda-se código e faz-se deploy. E não responde a "porque é que
  este pedido de 4.999 passou e o de 5.001 exigiu o diretor?".
- **Confundir *poder aprovar* com *precisar de acontecer*.** Um pedido pode ser perfeitamente
  autorizável quanto ao valor e mesmo assim ser desnecessário (comprar o que já se tem em stock). Se o
  único filtro é o valor, o desnecessário-mas-barato passa sempre.
- **Não saber quem aprovou.** Quando a decisão não persiste a via usada e o aprovador concreto, a
  auditoria é impossível e a responsabilidade dilui-se.

O módulo separa os três eixos e torna o escalão **dados, não código**.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Pedido (`pedido`)** — a coisa que precisa de autorização, com um **valor** ou **grau de risco** que
  determina o escalão (um montante, uma classificação de sensibilidade, um nível de acesso pedido).
- **Gate de necessidade** — um passo **inicial e separado** que decide se o pedido é sequer elegível:
  faz sentido? há alternativa? cumpre a política? É um **sim/não de entrada**, não uma aprovação de
  valor. Um pedido pode passar o gate e falhar no escalão, ou o inverso.
- **Escalão (`escalao`)** — a regra, **em dados**, que mapeia uma faixa de valor/risco para o conjunto
  de aprovadores necessários. Tipicamente uma tabela de faixas (`0–1.000 → gestor`; `1.000–10.000 →
  gestor + diretor`; `> 10.000 → + administração`). É **configurável** sem deploy.
- **Cadeia de aprovação (`cadeia`)** — a sequência concreta de passos que um pedido gera ao entrar, a
  partir do escalão aplicável no momento. Cada passo tem um **papel/aprovador**, um **estado**
  (pendente/aprovado/rejeitado) e, quando decidido, **quem** e **quando**.
- **Decisão (`decisao`)** — o registo imutável de cada aprovação/rejeição: aprovador, momento,
  justificação, e a **via** usada (portal, backoffice, delegação). Alimenta a auditoria.
- **Delegação** — a regra que permite a um aprovador transferir a sua autoridade por um período
  (ausência), sem perder o rasto de que foi por delegação.

A avaliação do escalão é um caso de decisão por regra configurável, parente da avaliação de tarifas em
`modules/credit-management.md` — a lógica lê-se dos dados, não se compila.

## Regras inegociáveis (numeradas, verificáveis)

1. **O escalão é configurável em dados, nunca fixo por perfil nem em código.** Mudar quem aprova o quê
   faz-se em configuração, sem deploy. Teste: alterar a tabela de escalões muda a cadeia gerada para um
   pedido novo, sem tocar em código.
2. **O gate de necessidade é separado da aprovação por escalão e não a substitui.** São dois passos
   ortogonais; passar um não implica passar o outro. Teste: um pedido elegível (gate sim) pode ficar
   pendente no escalão, e um pedido barato (escalão trivial) pode ser barrado no gate.
3. **A cadeia deriva do valor/risco no momento da submissão.** O escalão aplicado é o que estava em
   vigor quando o pedido entrou, não o de agora. Teste: mudar a tabela não altera cadeias já em curso.
4. **Toda a decisão persiste quem, quando, porquê e por que via.** Nenhuma aprovação é anónima ou sem
   rasto. Teste: cada passo aprovado/rejeitado reconduz a um aprovador identificado e a um momento
   (`modules/audit-and-provenance.md`).
5. **O efeito só ocorre quando a cadeia está completa.** Enquanto faltar um passo, a ação aprovada não
   produz efeito. A conclusão da cadeia e o efeito são atómicos (`modules/state-machines.md`). Teste:
   aprovar o penúltimo passo não dispara o efeito.
6. **Uma rejeição em qualquer passo termina a cadeia.** Não se "salta" um aprovador que rejeitou. Teste:
   rejeitar um passo leva o pedido a estado rejeitado, sem consultar os passos seguintes.
7. **Quem aprova tem autoridade confirmada no servidor.** O perfil/aprovador é validado contra os papéis
   realmente concedidos (`modules/rbac-and-scoping.md`), não contra o que o cliente declara. Teste: forjar
   o papel não aprova.
8. **Sem auto-aprovação, salvo regra explícita.** Por omissão, o autor de um pedido não é aprovador do
   seu próprio pedido. Teste: submeter e tentar aprovar o próprio pedido é recusado, exceto onde a
   política o autorize expressamente.

## Como se adota num produto novo (passos)

1. **Identificar as ações que exigem aprovação** e, para cada uma, o **eixo do escalão** (valor
   monetário? nível de risco? sensibilidade do dado?).
2. **Definir o gate de necessidade** — a pergunta de elegibilidade que corre **antes** do escalão — e
   deixá-lo explícito nas regras de negócio (`agents/01-requirements/business-rules-modeler.md`).
3. **Modelar a tabela de escalões em dados** (faixas → aprovadores) e a cadeia como máquina de estados
   (`modules/state-machines.md`); o efeito aprovado corre no fecho da cadeia.
4. **Ligar a autoridade ao RBAC** (`modules/rbac-and-scoping.md`) e cada decisão à auditoria
   (`modules/audit-and-provenance.md`).
5. **Registar as escolhas em ADR** (`templates/project/ADR-DECISION.md.template`): eixo do escalão,
   sequencial vs paralelo, regras de delegação e de auto-aprovação.
6. **Expor ao aprovador a fila de pendentes** e ao requerente o estado da cadeia, com textos da fonte
   única (`modules/single-source-of-content.md`).

## Variações e trade-offs

- **Sequencial vs paralelo.** Aprovadores em série (cada um só vê depois do anterior) dão controlo e
  contexto acumulado, mas são lentos; em paralelo (todos ao mesmo tempo, exige-se N de M) são rápidos
  mas podem aprovar sem verem a decisão dos pares.
- **Quórum "todos" vs "N de M".** Exigir todos os aprovadores de um passo é mais seguro e mais frágil (um
  ausente trava tudo); exigir N de M é resiliente mas dilui a responsabilidade.
- **Escalão por valor vs por risco vs matriz.** O valor é objetivo e fácil de configurar; o risco é mais
  fiel mas exige classificar cada pedido; uma matriz (valor × categoria) é a mais expressiva e a mais
  cara de manter.
- **Delegação: sim ou não.** Sem delegação, uma ausência bloqueia; com delegação, ganha-se continuidade
  mas é preciso rasto claro de que foi por delegação (Regra 4) para a auditoria não perder o fio.

## Exemplo (1–2, multi-domínio)

**Plataforma de despesas de uma empresa.** Um pedido de compra passa primeiro pelo **gate de
necessidade** (o item já existe em stock? há contrato-quadro que o cubra?) — separado do valor. Só depois
a **tabela de escalões** determina a cadeia: até 1.000 € aprova o gestor de equipa; até 10.000 € gestor +
diretor; acima, entra a administração. A tabela é editável pelo financeiro sem deploy (Regra 1). A ordem
de compra só é emitida quando a cadeia fecha (Regra 5); cada aprovação regista quem e quando (Regra 4).

**Plataforma de moderação de conteúdo (marketplace).** O eixo do escalão é o **risco**, não o valor: um
anúncio de baixo risco publica-se com uma aprovação automática; categorias sensíveis (saúde, finanças)
exigem revisor humano; conteúdo sinalizado por vários utilizadores sobe a um segundo revisor. O gate de
necessidade é a triagem inicial (cumpre as regras da categoria?), distinta da decisão de risco.

## Armadilhas conhecidas

- **Colapsar o gate de necessidade na aprovação por valor.** Passa a deixar o desnecessário-mas-barato
  entrar sempre e o necessário-mas-caro parecer suspeito. São eixos separados (Regra 2,
  `knowledge/origin-lessons.md` B1).
- **Cravar os escalões no código.** Toda a reorganização vira um deploy, e não há como um gestor de
  negócio ajustar limiares. Os escalões são dados (Regra 1).
- **Aplicar o escalão de agora a cadeias antigas.** Muda-se a tabela e cadeias em curso "saltam" ou
  "ganham" aprovadores retroativamente. A cadeia congela o escalão do momento da submissão (Regra 3).
- **Efeito antes de a cadeia fechar.** Emitir a ordem/publicar/conceder o acesso "adiantado" enquanto
  falta um aprovador desfaz o propósito do fluxo (Regra 5).
- **Aprovação anónima.** Sem persistir aprovador + via, a auditoria não responde a "quem autorizou isto?"
  (Regra 4).
- **Auto-aprovação silenciosa.** Deixar o autor aprovar o próprio pedido por omissão abre um buraco de
  controlo interno (Regra 8).

## Relacionados

- `modules/state-machines.md` — a cadeia de aprovação é uma máquina de estados; o efeito corre no fecho.
- `modules/rbac-and-scoping.md` — a autoridade do aprovador confirma-se no servidor.
- `modules/audit-and-provenance.md` — cada decisão é uma entrada de auditoria imutável.
- `modules/credit-management.md` — escalão avaliado por regra configurável, como as tarifas.
- `knowledge/origin-lessons.md` — B1: os três mecanismos ortogonais que não se substituem.
- `agents/01-requirements/business-rules-modeler.md` — traduz o gate e os escalões para o domínio.
