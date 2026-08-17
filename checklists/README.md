# Checklists — Verificação Objetiva

Uma checklist é o critério concreto de um portão (`core/quality-gates.md`) ou de um loop
(`loops/README.md`): transforma "parece pronto" em itens que se confirmam um a um. Usa-se sempre no
fim de uma fase, de uma fatia de código ou de um evento (incidente, lançamento) — nunca a meio, como
substituto do trabalho em si. A exceção deliberada é o bloco **"F6 — Esqueleto (fatia 0)"** da
`checklists/definition-of-done.md`, que corre **à entrada** da construção: guardas e runners
ligam-se antes da primeira fatia, não na véspera do go-live (promoção da 1.3.0, 2 confirmações).

## Como se usa uma checklist

- Cada portão do ciclo de vida (`core/lifecycle.md`) referencia uma ou mais checklists nos seus
  critérios (`core/quality-gates.md`).
- Confirma-se **item a item**, marcando `- [ ]` → `- [x]` só com evidência real. Um item sem evidência
  fica por marcar — não se marca "por confiança" (`knowledge/permanent-rules.md` §2).
- **Quem verifica nunca é quem produziu** o trabalho: revisor independente, harness de testes, ou o
  Orquestrador para critérios formais. É a mesma regra da anti-auto-validação em
  `core/quality-gates.md`.
- **Uma checklist chumbada bloqueia o portão.** Não há passagem parcial: ou todos os itens passam, ou
  o portão fica. A única saída é a **derrogação explícita do utilizador**, registada com o porquê e o
  risco assumido — nunca um atalho silencioso do agente.
- O resultado (passou / chumbou + itens falhados) regista-se em `STATE.md` e, quando produz relatório
  formal, em `product/99-records/`.

## Quem executa cada checklist

| Checklist | Quando corre | Quem executa |
| --- | --- | --- |
| `checklists/definition-of-done.md` | entrada de F6 (fatia 0), fim de cada fase e a cada alteração de código | Orquestrador confirma; o agente dono da fase reúne a evidência — nunca marca os próprios itens (`core/quality-gates.md`) |
| `checklists/pre-merge.md` | antes de qualquer merge para o ramo de integração | revisor independente (`agents/12-reviewers/`) |
| `checklists/pre-production-security.md` | portão P7 (F7→F8) e a cada release relevante | `agents/09-security/security-coordinator.md` |
| `checklists/accessibility.md` | por ecrã, em F4 (definição) e F7 (verificação) | `agents/03-experience/accessibility-specialist.md` |
| `checklists/web-performance.md` | por rota, em F4 (orçamento) e F7 (medição) | `agents/03-experience/web-performance-specialist.md` |
| `checklists/go-live.md` | portão P8 (F8 → produção) | `agents/07-devops/deployment-strategist.md` + aprovação do utilizador |
| `checklists/post-incident.md` | após a mitigação de qualquer incidente, antes de o fechar | dono do post-mortem (`workflows/W11-incident-response.md`) |
| `checklists/pr-review.md` | cada PR, antes de `checklists/pre-merge.md` | revisor independente do autor |

## Relacionados

- `core/quality-gates.md` — os portões que estas checklists servem.
- `core/lifecycle.md` — as fases onde cada portão se encaixa.
- `loops/README.md` — o outro consumidor de checklists (condição de saída de um loop).
- `core/project-memory.md` — onde se regista o resultado de cada verificação.
- `agents/12-reviewers/README.md` — quem tipicamente executa as checklists de revisão.
- `_meta/STYLE-GUIDE.md` — convenção `- [ ]` e formato de todos os documentos.
