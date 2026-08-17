# Gestão de Créditos · ledger genérico de saldo e consumo

Um módulo para **contabilizar e limitar** o consumo de qualquer recurso mensurável e cobrável — chamadas
a um modelo de IA, pedidos a uma API paga, minutos de processamento, envios de SMS, execuções de uma
ferramenta. Dá a um produto um **saldo por conta**, um **histórico imutável** de tudo o que entrou e
saiu, **tarifas** que convertem uso em custo, **quotas** que travam abusos e um **kill-switch** para
cortar consumo em emergência. Serve utilizadores individuais e organizações, com hierarquia entre eles.

## O problema que resolve

Sempre que um produto deixa os utilizadores consumir algo que **custa dinheiro a cada uso**, três
defeitos aparecem juntos:

- **Saldo que mente.** Guardar um campo `saldo` e fazer-lhe `update` a cada operação gera corridas (dois
  consumos simultâneos leem o mesmo saldo e ambos descontam do valor antigo) e torna impossível
  reconstruir *como* se chegou àquele número. Quando o cliente contesta a fatura, não há resposta.
- **Consumo sem teto.** Sem quota, um bug em ciclo ou um utilizador malicioso esgota o orçamento antes
  de alguém reparar — o primeiro sinal é a fatura do fornecedor.
- **Não há forma de parar.** Quando o custo dispara, falta um botão que corte o consumo **sem novo
  deploy**.

O módulo resolve os três com um princípio central: **o saldo nunca se escreve, deriva-se** de um
histórico de movimentos que só cresce.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Conta (`conta`)** — o titular do saldo. Pode ser um utilizador, uma organização, um projeto ou um
  ambiente. Contas podem formar **hierarquia** (uma organização com sub-contas por equipa); nesse caso
  decide-se se a quota é do topo, partilhada, ou por sub-conta (ver Variações).
- **Movimento (`movimento`)** — um facto **imutável** e datado: um crédito (entrada) ou um débito
  (saída), com montante, motivo, referência à operação que o originou (idempotência — ver Regra 4) e
  autor. Nunca se edita nem se apaga um movimento; um erro corrige-se com um **movimento de estorno**
  que o anula, deixando ambos no histórico.
- **Saldo** — **não é um campo**; é a soma dos movimentos da conta (`Σ créditos − Σ débitos`). Pode
  guardar-se um valor **derivado em cache** para leitura rápida, mas a fonte de verdade é sempre o
  histórico, e a cache reconcilia-se a partir dele.
- **Tarifa (`tarifa`)** — a regra que converte uma unidade de uso em montante de crédito
  (`por 1000 tokens do modelo X`, `por chamada à API Y`, `por minuto de transcodificação`). Versionada:
  uma tarifa muda ao longo do tempo, e um movimento antigo guarda a tarifa que **estava em vigor** quando
  ocorreu.
- **Quota (`quota`)** — um limite sobre uma conta numa janela (por dia, por mês, total). Pode ser
  **dura** (bloqueia ao atingir) ou **suave** (deixa passar mas alerta). Distinta do saldo: uma conta
  pode ter saldo e mesmo assim estar limitada por quota.
- **Kill-switch** — um interruptor por conta, por tarifa ou global que, ligado, faz **negar** todo o
  débito correspondente sem tocar no código (é um caso do `modules/feature-flags.md`).

A reserva/consumo faz-se em **duas fases** quando o custo só é conhecido no fim (ver Regra 5): reserva
uma estimativa, executa, ajusta ao valor real.

## Regras inegociáveis (numeradas, verificáveis)

1. **O saldo é derivado, nunca escrito.** Não existe operação que faça `SET saldo = …`. Teste: somar
   todos os movimentos de uma conta tem de dar exatamente o saldo apresentado; um valor em cache que
   divirja da soma é um defeito.
2. **Movimentos são imutáveis.** Nenhum caminho de código atualiza ou apaga um movimento existente. Uma
   correção é sempre um **novo** movimento de estorno com referência ao original. Teste: tentar editar
   um movimento é rejeitado pela camada de dados (constraint/append-only), não só pela app.
3. **Todo o débito é atómico com o efeito que paga.** Debitar e executar a operação cobrada acontecem na
   **mesma transação** (ou com reserva-confirma — Regra 5). Nunca se executa a operação e se debita
   "depois"; nunca se debita e se executa sem garantir o débito. Teste: um rollback da operação deixa
   zero movimentos.
4. **Débitos são idempotentes por referência estável.** Cada débito carrega a chave da operação que o
   originou; repetir a mesma operação não cria um segundo débito. Teste: submeter a mesma operação duas
   vezes (retry) resulta num único movimento.
5. **Custo desconhecido consome em duas fases: reservar → confirmar/libertar.** Quando o custo real só se
   sabe no fim, reserva-se uma estimativa (que já conta para o saldo disponível), executa-se, e ajusta-se
   ao valor real (confirma o excedente ou liberta a sobra). Teste: uma reserva nunca confirmada expira e
   é libertada; o saldo disponível reflete reservas em aberto.
6. **A quota verifica-se antes do débito, dentro do mesmo lock.** Ler quota, decidir e debitar sem lock
   tem corrida (TOCTOU — `knowledge/origin-lessons.md` C8). Teste: N consumos concorrentes contra
   uma quota de N−1 deixam exatamente um a falhar.
7. **O kill-switch nega em fail-closed.** Ligado, o débito correspondente é recusado com erro claro; nunca
   "passa por engano". Teste: com o switch ligado, toda a operação cobrada é bloqueada e registada.
8. **Toda a decisão de saldo/quota vive no servidor.** O cliente nunca decide se tem saldo; declara a
   intenção e o servidor confirma (`modules/rbac-and-scoping.md`). Teste: forjar o pedido não contorna a
   quota.
9. **Cada movimento é auditável.** Quem, quando, quanto, porquê e que operação — sem lacunas
   (`modules/audit-and-provenance.md`). Teste: qualquer débito reconduz à operação e ao autor.

## Como se adota num produto novo (passos)

1. **Delimitar o recurso cobrado e a unidade** (tokens? chamadas? minutos?) e o que é uma **conta** no
   produto (utilizador, organização, ambos com hierarquia).
2. **Modelar** `conta`, `movimento` (append-only), `tarifa` (versionada) e `quota`, com o saldo como
   **consulta derivada** — nunca coluna editável (`agents/06-data/data-modeler.md`).
3. **Impor as invariantes na camada mais baixa** (`knowledge/proven-patterns.md` §5):
   append-only por constraint/trigger; débito+efeito na mesma transação com lock na conta.
4. **Escolher as variantes** (pré-pago vs pós-pago; quota do topo vs por sub-conta; reserva-confirma vs
   débito direto) e **registar em ADR** (`templates/project/ADR-DECISION.md.template`).
5. **Ligar o kill-switch** ao módulo de flags (`modules/feature-flags.md`) e os alertas de saldo/quota à
   observabilidade (`modules/ai-observability.md` quando o recurso é IA).
6. **Expor o histórico ao titular** (extrato) e os limites (quota usada/restante), com os textos vindos
   da fonte única (`modules/single-source-of-content.md`).

## Variações e trade-offs

- **Pré-pago vs pós-pago.** Pré-pago (o saldo tem de ser positivo antes de consumir) protege o
  fornecedor mas trava o utilizador; pós-pago (consome e fatura no fim, com limite de crédito) é mais
  fluido mas assume risco de incobrável. Muitos produtos combinam: pós-pago até um teto, pré-pago acima.
- **Débito direto vs reserva-confirma.** Débito direto é mais simples e serve custo conhecido à cabeça
  (uma chamada com preço fixo); reserva-confirma é obrigatório quando o custo só se sabe no fim
  (streaming de tokens, transcodificação de duração variável).
- **Quota do topo vs por sub-conta.** Numa organização, uma quota única no topo é simples mas deixa uma
  equipa esgotar o orçamento das outras; quotas por sub-conta isolam mas exigem gestão de alocação.
- **Cache de saldo: sim ou não.** Derivar o saldo somando movimentos é correto mas caro em contas com
  milhões de linhas; uma cache reconciliável (snapshot periódico + movimentos desde então) resolve sem
  violar a Regra 1.

## Exemplo (1–2, multi-domínio)

**Plataforma SaaS com IA.** Cada organização tem uma conta de créditos. Uma resposta de um assistente
reserva créditos por uma estimativa de tokens, faz a chamada ao modelo, e confirma pelo consumo real
devolvido pelo fornecedor (Regra 5). A tarifa é por modelo e versionada (mudou o preço → tarifa nova, os
extratos antigos mantêm a antiga). Um kill-switch por modelo corta o mais caro se o custo do mês disparar
(liga a `modules/ai-observability.md`). O extrato mostra cada pedido e o seu custo; o admin vê a
quota mensal consumida.

**Marketplace de envio de SMS.** Cada cliente pré-carrega saldo. Enviar uma campanha debita um movimento
por lote, idempotente pela referência da campanha (Regra 4) — reenviar por timeout não cobra duas vezes.
A tarifa varia por país de destino. Uma quota diária dura evita que um script em ciclo esgote o saldo
antes do cliente reparar (Regra 6).

## Armadilhas conhecidas

- **Guardar `saldo` como coluna e "manter atualizado".** É a origem das corridas e das faturas
  irreconciliáveis. O saldo **deriva-se** (Regra 1); se precisa de cache, reconcilia-se do histórico.
- **Debitar fora da transação do efeito.** "Chamo a API e depois desconto" perde débitos quando a app
  cai no meio; "desconto e depois chamo" cobra sem entregar. Tem de ser atómico (Regra 3).
- **Esquecer a idempotência dos retries.** Cada retry de rede vira um débito duplicado. Sem chave de
  operação estável, o cliente paga o dobro (Regra 4).
- **Verificar a quota antes de adquirir o lock.** Cria a janela TOCTOU em que N pedidos concorrentes
  passam todos uma quota que só chegava para um (Regra 6, `knowledge/origin-lessons.md` C8).
- **Tarifa não versionada.** Mudar o preço reescreve retroativamente o custo do histórico — o extrato do
  mês passado muda sozinho. A tarifa carimba-se no movimento no momento em que ocorre.
- **Reservas que nunca expiram.** Uma reserva que fica presa por uma operação abortada "come" saldo
  disponível para sempre; toda a reserva tem prazo de expiração (Regra 5).

## Relacionados

- `modules/ai-observability.md` — quando o recurso cobrado é IA: tokens/custo por modelo e alertas.
- `modules/feature-flags.md` — o kill-switch de consumo é uma flag desligável sem deploy.
- `modules/audit-and-provenance.md` — cada movimento é uma entrada de auditoria imutável.
- `modules/rbac-and-scoping.md` — a decisão de saldo/quota vive no servidor, cliente não-fiável.
- `knowledge/proven-patterns.md` — §4 (saldo deriva-se) e §5 (invariantes na camada baixa).
- `agents/06-data/data-modeler.md` — modelar o ledger append-only e as constraints.
- `agents/13-guardians/cost-guardian.md` — vigia o custo real contra o orçamento.
