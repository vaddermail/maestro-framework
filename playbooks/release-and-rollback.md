# Release e Rollback

Procedimento de pôr uma versão em produção com rede: backup prévio **verificado**, deploy, verificação
pós-deploy real, e rollback **ensaiado** — testado antes de ser preciso, nunca só documentado.
Executado pelo `agents/07-devops/deployment-strategist.md`, tanto no go-live inicial
(`workflows/W08-launch.md`) como em qualquer release seguinte. A ida a produção exige sempre
aprovação humana explícita — nunca delegável a agentes.

## Pré-condições

- Portão de qualidade/segurança correspondente limpo (P7 no go-live; pipeline de qualidade e segurança
  verde nas releases seguintes).
- Segredos de produção fora do Git, injetados em runtime (`playbooks/secrets-management.md`).
- Se o release inclui mudança de esquema: plano de migração escrito
  (`playbooks/expand-contract-db-migration.md`).

## Passos

1. **Confirmar as pré-condições do portão.** `checklists/go-live.md` (primeiro release) ou pipeline de
   qualidade/segurança verde (releases seguintes). *Verifica-se* pela checklist completa. *Se falhar*:
   não avança — corrige-se a fase em falta primeiro.

2. **Backup prévio, verificado.** Tirar backup do estado atual (BD + config + assets relevantes) e
   confirmar que é **restaurável**, não só que "correu sem erro". *Verifica-se* com um restauro de
   teste recente (dentro da cadência do `agents/13-guardians/backup-guardian.md`) que provou
   restaurar. *Se não houver restauro testado recente*: parar e testar o restauro primeiro — um backup
   não verificado não conta como backup.

3. **Hard-block contra a infra errada.** Confirmar o alvo do deploy (ambiente, região, cluster) contra
   a configuração declarada, com uma verificação automática que recusa aplicar se não bater certo.
   *Verifica-se* simulando um alvo errado e confirmando que a pipeline aborta. *Se o bloqueio não
   existir ou não disparar*: não há release — é bloqueador, não recomendação.

4. **Ensaiar o rollback antes do deploy real.** Executar o procedimento de reversão em staging (ou
   equivalente) e confirmar que devolve o sistema ao estado anterior. *Verifica-se* que staging volta
   ao estado pré-deploy com dados intactos e serviço operacional. *Se o ensaio falhar*: o rollback não
   está pronto — não se avança para o deploy real até corrigir.

5. **Se há migração de BD, só a fase aditiva acompanha este release.** Segue-se
   `playbooks/expand-contract-db-migration.md` — nunca largar/renomear o que está em uso no mesmo
   passo do release.

6. **Aprovação humana explícita.** Apresentar o plano (o quê, riscos, janela, rollback já ensaiado) ao
   utilizador e obter aprovação registada em `STATE.md` antes de aplicar a produção. *Verifica-se*
   pela aprovação escrita. Isto nunca se salta, em nenhum perfil de esforço.

7. **Aplicar o deploy.** Seguindo a estratégia decidida (blue-green, canary ou big-bang, conforme o
   perfil e a janela de menor impacto) com o estado de reversão do passo 4 pronto a acionar.
   *Verifica-se* que a pipeline de entrega termina verde.

8. **Verificação pós-deploy: smoke test live real.** Exercitar os fluxos críticos no ambiente de
   produção real, não simulado. *Verifica-se* com evidência concreta anexada (output/captura).
   *Se vermelho*: aciona o rollback do passo 4 de imediato — nunca "vê-se amanhã".

9. **Monitorizar a janela pós-release.** Alertas ativos, métricas-chave observadas durante o período
   definido pelo perfil de esforço. *Verifica-se* confirmando dashboards/alertas ativos antes de
   declarar o release fechado.

10. **Documentar.** Registo em `STATE.md` (o quê, aprovação, resultado do smoke test); runbook em
    `product/07-operations/runbooks/` atualizado se o procedimento mudou.

## Reversão

O rollback **é** o procedimento ensaiado no passo 4, nunca improvisado na hora: acionar o estado de
reversão preparado (versão anterior + configuração e, se necessário, o restauro do backup do passo 2),
confirmar com o mesmo smoke test do passo 8, e registar o rollback em `STATE.md` com a causa. Um
rollback nunca deve exigir restauro manual heroico de dados — é por isso que qualquer migração de
esquema associada segue expand-contract (passo 5): a fase aditiva é sempre revertível sem perda, porque
nada em produção dependia ainda dela.

## Relacionados

- `agents/07-devops/deployment-strategist.md` — quem executa este playbook.
- `workflows/W08-launch.md` — a fase F8 onde o primeiro release corre.
- `checklists/go-live.md` — os critérios do portão P8.
- `playbooks/expand-contract-db-migration.md` — como acompanhar um release com mudança de esquema.
- `agents/13-guardians/backup-guardian.md` — quem mantém os backups testados.
- `core/quality-gates.md` — P8, aprovação humana sempre.
- `modules/feature-flags.md` — mudanças de risco desligáveis sem novo deploy.
