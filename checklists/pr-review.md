# Revisão de PR

A checklist do revisor **independente** (nunca o autor) antes de `checklists/pre-merge.md` — a
operacionalização concreta da regra "quem verifica nunca é quem produziu"
(`core/quality-gates.md`). Foca-se na correção e no risco do código, não no estado do
repositório (isso é `checklists/pre-merge.md`).

## Correção funcional

- [ ] O código faz o que a especificação/requisito pede — confirmado contra
      `product/04-specification/`, não só contra a descrição do PR.
- [ ] Casos-limite óbvios do domínio considerados (vazio, zero, duplicado, concorrência) — não só o
      caminho feliz.
- [ ] Nenhuma lógica duplicada que já existe algures no código (reuso em vez de reescrita paralela).

## Regras de negócio e invariantes

- [ ] Cada regra de negócio tocada corresponde exatamente ao que está numerado em
      `product/04-specification/`; divergência resolvida (a spec ganha, ou atualiza-se a spec
      primeiro, às claras).
- [ ] Relações bidirecionais e invariantes de dados mantidos coerentes dos dois lados
      (`agents/06-data/data-modeler.md`).
- [ ] Máquinas de estado respeitadas: só transições permitidas, com os efeitos completos da transição
      (`modules/state-machines.md`).

## Autorização e scoping

- [ ] Toda a decisão de quem pode/vê o quê é imposta no servidor, nunca só no cliente
      (`modules/rbac-and-scoping.md`).
- [ ] Scoping por âmbito organizacional aplicado em **todas** as queries/endpoints tocados, não só
      nalguns.
- [ ] Campos sensíveis ocultos por autorização no servidor, não só por não aparecerem no ecrã
      (defesa em profundidade).

## Testes

- [ ] Testes novos/alterados exercitam a lógica de risco (regras de negócio, autorização,
      reversibilidade) — não só o caminho feliz.
- [ ] Testes falham sem a correção e passam com ela — confirmado, não presumido.
- [ ] Nenhum teste foi enfraquecido (assert removido, limiar subido) só para passar.

## Reversibilidade

- [ ] A mudança tem caminho de reversão claro: revert simples, flag, ou migração com plano de down
      (`knowledge/permanent-rules.md` §3).
- [ ] Mudanças destrutivas/em massa (delete, update em lote) atuam por ID exato, nunca por
      substring/pesquisa aproximada.

## Falhas silenciosas

- [ ] Nenhum bloco de erro vazio ou exceção engolida sem log; toda a degradação é visível
      (`knowledge/proven-patterns.md` §10).
- [ ] Falhas de I/O externo (rede, fila, API terceira) tratadas explicitamente, não ignoradas por
      omissão.
- [ ] Limites atingidos (truncar, saltar, amostrar) são reportados, nunca escondidos como sucesso.

## Relacionados

- `checklists/pre-merge.md` — o portão seguinte, que pressupõe esta revisão feita.
- `agents/12-reviewers/README.md` — quem executa e o formato do painel de revisão.
- `modules/rbac-and-scoping.md` — o detalhe de autorização e scoping.
- `modules/state-machines.md` — o detalhe de transições e efeitos.
- `knowledge/proven-patterns.md` — fallbacks visíveis, SSOT, invariantes.
- `knowledge/permanent-rules.md` — reversibilidade e mudanças destrutivas.
