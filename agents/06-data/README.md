# 06 — Dados (a verdade persistida)

Os agentes que desenham, protegem e mantêm o **estado persistido** do sistema — a camada onde os
invariantes de negócio se tornam inegociáveis porque uma violação **corrompe dados**, não apenas
uma resposta HTTP. O princípio que atravessa toda a categoria: **a base de dados é a última linha
de defesa da integridade** — constraint na BD, guard amigável na aplicação, uma só fonte de verdade
por facto (`knowledge/proven-patterns.md` §4–§5, `knowledge/origin-lessons.md` §B,§C).

## Fase(s) e quando entra

Fase dominante **F5–F6** (`core/lifecycle.md`), com um pé em F8–F9:

- **F5 (especificação):** o `modelador-de-dados.md` deriva o **modelo lógico agnóstico**
  (`templates/specification/logical-data-model.md.template`) das regras de negócio e das
  máquinas de estado — entidades, relações, invariantes — **sem** escolher motor de BD. É o *quê*
  dos dados.
- **F6 (construção):** o modelo lógico vira modelo físico; o `engenheiro-de-migracoes` materializa-o
  em migrações aditivas; o `especialista-de-indexes` e o `otimizador-de-desempenho-de-bd` afinam o
  acesso; o `auditor-de-dados` instala trilhos de auditoria e proveniência.
- **F8–F9 (lançamento e operação):** o `especialista-de-backups`, o `planeador-de-disaster-recovery`
  e o `gestor-de-versionamento-de-schema` garantem que os dados sobrevivem a falhas e que os
  ambientes não divergem. O `agents/13-guardians/backup-guardian.md` **opera** em cadência o
  que estes agentes **desenharam**.

## Agentes da categoria

**Modelo e integridade**
- `agents/06-data/data-modeler.md` — modelo lógico agnóstico → físico; invariantes na BD, relações bidirecionais com fonte única, seeds com datas relativas.
- `agents/06-data/migration-engineer.md` — migrações expand-contract, sempre com plano de reversão; nunca larga/renomeia o que está em uso.
- `agents/06-data/schema-versioning-manager.md` — versão do schema, ordem das migrações, seeds por ambiente, ambientes convergentes.

**Desempenho de acesso**
- `agents/06-data/indexing-specialist.md` — índices por padrão de acesso real; custo de escrita vs. leitura, índices parciais e compostos.
- `agents/06-data/db-performance-optimizer.md` — diagnóstico de queries lentas por plano de execução, particionamento, ajuste de configuração.

**Confiança e sobrevivência**
- `agents/06-data/data-auditor.md` — trilhos de auditoria imutáveis, proveniência de dados tocados por IA, retenção e qualidade de dados.
- `agents/06-data/backup-specialist.md` — backups automáticos, RPO por classe de dados, restauro **testado** (não presumido).
- `agents/06-data/disaster-recovery-planner.md` — RTO/RPO do sistema, runbooks de recuperação, exercícios periódicos de perda catastrófica.

## Ordem de trabalho recomendada

1. **Modelo primeiro** (`modelador-de-dados`) — deriva entidades, relações e invariantes das regras
   de negócio (`agents/01-requirements/business-rules-modeler.md`); é o input de todos os outros.
2. **Materialização e versão** (`engenheiro-de-migracoes` + `gestor-de-versionamento-de-schema`) —
   cada mudança de schema é uma migração aditiva versionada e reversível.
3. **Acesso** (`especialista-de-indexes` → `otimizador-de-desempenho-de-bd`) — índices desenhados dos
   padrões de acesso; o otimizador diagnostica o que escapou quando aparecem queries lentas.
4. **Confiança** (`auditor-de-dados`) — auditoria e proveniência não são um retoque final.
5. **Sobrevivência** (`especialista-de-backups` → `planeador-de-disaster-recovery`) — backups são um
   input do plano de DR; o DR cobre o desastre que o backup sozinho não resolve.

## Como o Orquestrador a convoca

O `core/orchestrator.md` monta o grafo de dependências a partir das secções **Inputs**/**Interações**
de cada ficha. Em F5 chama só o `modelador-de-dados`; em F6 chama os restantes por fatia vertical,
coordenando **a montante** com `agents/01-requirements/` (regras e invariantes) e **a jusante** com
`agents/05-backend/` (que orquestra a escrita em transações — `knowledge/origin-lessons.md`
§C3–C4). A integridade transacional e a autorização vivem no backend; **a integridade estrutural
(constraints, chaves, unicidade) vive aqui** e é imposta pela própria BD.

## Relacionados

- `agents/05-backend/README.md` — quem orquestra a escrita nos dados que esta categoria modela.
- `agents/08-infrastructure/README.md` — onde a BD corre; storage, HA e backup de **infra** (não de dados).
- `agents/13-guardians/backup-guardian.md` — opera em cadência os backups que aqui se desenham.
- `modules/state-machines.md` · `modules/audit-and-provenance.md` · `modules/entity-lifecycle.md` — capacidades reutilizáveis que os agentes aplicam.
- `knowledge/proven-patterns.md` §4–§5 · `knowledge/origin-lessons.md` §B,§C — os padrões que a categoria implementa.
