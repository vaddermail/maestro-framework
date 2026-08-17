# L01 — Requisitos Ambíguos

> Loop `L01` da framework Maestro — persiste enquanto existirem requisitos ambíguos,
> contraditórios ou em falta, até desambiguar tudo o que é crítico ou provar que a decisão está fora
> do alcance da sessão. Segue a anatomia de `loops/README.md`.

Um requisito ambíguo aceite em silêncio é o defeito mais barato de evitar e o mais caro de descobrir
tarde — reaparece em cada fase seguinte, cada vez mais caro de corrigir (arquitetura já escolhida, UI
já desenhada, código já escrito). Este loop existe para que nenhuma ambiguidade sobreviva a F2 sem
virar uma pergunta explícita ao utilizador.

## Identificação

| Campo | Valor |
| --- | --- |
| **Quando corre** | F2 (principal); reaberto em F5 quando a especificação expõe lacunas novas |
| **Agente que executa a ação** | `agents/01-requirements/ambiguity-hunter.md` deteta e formula a pergunta; o agente-dono do artefacto (`engenheiro-de-requisitos`, `modelador-de-regras-de-negocio`, `especificador-de-requisitos-nao-funcionais`, `redator-de-criterios-de-aceitacao`, `curador-do-glossario`) aplica a resposta |
| **Modelo sugerido** | Topo, esforço médio, para a deteção adversarial (`core/model-routing.md`); Padrão para aplicar a resposta ao artefacto |

## Métrica de progresso

Número de achados `A-nnn` com severidade **crítica** em estado `aberto` nos artefactos de F2/F5
(ambiguidade + contradição + lacuna, somados). Contável por artefacto e no total, comparável lote a
lote porque cada achado tem ID estável.

## Condição de entrada

Existe pelo menos um achado `A-nnn` crítico em estado `aberto` — detetado pelo Caçador de
Ambiguidades numa leitura por artefacto ou cruzada (`agents/01-requirements/ambiguity-hunter.md`
§Workflow).

## Ação (o corpo da iteração)

1. O Caçador lê o(s) artefacto(s) que mudou(aram) desde a última passagem e atualiza a lista de
   achados `A-nnn` (novos, reabertos, fechados).
2. O Orquestrador agrupa os achados que exigem decisão do utilizador num **lote coerente** (3–8
   perguntas, nunca mais de 12) via `core/question-engine.md`, indicando o que cada resposta
   desbloqueia.
3. O lote é colocado ao utilizador; entretanto, o trabalho que não depende das respostas continua — o
   loop não espera às escuras.
4. Cada resposta que chega é aplicada pelo agente-dono do artefacto correspondente (nunca pelo
   Caçador, que só deteta).
5. O Caçador reverifica os achados tocados pela resposta e fecha os que ficaram resolvidos.

## Condição de saída (sucesso)

Zero achados críticos em estado `aberto`, confirmado pelo Caçador de Ambiguidades numa passagem final
cruzada sobre todos os artefactos de F2 — não basta cada agente-dono declarar o seu artefacto
corrigido isoladamente, porque a contradição vive **entre** documentos.

## Salvaguarda anti-loop-infinito

- **Estagnação:** 3 lotes de perguntas consecutivos sem reduzir a contagem de achados críticos → parar.
- **Oscilação:** um achado fechado por uma resposta é reaberto por uma resposta posterior contraditória
  sobre o mesmo termo/regra → tratar como ciclo de imediato, não esperar pela 3.ª iteração; sinal de
  que a pergunta original estava mal desenhada (revê-la, não repeti-la igual).
- **Teto duro:** 8 lotes por fase. Ultrapassado, o loop para: regista em `STATE.md` → "Decisões
  pendentes" os achados que restam, com o porquê de não convergirem (utilizador indisponível,
  respostas contraditórias, âmbito a decidir), e sobe ao utilizador com opções (cortar o requisito do
  MVP, aceitar uma ambiguidade não-crítica com risco registado, ou mudar quem decide).
- Um utilizador que não responde **não conta como iteração sem progresso** — o motor de perguntas já
  prevê que o loop não gira em vazio (`core/question-engine.md` §Loop associado); a salvaguarda
  dispara sobre lotes efetivamente respondidos que não resolveram nada.

## Registo em STATE.md

```
L01 · requisitos ambíguos · métrica 9→5→2 · iter 3 (teto 8) · último progresso: iter 3 · estado: em curso
```

Ao fechar (métrica a zero, verificado), colapsa para uma linha no "Registo histórico"
(`core/project-memory.md` §Higiene) com a data e o total de achados resolvidos.

## Exemplo (SaaS B2B — faturação por assinatura)

O `engenheiro-de-requisitos` escreve **RF-018**: *"O sistema cobra automaticamente no início de cada
ciclo."* O Caçador levanta três achados no mesmo enunciado: **A-031** (ambiguidade) — "início do
ciclo" é a data de subscrição de cada cliente ou o dia 1 do mês civil para todos?; **A-032** (lacuna)
— o que acontece se o cartão for recusado: retenta, suspende o acesso, ou notifica só o financeiro?;
**A-033** (contradição) — RF-018 implica cobrança automática, mas **RN-009** diz "toda a cobrança
acima de 500€ exige aprovação manual do financeiro". Os três viram o lote P-041/042/043. O utilizador
responde: ciclo por data de subscrição; retenta 3× em 48h e depois suspende; RN-009 só se aplica a
faturas avulsas de upsell, não à mensalidade recorrente. O `engenheiro-de-requisitos` e o
`modelador-de-regras-de-negocio` corrigem os artefactos, o Caçador reverifica e fecha os três achados.

## Relacionados

- `core/question-engine.md` — o mecanismo de pergunta em lote que este loop aciona.
- `agents/01-requirements/ambiguity-hunter.md` — o agente dono da deteção.
- `agents/01-requirements/README.md` — os agentes-donos que aplicam as respostas.
- `core/quality-gates.md` — P2 não passa com achados críticos abertos.
- `core/orchestrator.md` — §Recuperação, a origem da regra dos 3.
- `knowledge/ai-pitfalls.md` — §3, assumir em vez de perguntar, a armadilha que este loop bloqueia.
