# W12 — Revisão Global (sob pedido)

> **Disparo:** o utilizador pede uma revisão multidisciplinar completa · **Coordena:** o Orquestrador
> monta o painel de `agents/12-reviewers/` · **Condição de fecho:** plano consolidado entregue e o
> utilizador decidiu o que se corrige já vs backlog.

## Objetivo

Dar ao utilizador uma **fotografia independente e multidisciplinar** do estado de um âmbito à sua
escolha — o produto todo, um módulo, uma release, um repositório herdado — e um **plano priorizado**
de correções para ele decidir. Ao contrário de todas as fases, W12 **não é um portão** e **não
bloqueia** nada por si: é diagnóstico a pedido. Quem decide o que fazer com os achados é o utilizador.

### W12 vs W07 — a diferença que importa

| | `workflows/W07-quality-and-security.md` | `workflows/W12-global-review.md` (este) |
| --- | --- | --- |
| **Natureza** | Portão **obrigatório** de pré-lançamento (P7) | Revisão **convocável** a qualquer momento |
| **Quando** | Sempre, antes de F8 | Sob pedido do utilizador |
| **Âmbito** | O MVP / a release a lançar | Qualquer âmbito que o utilizador defina |
| **Efeito de um bloqueador** | Impede o lançamento | Vira item priorizado; o utilizador decide |

W07 **usa** este workflow como mecânica de painel; W12 pode correr sem que haja lançamento nenhum
(ex.: revisão trimestral de um SaaS, due diligence antes de uma aquisição, auditoria de um módulo
legado antes de lhe mexer).

## Gatilho e pré-condições

- [ ] Pedido explícito do utilizador com um **âmbito definido**. Se vier vago ("revê o projeto"), o
      Orquestrador delimita-o em lote (`core/question-engine.md`): que módulos, que profundidade,
      com ou sem auditoria adversarial.
- [ ] Os artefactos do âmbito existem e estão acessíveis (código, specs de `product/04-specification/`,
      ADRs de `product/02-architecture/`). Um revisor sem artefacto **declara-o** em "fora de âmbito",
      não inventa (`agents/12-reviewers/README.md` §formato).

## Passos (agente → artefacto)

Os relatórios de todos os revisores vivem em `product/99-records/reviews/RG-nnn/`; o plano
consolidado em `product/99-records/reviews/RG-nnn/plano-consolidado.md`.

| # | Passo | Agente | Artefacto | Depende de |
| --- | --- | --- | --- | --- |
| 1 | **Delimitar o âmbito** | Orquestrador + utilizador | `RG-nnn/ambito.md`: o que se revê, profundidade, se inclui auditoria adversarial | pedido |
| 2 | **Lançar o painel completo, em paralelo e às cegas** | os 9 revisores de `agents/12-reviewers/` (arquitetura, frontend, backend, ux, devops, performance, segurança, documentação, testes) | um relatório por revisor (`templates/technical/review-report.md.template`) | 1 |
| 3 | **Auditoria adversarial** (se pedida no passo 1) | `playbooks/adversarial-audit.md` | relatório adversarial anexo | 1 |
| 4 | **Consolidar** | `agents/12-reviewers/review-consolidator.md` | `plano-consolidado.md`: achados fundidos, sem duplicados nem contradições, ordenados por risco real | 2, 3 |
| 5 | **Apresentar e decidir** | Orquestrador → utilizador | decisão registada em `STATE.md`: **corrige-já** vs **backlog** por item | 4 |

**Painel = independência + cegueira** (`agents/12-reviewers/README.md`): cada revisor recebe os
mesmos artefactos e o mesmo âmbito mas **não lê os relatórios dos outros** enquanto trabalha — a
convergência de dois pareceres separados é sinal forte; a contaminação destrói esse sinal. Uma
dimensão por revisor; o consolidador é o **único** que lê tudo, e só no passo 4. O Orquestrador
roteia o modelo de cada revisor por tarefa (`core/model-routing.md`), não o de topo em toda
a fila.

## Pontos de decisão (aprovação humana)

- **Passo 1 — o âmbito e a profundidade** são do utilizador (define o custo da revisão).
- **Passo 5 — o núcleo de W12:** para **cada** achado, o utilizador decide **corrigir já** ou **mandar
  para o backlog**. O agente não decide isso sozinho — a priorização técnica (`consolidador`) informa;
  a decisão de negócio é do dono (`core/orchestrator.md` §Aprovação humana). Achados que envolvam
  dados pessoais, dinheiro ou fluxos irreversíveis recebem recomendação explícita de "corrigir já"
  (`MANIFESTO.md` §9), mas a palavra final é do utilizador.

## Loops que abre

Os achados que o utilizador manda **corrigir já** alimentam os loops normais, por dimensão:

- `loops/L02-failing-tests.md` (achados de testes), `loops/L03-security-issues.md`
  (segurança, por severidade), `loops/L04-code-smells.md` (qualidade), `loops/L05-inconsistencies.md`
  (docs↔código↔dados).
- O que vai para **backlog** entra em `loops/L08-technical-debt.md` — rastreável, com dono e prazo,
  nunca esquecido num relatório que ninguém reabre.

## Condição de fecho (não é um portão)

W12 **termina** — não "aprova" — quando:

- [ ] Todos os revisores do âmbito entregaram relatório no molde comum (ou declararam explicitamente o
      que não puderam rever e porquê — honestidade absoluta, `knowledge/permanent-rules.md` §2).
- [ ] O `consolidador-de-revisoes` produziu **um** plano priorizado, sem duplicados nem contradições.
- [ ] O utilizador triou cada item (corrige-já / backlog) e a decisão ficou em `STATE.md`.

Se W12 foi convocado **como parte de um lançamento** (a partir de W07), então sim, o seu resultado
alimenta o portão P7 — mas essa vinculação é de W07, não deste workflow.

## Recuperação de falhas

| Situação | Resposta |
| --- | --- |
| Dois revisores contradizem-se | O `consolidador` não escolhe em silêncio: expõe a contradição no plano e sobe-a ao utilizador ou pede reanálise com o conflito explícito (`core/orchestrator.md` §Recuperação). |
| Um revisor não tem o artefacto de que precisa | Declara-o em "fora de âmbito"; o Orquestrador agenda o artefacto em falta ou nota a lacuna no plano. Não se inventa um veredicto sobre o que não se viu. |
| Achados demais para triar de uma vez | O consolidador agrupa por severidade e por módulo; o utilizador tria por lotes (bloqueadores primeiro). |
| Âmbito revelou-se maior do que o pedido | Renegociar o âmbito com o utilizador (passo 1) antes de gastar o painel todo — a profundidade é uma decisão de custo dele. |

## Perfis de esforço

| Perfil | Como muda |
| --- | --- |
| **Protótipo** | Painel mínimo (arquitetura + segurança + o revisor da dimensão em causa); sem auditoria adversarial. |
| **Produto interno** | Painel completo nos módulos de risco; adversarial opcional. |
| **Produto comercial / Plataforma** | Painel completo + `playbooks/adversarial-audit.md` de série; W12 como **revisão periódica** agendada, não só a pedido pontual. |

## Relacionados

- `agents/12-reviewers/README.md` — o painel, a regra da cegueira, o formato do relatório.
- `agents/12-reviewers/review-consolidator.md` — quem funde os relatórios num plano único.
- `workflows/W07-quality-and-security.md` — o portão obrigatório que usa esta mecânica.
- `playbooks/adversarial-audit.md` — o escrutínio máximo, opcional aqui.
- `templates/technical/review-report.md.template` — o molde comum dos revisores.
- `loops/L08-technical-debt.md` — para onde vai o que fica em backlog.
