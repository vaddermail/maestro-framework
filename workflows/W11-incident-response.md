# W11 — Resposta a Incidente (transversal a F9)

> **Disparo:** algo em produção está a falhar ou a arriscar dados **agora** · **Coordena:** o
> Orquestrador (com o `agents/09-security/security-coordinator.md` se for incidente de
> segurança) · **Condição de fecho:** `checklists/post-incident.md` completa.

## Objetivo

Conter um incidente em produção com o mínimo de dano e sem esconder nada: **mitigar primeiro,
diagnosticar depois**, comunicar com honestidade e cadência, corrigir a causa e aprender sem procurar
culpados. Não é um portão de fase — é um procedimento transversal que pode disparar a qualquer momento
durante a operação (`workflows/W09-continuous-operation.md`). A **reversibilidade é a primeira arma**
(`knowledge/permanent-rules.md` §reversibilidade): quase todo o incidente se atenua a desligar
uma mudança recente antes de perceber a causa.

## Gatilho e pré-condições

- [ ] Sinal de incidente: alerta de um guardião (`agents/13-guardians/README.md`), erro reportado por
      utilizador, degradação observada, ou suspeita de fuga/acesso indevido.
- [ ] Existe rollback e/ou flags para a mudança suspeita (`playbooks/release-and-rollback.md`,
      `modules/feature-flags.md`) — se não existirem, é a primeira lição do post-mortem.
- [ ] Abre-se `product/99-records/incidents/INC-nnn.md` **imediatamente** e regista-se em tempo real:
      o log do incidente é a fonte de verdade, não a memória.

## O princípio: mitigar primeiro, diagnosticar depois

A ordem é deliberada e não se inverte sob pressão:

1. **Parar a hemorragia** (mitigação) vem antes de **perceber a causa** (diagnóstico). Rollback ou
   kill-switch reduzem o dano em minutos; a causa-raiz pode levar horas. Diagnosticar com produção a
   sangrar troca dano real por curiosidade.
2. **Honestidade absoluta no relato** (`knowledge/permanent-rules.md` §honestidade — tolerância
   zero): comunica-se o que se sabe, o que não se sabe e o que se está a fazer. Nunca minimizar,
   nunca inventar uma causa antes de a confirmar.
3. **Reverter não é admitir derrota** — é a resposta correta. O diagnóstico faz-se sobre o sistema já
   estabilizado (ou numa réplica), não sobre os utilizadores.

## Passos (fase do incidente → agente → artefacto)

| # | Fase | Agente | Artefacto / ação | Depende de |
| --- | --- | --- | --- | --- |
| 1 | **Triagem** | Orquestrador (+ guardião que detetou) | `INC-nnn.md` §triagem: **severidade** (tabela abaixo), **âmbito** (que serviço/módulo), **dados afetados** (há dados pessoais? corrompidos? expostos?) | sinal |
| 2 | **Mitigação imediata** | `agents/07-devops/deployment-strategist.md` (rollback) · `agents/07-devops/feature-flags-specialist.md` (kill-switch) | mudança suspeita revertida/desligada; serviço estabilizado; timestamp no log | 1 |
| 3 | **Avaliação de dados** (se §dados afetados ≠ nenhum) | `agents/06-data/data-auditor.md` (+ `coordenador-de-seguranca` se fuga) | extensão do dano a dados: registos tocados, proveniência, necessidade de restauro (`agents/06-data/backup-specialist.md`) | 1 |
| 4 | **Comunicação** | Orquestrador | quem avisa quem, com que cadência (tabela abaixo); registo dos avisos em `INC-nnn.md` | 1 (arranca em paralelo com 2) |
| 5 | **Correção definitiva** | equipa de construção via `workflows/W10-feature-evolution.md` (fatia de correção) | causa-raiz corrigida com teste que **reproduz** o incidente antes de o fechar | 2, diagnóstico |
| 6 | **Post-mortem sem culpados** | Orquestrador + `agents/11-documentation/technical-writer.md` | `product/99-records/incidents/INC-nnn-postmortem.md` (`templates/technical/post-mortem.md.template`) | 5 |

**Triagem — severidade** (o que dita a cadência e quem se acorda):

| Sev | Critério | Exemplo multi-domínio |
| --- | --- | --- |
| **SEV1** | Indisponível ou dados de utilizadores em risco/expostos | Checkout de e-commerce em baixo; scoping partido num SaaS mostra dados de um cliente a outro. |
| **SEV2** | Funcionalidade central degradada, com contorno | Pipeline de dados atrasado horas; relatórios a falhar mas leitura OK. |
| **SEV3** | Falha localizada, impacto limitado | Um filtro devolve erro; um ecrã secundário quebrado. |
| **SEV4** | Cosmético / sem impacto funcional | Label errado, ícone em falta. |

## Pontos de decisão (aprovação humana)

- **Mitigação de baixo risco não espera aprovação:** reverter para um estado bom conhecido e acionar
  kill-switches são ações reversíveis dentro de runbook — fazem-se já (`core/quality-gates.md`
  §nunca precisam de humano: refactors/ações reversíveis). Parar para pedir autorização a sangrar é o
  erro.
- **Sobe ao humano, sempre:** qualquer ação **destrutiva ou irreversível** na mitigação (apagar dados,
  restaurar backup por cima de dados novos — `agents/06-data/disaster-recovery-planner.md`);
  **notificar clientes/reguladores** de fuga de dados pessoais; aceitar risco residual ao reabrir o
  serviço antes da causa-raiz estar fechada.
- **Comunicação — cadência por severidade:** SEV1 → atualização ao utilizador/stakeholders a cada
  30–60 min até estabilizar; SEV2 → por marco; SEV3/4 → no fecho. Quem comunica é o Orquestrador; os
  destinatários (dono do produto, utilizadores afetados, segurança) definem-se na triagem.

## Loops que abre

- `loops/L03-security-issues.md` — se é incidente de segurança, resolve-se por severidade e
  entra o `coordenador-de-seguranca` como dono do risco.
- `loops/L07-cves.md` / `playbooks/cve-response.md` — se a causa é uma vulnerabilidade de dependência.
- `loops/L08-technical-debt.md` — as ações preventivas do post-mortem que não se fazem já entram como
  dívida rastreável, com dono e prazo (nunca "vamos ter cuidado da próxima vez").

## Condição de fecho (o portão deste workflow)

O incidente **fecha** quando `checklists/post-incident.md` está completa:

- [ ] Serviço estável e **verificado** (prova-live, não suposição); mitigação temporária substituída
      pela correção definitiva (etapa 5) **ou** a correção está agendada com dono e a mitigação é segura.
- [ ] Teste de regressão que **reproduz** o incidente adicionado e verde (`agents/10-quality/`).
- [ ] Dados avaliados: restaurados/reconciliados, ou confirmado que não houve dano
      (`agents/06-data/data-auditor.md`).
- [ ] **Post-mortem sem culpados** escrito: linha temporal, causa-raiz, o que correu bem, ações
      preventivas com dono e prazo (`templates/technical/post-mortem.md.template`). Foco no sistema, não
      nas pessoas.
- [ ] `STATE.md` atualizado; lições não-óbvias registadas (`core/project-memory.md`).

## Recuperação de falhas (o incidente dentro do incidente)

| Situação | Resposta |
| --- | --- |
| Não há rollback nem flag para a mudança suspeita | Mitigar pelo meio disponível (isolar o serviço, degradar graciosamente); **1ª ação preventiva do post-mortem:** tornar aquela mudança reversível. |
| Rollback também falha | Escalar para DR (`agents/06-data/disaster-recovery-planner.md`); acionar o dono humano — nunca improvisar destrutivo sob pânico. |
| Causa-raiz não aparece após mitigação | Manter mitigado; diagnosticar sem pressa em réplica; não reabrir o caminho quebrado "para ver se acontece de novo" em produção. |
| Pressão para fechar sem post-mortem | Não se fecha: o post-mortem é o que impede a repetição (`knowledge/permanent-rules.md`). SEV3/4 podem ter post-mortem curto; ter, têm. |

## Relacionados

- `checklists/post-incident.md` — a condição de fecho detalhada.
- `templates/technical/post-mortem.md.template` — o molde do post-mortem sem culpados.
- `playbooks/release-and-rollback.md` · `modules/feature-flags.md` — as armas de mitigação.
- `workflows/W10-feature-evolution.md` — o caminho da correção definitiva.
- `workflows/W09-continuous-operation.md` — a operação de onde o incidente emerge.
- `agents/13-guardians/README.md` — os guardiões que detetam cedo.
