# Migração Mecânica em Larga Escala

Como fazer uma varredura mecânica que toca **muitos ficheiros/call-sites** de uma vez — renomear um
conceito, mudar a forma de um contrato/serialização, substituir um mecanismo transversal, trocar uma
biblioteca de UI — sem partir o ramo a meio. Distinto de `playbooks/expand-contract-db-migration.md`
(que é sobre esquema e dados): aqui o risco é o **código** ficar meio-migrado e observável. Executado
pelo agente da camada em causa (frontend, backend, dados), tipicamente dentro de uma fatia de
`workflows/W06-build.md`.

## Pré-condições

- Estado final decidido; se muda um contrato ou uma decisão fechada, a especificação/ADR é atualizada
  **primeiro** (`core/decision-engine.md`).
- Gates verdes antes de começar (a linha de base): sem verde inicial, não se sabe o que a migração
  partiu.
- Uma forma rápida de correr todos os gates (o oráculo de correção da varredura).

## Passos

1. **Construir a GUARDA primeiro.** Um teste/guardrail que *falha* enquanto a migração não estiver
   completa e que apanha reintroduções depois (ex.: um teste de arquitetura/fronteiras, um typecheck
   estrito, um scanner de padrão proibido). *Verifica-se* que a guarda **falha** no estado atual. *Se
   não falhar*: a guarda não mede o que interessa — reescrevê-la antes de tocar no resto.
2. **Superfície pública antes da interna.** Mudar primeiro o que o exterior vê (o contrato, a
   serialização, a rota) e só depois o interno — evita um estado meio-migrado *observável* por quem
   consome.
3. **Varrer de forma automatizável mas verificada.** Preferir transformações mecânicas (script/codemod)
   com os gates como oráculo, a edição manual sítio a sítio — e correr os gates **a seguir a cada
   varredura**, não só no fim. *Se um passo parte centenas de testes*: falta um passo intermédio
   aditivo — não é para "arranjar no fim".
4. **Manter os gates verdes ao longo do caminho.** O ramo nunca fica partido entre passos. Cada fase
   temática é um commit revertível; a migração deve poder recomeçar (idempotência).
5. **Fechar com a guarda a proteger.** Terminada a migração, a guarda passa a defender contra a
   reintrodução do padrão antigo e fica no CI — a varredura de hoje é o guardrail de amanhã.

## Reversão

Revert por fase temática. A guarda garante que um revert parcial (que reintroduza o padrão antigo) é
detetado em vez de passar despercebido.

## Relacionados

- `playbooks/expand-contract-db-migration.md` — o irmão para esquema/dados; muitas migrações usam os dois.
- `checklists/pre-merge.md` — os gates que se mantêm verdes ao longo da varredura.
- `checklists/pr-review.md` — a guarda como "teste que falha sem a alteração".
- `loops/L02-failing-tests.md` — corrigir a causa, nunca o detetor, quando a varredura acende vermelho.
- `loops/L05-inconsistencies.md` — reconciliar docs↔código↔dados que a migração possa desalinhar.
