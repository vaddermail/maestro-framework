# L04 — Code Smells

> Loop `L04` da framework Maestro — persiste enquanto existirem code smells acima do limiar
> acordado, melhorando a estrutura **sem mudar comportamento**. Segue a anatomia de `loops/README.md`.

Duplicação, complexidade e acoplamento não partem o sistema hoje — encarecem cada mudança amanhã.
Este loop existe para que a dívida de legibilidade se pague em fatias pequenas e verificáveis, nunca
num "grande refactor" que ninguém consegue rever nem reverter em bloco.

## Identificação

| Campo | Valor |
| --- | --- |
| **Quando corre** | F6 (por fatia, ao fechar); F9 (cadência do guardião) |
| **Agente que executa a ação** | `agents/13-guardians/quality-guardian.md` deteta e mede; o dono do código (`agents/04-frontend/` ou `agents/05-backend/`) aplica o refactor; um revisor (`agents/12-reviewers/`) confirma que o comportamento não mudou |
| **Modelo sugerido** | Económico para refactors mecânicos (extrair função, renomear); Padrão para reestruturações com risco de comportamento (`core/model-routing.md`) |

## Métrica de progresso

Número de violações acima do limiar definido para o perfil de esforço do projeto (duplicação %,
complexidade ciclomática, tamanho de função/módulo, acoplamento) — contagem total reportada pelo
guardião, comparável ciclo a ciclo.

Limiares por defeito (na calibração de F0 o utilizador aceita-os ou fixa outros — o valor acordado
regista-se no `CLAUDE.md` do projeto; `workflows/W00-project-kickoff.md` §Pontos de decisão):

| Perfil | Duplicação | Complexidade por função | Tamanho de função |
| --- | --- | --- | --- |
| Protótipo | — (loop desarmado) | — | — |
| Produto interno | ≤5% | ≤15 | ≤80 linhas |
| Produto comercial | ≤3% | ≤10 | ≤60 linhas |
| Plataforma empresarial | ≤2% | ≤10 | ≤50 linhas |

## Condição de entrada

`agents/13-guardians/quality-guardian.md` relata ≥1 smell acima do limiar acordado.

## Ação (o corpo da iteração)

1. Escolher o smell de maior **juro** (o que mais encarece mudanças futuras), não o maior em linhas.
2. Confirmar (ou escrever) o teste de comportamento que cobre a área — é a rede de segurança que prova
   que nada mudou; sem ela, não se refatora.
3. Refatorar sem alterar comportamento observável.
4. Correr a suite antes **e** depois: têm de ficar idênticas (mesmos testes verdes, mesmo resultado
   funcional) — qualquer diferença é regressão, não melhoria.

## Condição de saída (sucesso)

Contagem de smells ≤ limiar acordado, com os testes de comportamento verdes antes e depois,
confirmado por um revisor que não fez o refactor. **Nunca** se sobe o limiar para o smell "passar" —
isso é fraudar a métrica (`loops/README.md` §Princípios transversais).

## Salvaguarda anti-loop-infinito

- **Estagnação:** 3 iterações sem baixar a contagem de smells → parar.
- **Oscilação:** refatorar A introduz um smell equivalente em B (duplicação movida, não eliminada) →
  parar de imediato; sinal de que falta uma abstração partilhada, não mais refactor pontual.
- **Teto duro:** 5 iterações por área de código. Ultrapassado, sobe ao utilizador: pode ser sinal de um
  problema arquitetural que um refactor local não resolve (candidato a `loops/L08-technical-debt.md`
  em vez de correção imediata).

## Registo em STATE.md

```
L04 · code smells · métrica 23→14→14 · iter 3 (teto 5) · último progresso: iter 2 · estado: EM RISCO
```

## Exemplo (plataforma de dados — pipeline de ingestão)

O guardião reporta a mesma lógica de "normalizar nome de coluna" duplicada em quatro conectores de
fonte (CSV, API, BD externa, ficheiro Excel), cada cópia já ligeiramente diferente das outras —
duplicação acima do limiar e uma bifurcação silenciosa a começar. O engenheiro de dados escreve
primeiro um teste que fixa o comportamento atual de cada conector (mesmo com as pequenas diferenças),
extrai uma função `normalizarNomeColuna` partilhada e parametrizável, e migra os quatro conectores um
a um, correndo a suite entre cada migração. Resultado: quatro chamadas à mesma função, zero mudança de
comportamento, smell fechado. Sem os testes de fixação prévios, a extração teria uniformizado à força
as diferenças reais entre conectores — mudança de comportamento disfarçada de refactor.

## Relacionados

- `agents/13-guardians/quality-guardian.md` — deteta e mede os smells.
- `agents/13-guardians/README.md` — cadência e relatório comum do guardião.
- `checklists/definition-of-done.md` · `checklists/pre-merge.md` — onde este loop se verifica por fatia.
- `pipelines/ci-quality.md` — a medição automatizada que alimenta a métrica.
- `knowledge/proven-patterns.md` — os padrões-alvo de muitos destes refactors.
- `loops/L08-technical-debt.md` — para onde escala um smell que é sintoma estrutural.
