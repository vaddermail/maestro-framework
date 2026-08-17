# L08 — Dívida Técnica

> Loop `L08` da framework Maestro — persiste enquanto existir dívida técnica registada,
> reduzindo-a de forma planeada e reversível, priorizada pelo juro que cobra, nunca pelo tamanho do
> item. Segue a anatomia de `loops/README.md`.

Dívida técnica não registada não é "zero dívida" — é dívida invisível, a mais cara de todas, porque
ninguém a prioriza. Este loop existe para que a dívida seja uma lista viva, com juro estimado, que se
paga deliberadamente — nunca num "big-bang" de fim de trimestre.

## Identificação

| Campo | Valor |
| --- | --- |
| **Quando corre** | F9 — planeado, por ciclo (não por evento) |
| **Agente que executa a ação** | O Orquestrador prioriza e planeia o ciclo; o agente dono da área do item (`agents/05-backend/`, `agents/04-frontend/`, `agents/06-data/`, `agents/07-devops/`, conforme o item) executa |
| **Modelo sugerido** | Padrão para planear e executar; Topo quando o item exige rever uma decisão de arquitetura (ADR) para se resolver de vez (`core/model-routing.md`) |

## Métrica de progresso

**Juro total estimado** da dívida registada e por pagar — custo recorrente em tempo/risco/atrito
(ex.: horas perdidas por mês, incidentes evitáveis, lentidão de mudança), não a contagem nem o tamanho
dos itens. Um item pequeno com juro alto prioriza-se antes de um item grande com juro baixo.

## Condição de entrada

Existe ≥1 item de dívida técnica registado (em `STATE.md` ou no registo de dívida do projeto) com
juro estimado > 0, ainda por pagar.

## Ação (o corpo da iteração)

1. Ordenar os itens por **juro**, não por tamanho nem por antiguidade.
2. Escolher o item de maior juro e desenhar o **menor passo aditivo e reversível** que o reduz — nunca
   um big-bang que reescreve tudo de uma vez (`knowledge/permanent-rules.md` §3, §4).
3. Implementar atrás de feature flag quando o passo tiver risco de regressão
   (`modules/feature-flags.md`).
4. Medir se o juro baixou de facto (o sintoma que motivou o registo desapareceu ou diminuiu
   mensuravelmente) — não basta a sensação de "código mais limpo".

## Condição de saída (sucesso)

Juro total ≤ limiar acordado com o utilizador para o ciclo. Defaults por perfil (na escala de juro
deste loop): protótipo — loop desarmado; produto interno ≤10; produto comercial ≤6; plataforma
empresarial ≤3. O valor acordado na calibração de F0 regista-se no `CLAUDE.md` do projeto
(`workflows/W00-project-kickoff.md` §Pontos de decisão). Um item dado por fechado tem prova de
que o juro parou de se acumular, não só de que o código mudou.

## Salvaguarda anti-loop-infinito

- **Estagnação:** 3 itens pagos consecutivamente sem o juro total baixar → parar o ciclo.
- **Oscilação:** pagar a dívida A cria dívida B de juro equivalente (trocar um atalho por outro) →
  parar de imediato; sinal de que o passo escolhido não era realmente aditivo/estrutural.
- **Teto duro:** 5 itens por ciclo de planeamento, independentemente do progresso. Ultrapassado, o
  ciclo para: regista-se o que foi pago, o que ficou, e o porquê (falta de tempo, item maior do que
  estimado, decisão de arquitetura pendente), e sobe-se ao utilizador para replanear o próximo ciclo —
  nunca se estica um ciclo indefinidamente para "terminar a lista".

## Registo em STATE.md

```
L08 · dívida técnica · métrica juro 40h/mês→28h/mês→28h/mês · iter 3 (teto 5) · último progresso: iter 2 · estado: EM RISCO
```

## Exemplo (plataforma de dados — pipeline de relatórios)

O registo de dívida tem um item antigo: "o job noturno de agregação corre em série, 6h de duração, 1
pessoa precisa de o reiniciar manualmente quando falha a meio" — juro estimado: ~4h/semana de atenção
manual + risco de relatórios atrasados. É o item de maior juro do ciclo (mais do que um item maior —
"migrar o ORM" — que tem juro quase zero porque raramente dói). O passo aditivo escolhido: não
reescrever o pipeline inteiro, só torná-lo **retomável por etapa** (checkpoint a cada fonte de dados
processada), atrás de flag. Depois de um mês em produção, as falhas a meio deixam de exigir reinício
manual — o juro medido cai para quase zero. O item "migrar o ORM" continua na lista, sem se tocar,
porque o seu juro não justificou o ciclo.

## Relacionados

- `core/orchestrator.md` — §Effort profiles; os defaults do limiar vivem na §Condição de saída
  deste loop e o valor do projeto no seu `CLAUDE.md`.
- `core/project-memory.md` — onde a dívida técnica se regista e se acompanha entre sessões.
- `modules/feature-flags.md` — como pagar dívida com risco atrás de kill-switch.
- `knowledge/proven-patterns.md` — os padrões-alvo de muitos pagamentos de dívida.
- `workflows/W09-continuous-operation.md` — a cadência de F9 onde este loop corre por defeito.
- `workflows/W10-feature-evolution.md` — quando um item de dívida se converte em pedido de evolução.
