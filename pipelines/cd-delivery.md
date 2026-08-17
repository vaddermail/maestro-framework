# CD de Entrega (Delivery CD)

Pipeline que pega no artefacto verde do `pipelines/ci-quality.md` — já filtrado pelo
`pipelines/ci-security.md` — e leva-o a produção de forma reversível: promoção por ambientes, backup
antes de tocar em produção, estratégia de release com critérios de saúde e *rollback* automático
quando esses critérios falham. Executa a estratégia definida por
`agents/07-devops/deployment-strategist.md`; materializado por
`agents/07-devops/github-actions-specialist.md` ou fornecedor equivalente.

## Princípios

- **Promove-se o mesmo artefacto que passou o CI**, por hash/tag — nunca se reconstrói por ambiente
  (`agents/07-devops/deployment-strategist.md` regra 5).
- **Nunca promove sobre vermelho.** Sem build verde do CI de qualidade e sem gate do CI de segurança,
  o pipeline de entrega não arranca (`core/quality-gates.md`).
- **Backup/estado de reversão antes de qualquer deploy de produção** — sem ponto de retorno
  verificado, não há promoção (`knowledge/permanent-rules.md` §3).
- **Produção atrás de aprovação humana, sempre.** Nunca automático no merge, por mais verde que o
  pipeline esteja a montante.
- **Hard-block contra a infra errada.** O pipeline confirma o alvo (ambiente/conta/cluster/host) antes
  de qualquer passo o tocar, e **aborta** se não bater certo — um deploy de staging que acerta em
  produção é a classe de erro mais cara.
- **Rollback automático por critério objetivo**, definido antes do release (taxa de erro, latência,
  disponibilidade), nunca decidido "a olho" durante o incidente.

## Estágios

1. **Gatilho** — merge no ramo de integração dispara deploy automático a **dev**; uma tag/release
   dispara promoção a **staging**; a promoção a **produção** é sempre um passo manual de aprovação,
   nunca automático por evento.
2. **Confirmação de alvo (hard-block)** — antes de qualquer ação, o pipeline valida que o ambiente/
   conta/cluster de destino é o pretendido; se divergir, aborta sem tocar em nada.
3. **Deploy em dev** — automático a cada merge; ambiente descartável, sem aprovação, feedback rápido
   para quem desenvolveu.
4. **Deploy em staging** — automático depois de dev saudável (ou disparado por tag); espelha produção
   o mais possível (dados, configuração, topologia) para o release não surpreender mais tarde.
5. **Backup de produção** — obrigatório e **verificado** antes do primeiro passo que toca produção
   (`agents/06-data/backup-specialist.md`, `agents/08-infrastructure/infra-backup-specialist.md`);
   sem backup confirmado, o pipeline não avança.
6. **Aprovação humana (ambiente de produção)** — gate manual com reviewers definidos à partida; regista
   quem aprovou e quando, como parte da evidência do release.
7. **Promoção com estratégia de release** — recreate/rolling/blue-green/canary conforme decidido pelo
   `agents/07-devops/deployment-strategist.md`; se houver migração de BD, corre em expand-contract
   coordenado com `agents/06-data/migration-engineer.md` (`playbooks/expand-contract-db-migration.md`).
8. **Health checks contra critério pré-acordado** — erro/latência/disponibilidade observados durante
   uma janela definida (ex.: 5–20 min de canário), nunca "parece estar bem".
9. **Decisão: promover 100% ou reverter** — aplicação mecânica do critério objetivo; se os health
   checks falham dentro da janela, **rollback automático** para a versão anterior, sem esperar por
   confirmação humana.
10. **Registo** — versão, decisão e evidência escritos no runbook de release/rollback
    (`playbooks/release-and-rollback.md`) e no `STATE.md` do produto (`core/project-memory.md`);
    obrigatório mesmo quando o release corre sem incidentes.

## Exemplo (pseudocódigo neutro, ilustrativo)

```yaml
pipeline: cd-entrega
gatilhos: [merge(integracao), tag(release), promocao_manual(producao)]
estagios:
  - job: confirmar-alvo
    hard_block: true
  - job: deploy-dev
    corre_em: [merge(integracao)]
    depende_de: [confirmar-alvo]
  - job: deploy-staging
    corre_em: [tag(release)]
    depende_de: [deploy-dev-saudavel]
  - job: backup-producao
    corre_em: [promocao_manual(producao)]
    obrigatorio: true
  - job: aprovacao-producao
    tipo: gate-humano
    depende_de: [backup-producao]
  - job: promover-producao
    estrategia: canario
    depende_de: [aprovacao-producao]
    health_check:
      janela: 20m
      criterio: erro < 1%
  - job: decisao
    se_saudavel: promover_100
    senao: rollback_automatico
```

## Relacionados

- `pipelines/README.md` · `pipelines/ci-quality.md` · `pipelines/ci-security.md`
- `playbooks/release-and-rollback.md` · `checklists/go-live.md` · `playbooks/expand-contract-db-migration.md`
- `agents/07-devops/deployment-strategist.md` · `agents/07-devops/github-actions-specialist.md`
- `agents/06-data/migration-engineer.md` · `agents/07-devops/feature-flags-specialist.md`
