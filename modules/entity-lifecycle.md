# Ciclo de Vida de Entidades · onboarding e offboarding transacionais

> **Validação em produção:** 2.ª confirmação em domínio distinto do projeto-mãe (P2 — curadoria de 2026-08; nuances confirmadas: esquecimento RGPD irreversível; a auditoria
> nunca guarda PII em claro — referência por id, para o rasto sobreviver ao esquecimento). O desenho
> mantém-se; a confiança sobe.

Módulo reutilizável para a **entrada e saída de entidades de longa duração** — pessoas, clientes,
contratos, dispositivos, fornecedores — que ao longo da vida **acumulam recursos e responsabilidades**.
O ponto crítico é a **saída**: libertar tudo o que a entidade detinha de forma **atómica**, bloquear se
houver responsabilidades por reatribuir, e deixar um estado terminal auditável.

## O problema que resolve

Uma entidade ativa vai ganhando ligações: um colaborador tem equipamentos, acessos, uma viatura,
seats de licença; um cliente tem subscrições, faturas em aberto, dados; um contrato tem recursos
alocados. Quando sai, cada uma dessas ligações **tem de ser resolvida** — e é aqui que os produtos
falham:

- **Libertação parcial:** liberta-se o equipamento mas esquece-se o acesso; a meio do processo algo
  falha e a entidade fica num limbo (metade dentro, metade fora).
- **Recursos órfãos:** um seat de licença que ninguém libertou continua a custar; um acesso que ficou
  ativo é um risco de segurança.
- **Responsabilidades abandonadas:** a pessoa que saía era o responsável por devolver algo, ou o
  aprovador de um processo em aberto — e ninguém reatribuiu.

A saída tem de ser **tudo-ou-nada** e **bloqueante quando preciso**. É uma aplicação direta da
transação atómica com locks (`knowledge/origin-lessons.md` §C4) e do serviço partilhado por
múltiplas vias (`knowledge/proven-patterns.md` §8).

## O modelo (conceitos e entidades, agnóstico de stack)

- **Entidade de ciclo de vida** — tem um `estado de vida` que é uma máquina explícita
  (`modules/state-machines.md`): tipicamente `pré-ativa → ativa → em-saída → terminada`, com
  transições nomeadas e efeitos.
- **Recursos associados** — tudo o que a entidade detém e que a saída deve libertar: relações
  bidirecionais (`device.owner ↔ collab.devs`), atribuições, seats, acessos. A libertação repõe cada
  um no seu estado livre e mantém a coerência do outro lado da relação.
- **Responsabilidades reatribuíveis** — papéis que a entidade ocupa e que **não podem ficar vazios**:
  ser aprovador, ser responsável por uma devolução em aberto, ser dono de um processo. São **gates**.
- **Gate bloqueante** — pré-condição que **impede** a conclusão da saída até ser resolvida. Não se
  "salta"; ou se reatribui a responsabilidade, ou a saída não fecha (`modules/approval-engine.md`
  para o padrão de gate).
- **Operação de saída (offboarding)** — o caso-de-uso transacional único que executa **todos** os
  efeitos de uma vez. Pode ser acionado por várias vias (RH, backoffice, automático por evento da
  origem — `modules/readonly-external-integrations.md`), todas com **efeitos idênticos**
  (`knowledge/proven-patterns.md` §8).
- **Estado terminal auditável** — depois da saída, fica registado **o que** foi libertado, **quando** e
  **por quem**, de forma imutável (`modules/audit-and-provenance.md`). O terminal não se reabre em
  silêncio; reativar é uma transição nova, registada.

## Regras inegociáveis (numeradas, verificáveis)

1. **A saída é atómica: tudo-ou-nada.** Todos os recursos libertam-se na **mesma transação**; se um
   passo falha, nada muda. Verificável: injetar falha a meio e afirmar que o estado ficou intacto (sem
   libertação parcial).
2. **Nenhum recurso fica órfão.** Ao terminar, todos os recursos associados estão livres e coerentes
   dos dois lados (`knowledge/proven-patterns.md` §4). Verificável: após offboarding, uma
   varredura não encontra recurso ainda ligado à entidade terminada.
3. **Gates bloqueiam a conclusão.** Se há responsabilidade por reatribuir, a saída **não fecha**;
   verificável: tentar terminar com um gate por resolver é recusado com erro claro.
4. **Efeitos idênticos em todas as vias.** Verificável: acionar a saída por cada via produz o **mesmo**
   estado final (mesmo teste, entradas diferentes) — nenhuma via esquece um efeito.
5. **Concorrência fechada com locks.** A operação bloqueia o agregado central (`FOR UPDATE` ou
   equivalente) para fechar a janela TOCTOU entre ler responsabilidades e libertar recursos
   (`knowledge/origin-lessons.md` §C4).
6. **Estado terminal é auditável e explícito.** Verificável: existe registo imutável do que foi
   libertado, quando e por quem; a entidade fica num estado terminal nomeado, não apenas "apagada".
7. **Reversão é uma transição nova, não um `undo` mágico.** Reativar uma entidade terminada é um passo
   deliberado e registado — os recursos não "voltam" sozinhos (`knowledge/permanent-rules.md` §3).

## Como se adota num produto novo (passos)

1. **Modelar a máquina de estados de vida** da entidade com o utilizador (`modules/state-machines.md`):
   estados, transições, quem pode cada uma.
2. **Inventariar os recursos associados** e como cada um se liberta (repor livre + coerência do inverso).
3. **Identificar as responsabilidades reatribuíveis** e transformá-las em **gates** explícitos.
4. **Escrever o caso-de-uso de saída** como núcleo transacional único, com lock do agregado, executando
   todos os efeitos; efeitos secundários (notificar, integrar) via outbox (`modules/job-queue.md`).
5. **Ligar todas as vias** de acionamento a esse mesmo caso-de-uso — nenhuma reimplementa a lógica
   (`knowledge/proven-patterns.md` §8).
6. **Registar o estado terminal** no trilho de auditoria (`modules/audit-and-provenance.md`).
7. **Testar a lógica de risco:** atomicidade sob falha, ausência de órfãos, gates a bloquear,
   concorrência, paridade entre vias (`knowledge/permanent-rules.md` §7).

## Variações e trade-offs

- **Offboarding síncrono vs em duas fases.** Síncrono (tudo numa transação) é o mais correto para os
  efeitos internos. Efeitos **externos** (revogar acesso num sistema terceiro) não cabem na transação
  da BD — modelam-se como jobs na outbox, com o estado "a revogar" visível até confirmação
  (`modules/job-queue.md`, `modules/readonly-external-integrations.md`).
- **Gate duro vs aviso.** Uma responsabilidade crítica (aprovador único, devolução por fazer) é gate
  **duro** que bloqueia; uma menor pode ser aviso que se regista. Decidir por tipo, nunca colapsar tudo
  em aviso (perde-se a proteção) nem tudo em bloqueio (paralisa saídas triviais).
- **Terminação reversível vs definitiva.** Preferir estado terminal **reversível por transição nova**
  (reativação registada) a apagar dados — o apagar é irreversível e raramente exigido cedo
  (`knowledge/permanent-rules.md` §3). Purga definitiva, quando obrigatória (retenção legal), é
  operação à parte, com plano e backup (`knowledge/permanent-rules.md` §4).
- **Onboarding leve vs com gates.** A entrada costuma ter menos gates que a saída, mas o padrão é o
  mesmo: transição nomeada, efeitos coerentes, estado explícito.

## Exemplo (multi-domínio)

**RH — saída de colaborador.** Ao acionar o offboarding (por RH, pelo backoffice, ou automático quando
o diretório marca a conta como inativa), uma única transação: liberta os equipamentos (→ em stock),
revoga os acessos, larga todos os seats de licença da pessoa, desliga a viatura e põe o colaborador em
`Saído`. **Gate:** se a pessoa era a responsável por devoluções ainda em aberto, a saída **não fecha**
até esse papel ser reatribuído — nada se liberta enquanto o gate estiver por resolver. Tudo fica no
trilho de auditoria; reativar (readmissão) é uma transição nova.

**SaaS — encerramento de conta de cliente.** Terminar a subscrição liberta seats, cancela recursos
provisionados e marca a conta `encerrada` — atomicamente. **Gate:** se houver fatura em aberto, o
encerramento bloqueia até ser resolvida ou explicitamente perdoada. Os dados entram em período de
retenção reversível antes de qualquer purga; a revogação de acessos a serviços externos corre como
jobs, visível até confirmada.

## Armadilhas conhecidas

- **Libertação sem transação:** libertar recurso a recurso fora de uma transação deixa o limbo
  meio-dentro-meio-fora ao primeiro erro — a regra 1 é o coração do módulo.
- **Esquecer o outro lado da relação:** libertar `entidade.recurso` sem repor `recurso.entidade`
  reintroduz a incoerência bidirecional (`knowledge/proven-patterns.md` §4).
- **Via que diverge:** implementar a saída em dois sítios garante que um ganha um efeito que o outro
  esquece — a devolução que atualiza um campo num sítio e não no outro (regra 4, §8 dos padrões).
- **Gate opcional:** deixar a responsabilidade por reatribuir como "aviso" faz com que aprovadores e
  devoluções fiquem órfãos; se é crítico, bloqueia.
- **TOCTOU na saída:** ler "não tem responsabilidades" e libertar sem lock permite que uma
  responsabilidade nova entre entre a leitura e a escrita (regra 5).
- **Terminar apagando:** o apagar é irreversível e perde a auditoria; o estado terminal é um estado,
  não um `DELETE`.

## Relacionados

- `modules/state-machines.md` — o estado de vida da entidade como máquina explícita.
- `modules/approval-engine.md` — o padrão de gate bloqueante separado da autorização.
- `modules/rbac-and-scoping.md` — quem pode acionar a saída e reatribuir responsabilidades.
- `modules/job-queue.md` — efeitos externos da saída via outbox/executor único.
- `modules/audit-and-provenance.md` — o estado terminal auditável.
- `modules/readonly-external-integrations.md` — saída acionada por evento da origem; revogação externa.
- `knowledge/proven-patterns.md` — §4 SSOT/relações, §8 serviço partilhado por N vias.
- `knowledge/origin-lessons.md` — §C4 (transação atómica com locks).
