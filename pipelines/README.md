# Pipelines — automação de referência

Um **pipeline** é a sequência de estágios automatizados que valida e entrega código, do commit à
produção. Esta pasta descreve os **três pipelines de referência** da framework de forma **agnóstica
de fornecedor de CI** (GitHub Actions, GitLab CI, Azure DevOps, …): o *quê* corre, quando corre e o
que bloqueia. O adaptador concreto por fornecedor vive em `agents/07-devops/` (ex.:
`agents/07-devops/github-actions-specialist.md`), que traduz este contrato agnóstico em workflows
reais.

## Princípios

- **Pipeline como código, versionado no repositório.** Revisto por PR como qualquer outro código;
  nunca configurado só pela UI do fornecedor de CI, onde não há histórico nem revisão.
- **CI separado por app.** Frontend e backend correm em jobs/estágios distintos; **ambos têm de estar
  verdes** antes de merge — um vermelho não se esconde atrás de um verde do outro lado
  (`knowledge/permanent-rules.md` §7).
- **Nada integra sem verde.** Os checks requeridos bloqueiam o merge; não há *bypass* silencioso nem
  `continue-on-error` a pintar de verde o que falhou (`core/quality-gates.md`).
- **Segredos injetados em runtime, nunca hardcoded.** Vivem no *secrets store*/OIDC do fornecedor,
  nunca em claro no ficheiro do pipeline nem em log (`knowledge/permanent-rules.md` §5).
- **Tempos de pipeline vigiados.** Um pipeline lento é um pipeline que a equipa aprende a ignorar ou a
  contornar; cache correto (por lockfile) e paralelização fazem parte do contrato, não são otimização
  opcional.

## Os três pipelines

| Pipeline | O que garante |
| --- | --- |
| `pipelines/ci-quality.md` | Lint, typecheck, testes unitários/integração (frontend e backend separados), build e deteção de *drift* de contratos gerados — em cada push/PR. |
| `pipelines/ci-security.md` | SAST, *secrets scan* (diff e histórico), *dependency scan*, *container scan*, SBOM gerado, DAST agendado contra ambiente de teste. |
| `pipelines/cd-delivery.md` | Promoção entre ambientes com aprovação humana, backup antes de produção, estratégia blue-green/canary e *rollback* automático. |

Os pipelines de qualidade e de segurança correm **em paralelo**, a partir do mesmo commit/PR. O de
entrega só arranca com **ambos verdes** — nunca promove um artefacto que não passou pelos dois
(`core/quality-gates.md`).

## Relacionados

- `agents/07-devops/github-actions-specialist.md` · `agents/07-devops/azure-devops-specialist.md` · `agents/07-devops/gitlab-ci-specialist.md`
- `agents/07-devops/deployment-strategist.md` · `core/quality-gates.md`
- `checklists/pre-merge.md` · `knowledge/permanent-rules.md`
