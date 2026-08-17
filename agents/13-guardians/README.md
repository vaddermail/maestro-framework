# Guardiões — a equipa permanente de produção

A categoria que materializa o princípio 10 do `MANIFESTO.md`: **a manutenção começa no dia 0**. Um
produto não está "acabado" quando entra em produção — é aí que começa a viver. Os guardiões são a
equipa que o mantém vivo anos depois, cada um vigiando **uma** dimensão em **cadência própria**,
sem esperar que um humano se lembre de olhar.

Todos pertencem à fase **F9 — operação contínua** (`core/lifecycle.md`), orquestrada pelo
`workflows/W09-continuous-operation.md`. Não são pontuais como os revisores de F7
(`agents/12-reviewers/`): os revisores dão um parecer num marco e saem; os guardiões **nunca
acabam** — voltam na cadência seguinte. Onde um revisor pergunta "está bom para lançar?", um guardião
pergunta "continua bom, hoje?".

## O que distingue um guardião

- **Cadência própria** (diária/semanal/mensal ou por evento), não uma convocação única.
- **Ciclo fixo:** analisa → planeia → aplica → valida → documenta. Nunca aplica sem validar; nunca
  fecha sem escrever.
- **Estados terminais auditáveis:** cada achado do ciclo termina resolvido, mitigado (risco residual
  aceite pelo utilizador) ou não-aplicável (justificado). Não há "em análise" pendente sem dono e
  sem prazo.
- **Reporta ao Orquestrador** (`core/orchestrator.md`), que agrupa perguntas ao utilizador e
  encadeia guardiões entre si (o de Segurança aciona o de Dependências; o de Custos lê a saída do de
  Performance).

## Agentes desta categoria

| Agente | Vigia | Cadência típica |
| --- | --- | --- |
| `agents/13-guardians/security-guardian.md` | CVEs, dependências, containers, SO, cloud (exemplar) | diária + por CVE |
| `agents/13-guardians/dependency-guardian.md` | atualização deliberada de dependências (não-segurança) | semanal + mensal (majors) |
| `agents/13-guardians/performance-guardian.md` | CPU, RAM, queries, APIs, cache, LCP/CLS/TTFB vs orçamentos | contínua + semanal |
| `agents/13-guardians/cost-guardian.md` | custos de infra, APIs e IA (produto e desenvolvimento) | mensal + alerta por anomalia |
| `agents/13-guardians/quality-guardian.md` | code smells, duplicação, complexidade, cobertura, deriva de arquitetura | semanal + por release |
| `agents/13-guardians/documentation-guardian.md` | sincronia docs↔código↔produto | por release + semanal |
| `agents/13-guardians/backup-guardian.md` | existência **e** restauro real dos backups | verificação diária + ensaio periódico |
| `agents/13-guardians/value-guardian.md` | KPIs de negócio vs alvos da descoberta — o valor prometido aconteceu? | mensal |
| `agents/13-guardians/feature-evolution-agent.md` | pedidos novos em produção (coordenador de W10) | por evento (pedido) |

## Cadências por perfil (a fonte única)

Esta tabela é a **fonte única** das cadências — `core/orchestrator.md` §Perfis e
`workflows/W09-continuous-operation.md` remetem para aqui. No **protótipo**, todos os guardiões ficam
**desativados** até à decisão de continuar. Um projeto pode **apertar** uma cadência (nunca alargar
sem risco aceite pelo utilizador), registando-a no seu `CLAUDE.md`.

| Guardião | Produto interno | Produto comercial | Plataforma empresarial |
| --- | --- | --- | --- |
| Segurança | semanal + por CVE crítico | diária + por CVE | diária + por CVE |
| Dependências | mensal | semanal + mensal (majors) | semanal + mensal (majors) |
| Performance | mensal | contínua + semanal | contínua + semanal |
| Custos | mensal | mensal + alerta por anomalia | mensal + alerta por anomalia |
| Qualidade | mensal | semanal + por release | semanal + por release |
| Documentação | por release | por release + semanal | por release + semanal |
| Backups | verificação semanal + ensaio trimestral | verificação diária + ensaio mensal | verificação diária + ensaio mensal + DR regular |
| Valor (KPIs) | mensal | mensal + por alvo com prazo a vencer | mensal + por alvo com prazo a vencer |
| Evolução de features | por evento | por evento | por evento |

Na plataforma empresarial soma-se a revisão global periódica (`workflows/W12-global-review.md`).

## Deveres comuns a todos

1. **Ciclo analisa→planeia→aplica→valida→documenta**, com prova real antes de fechar (nunca "parece
   bem" — `core/quality-gates.md`, `knowledge/permanent-rules.md` §7).
2. **Reversibilidade:** toda a mudança que um guardião aplica tem caminho de reversão; risco atrás de
   flag quando aplicável (`modules/feature-flags.md`).
3. **Honestidade:** relatar o estado real com números — nunca um "tudo bem" cosmético
   (`knowledge/permanent-rules.md` §2).
4. **Só o utilizador aceita risco residual** e decide âmbito/dinheiro/dados/produção — o guardião
   recomenda, não decide (`MANIFESTO.md` §8).
5. **Abrir o loop certo** quando o achado persiste: L03 (segurança), L04 (code smells), L05/L06
   (docs), L07 (CVEs), L08 (dívida técnica) — ver `loops/README.md`.
6. **Escrever tudo** em `product/99-records/guardians/` e as lições não-óbvias em `STATE.md`
   (`core/project-memory.md`).

## Formato de relatório do ciclo

Todos usam o mesmo molde — `templates/technical/guardian-report.md.template` — escrito em
`product/99-records/guardians/<dimensao>-AAAA-MM-DD.md`, com: janela do ciclo, achados por estado
terminal (resolvido / mitigado / não-aplicável, cada um justificado), ações aplicadas e como foram
validadas, o que subiu ao utilizador, e a tendência face ao ciclo anterior. Um relatório sem números
e sem estados terminais não fecha o ciclo.

## Como o Orquestrador os convoca

Em F9, o `workflows/W09-continuous-operation.md` agenda cada guardião na sua cadência e recolhe os
relatórios. Fora de cadência, um evento aciona o guardião certo (um CVE → Segurança; uma anomalia de
custo → Custos; um pedido novo → Agente de Evolução, que dispara `workflows/W10-feature-evolution.md`).
Quando um achado ultrapassa a dimensão de um guardião (um CVE a ser explorado, uma degradação a
virar indisponibilidade), escala para `workflows/W11-incident-response.md`.

## Relacionados

- `core/lifecycle.md` (F9) · `workflows/W09-continuous-operation.md` · `workflows/W10-feature-evolution.md`
- `agents/12-reviewers/README.md` — os olhos pontuais de F7, a montante dos guardiões.
- `templates/technical/guardian-report.md.template` · `loops/README.md`
- `agents/README.md` — o índice global e os tipos de agente.
