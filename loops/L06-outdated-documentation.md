# L06 — Documentação Desatualizada

> Loop `L06` da framework Maestro — persiste enquanto existir documentação fora de sincronia com
> o estado real do produto, atualizando sempre a partir da fonte. Segue a anatomia de
> `loops/README.md`.

Documentação errada é pior do que nenhuma — engana com confiança. Este loop existe para que a
documentação nunca fique "asneira conhecida e tolerada": ou está sincronizada, ou está marcada e em
correção.

## Identificação

| Campo | Valor |
| --- | --- |
| **Quando corre** | F9 (cadência do guardião); disparado também logo após qualquer mudança relevante ao código/produto |
| **Agente que executa a ação** | `agents/13-guardians/documentation-guardian.md` deteta e atualiza; `agents/11-documentation/technical-writer.md` escreve quando a mudança é substancial; `agents/12-reviewers/documentation-reviewer.md` confirma sincronia |
| **Modelo sugerido** | Económico quando a atualização é mecânica (espelhar uma mudança já clara no código/spec); Padrão quando exige reconciliar com uma decisão de negócio (`core/model-routing.md`) |

## Métrica de progresso

Número de documentos/secções detetados como desatualizados (referência a algo que já mudou, exemplo
que já não corresponde ao comportamento real, link para artefacto obsoleto).

## Condição de entrada

`agents/13-guardians/documentation-guardian.md` (ou qualquer agente/revisor) deteta ≥1 documento
que diverge do estado real do código/produto.

## Ação (o corpo da iteração)

1. Confirmar a **fonte de verdade atual** do facto documentado (código, spec aprovada, ADR) — nunca
   inventar o que mudou; se a fonte não for clara, o loop não avança sozinho, pergunta-se
   (`core/question-engine.md`).
2. Atualizar a documentação a partir dessa fonte, com exemplos reais e correntes.
3. Se o facto vive também em labels/ajuda de UI, atualizar a **fonte única**
   (`modules/single-source-of-content.md`) em vez de duplicar a correção em dois sítios.
4. Marcar o artefacto como `aprovado` de novo (`core/artifact-protocol.md`).

## Condição de saída (sucesso)

Zero documentos detetados como desatualizados; `agents/12-reviewers/documentation-reviewer.md`
confirma a sincronia numa passagem independente.

## Salvaguarda anti-loop-infinito

- **Estagnação:** 3 ciclos de atualização sem reduzir a contagem de documentos desatualizados → parar.
- **Oscilação:** o mesmo documento volta a divergir logo no ciclo seguinte → sinal de que está a ser
  mantido manualmente onde devia ser derivado (ex.: referência de API que devia gerar-se do schema,
  `agents/11-documentation/api-documenter.md`) — parar e propor a automação em vez de repetir a
  correção manual.
- **Teto duro:** 4 iterações por documento. Ultrapassado, sobe ao utilizador com a proposta de mudar a
  forma como aquele documento se mantém (gerado vs. escrito à mão).

## Registo em STATE.md

```
L06 · documentação · métrica 8→4→4 · iter 3 (teto 4) · último progresso: iter 2 · estado: EM RISCO
```

## Exemplo (app interna — ferramenta de aprovação de despesas)

O runbook de operação (`product/07-operations/runbooks/reprocessar-despesa-falhada.md`) descreve um
comando `npm run reprocess -- --id=X`, mas a fatia de F6 mais recente substituiu o script CLI por um
botão no backoffice ("Reprocessar"), sem atualizar o runbook. O guardião de documentação deteta a
divergência na sua cadência semanal ao cruzar o runbook com o `CHANGELOG.md`. Confirma a fonte (o
código do backoffice, já em produção), reescreve o runbook com o novo procedimento e uma nota de
migração ("antes: CLI; agora: botão X no ecrã Y, mesma permissão"), e pede ao
`revisor-de-documentacao` para confirmar contra o comportamento real. Sem este loop, o próximo
incidente às 3h da manhã seguiria um runbook que já não existe.

## Relacionados

- `agents/13-guardians/documentation-guardian.md` — dono da cadência de deteção e correção.
- `agents/13-guardians/README.md` — cadências e relatório comum aos guardiões.
- `agents/12-reviewers/documentation-reviewer.md` — verificação independente.
- `agents/11-documentation/technical-writer.md` — quem escreve quando a mudança é substancial.
- `modules/single-source-of-content.md` — evita duplicar a correção em ecrã e documento.
- `workflows/W09-continuous-operation.md` — a cadência de F9 onde este loop corre por defeito.
