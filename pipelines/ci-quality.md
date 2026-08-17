# CI de Qualidade (Quality CI)

Pipeline que corre em **cada push e pull/merge request**: garante que só código lintado, tipado,
testado e compilável chega ao ramo de integração. É o primeiro gate — cedo, rápido, sempre verde antes
de merge (`knowledge/permanent-rules.md` §7). O adaptador concreto (GitHub Actions, GitLab CI,
Azure DevOps) materializa-o; ver `agents/07-devops/github-actions-specialist.md` e as fichas irmãs
por fornecedor.

## Princípios

- **Frontend e backend em jobs/estágios separados, ambos verdes.** Um não mascara o outro; um vermelho
  em qualquer um bloqueia o merge (`knowledge/permanent-rules.md` §7).
- **Rápido antes de exaustivo.** Lint e typecheck correm primeiro (segundos); testes mais pesados
  depois — falha cedo, sem esperar minutos para descobrir um erro de sintaxe.
- **Cache pela chave do lockfile**, nunca por chave fixa — uma chave fixa esconde dependências
  desatualizadas; a chave certa invalida sozinha quando o lockfile muda.
- **O artefacto de build é o que se promove**, nunca código reconstruído em cada ambiente
  (`agents/07-devops/deployment-strategist.md` regra 5) — este pipeline produz esse artefacto uma
  única vez, imutável e versionado.
- **Drift de contratos gerados é falha, não aviso.** Um cliente TypeScript desatualizado face ao
  OpenAPI (ou equivalente) é o mesmo tipo de bug que um teste vermelho — bloqueia da mesma forma.

## Estágios

1. **Gatilho** — todo `push` a um branch e toda abertura/atualização de *pull/merge request*. Corre
   sempre; não é opcional por tamanho do diff.
2. **Lint** — frontend e backend em jobs separados, cada um só com as regras da sua linguagem/
   framework. Bloqueia o merge se falhar em qualquer um dos dois.
3. **Typecheck** — quando a stack é tipada estaticamente, job próprio por app. Bloqueia o merge.
4. **Testes unitários e de integração** — frontend e backend **sempre em jobs distintos**
   (`knowledge/permanent-rules.md` §7); os testes de integração usam serviços reais em
   contentor (BD, fila) em vez de mocks que a produção não tem. Bloqueia se qualquer job falhar.
5. **Build** — compila/empacota cada app; produz o artefacto imutável e versionado (hash ou tag) que
   o `pipelines/cd-delivery.md` promove mais tarde. Bloqueia se não compilar.
6. **Drift de contratos gerados** — regenera o artefacto derivado (ex.: cliente a partir do OpenAPI,
   tipos a partir de um schema) e compara com o que está commitado; qualquer diferença falha o job
   (`agents/05-backend/api-versioning-specialist.md`). Bloqueia o merge.
7. **Publicação de artefactos** — build, relatórios de teste e de cobertura ficam anexados à execução,
   versionados pelo commit/tag; é o que os revisores e o `pipelines/cd-delivery.md` consomem a seguir.
   Não bloqueia por si, mas tem de correr para o CD ter o que promover.

## Cache

Chave de cache = hash do lockfile, por app (frontend e backend com chaves independentes). Restaura só
dependências, nunca artefactos de build não determinísticos nem segredos. Lockfile mudou → cache
recalculado do zero, nunca remendado por cima do antigo.

## O que bloqueia o merge

| Estágio | Bloqueia merge? |
| --- | --- |
| Lint (frontend / backend) | Sim |
| Typecheck (frontend / backend) | Sim |
| Testes unitários/integração (frontend / backend) | Sim |
| Build | Sim |
| Drift de contratos gerados | Sim |
| Publicação de artefactos | Não bloqueia — mas é obrigatório correr |

## Exemplo (pseudocódigo neutro, ilustrativo)

```yaml
pipeline: ci-qualidade
gatilhos: [push, pull_request]
cache:
  chave: hash(lockfile-por-app)
estagios:
  - job: lint-frontend
    bloqueia_merge: true
  - job: lint-backend
    bloqueia_merge: true
  - job: typecheck-frontend
    bloqueia_merge: true
  - job: typecheck-backend
    bloqueia_merge: true
  - job: testes-frontend
    depende_de: [lint-frontend, typecheck-frontend]
    bloqueia_merge: true
  - job: testes-backend
    depende_de: [lint-backend, typecheck-backend]
    servicos: [bd-teste]
    bloqueia_merge: true
  - job: build
    depende_de: [testes-frontend, testes-backend]
    bloqueia_merge: true
    produz: artefacto-imutavel
  - job: drift-contratos
    depende_de: [build]
    bloqueia_merge: true
```

## Relacionados

- `pipelines/README.md` · `pipelines/ci-security.md` · `pipelines/cd-delivery.md`
- `checklists/pre-merge.md` · `knowledge/permanent-rules.md`
- `agents/07-devops/github-actions-specialist.md` · `agents/10-quality/test-strategist.md`
- `agents/05-backend/api-versioning-specialist.md`
