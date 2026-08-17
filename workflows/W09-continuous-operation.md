# W09 — Operação Contínua (Fase F9)

A fase que **nunca acaba**. Um produto não está "acabado" quando entra em produção — é aí que começa a
viver (`MANIFESTO.md` §10: a manutenção começa no dia 0). F9 mantém-no saudável para sempre através de
uma **equipa permanente de guardiões**, cada um a vigiar uma dimensão na sua **cadência própria**, sem
esperar que um humano se lembre de olhar. Onde um revisor de F7 pergunta "está bom para lançar?", um
guardião pergunta "continua bom, hoje?".

> **Fase:** F9 (perpétua) · **Portão de entrada:** P8 (produto em produção, com rollback ensaiado)
> · **Portão de saída:** não há — há **cadências (P9)** e os loops L02–L08 sempre armados
> · **Workflow anterior:** `workflows/W08-launch.md` · **transversais:** `workflows/W10-feature-evolution.md`, `workflows/W11-incident-response.md`

## Objetivo

Manter o produto seguro, rápido, barato, documentado e recuperável ao longo dos anos — com prova real,
nunca "parece bem". Cada ciclo de guardião termina em **estado terminal auditável** (resolvido /
mitigado / não-aplicável), e o não-óbvio volta à memória do projeto (`core/project-memory.md`);
o que é geral e da framework sobe à mãe na cadência do perfil
(`playbooks/report-framework-improvements.md`).

## Pré-condições (portão de entrada)

- [ ] P8 passou: produto em produção, monitorização ativa, rollback ensaiado, `product/07-operations/`
      completo (runbooks, SLOs, observabilidade, plano DR).
- [ ] Perfil de esforço confirmado em `STATE.md` — decide **quais** guardiões correm e com que
      cadência (`core/orchestrator.md` §Perfis).
- [ ] Molde de relatório disponível (`templates/technical/guardian-report.md.template`).

## Passos (agente → artefacto → cadência)

F9 não é uma sequência única: é um **conjunto de ciclos agendados** que o Orquestrador orquestra em
paralelo. Cada guardião corre o seu ciclo fixo — **analisa → planeia → aplica → valida → documenta** —
e escreve em `product/99-records/guardians/<dimensao>-AAAA-MM-DD.md`.

| # | Guardião | Vigia | Cadência | Encadeia / escala para |
| --- | --- | --- | --- | --- |
| 1 | `agents/13-guardians/security-guardian.md` | CVEs, deps, containers, SO, cloud | diária + por CVE | aciona (2); `loops/L07-cves.md`, `loops/L03-security-issues.md`, `playbooks/cve-response.md` |
| 2 | `agents/13-guardians/dependency-guardian.md` | atualização deliberada (não-segurança) | semanal + mensal (majors) | `playbooks/dependency-updates.md`, `loops/L08-technical-debt.md` |
| 3 | `agents/13-guardians/performance-guardian.md` | CPU/RAM, queries, APIs, cache, LCP/CLS/TTFB vs orçamentos | contínua + semanal | alimenta (4) |
| 4 | `agents/13-guardians/cost-guardian.md` | custos de infra, APIs e IA (produto e desenvolvimento) | mensal + alerta por anomalia | **lê a saída de (3)** |
| 5 | `agents/13-guardians/quality-guardian.md` | code smells, duplicação, complexidade, cobertura, deriva de arquitetura | semanal + por release | `loops/L04-code-smells.md`, `loops/L08-technical-debt.md` |
| 6 | `agents/13-guardians/documentation-guardian.md` | sincronia docs↔código↔produto | por release + semanal | `loops/L05-inconsistencies.md`, `loops/L06-outdated-documentation.md` |
| 7 | `agents/13-guardians/backup-guardian.md` | existência **e restauro real** dos backups | verificação diária + ensaio periódico | `workflows/W11-incident-response.md` se o restauro falha |
| 8 | `agents/13-guardians/value-guardian.md` | KPIs de negócio vs alvos de `product/00-discovery/goals-and-kpis.md` | mensal + por alvo com prazo a vencer | alvo falhado → decisão de produto sobe ao utilizador; pode disparar (9) |
| 9 | `agents/13-guardians/feature-evolution-agent.md` | pedidos novos em produção | por evento (pedido) | dispara `workflows/W10-feature-evolution.md` |

**Encadeamento entre guardiões (`agents/13-guardians/README.md`):** o Orquestrador não os corre em
silos — o de Segurança aciona o de Dependências quando o patch exige atualizar; o de Custos lê a saída
do de Performance (uma query lenta que escalou a fatura); o de Qualidade e o da Documentação partilham
os mesmos loops de reconciliação. **Reportam todos ao Orquestrador**, que agrupa as perguntas ao
utilizador em lotes (nunca à peça — `core/question-engine.md`).

> **Escala ao perfil:** as cadências concretas de cada guardião por perfil vivem na **tabela única**
> de `agents/13-guardians/README.md` §Cadências por perfil — num protótipo ficam todos desativados
> até à decisão de continuar; na plataforma empresarial soma-se a revisão global periódica
> (`workflows/W12-global-review.md`).

## Pontos de decisão

- **Aprovação humana** (`core/orchestrator.md` §Aprovação humana): só o utilizador **aceita risco
  residual** (um CVE que se decide não corrigir já), autoriza **gastar dinheiro** (upgrade de infra
  proposto pelo guardião de custos), aprova **majors** de dependências com risco, ou toca em **dados
  pessoais**. O guardião recomenda com evidência; **não decide**.
- **Agrupar perguntas.** As pendências de vários guardiões juntam-se num lote coerente por ciclo, não
  uma interrupção por achado (`core/question-engine.md`); ficam visíveis em `STATE.md` →
  "Decisões pendentes" enquanto o utilizador não responde.
- **Estados terminais obrigatórios.** Nenhum achado fica "em análise" sem dono e sem prazo: termina
  **resolvido** (com prova), **mitigado** (risco aceite pelo utilizador) ou **não-aplicável**
  (justificado).

Exemplo multi-domínio: num **SaaS B2B**, o guardião de segurança triava um CVE numa lib de PDF e, como
não há caminho de exploração no produto, marca **não-aplicável** com justificação; num **e-commerce**,
o de custos deteta que a fatura de IA da pesquisa disparou e propõe um kill-switch por modelo
(`modules/ai-observability.md`); numa **app interna**, o de backups faz o ensaio mensal de
restauro e descobre um dump corrompido — o que **vira incidente**.

## Encaminhamento: quando um ciclo deixa de ser um ciclo

- **Achado → incidente.** Quando um achado ultrapassa a dimensão do guardião (um CVE a ser explorado
  ativamente, uma degradação a virar indisponibilidade, um restauro que falha), **escala para**
  `workflows/W11-incident-response.md` — triagem, mitigação, comunicação, post-mortem sem culpados
  (`checklists/post-incident.md`).
- **Pedido novo → evolução.** Um pedido de funcionalidade em produção entra pelo
  `agents/13-guardians/feature-evolution-agent.md`, que dispara
  `workflows/W10-feature-evolution.md` — o mini-ciclo que reexecuta F2→F8 em miniatura, com os
  portões das fases que toca (`core/lifecycle.md` regra 4). Não se "mete a feature direto em
  produção" saltando os portões.

## Loops que abre

Em F9 os loops L02–L08 estão **sempre armados** (`core/lifecycle.md` F9), acionados pelos
guardiões: `loops/L02-failing-tests.md`, `loops/L03-security-issues.md`,
`loops/L04-code-smells.md`, `loops/L05-inconsistencies.md`, `loops/L06-outdated-documentation.md`,
`loops/L07-cves.md`, `loops/L08-technical-debt.md`. Salvaguarda: três iterações sem progresso param o
loop e sobem ao utilizador (`loops/README.md`).

## Portão de saída (P9 — cadências, não fase)

F9 não fecha — **cumpre-se por cadência** (`core/quality-gates.md` P9). Cada ciclo de guardião
"passa" quando:

- [ ] O relatório do ciclo está escrito em `product/99-records/guardians/` **com números e estados
      terminais** — um relatório sem números e sem estados terminais **não fecha** o ciclo.
- [ ] Nenhum achado ficou "em análise" sem dono e prazo; o que subiu ao utilizador está em `STATE.md`.
- [ ] As mudanças aplicadas foram **validadas com prova real** e têm caminho de reversão
      (`modules/feature-flags.md` quando aplicável).
- [ ] As lições não-óbvias foram para `STATE.md` (`core/project-memory.md`); as que são da
      **framework** foram para `FRAMEWORK-IMPROVEMENTS.md`, e o reporte seguiu na cadência do
      perfil (`playbooks/report-framework-improvements.md`).

**Quem verifica:** o Orquestrador, por cadência. **Quem aprova:** o utilizador, **por exceção** (só
quando há risco residual, dinheiro, dados ou produção em jogo).

## Perfis de esforço

| Perfil | Como muda F9 |
| --- | --- |
| **Protótipo** | Guardiões desativados até a decisão de evoluir para produto; sem cadências. |
| **Produto interno** | Guardiões em cadência mensal; loops armados; DR verificado periodicamente. |
| **Produto comercial** | Cadência semanal + alertas; guardião de custos com anomalias; on-call para incidentes (W11). |
| **Plataforma empresarial** | Cadências apertadas, ensaio de DR regular, revisão global periódica (`workflows/W12-global-review.md`), custos de IA com kill-switch por modelo. |

## Anti-padrões

- ❌ "Está em produção, está acabado" → ✅ a manutenção começa no dia 0; guardiões em cadência.
- ❌ Backup que existe mas nunca se restaurou → ✅ ensaio real de restauro é o que conta.
- ❌ Achado "em análise" eterno → ✅ estado terminal com dono e prazo.
- ❌ Feature nova metida direto em produção → ✅ `workflows/W10-feature-evolution.md` com portões.
- ❌ Metralhadora de perguntas ao utilizador a cada achado → ✅ lotes por ciclo.

## Relacionados

- `agents/13-guardians/README.md` — cadências, deveres comuns e formato de relatório.
- `workflows/W10-feature-evolution.md` — pedidos novos; `workflows/W11-incident-response.md` — quando um achado vira incidente.
- `core/lifecycle.md` (F9) · `core/quality-gates.md` (P9) · `core/project-memory.md`.
- `loops/README.md` — os loops L02–L08 armados em produção.
- `templates/technical/guardian-report.md.template` · `checklists/post-incident.md`.
- `playbooks/report-framework-improvements.md` — o reporte de melhorias na cadência de F9.
- `agents/12-reviewers/README.md` — os olhos pontuais de F7, a montante dos guardiões.
