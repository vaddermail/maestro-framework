# W05 — Especificação (F5)

> **Fase:** F5 · **Portão de saída:** P5 (**desbloqueia código**) · **Agentes-núcleo:**
> `agents/01-requirements/business-rules-modeler.md`, `agents/06-data/data-modeler.md`,
> `agents/05-backend/api-designer.md` e `agents/09-security/threat-modeler.md`,
> coordenados pelo `core/orchestrator.md`.

## Objetivo

Produzir a **fonte de verdade funcional canónica, agnóstica de tecnologia**: as regras de negócio
consolidadas por módulo, os fluxos críticos como máquinas de estado, o modelo de dados lógico e o
contrato do backend (autorização, scoping, integridade, campos sensíveis). É o documento que
**sobrevive a reescritas do código** — quando o código e a spec divergirem, a spec ganha
(`core/artifact-protocol.md` §4). **Só depois de P5 se escreve código de produto** (F6).

## Pré-condições (portão de entrada)

- [ ] P2 fechado: requisitos, `RN-nnn`, RNF e critérios de aceitação `aprovado` (`product/01-requirements/`).
- [ ] P3 fechado: ADRs e stack `aprovado` (`product/02-architecture/`) — o contrato de backend
      assume o estilo e as fronteiras já decididos.
- [ ] P4 fechado: mapa de ecrãs e fluxos `aprovado` (`product/03-experience/`) — as máquinas de
      estado dos fluxos críticos refletem o que a UX desenhou.

Faltando qualquer um, **não se especifica**: a spec seria construída sobre âmbito, arquitetura ou UX
por fechar (`core/lifecycle.md` §2).

## Passos (agente → artefacto)

A especificação **consolida** o que F2–F4 produziram — não reinventa. Artefactos em
`product/04-specification/` (e o threat model em `product/05-security/`).

| # | Agente | Artefacto | Depende de |
| --- | --- | --- | --- |
| 1 | Orquestrador | `README.md` (índice dos módulos a especificar, derivado do MVP) | prioridades (F1), `RF` (F2) |
| 2 | `agents/01-requirements/business-rules-modeler.md` | `modules/<modulo>.md` (regras `RN-nnn` consolidadas, permissões, fluxos por módulo) | `RN-nnn` (F2), fluxos (F4) |
| 3 | `agents/01-requirements/business-rules-modeler.md` | `maquinas-de-estado.md` (estados, transições, efeitos, quem pode — `modules/state-machines.md`) | 2 |
| 4 | `agents/06-data/data-modeler.md` | `modelo-de-dados-logico.md` (entidades, relações **bidirecionais coerentes**, invariantes — agnóstico de BD) | 2 |
| 5 | `agents/05-backend/api-designer.md` | `contrato-backend.md` (authz/scoping/integridade/campos sensíveis **100% no servidor**) | 2, 4, ADRs (F3) |
| 6 | `agents/09-security/threat-modeler.md` | `product/05-security/threat-model.md` (STRIDE por funcionalidade crítica) | 2–5 |

**Templates:** `templates/specification/business-rules.md.template`,
`maquina-de-estados.md.template`, `modelo-de-dados-logico.md.template`,
`contrato-backend.md.template` (e `requisito-funcional.md.template` para o rasto `RF`→spec).

**Paralelismo (`core/orchestrator.md` §Paralelismo):** os módulos independentes (passo 2)
especificam-se em paralelo; máquinas de estado (3), modelo de dados (4) e contrato de backend (5)
partilham as regras do passo 2 e encadeiam-se por dependência. O `modelador-de-ameacas` (6) corre
sobre o conjunto já esboçado. O `agents/09-security/security-coordinator.md` tem assento
transversal — segurança não é uma fase, é uma dimensão (`core/lifecycle.md` §5).

> **Regra de ouro do contrato de backend (`modules/rbac-and-scoping.md`):** o cliente **declara**, o
> servidor **confirma**; fail-closed; fora-de-scope responde **404** (nunca 403 que confirme a
> existência). Campos sensíveis nunca saem do servidor a quem não os pode ver. Isto especifica-se
> aqui, não se "lembra" em F6.

> **Escala ao perfil:** num protótipo, os quatro documentos colapsam numa `product/04-specification/spec.md`
> de poucas páginas — mas as **máquinas de estado dos fluxos críticos e as invariantes de dados**
> escrevem-se sempre (são a origem histórica da maioria dos defeitos, `knowledge/origin-lessons.md`).

## Pontos de decisão

Lacunas sobem em **lotes** ao Orquestrador (`core/question-engine.md`). Lotes típicos de F5:

- **Estados e transições** — que transições são legais, que efeitos disparam, quem as pode fazer.
- **Invariantes de dados** — o que nunca pode ficar incoerente (relações bidirecionais, unicidade).
- **Autorização fina** — que perfil vê/faz o quê, e o que o scoping por unidade organizacional corta.
- **Campos sensíveis** — o que é confidencial e a quem se oculta.

**Aprovação humana obrigatória (P5):** a **especificação completa** é aprovada pelo utilizador — é o
contrato que desbloqueia a construção. Qualquer tratamento **novo de dados pessoais/sensíveis**
sinalizado em F2 confirma-se aqui no threat model.

## Loops que abre

- **`loops/L05-inconsistencies.md`** — enquanto houver divergência entre spec ↔ requisitos ↔ modelo
  de dados (ex.: uma regra sem entidade, um estado sem transição de saída), reconcilia-se com a fonte
  de verdade a montante. **Condição de saída:** zero inconsistências abertas.
- Uma lacuna que revele **requisito em falta** reabre F2 via `loops/L01-ambiguous-requirements.md` — a
  spec **não inventa** o requisito, devolve-o (`core/lifecycle.md` §2). **Salvaguarda**
  anti-loop de 3 iterações em ambos (`loops/README.md`).

## Portão de saída (P5)

`core/quality-gates.md` + `checklists/definition-of-done.md`:

- [ ] Especificação **revista em painel mínimo** — arquitetura + segurança + UX — e consolidada pelo
      `agents/12-reviewers/review-consolidator.md` num plano único sem contradições.
- [ ] **Máquinas de estado** dos fluxos críticos completas (estados, transições, efeitos, quem pode).
- [ ] **Modelo de dados lógico** com invariantes e relações bidirecionais coerentes.
- [ ] **Contrato de backend** define authz, scoping e ocultação de sensíveis **no servidor**.
- [ ] Cada `RF` do MVP tem spec rastreável; threat model cobre as funcionalidades críticas.
- [ ] Utilizador **aprovou** a especificação.

**Quem verifica:** o painel de revisores (substância) + consolidador (coerência) — nunca quem
escreveu. **Quem aprova:** o utilizador. **Com P5 fechado, desbloqueia-se o código:** arranca
`workflows/W06-build.md`.

## Recuperação de falhas e bloqueios

`core/orchestrator.md` §Recuperação. Revisões contraditórias (ex.: contrato de backend vs threat
model) → o consolidador não escolhe em silêncio: expõe o conflito e pede reanálise, ou sobe ao
utilizador se for decisão de produto. Requisito em falta descoberto ao especificar → devolve-se a F2,
regista-se em `STATE.md`; **não se avança para F6** com a spec incompleta. Utilizador indisponível
para aprovar → a spec fica `em-revisao`, a pendência em `STATE.md` → "Decisões pendentes"; **nenhuma
linha de código de produto** se escreve antes de P5.

## Perfis de esforço

| Perfil | Profundidade de F5 |
| --- | --- |
| **Protótipo** | Spec de poucas páginas revista pelo próprio Orquestrador + OK do utilizador; máquinas de estado só dos fluxos críticos. |
| **Produto interno** | Spec por módulo; painel mínimo (arquitetura + segurança + UX); modelo de dados e contrato completos. |
| **Produto comercial** | + threat model formal (STRIDE); revisão em painel alargado; contrato de backend detalhado por endpoint. |
| **Plataforma empresarial** | + modelo de dados com auditoria/retenção; contrato com ASVS-alvo; revisão global (`workflows/W12-global-review.md`) antes de P5. |

## Relacionados

- `core/artifact-protocol.md` — `product/04-specification/` é a fonte de verdade a jusante.
- `workflows/W02-requirements.md` · `workflows/W03-architecture.md` · `workflows/W04-experience.md` — as fases que esta consolida.
- `workflows/W06-build.md` — a fase que P5 desbloqueia.
- `modules/state-machines.md` · `modules/rbac-and-scoping.md` — os padrões que a spec aplica.
- `agents/12-reviewers/review-consolidator.md` — quem funde o painel de revisão de P5.
- `templates/specification/backend-contract.md.template` — o molde do contrato do servidor.
