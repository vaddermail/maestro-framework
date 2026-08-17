# Migração de BD — Expand-Contract

Procedimento de mudança de esquema em três fases separadas: **expand** (aditivo), **migrar dados e
código**, e só depois **contract** (largar/renomear o antigo) — nunca no mesmo passo. Executado pelo
`agents/06-data/migration-engineer.md`, tanto dentro de uma fatia de `workflows/W06-build.md`
como a acompanhar um release em `playbooks/release-and-rollback.md`. Cada fase tem *down* documentado;
a fase Contract só corre depois de um **ponto de não-retorno** explícito.

## Pré-condições

- Modelo de dados lógico aprovado para o estado alvo (`agents/06-data/data-modeler.md`).
- Harness de regressão a funcionar contra o motor de BD **real** (não um motor leve que serializa
  corridas que a produção não serializa — `knowledge/ai-pitfalls.md` §15).
- `templates/technical/migration-plan.md.template` disponível para instanciar.

## Passos

1. **Escrever o plano de migração** a partir de `templates/technical/migration-plan.md.template`:
   estado atual, estado alvo, as três fases, e o *down* de cada uma. *Verifica-se* que o plano existe
   como ficheiro e cobre as 3 fases com reversão descrita. *Se não houver plano escrito*: não se aplica
   nenhuma migração — o plano é pré-condição, não formalidade posterior.

2. **Fase Expand — aditiva.** Criar a coluna/tabela/índice nova sem tocar no que está em uso; o
   esquema antigo continua a funcionar inalterado. *Verifica-se* que o código antigo, sem qualquer
   alteração, continua a passar nos testes existentes contra o esquema já com a adição. *Se falhar*: a
   mudança não é puramente aditiva — corrigir antes de avançar.

3. **Validar a fase Expand isoladamente.** Aplicar em staging, correr a regressão completa (frontend +
   backend), confirmar zero impacto no código ainda não migrado. *Verifica-se* com o harness verde e a
   aplicação antiga a funcionar sem saber que a novidade existe.

4. **Deploy da fase Expand como release própria**, seguindo `playbooks/release-and-rollback.md` (backup,
   hard-block, rollback ensaiado). *Verifica-se* com release verde + smoke live.

5. **Migrar os dados.** Backfill dos registos existentes para o novo esquema, em lote controlado — não
   um `UPDATE` cego em massa (mudanças em dados sensíveis seguem plano + lista + motivo por item,
   `knowledge/permanent-rules.md` §4). *Verifica-se* que a contagem de linhas migradas bate com a
   origem, com amostra validada manualmente. *Se o backfill falhar a meio*: tem de ser retomável e
   idempotente — nunca deixar o esquema num estado misto sem saber exatamente onde parou.

6. **Migrar o código.** Atualizar a aplicação para ler/escrever no novo esquema, mantendo capacidade de
   ler o antigo durante a transição quando necessário (dual-read). *Verifica-se* com testes que cobrem
   ambos os caminhos — o novo já escrito, o antigo ainda lido por quem não migrou.

7. **Validar as constraints em duas fases, com dados legados** (lição C7,
   `knowledge/origin-lessons.md`). Aplicar `CHECK`/`NOT NULL`/FK novos **só depois** do backfill
   confirmado — nunca antes, ou rejeita-se dados legados ainda por migrar. *Verifica-se* com um teste
   que insere a linha "antiga" e confirma que passa antes da constraint entrar em vigor e falha depois.
   Atenção a `NULL` vs `FALSE`: um `CHECK` só rejeita em `FALSE` estrito — `NULL` passa (lição C8).

8. **Ponto de não-retorno explícito.** Antes de contrair, confirmar — com o utilizador ou um critério
   objetivo acordado (ex.: N dias sem escrita no esquema antigo) — que já não há consumidor do antigo.
   *Verifica-se* com log/métrica de acesso ao caminho antigo em zero durante a janela acordada.
   *Se ainda houver consumidores* (outro serviço, relatório, integração externa): não contrair — mais
   uma iteração do passo 6, ou aceitar manter os dois esquemas por mais tempo.

9. **Fase Contract — só depois do ponto de não-retorno, em release própria.** Largar/renomear a
   coluna/tabela antiga. *Verifica-se* com regressão verde e zero referências ao esquema antigo no
   código (confirmado por pesquisa exaustiva, não por memória). *Se algo ainda referenciar o antigo*:
   abortar a contração — não é seguro avançar.

10. **Documentar.** Plano de migração atualizado com o resultado de cada fase; lição em `STATE.md` se
    algo surpreendeu; o template preenchido arquivado em `product/` para auditoria futura.

## Reversão

Cada fase tem *down* documentado no plano do passo 1. **Expand** reverte-se removendo a coluna/tabela
nova — sem perda, porque nada em produção dependia ainda dela. **Migrar dados/código** reverte-se
voltando o código a ler só do esquema antigo (o antigo nunca foi tocado até à fase Contract, por
desenho). **Contract** é a única fase com reversão cara (dados já largados) — por isso só corre depois
do ponto de não-retorno explícito do passo 8; se ainda assim for preciso reverter depois da Contract,
recorre-se ao backup verificado do release correspondente (`playbooks/release-and-rollback.md`), não a um
*down* de esquema que já não existe.

## Relacionados

- `agents/06-data/migration-engineer.md` — quem executa este playbook.
- `templates/technical/migration-plan.md.template` — o documento instanciado no passo 1.
- `playbooks/release-and-rollback.md` — cada fase (Expand e Contract) é um release próprio.
- `knowledge/origin-lessons.md` C7, C8 — as lições de origem desta disciplina.
- `knowledge/permanent-rules.md` §3, §4 — reversibilidade e mudanças em massa.
- `modules/state-machines.md` — quando a migração acompanha uma mudança de fluxo crítico.
