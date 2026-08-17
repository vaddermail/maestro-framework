# Go-Live

O portão P8 (F8 → produção) — a única aprovação **sempre humana** do ciclo de vida
(`core/quality-gates.md`). Dono da execução: `agents/07-devops/deployment-strategist.md`; a
decisão final de promover é sempre do utilizador, nunca delegável a um agente.

## Reconhecimento do alvo e pré-voo de ambiente

Corre **antes** de provisionar — nunca assumir campo verde. Um alvo mal caracterizado é onde os
deploys partem o que já lá estava, ou onde a app não arranca por uma dependência que nunca se testou.

- [ ] Alvo caracterizado: é dedicado ou **partilhado**? O que já lá corre? O novo serviço entra
      **isolado** (BD/rede próprias) e qual é o *blast-radius* sobre o que já existe? A única alteração
      ao que já lá está é aditiva e reversível?
- [ ] Folga de recursos do alvo verificada e monitorizada (disco, memória, portos) — um alvo perto do
      limite antes de arrancar é risco.
- [ ] **Dependências de saída** de que a app precisa em runtime (portas de e-mail/SMTP, APIs externas,
      filas) testadas **a partir do próprio alvo** — muitos fornecedores bloqueiam portas ou saídas por
      omissão; descobre-se agora, não no primeiro utilizador. Atenção redobrada quando a autenticação
      ou um fluxo crítico depende dessa saída.
- [ ] Particularidades da plataforma-alvo verificadas: mudanças de comportamento entre **versões
      maiores** de imagens/serviços, e que a configuração montada é mesmo a que o serviço **lê**
      (não uma versão presa/antiga).
- [ ] Acesso operacional ao alvo estável durante o deploy (reutilizar ligações; evitar disparar
      proteções por excesso de tentativas) — para o próprio deploy não se auto-sabotar.

## Preparação

- [ ] Build/artefacto verde, com os gates de qualidade e segurança já passados
      (`checklists/pre-merge.md`, `checklists/pre-production-security.md`).
- [ ] **Caminho de deploy exercido ponta-a-ponta** pelo menos uma vez antes do dia (staging ou
      ensaio) — artefactos de deploy existirem **não** é o caminho estar exercido; só produção real
      expõe o que falta.
- [ ] Backup do estado atual (dados e infra) feito e **verificado** imediatamente antes do
      lançamento; restauro **ensaiado** pelo menos uma vez — um backup que nunca se restaurou não
      conta (`agents/06-data/backup-specialist.md`,
      `agents/08-infrastructure/infra-backup-specialist.md`).
- [ ] Fluxo de autenticação **de produção** exercido de verdade (login real, não o atalho de
      desenvolvimento) antes de haver utilizadores.
- [ ] Migração de BD, se houver, em expand-contract — sem largar/renomear nada ainda em uso
      (`playbooks/expand-contract-db-migration.md`).

## Rollback

- [ ] Procedimento de rollback **ensaiado num ambiente equivalente**, não só escrito no runbook
      (`playbooks/release-and-rollback.md`).
- [ ] Critério objetivo de rollback definido antes do lançamento (ex.: taxa de erro > X%, latência >
      Yms) — nunca decidido a olho durante o incidente.
- [ ] Runbook de release/rollback atualizado e acessível (`templates/technical/runbook.md.template`).

## Monitorização

- [ ] Alertas de erro, latência e disponibilidade ativos e a apontar para os donos corretos antes de
      o tráfego real começar.
- [ ] Painel de observação disponível para acompanhar a janela de lançamento em tempo real.

## Pessoas e comunicação

- [ ] Donos contactáveis durante a janela de lançamento **confirmados**, não só nomeados numa lista.
- [ ] Plano de comunicação definido: quem avisa quem, em caso de sucesso e em caso de rollback.
- [ ] Aprovação humana explícita para produção registada em `STATE.md`, com nome e data — nunca
      implícita ou assumida.

## Infra e hard-block

- [ ] Pipeline confirma o ambiente/conta/cluster de destino e **aborta** se não corresponder ao
      pretendido — testado a abortar de propósito pelo menos uma vez
      (`agents/07-devops/deployment-strategist.md`).
- [ ] Segredos de produção injetados em runtime, nunca embutidos no artefacto
      (`agents/07-devops/secrets-manager.md`).

## Relacionados

- `agents/07-devops/deployment-strategist.md` — dono da estratégia e da execução do release.
- `playbooks/release-and-rollback.md` — o procedimento detalhado que esta checklist verifica.
- `core/quality-gates.md` — o portão P8, aprovação sempre humana.
- `checklists/pre-production-security.md` — pré-condição deste portão.
- `pipelines/cd-delivery.md` — a automação de entrega e o hard-block.
- `workflows/W08-launch.md` — o workflow completo de F8.
