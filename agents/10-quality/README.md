# 10 — Qualidade

A categoria que **prova que o produto funciona** — não por sensação, mas por evidência reproduzível.
Trabalha sobretudo em **F6 (construção)** e **F7 (qualidade & segurança)** do `core/lifecycle.md`,
e deixa atrás de si um ativo permanente: o **harness de regressão** que os guardiões (`agents/13-guardians/`)
correm para sempre em F9. O princípio que atravessa toda a categoria: **qualidade proporcional ao risco**
(`MANIFESTO.md` §9) — o esforço de teste concentra-se nas regras de negócio, autorização, dinheiro,
dados pessoais e fluxos irreversíveis, não distribuído em cobertura cega por getters e setters.

## Agentes da categoria

| Agente | Uma linha |
| --- | --- |
| `agents/10-quality/test-strategist.md` | Desenha a estratégia: o que se testa, a que nível, e o que se falseia (I/O externo). |
| `agents/10-quality/unit-test-engineer.md` | Testa regras de negócio e invariantes em isolamento, com fakes para tudo o que é I/O. |
| `agents/10-quality/integration-test-engineer.md` | Testa contra a BD real, contratos e transações — onde os fakes mentem. |
| `agents/10-quality/e2e-test-engineer.md` | Percorre perfis × páginas e os fluxos críticos ponta a ponta; fecha com smoke live real. |
| `agents/10-quality/performance-test-engineer.md` | Carga, stress e perfis de tráfego contra os limites conhecidos dos RNF. |
| `agents/10-quality/regression-test-engineer.md` | Mantém o harness que impede o regresso de bugs já corrigidos, atualizado a cada fluxo novo. |
| `agents/10-quality/coverage-auditor.md` | Audita a cobertura pelo risco (não pela percentagem) e nomeia os buracos de teste. |

## Ordem de trabalho recomendada

1. **Estratégia primeiro** (`estratega-de-testes`) — define a pirâmide e o mapa risco→nível **antes**
   de se escrever um teste. Sem isto, os engenheiros produzem cobertura desequilibrada.
2. **Unitários + integração em paralelo por fatia** (`engenheiro-de-testes-unitarios`,
   `engenheiro-de-testes-de-integracao`) — cada fatia vertical de F6 leva os seus, à medida que é construída.
3. **E2E dos fluxos críticos** (`engenheiro-de-testes-e2e`) — quando há caminho completo para exercitar.
4. **Performance** (`engenheiro-de-testes-de-performance`) — perto de F7/F8, contra os RNF quantificados.
5. **Regressão** (`engenheiro-de-testes-de-regressao`) — absorve continuamente cada teste dos passos
   anteriores no harness; é o legado que sobrevive à categoria.
6. **Auditoria de cobertura** (`auditor-de-cobertura`) — no portão de F7, verifica que o risco está coberto.

O Orquestrador (`core/orchestrator.md`) monta o grafo pelas secções **Inputs**/**Interações** das
fichas, não por esta ordem rígida. Unitários e integração de uma fatia correm com a construção dessa
fatia (`workflows/W06-build.md`); E2E, performance e auditoria concentram-se no portão de fase.

## Deveres comuns a todos os agentes da categoria

- **Testar a lógica de risco, não o trivial** (`knowledge/permanent-rules.md` §7). Um teste que
  passaria em qualquer produto genérico não vale o custo de o manter.
- **Fakes/mocks só para I/O externo**; a lógica de domínio testa-se a sério (`estratega-de-testes`).
- **O mock espelha o servidor real** — mesmas formas, mesmas regras de escrita; um mock que mente dá
  verde falso (`knowledge/proven-patterns.md` §7, `knowledge/ai-pitfalls.md` #2).
- **Prova-live real é gate insubstituível** — testes verdes provam que o código não parte, não que
  resolve o problema (`checklists/definition-of-done.md`; `knowledge/ai-pitfalls.md` #2).
- **Quem produz não valida** — a revisão da substância dos testes é de um agente independente,
  `agents/12-reviewers/test-reviewer.md` (`core/quality-gates.md`).

## Armadilha crítica desta categoria: suites pesadas em paralelo

Suites de teste com BD-em-memória, WASM ou muitos processos **rebentam a máquina de dev por OOM**
quando correm em paralelo — repetiu-se vezes suficientes no projeto-mãe para ser lei
(`knowledge/ai-pitfalls.md` #14). Regras que **todos** os agentes desta categoria cumprem:

- **Suites pesadas correm em série** (sem paralelismo de ficheiros), focadas por ficheiro, em foreground.
- **Um subagente nunca corre a suite completa em background.** O idioma "filtro do gestor de pacotes +
  padrão" muitas vezes **não filtra** (corre tudo) e mata o subagente silenciosamente. Usar o runner
  direto por ficheiro.
- **O agente controlador fecha os seus subagentes explicitamente** e valida o WIP verde comparando o
  estado do repositório com o relatório — nunca deixa um subagente pendurado num monitor.

## Como o Orquestrador a convoca

`workflows/W06-build.md` invoca unitários e integração por fatia; `workflows/W07-quality-and-security.md`
convoca E2E, performance e o `auditor-de-cobertura` para o portão de F7. O harness de regressão passa,
no fim, para a tutela do `agents/13-guardians/quality-guardian.md`, que o corre em cadência F9.
A categoria **produz** testes; **rever** a estratégia e a substância é de `agents/12-reviewers/test-reviewer.md`.

## Relacionados

- `agents/README.md` · `agents/_template/AGENT-TEMPLATE.md`
- `workflows/W06-build.md` · `workflows/W07-quality-and-security.md` · `core/quality-gates.md`
- `templates/technical/test-plan.md.template` · `checklists/definition-of-done.md`
- `agents/12-reviewers/test-reviewer.md` — os olhos independentes sobre o que esta categoria produz.
- `agents/13-guardians/quality-guardian.md` — quem herda o harness em produção.
