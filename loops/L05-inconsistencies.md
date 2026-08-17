# L05 — Inconsistências (docs ↔ código ↔ dados)

> Loop `L05` da framework Maestro — persiste enquanto existirem inconsistências entre
> documentação, código e dados, reconciliando sempre com a fonte de verdade declarada. Segue a
> anatomia de `loops/README.md`.

Duas versões do mesmo facto que divergem são a classe de bug mais teimosa que existe
(`knowledge/proven-patterns.md` §4) — porque nenhuma delas "falha" sozinha, só produzem
decisões erradas em silêncio. Este loop existe para que a divergência nunca se resolva "escolhendo a
que parece mais provável", mas sempre pela fonte de verdade declarada.

## Identificação

| Campo | Valor |
| --- | --- |
| **Quando corre** | Contínuo, em qualquer fase — disparado por qualquer agente/guardião/revisor que note a divergência |
| **Agente que executa a ação** | O agente dono da fonte de verdade do facto em causa (`core/artifact-protocol.md` — a spec, o ADR, ou o modelo de dados, conforme o tipo de facto); o Orquestrador coordena quando a própria fonte de verdade está em dúvida |
| **Modelo sugerido** | Padrão para reconciliar contra uma fonte já clara; Topo quando a própria fonte de verdade pode estar errada e a decisão tem peso de regra de negócio (`core/model-routing.md`) |

## Métrica de progresso

Número de inconsistências detetadas entre pares de artefactos (docs↔código, spec↔dados,
código↔dados) em estado `aberto`.

## Condição de entrada

Existe ≥1 par de factos que se contradizem entre dois artefactos (ou entre um artefacto e o
comportamento real observado do sistema).

## Ação (o corpo da iteração)

1. Identificar a **fonte de verdade declarada** para aquele facto (regra geral:
   `product/04-specification/` ganha sobre o código; código+testes ganham sobre um documento
   secundário desatualizado — `core/project-memory.md` §Memory layers).
2. Se a fonte de verdade estiver certa, corrigir o lado divergente para a igualar.
3. Se a fonte de verdade estiver **errada**, corrigir a fonte primeiro, com aprovação do utilizador
   (`MANIFESTO.md` §8), e só depois propagar aos artefactos que dependiam dela.
4. Registar a reconciliação: o que divergia, qual venceu, e porquê — para não se repetir a mesma
   pergunta na próxima sessão.

## Condição de saída (sucesso)

Zero inconsistências em estado `aberto`; cada uma fechada com o lado corrigido identificado e a fonte
de verdade final registada. Verificado por quem não fez a correção (revisor da área ou o
Orquestrador).

## Salvaguarda anti-loop-infinito

- **Estagnação:** 3 iterações sem reduzir a contagem de inconsistências abertas → parar.
- **Oscilação:** a mesma inconsistência reaparece depois de "corrigida" → sinal de que a causa raiz
  continua a gerar o drift (ex.: um processo manual que devia ser derivado automaticamente,
  `knowledge/proven-patterns.md` §7) — parar de imediato, não voltar a corrigir o sintoma.
- **Teto duro:** 4 iterações por inconsistência. Ultrapassado, sobe ao utilizador: normalmente sinal de
  que falta um guardrail automático (um teste que varre e falha), não de que a próxima correção manual
  vai pegar.

## Registo em STATE.md

```
L05 · inconsistências · métrica 6→3→1 · iter 3 (teto 4) · último progresso: iter 3 · estado: em curso
```

## Exemplo (SaaS B2B — plano de subscrição)

O `revisor-de-documentacao` nota que a página de ajuda diz "o plano Starter permite até 5 utilizadores
por conta", mas o código de validação (`limiteUtilizadores.ts`) usa a constante `10`. A especificação
(`product/04-specification/modules/subscricoes.md`) diz `5` — é a fonte de verdade. Investiga-se a
origem do `10`: foi um ajuste manual feito num incidente há três meses para desbloquear um cliente,
nunca revertido nem documentado. Corrige-se o código para `5` (a fonte de verdade está certa),
regista-se a reconciliação e escreve-se uma lição em `STATE.md`: "ajustes manuais em produção
precisam de ticket de reversão — este ficou três meses divergente sem ninguém notar."

## Relacionados

- `core/artifact-protocol.md` — §Handling rules, a regra de precedência da spec.
- `core/project-memory.md` — a estratificação de fontes de verdade.
- `knowledge/proven-patterns.md` — §4, §7, SSOT e guardrails automáticos.
- `agents/13-guardians/documentation-guardian.md` — deteta divergências docs↔código na sua cadência.
- `agents/12-reviewers/documentation-reviewer.md` — o principal detetor manual.
- `core/decision-engine.md` — quando a própria fonte de verdade precisa de ser corrigida.
