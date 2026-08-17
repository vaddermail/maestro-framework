# Definição de Pronto

O que fecha cada fase do ciclo de vida (`core/lifecycle.md`, F1–F9) e o que fecha qualquer
alteração de código dentro de F6. É a base factual do portão de cada fase
(`core/quality-gates.md`) — a checklist não decide sozinha a passagem, mas sem ela o portão
não tem evidência para decidir. **Transversal a todos os fechos de fase:** a linha da fase no
dossier de génese (`product/99-records/genesis.md` — `templates/project/GENESIS.md.template`) faz
parte do portão; e `bash Maestro/_meta/verify-project.sh` verde confirma que o processo está a
ser seguido, não só declarado.

## F1 — Descoberta

- [ ] Dossier de descoberta completo em `product/00-discovery/`: stakeholders, personas, casos de
      utilização, objetivos, KPIs, riscos, roadmap e MVP escritos.
- [ ] MVP delimitado e aprovado explicitamente pelo utilizador (registo em `STATE.md`).
- [ ] Cada risco tem dono nomeado e mitigação descrita.
- [ ] Zero lacunas críticas por fechar — perguntas da fase respondidas ou registadas como pendentes.

## F2 — Requisitos

- [ ] Zero ambiguidades **críticas** abertas no `loops/L01-ambiguous-requirements.md`; não-críticas
      registadas com risco aceite pelo utilizador (o critério que L01 operacionaliza).
- [ ] Requisitos não-funcionais quantificados com números concretos (ex.: "P95 < 300ms", não "rápido").
- [ ] Regras de negócio numeradas e aprovadas pelo utilizador.
- [ ] Todo o requisito funcional tem critério de aceitação verificável associado.

## F3 — Arquitetura

- [ ] Cada ADR escrito com alternativas comparadas e plano de reversão explícito
      (`templates/project/ADR-DECISION.md.template`).
- [ ] Stack fixada em versões estáveis (LTS/GA); nenhuma alpha/beta/RC sem justificação registada
      (`knowledge/permanent-rules.md` §6).
- [ ] Utilizador validou custos e trade-offs em linguagem simples, com o registo da decisão em
      `STATE.md`.

## F4 — Experiência

- [ ] Wireframes dos fluxos críticos validados pelo utilizador.
- [ ] Tokens do design system definidos (cor, tipografia, espaçamento) — nenhum valor hardcoded.
- [ ] Nível WCAG alvo confirmado e plano de acessibilidade escrito
      (`agents/03-experience/accessibility-specialist.md`).
- [ ] Orçamentos de performance por tipo de rota definidos
      (`agents/03-experience/web-performance-specialist.md`). *(dispensável em: protótipo)*

## F5 — Especificação

- [ ] Especificação revista pelo painel mínimo (arquitetura + segurança + UX) e aprovada pelo
      utilizador (`agents/12-reviewers/review-consolidator.md`). *(em protótipo, a revisão
      pelo Orquestrador + OK do utilizador substitui o painel — `core/quality-gates.md`)*
- [ ] Máquinas de estado de todos os fluxos críticos escritas (`modules/state-machines.md`).
- [ ] Modelo de dados lógico completo, com invariantes explícitos.
- [ ] Contrato do backend escrito: autorização, scoping, integridade transacional, campos sensíveis.

## F6 — Esqueleto (fatia 0), uma vez antes das fatias de funcionalidade

O que muitos portões pressupõem mas que só se descobre em falta tarde — um lado sem *runner* de
testes, um guardrail que nunca foi ligado — tem de existir **antes** da primeira fatia de
funcionalidade. É critério de **entrada**, não só de saída: uma regra que só se verifica no fim de
F7 já foi contornada durante toda a construção.

- [ ] Cada superfície testável (frontend, backend, …) tem um *runner* de testes **configurado e a
      correr em CI** — typecheck e build a passar **não** contam como testado (`checklists/pre-merge.md`).
- [ ] Os guardrails que o produto vai exigir estão ligados no CI desde já (lint, análise estática,
      fronteiras de arquitetura, varrimento de segredos), mesmo que ainda apanhem pouco — ligam-se
      cedo, não na véspera do go-live.
- [ ] O pipeline corre em todas as superfícies, separadas, e está verde antes de a primeira fatia
      começar.

## F6 — Construção (por fatia)

- [ ] Secção "Por alteração de código" (abaixo) cumprida.
- [ ] `checklists/pre-merge.md` cumprida.
- [ ] A fatia respeita a especificação — ou a especificação foi atualizada primeiro, às claras.
- [ ] Progresso da fatia registado em `STATE.md`; o não-óbvio que é da **framework** (não do
      produto) registado no momento em `FRAMEWORK-IMPROVEMENTS.md`
      (`templates/project/FRAMEWORK-IMPROVEMENTS.md.template`).

## P6b — Fecho de F6 (aceitação do MVP)

- [ ] Todos os RF do MVP com código e teste rastreável; harness de regressão verde no ambiente-alvo
      (`workflows/W06-build.md` §O portão por fatia (P6) e o da fase (P6b)).
- [ ] Dívida técnica não resolvida **registada** (`loops/L08-technical-debt.md`), não escondida.
- [ ] `FRAMEWORK-IMPROVEMENTS.md` consolidado e reporte enviado à framework-mãe
      (`playbooks/report-framework-improvements.md`) — em construções longas, as lições sobem no
      aceite do MVP, não meses depois.
- [ ] Aceitação do MVP pelo utilizador registada em `STATE.md`.

## F7 — Qualidade & Segurança

- [ ] Zero achados críticos ou altos por resolver.
- [ ] `checklists/pre-production-security.md` completa.
- [ ] Auditoria adversarial corrida quando o perfil de esforço o exige
      (`playbooks/adversarial-audit.md`).
- [ ] Risco residual assinado explicitamente pelo utilizador.
- [ ] `FRAMEWORK-IMPROVEMENTS.md` consolidado e reporte enviado à framework-mãe
      (`playbooks/report-framework-improvements.md`).

## F8 — Lançamento

- [ ] `checklists/go-live.md` completa.
- [ ] Aprovação humana explícita para produção registada em `STATE.md` — nunca delegável a agentes.
- [ ] Lições do go-live (as que só produção expõe) registadas e reporte enviado
      (`playbooks/report-framework-improvements.md`).

## F9 — Operação contínua

- [ ] Cadências dos guardiões cumpridas na periodicidade definida (`agents/13-guardians/README.md`).
- [ ] Nenhum loop com pendência crítica aberta além do teto definido (`loops/README.md`).
- [ ] Post-mortems de incidentes fechados têm ações verificadas, não só planeadas
      (`checklists/post-incident.md`).
- [ ] Reporte de melhorias enviado na cadência do perfil
      (`playbooks/report-framework-improvements.md`).

## Por alteração de código

Aplica-se a qualquer fatia, PR ou hotfix, do primeiro commit de F6 em diante:

- [ ] Sintaxe válida e build/compilação sem erros.
- [ ] Sem erros de consola/log ao exercitar os ecrãs ou endpoints afetados, nos perfis/papéis
      afetados.
- [ ] Integridade de relações e invariantes de negócio mantida (regras de `product/04-specification/`).
- [ ] Scoping e autorização preservados nas listas/endpoints tocados.
- [ ] `STATE.md` atualizado; `CHANGELOG.md` também se for marco.

## Relacionados

- `core/lifecycle.md` — as fases que esta checklist fecha.
- `core/quality-gates.md` — como o resultado decide a passagem.
- `checklists/pre-merge.md` — o portão seguinte de cada fatia.
- `checklists/README.md` — como se usa e quem executa.
- `core/project-memory.md` — onde se regista o resultado.
- `knowledge/permanent-rules.md` — os princípios que os itens operacionalizam.
