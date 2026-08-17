# Máquinas de Estado · fluxos críticos como estados e transições explícitos

> **Validação em produção:** 2.ª confirmação em domínio distinto do projeto-mãe (P2 — curadoria de 2026-08; nuance confirmada: máquinas **puras no contrato partilhado**
> api↔web, a api como autoridade — nunca duplicar entre camadas). O desenho mantém-se; a confiança sobe.

Um módulo para modelar **qualquer fluxo em que uma entidade passa por fases** com efeitos irreversíveis
pelo caminho — uma encomenda (carrinho → paga → expedida → entregue), um artigo (rascunho → em revisão →
publicado → arquivado), um pedido de suporte (aberto → em curso → resolvido → fechado), uma subscrição
(ativa → suspensa → cancelada). Em vez de dispersar `if estado == …` por todo o código, o fluxo declara-se
como uma **máquina de estados explícita**: os estados possíveis, as **transições permitidas**, os
**efeitos colaterais transacionais** de cada uma, **quem** a pode disparar, e quais os **estados
terminais irreversíveis**. É o esqueleto que os módulos de aprovações e de ciclo de vida usam por baixo.

## O problema que resolve

Quando um fluxo crítico vive espalhado em condicionais, aparecem os defeitos mais caros de um sistema:

- **Transições impossíveis que acontecem.** Uma encomenda "cancelada" volta a "expedida" porque nenhum
  sítio proibiu essa passagem. O estado torna-se inconsistente e ninguém sabe como lá chegou.
- **Efeitos meio-feitos.** A transição "expedir" devia baixar stock, cobrar o cliente e notificar; um
  caminho faz duas das três e uma falha deixa o mundo a meio, sem rollback.
- **Estados terminais que se reabrem.** Algo "reembolsado" ou "eliminado" — que devia ser final — é
  mexido de novo, corrompendo dados que já tinham fechado contas.
- **Corridas na transição.** Duas ações concorrentes leem o mesmo estado e ambas transitam, executando o
  efeito duas vezes (cobrar duas vezes, expedir duas vezes).

A máquina de estados explícita fecha os quatro: só transições declaradas são possíveis, cada uma é
atómica com os seus efeitos, os terminais têm guarda, e a transição adquire um lock.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Estado (`estado`)** — uma fase nomeada e finita da entidade. O conjunto de estados é fechado e
  conhecido; não há "estados" implícitos por combinação de flags soltas.
- **Transição (`transicao`)** — uma passagem **declarada** de um estado de origem para um de destino, com
  um nome (`expedir`, `cancelar`, `publicar`). O que **não** está declarado é **proibido** — a matriz de
  transições é uma allow-list, não uma deny-list.
- **Guarda (`guarda`)** — a pré-condição que uma transição exige para ser legal (`há stock`, `pagamento
  confirmado`, `revisor atribuído`). Uma guarda falhada recusa a transição com erro claro, sem efeito.
- **Efeito (`efeito`)** — as consequências que a transição produz, **todas na mesma transação**: mutações
  de dados, eventos emitidos (via `modules/job-queue.md`/outbox), entradas de auditoria. Ou tudo
  acontece, ou nada (rollback).
- **Autoridade da transição** — quem a pode disparar (que perfil/âmbito), confirmado no servidor
  (`modules/rbac-and-scoping.md`). *Poder transitar* é distinto de *a transição ser legal*: a autoridade é
  sobre o ator, a guarda é sobre o estado.
- **Estado terminal (`terminal`)** — um estado do qual **não sai nenhuma transição**. É irreversível por
  construção e protegido por guarda: nenhuma operação o reabre.
- **Overlay (camada ortogonal)** — quando uma preocupação temporária compete com o estado permanente
  (reserva sobre atribuição, rascunho-de-edição sobre publicado), modela-se como **camada separada** que
  se aplica por cima, e o estado apresentado **deriva** das duas — nunca se sobrescreve o permanente
  (`knowledge/proven-patterns.md` §9).

## Regras inegociáveis (numeradas, verificáveis)

1. **Só transições declaradas são possíveis.** A matriz origem→destino é uma allow-list; qualquer
   passagem não declarada é recusada. Teste: tentar uma transição fora da matriz falha com erro de
   transição inválida, sem alterar o estado.
2. **Cada transição é atómica com todos os seus efeitos.** Mutações, eventos e auditoria correm na mesma
   transação; uma falha reverte tudo. Teste: forçar a falha de um efeito deixa o estado **inalterado** e
   zero efeitos parciais.
3. **A guarda avalia-se antes do efeito, dentro da transação.** Uma pré-condição falhada recusa sem
   produzir efeito. Teste: transição com guarda falsa não muda nada.
4. **Estados terminais não têm transição de saída.** Nenhuma operação reabre um terminal. Teste: toda a
   transição a partir de um estado terminal é recusada; a matriz não declara nenhuma saída dele.
5. **A transição adquire lock sobre a entidade (concorrência).** Ler-decidir-escrever sem lock permite
   duas transições concorrentes (`knowledge/origin-lessons.md` C4/C8). Teste: duas transições
   simultâneas sobre a mesma entidade resultam numa aplicada e uma recusada, nunca ambas.
6. **A autoridade confirma-se no servidor.** Quem transita é validado contra os papéis concedidos
   (`modules/rbac-and-scoping.md`), não contra o cliente. Teste: forjar o perfil não autoriza a transição.
7. **O estado apresentado deriva; preocupações ortogonais são camadas.** Uma ação temporária nunca
   sobrescreve estado permanente; termina-se o overlay e reverte-se à base. Teste: terminar uma camada
   temporária devolve o estado base exato que existia antes, não um default.
8. **Cada transição deixa rasto.** Quem, quando, de que estado para qual, e porquê
   (`modules/audit-and-provenance.md`). Teste: o histórico reconstrói o caminho completo da entidade.

## Como se adota num produto novo (passos)

1. **Identificar os fluxos críticos** (aqueles com efeitos irreversíveis ou dinheiro/dados sensíveis
   envolvidos) e, para cada um, **enumerar os estados** finitos.
2. **Desenhar a matriz de transições** (origem → destino → nome → guarda → autoridade → efeitos) num
   documento canónico (`templates/specification/state-machine.md.template`).
3. **Marcar os terminais** e provar que não têm saída; decidir quais preocupações são **overlays** e não
   estados (`knowledge/proven-patterns.md` §9).
4. **Impor as invariantes na camada de dados** onde possível (índice único parcial para "≤1 estado aberto",
   `CHECK` de exclusividade) além dos guards de aplicação (`knowledge/proven-patterns.md` §5).
5. **Implementar cada transição como caso-de-uso único e transacional**, reutilizado por todas as vias de
   entrada (`knowledge/proven-patterns.md` §8) — portal, backoffice, API partilham o mesmo
   núcleo.
6. **Testar a máquina exaustivamente**: cada transição legal, cada transição ilegal recusada, cada guarda,
   e a concorrência (`agents/10-quality/unit-test-engineer.md`).

## Variações e trade-offs

- **Máquina simples vs statechart (estados aninhados/paralelos).** A maioria dos fluxos resolve-se com
  estados planos; aninhamento (um "ativo" com sub-estados) e regiões paralelas ganham expressividade ao
  custo de complexidade — só quando o domínio realmente o exige.
- **Estado como coluna vs histórico com início/fim.** Guardar só o estado atual é simples mas perde o
  caminho; modelar como histórico de períodos (`inicio`/`fim`) dá auditoria e "estado a uma data"
  gratuitos, mas exige derivar o atual (`knowledge/proven-patterns.md` §5).
- **Transições disparadas por ator vs por tempo/evento.** Algumas transições são humanas (aprovar,
  expedir); outras automáticas (expirar após 30 dias, fechar após inatividade). As automáticas correm por
  um executor único (`modules/job-queue.md`), não por leitura ad-hoc.
- **Efeitos síncronos vs via outbox.** Mutações do próprio agregado ficam na transição; efeitos externos
  (email, integração) emitem-se como eventos na mesma transação e entregam-se assíncronos
  (`knowledge/proven-patterns.md` §3).

## Exemplo (1–2, multi-domínio)

**Encomenda de e-commerce.** Estados: `carrinho → aguarda-pagamento → paga → em-preparação → expedida →
entregue`, com ramos `cancelada` e `reembolsada` (terminais). A transição `pagar` tem guarda "pagamento
confirmado" e efeitos atómicos: baixar stock, criar fatura, emitir evento de expedição (Regra 2).
`entregue` e `reembolsada` são terminais sem saída (Regra 4) — uma encomenda entregue não "volta" a
expedida. A concorrência entre "cancelar" e "expedir" resolve-se por lock (Regra 5): uma ganha, a outra é
recusada.

**Publicação editorial.** Um artigo percorre `rascunho → em-revisão → aprovado → publicado → arquivado`.
"Publicar" exige guarda "revisor aprovou" e autoridade de editor (Regra 6). Uma **edição de um artigo já
publicado** não sobrescreve o publicado: cria um **overlay** de rascunho-de-edição que coexiste, e o
publicado só muda quando essa edição é, ela própria, aprovada e promovida (Regra 7,
`knowledge/proven-patterns.md` §9).

## Armadilhas conhecidas

- **Deny-list em vez de allow-list.** Tentar proibir as transições más deixa sempre escapar uma; só o que
  está **declarado** é permitido (Regra 1).
- **Efeitos fora da transição da transição.** "Mudo o estado e depois disparo os efeitos" perde efeitos
  quando a app cai no meio, e deixa o mundo a meio sem rollback (Regra 2).
- **Reabrir um terminal "só desta vez".** Um estado final que ganha uma exceção deixa de ser final e
  corrompe o que fechou nele (contas, stock, faturas) (Regra 4).
- **Transitar sem lock.** A janela ler-decidir-escrever cobra duas vezes ou expede duas vezes sob
  concorrência (Regra 5, `knowledge/origin-lessons.md` C4).
- **Sobrescrever estado permanente com estado temporário.** A reserva de curto prazo que apaga a
  atribuição de base é a classe de bug que os overlays evitam (Regra 7).
- **Estado calculável guardado como coluna e a divergir.** Se o estado se pode derivar dos factos, derivá-lo;
  duas cópias divergem (`knowledge/proven-patterns.md` §4).

## Relacionados

- `modules/approval-engine.md` — a cadeia de aprovação é uma máquina de estados.
- `modules/entity-lifecycle.md` — onboarding/offboarding como transições com libertação de recursos.
- `modules/job-queue.md` — efeitos externos e transições por tempo correm por executor único.
- `modules/rbac-and-scoping.md` — a autoridade da transição confirma-se no servidor.
- `modules/audit-and-provenance.md` — cada transição deixa rasto imutável.
- `knowledge/proven-patterns.md` — §5 (invariantes duplos), §8 (serviço partilhado), §9 (camadas).
- `templates/specification/state-machine.md.template` — onde se documenta a matriz de transições.
