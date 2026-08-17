# Fila de Jobs · executor único, submissão múltipla

> **Validação em produção:** 2.ª confirmação em domínio distinto do projeto-mãe (P2 — curadoria de 2026-08; nuances confirmadas: executor único, kill-switch por variável de
> ambiente, falhas nunca silenciosas). O desenho mantém-se; a confiança sobe.

Módulo reutilizável para **trabalho assíncrono fiável**: vários pontos do sistema submetem trabalho,
**um** executor drena-o, e nenhum efeito acontece duas vezes. Encapsula o padrão "fila com executor
único" (`knowledge/proven-patterns.md` §1) numa capacidade adotável isoladamente.

## O problema que resolve

Sempre que um efeito não deve bloquear o pedido que o originou — enviar um email, chamar uma
integração externa, recalcular um agregado, gerar um relatório — a tentação é executá-lo em linha.
Isso encadeia três defeitos clássicos:

- **Efeitos duplicados:** dois produtores disparam o mesmo email; um retry reenvia o que já tinha ido.
- **Efeitos perdidos:** o pedido confirma ao utilizador, mas o processo morre antes de o efeito correr.
- **Efeitos fantasma:** o efeito corre e **depois** a transação faz rollback — notificou-se algo que
  nunca aconteceu.

A fila resolve isto separando **submeter** (barato, transacional, muitos) de **executar** (um só,
idempotente, observável). O detalhe de *porquê* está em `knowledge/origin-lessons.md` §C5.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Job** — uma unidade de trabalho: `tipo`, `payload`, `fingerprint`, `estado`, `tentativas`,
  `disponivelEm`, `resultado/erro`. Não presume tabela, tópico ou ficheiro — é o conceito.
- **Produtor** — qualquer via que submete: um handler HTTP, um cron, um comando de CLI, um botão de
  backoffice. Submeter é `inserir-se-não-existe` pelo `fingerprint`.
- **Fingerprint** — chave **estável e determinística** que identifica o efeito, não a tentativa:
  `tipo:entidade:contexto` (ex.: `email-boas-vindas:cliente#4471`). Dois produtores com o mesmo
  fingerprint produzem **um** job.
- **Executor (worker)** — **único** por tipo de trabalho. Reclama jobs elegíveis, executa, marca o
  desfecho. Único não significa uma máquina: significa que **um** consumidor processa cada job de cada
  vez (garantido por lock/claim atómico), mesmo com várias réplicas.
- **Backoff** — em falha, o job volta à fila com `disponivelEm` adiado exponencialmente (ex.:
  1min, 5min, 25min) e `tentativas++`.
- **DLQ (dead-letter queue)** — destino dos jobs que esgotaram as tentativas: **não** desaparecem,
  ficam visíveis para triagem manual.
- **Estados** — `pendente → em-execução → concluído` | `falhado(→retry)` | `morto(DLQ)`. É uma
  máquina de estados pequena (`modules/state-machines.md`).

Ligação natural ao **transactional outbox**: o job é inserido **dentro da transação** do facto que o
origina (`knowledge/proven-patterns.md` §3), pelo que rollback ⇒ zero jobs, sem código
extra.

## Regras inegociáveis (numeradas, verificáveis)

1. **Submissão é `inserir-se-não-existe` por fingerprint.** Verificável: submeter o mesmo fingerprint
   N vezes cria **um** job; um teste afirma-o.
2. **Um só executor efetiva cada job.** O claim é atómico (lock/`SELECT … FOR UPDATE SKIP LOCKED` ou
   equivalente). Verificável: dois workers em paralelo sobre a mesma fila nunca executam o mesmo job
   (teste de concorrência).
3. **A execução é idempotente.** Mesmo que um job corra duas vezes (falha após efeito, antes de marcar
   concluído), o efeito líquido é um só — a idempotência é do **handler**, ancorada no fingerprint.
4. **Falha de um item nunca aborta o lote.** Cada job é uma transação independente; um erro marca esse
   job e o executor prossegue.
5. **Nada falha em silêncio.** Todo o erro é logado com o fingerprint e correlação; esgotar tentativas
   move para a **DLQ**, nunca apaga (`knowledge/proven-patterns.md` §10).
6. **Retries com backoff e teto.** Há um número máximo de tentativas e um crescimento do intervalo;
   sem teto, um job envenenado martela o sistema para sempre.
7. **Estado de cada job é consultável.** Existe forma de responder "onde está este trabalho?" sem ler
   logs — pendente, a correr, concluído, morto, com contagem de tentativas e último erro.
8. **Kill-switch por tipo/canal.** Um tipo de job pode ser suspenso sem novo deploy
   (`modules/feature-flags.md`); os jobs acumulam-se em `pendente`, não se perdem.

## Como se adota num produto novo (passos)

1. **Decidir o substrato** com o utilizador (`core/decision-engine.md`): tabela na BD relacional
   (o mais simples e transacional — recomendado por defeito), ou broker dedicado se o volume o exigir.
   Não introduzir infraestrutura de filas antes de a precisar.
2. **Definir o registo de Job** e o índice único parcial sobre `fingerprint` **onde** o job ainda está
   ativo (garante a regra 1 na camada mais baixa — `knowledge/proven-patterns.md` §5).
3. **Criar a porta de submissão** `enfileirar(tx, tipo, payload)` que participa na transação do
   chamador (outbox).
4. **Escrever o executor** com claim atómico, ciclo de drenagem, backoff, DLQ e logging estruturado.
5. **Registar os handlers por tipo**, cada um idempotente e com fake em dev/test.
6. **Expor o estado** (backoffice ou endpoint) e ligar o **kill-switch por tipo** às flags.
7. **Testar a lógica de risco:** dedupe, concorrência de dois workers, retry/backoff, caminho para DLQ
   (`knowledge/permanent-rules.md` §7).

## Variações e trade-offs

- **Fila na BD vs broker dedicado.** BD: transacional com o resto do domínio (outbox trivial),
  observável por SQL, ótima até milhares/min. Broker (Redis/RabbitMQ/SQS/…): escala e fan-out
  maiores, mas o outbox deixa de ser grátis e ganha-se uma peça de infra para operar. Comece na BD.
- **Executor único lógico vs físico.** Uma réplica só evita concorrência mas é um ponto único de
  paragem; várias réplicas com claim atómico (`SKIP LOCKED`) dão tolerância a falhas mantendo "um por
  job". Prefira o segundo assim que a disponibilidade importe.
- **Ordenação.** A fila simples não garante ordem entre jobs; se a ordem importa (eventos por
  agregado), particione por chave e serialize dentro da partição — ver `agents/05-backend/events-specialist.md`.
- **Prioridades.** Uma coluna de prioridade ou filas separadas por classe evita que relatórios
  pesados atrasem emails urgentes — só a partir do momento em que compete por vazão.

## Exemplo (multi-domínio)

**E-commerce — email de confirmação de encomenda.** Ao confirmar o pagamento, o handler insere na
mesma transação um job `email-confirmacao:encomenda#8812`. Se o gateway confirma mas a app cai antes
de commit, a transação inteira reverte: nem encomenda nem email. Se dois webhooks do gateway chegarem
(duplicação normal), o fingerprint garante um único email. O executor envia; se o SMTP falha, backoff
e retry; ao fim de 5 tentativas, DLQ visível para o suporte investigar.

**Plataforma de dados — reprocessamento de um lote.** Um cron noturno e um botão "reprocessar agora"
no backoffice submetem ambos `recalcular-agregado:2026-07`. Como partilham fingerprint, coincidindo
no tempo geram **um** job, não dois recálculos concorrentes sobre a mesma partição.

## Armadilhas conhecidas

- **Fingerprint que inclui a tentativa** (timestamp, UUID aleatório) anula o dedupe — tem de ser
  estável no **efeito**, não no evento.
- **Handler não idempotente** transforma um retry legítimo num efeito duplicado; a regra 3 é sobre o
  handler, não sobre a fila.
- **DLQ que ninguém olha** é um cemitério silencioso — precisa de alerta e de dono
  (`agents/13-guardians/README.md`).
- **Efeito antes do commit** (enviar o email e *depois* gravar) reintroduz o efeito-fantasma; o job
  entra na transação, a entrega é sempre pós-commit.
- **Claim não atómico** (ler-marcar-executar sem lock) reabre a corrida TOCTOU que a regra 2 fecha —
  ver `knowledge/origin-lessons.md` §C4.
- **Sem teto de tentativas**, um job envenenado consome o executor indefinidamente.

## Relacionados

- `knowledge/proven-patterns.md` — §1 fila única, §3 outbox, §10 fallbacks visíveis.
- `agents/05-backend/queue-specialist.md` — o agente que implementa este módulo.
- `agents/05-backend/events-specialist.md` — outbox, ordering e idempotência de eventos.
- `modules/state-machines.md` — os estados do job como máquina explícita.
- `modules/feature-flags.md` — o kill-switch por tipo/canal.
- `modules/ai-observability.md` — quando os jobs chamam modelos de IA, contabilizar o consumo.
- `knowledge/origin-lessons.md` — §C4 (locks/TOCTOU), §C5 (outbox).
