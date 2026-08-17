# L02 — Testes Falhados

> Loop `L02` da framework Maestro — persiste enquanto existirem testes a falhar, corrigindo
> sempre a **causa**, nunca o teste (salvo prova de que o teste está errado). Segue a anatomia de
> `loops/README.md`.

Um teste falhado é o detetor mais barato de defeito que a framework tem — e o mais fácil de fraudar
("comentar o teste", "subir o timeout", "apagar o assert incómodo"). Este loop existe para que a única
saída aceite seja o sistema a comportar-se corretamente, nunca o detetor calado.

## Identificação

| Campo | Valor |
| --- | --- |
| **Quando corre** | F6 (contínuo, por fatia); reaberto em F7 pelo harness de regressão e em F9 a cada mudança |
| **Agente que executa a ação** | O dono do código que falha — `agents/04-frontend/` ou `agents/05-backend/` conforme a camada — corrige a causa; coordenado por `agents/10-quality/test-strategist.md`. Só se decide "teste errado" com prova anexa (requisito/spec que o contradiz), nunca por conveniência |
| **Modelo sugerido** | Padrão para a correção; sobe a Topo se a causa raiz tocar RBAC, máquina de estado ou fluxo crítico com reversibilidade (`core/model-routing.md`) |

## Métrica de progresso

Número de testes em estado `a falhar` reportado pelo harness (unitários + integração + E2E +
regressão, somados), na última corrida completa.

## Condição de entrada

O harness de testes reporta ≥1 teste a falhar numa corrida (local, CI, ou regressão).

## Ação (o corpo da iteração)

1. Isolar o teste falhado e identificar a **causa raiz** — nunca parar na primeira hipótese;
   reproduzir antes de corrigir.
2. Decidir: bug no código (regra geral) ou teste provado errado (exceção — anexar a prova: qual
   requisito/spec/critério de aceitação o teste contradiz).
3. Aplicar a correção mínima e reversível na causa (nunca no sintoma nem no detetor —
   `loops/README.md` §Princípios transversais).
4. Correr a suite completa localmente, frontend e backend separados, **ambos** verdes antes de
   declarar a iteração feita.

## Condição de saída (sucesso)

Zero testes a falhar, confirmado por uma corrida independente do harness (CI ou outro agente/revisor —
nunca só a corrida local de quem corrigiu, que é auto-validação).

## Salvaguarda anti-loop-infinito

- **Estagnação:** 3 corridas consecutivas sem baixar a contagem de testes falhados → parar.
- **Oscilação:** o mesmo conjunto de testes falhados reaparece (fingerprint da lista de testes
  repete-se) — sinal de que a correção anterior não tocou a causa, ou introduziu uma regressão que
  desfaz o progresso; parar de imediato.
- **Teto duro:** 6 iterações por fatia/PR. Ultrapassado, sobe ao utilizador: pode ser sintoma de que a
  fatia é maior do que uma sessão resolve, de um problema arquitetural, ou de dois requisitos
  contraditórios materializados em dois testes que não podem ambos passar (nesse caso, o problema é
  de facto `loops/L01-ambiguous-requirements.md`, não deste loop).

## Registo em STATE.md

```
L02 · testes falhados · métrica 12→7→7 · iter 3 (teto 6) · último progresso: iter 2 · estado: EM RISCO
```

## Exemplo (e-commerce — carrinho e cupões)

A suite de integração falha em `carrinho.aplicar-cupao.test`: um cupão de 20% aplicado a um carrinho
com um item já em saldo deveria dar erro ("cupões não acumulam com saldo"), mas o teste regista que o
desconto foi aplicado na mesma. A hipótese inicial ("o teste está desatualizado") falha ao verificar:
**RN-014** confirma explicitamente que cupão e saldo não acumulam. A causa real é um `if` que só
verifica o primeiro item do carrinho, não todos. Corrige-se a função `calcularDesconto` para iterar
todos os itens; a suite volta a verde nas duas camadas (unitário do cálculo + integração do fluxo de
checkout). Sem esta disciplina, a "correção rápida" teria sido comentar o teste — escondendo um bug de
faturação real.

## Relacionados

- `agents/10-quality/README.md` — a categoria que fornece o harness e a estratégia.
- `agents/10-quality/test-strategist.md` — coordena a suite e a rede de segurança.
- `agents/10-quality/regression-test-engineer.md` — o harness que reabre este loop em F7/F9.
- `checklists/definition-of-done.md` · `checklists/pre-merge.md` — os portões que este loop tem de satisfazer.
- `core/quality-gates.md` — P6 não passa com testes vermelhos.
- `knowledge/ai-pitfalls.md` — §2, "funciona sem prova", a armadilha gémea deste loop.
