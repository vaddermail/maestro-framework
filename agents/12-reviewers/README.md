# 12 — Revisores

Os **olhos independentes** do produto. Esta categoria não constrói nada: examina o que outros
construíram, cada revisor por **uma dimensão**, e devolve um **relatório de achados verificáveis**. A
fase dominante é **F7** (`workflows/W07-quality-and-security.md`), o portão de pré-lançamento; os
mesmos revisores são reconvocados a cada marco e na revisão global sob pedido
(`workflows/W12-global-review.md`). O princípio que os justifica é uma armadilha de IA concreta:
**quem produz nunca valida o próprio trabalho** (`knowledge/ai-pitfalls.md` §20) e **uma só
perspetiva não chega** (§21).

## O que é um painel de revisão

Um painel são **várias revisões independentes, às cegas, da mesma coisa**. Independentes: cada
revisor recebe os mesmos artefactos e o mesmo âmbito, mas **não lê os relatórios dos outros** enquanto
trabalha — a convergência de dois pareceres separados é sinal forte; a contaminação por um parecer
alheio destrói esse sinal. Uma dimensão por revisor evita o "revisor omnisciente" que passa por tudo
com pouca profundidade em cada coisa (`MANIFESTO.md` §1). O `agents/12-reviewers/review-consolidator.md`
funde os relatórios **depois**, num plano único priorizado, sem duplicados nem contradições — é o
único agente da categoria que lê todos os relatórios.

## Agentes da categoria

| Agente | Uma linha |
| --- | --- |
| `agents/12-reviewers/architecture-reviewer.md` | Adesão à arquitetura decidida (ADRs) e integridade das fronteiras entre módulos. |
| `agents/12-reviewers/frontend-reviewer.md` | Código/UX do cliente: SSOT de conteúdos, tokens, estados de ecrã, tratamento de erros. |
| `agents/12-reviewers/backend-reviewer.md` | Servidor: autorização vs scoping, transações, invariantes, adesão ao contrato de API. |
| `agents/12-reviewers/ux-reviewer.md` | Fluxos reais percorridos de ponta a ponta contra personas e casos de utilização. |
| `agents/12-reviewers/devops-reviewer.md` | Pipelines, deploy/rollback, segredos fora do Git, flags de risco. |
| `agents/12-reviewers/performance-reviewer.md` | Orçamentos de performance, queries, caching. |
| `agents/12-reviewers/security-reviewer.md` | Threat model, OWASP, least privilege. |
| `agents/12-reviewers/documentation-reviewer.md` | Sincronia docs↔código e completude da ajuda. |
| `agents/12-reviewers/test-reviewer.md` | Substância dos testes, não só a existência. |
| `agents/12-reviewers/review-consolidator.md` | Funde os relatórios num plano único priorizado, sem duplicados nem contradições. |

## Formato do relatório (comum a todos)

Todos os revisores escrevem no **mesmo molde** — `templates/technical/review-report.md.template` —
para o consolidador os poder fundir sem tradução. O relatório tem:

1. **Cabeçalho** — revisor (dimensão), âmbito revisto (que fatia/commits/artefactos), data, modelo e
   esforço usados (`core/model-routing.md`). Rastreabilidade do que foi olhado.
2. **Veredicto global** — `passa` · `passa-com-ressalvas` · `bloqueia`. Um único bloqueador basta para
   bloquear; o veredicto liga ao portão de F7 (`core/quality-gates.md`).
3. **Achados, ordenados por severidade** — cada um com: `id`, severidade (**bloqueador · maior ·
   menor · nit**), localização (`ficheiro:linha` ou artefacto), o defeito em uma frase, o **cenário de
   falha concreto** (inputs/estado → resultado errado — nunca "parece frágil"), a recomendação e a
   **confiança** (`confirmado` se reproduzido, `plausível` se por inspeção).
4. **O que foi verificado e passou** — para dar confiança, não só o negativo; e para o consolidador
   saber o que já está coberto.
5. **Fora de âmbito / não verificável** — honestidade absoluta (`knowledge/permanent-rules.md`
   §2): o que este revisor não olhou e porquê (falta de artefacto, dimensão de outro revisor).

Regra transversal: um achado **confirmado** vale mais do que dez suspeitas; ordenar por risco real,
não por número de achados. Achados de correção, autorização, dinheiro, dados pessoais e fluxos
irreversíveis recebem o máximo escrutínio (`MANIFESTO.md` §9).

## Como o Orquestrador monta o painel

O `workflows/W07-quality-and-security.md` (F7) lança os revisores **em paralelo** sobre a mesma
fatia/release, cada um com o seu âmbito e os artefactos de que precisa (o Orquestrador —
`core/orchestrator.md` — resolve os inputs a partir das secções **Inputs** de cada ficha). Nenhum
revisor é o autor do que revê. Terminadas as revisões, o `consolidador-de-revisoes` produz o plano
único; os achados bloqueadores voltam à equipa de construção e, se forem transversais, alimentam os
loops (`loops/L02-failing-tests.md`, `loops/L03-security-issues.md`,
`loops/L04-code-smells.md`, `loops/L05-inconsistencies.md`). A revisão fecha quando o portão de F7
passa; para revisões extensas e adversariais, o painel escala para
`playbooks/adversarial-audit.md`.

## Relacionados

- `agents/README.md` · `agents/_template/AGENT-TEMPLATE.md`
- `templates/technical/review-report.md.template` · `checklists/pr-review.md` · `checklists/pre-merge.md`
- `workflows/W07-quality-and-security.md` · `workflows/W12-global-review.md` · `core/quality-gates.md`
- `playbooks/adversarial-audit.md` · `knowledge/ai-pitfalls.md`
