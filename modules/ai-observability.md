# Observabilidade de IA · contabilizar, ver e cortar o consumo

Módulo reutilizável para os produtos que **chamam modelos de IA**: cada utilização é contabilizada
(tokens, custo, latência), atribuída (funcionalidade, modelo, utilizador/organização), visível num
painel, com alertas de anomalia e **kill-switch por modelo**. Sem isto, o custo de IA é uma caixa
negra que só se descobre na fatura.

## O problema que resolve

Chamadas a modelos de IA têm três propriedades perigosas: **custam por uso** (não são um custo fixo),
**variam muito** (um prompt mal montado multiplica tokens) e são **fáceis de proliferar** (fan-out de
subagentes, retries, contextos inchados). Sem observabilidade dedicada:

- ninguém sabe **que funcionalidade** consome o quê, logo não há como otimizar;
- uma anomalia (loop de retries, prompt gigante) só aparece na conta ao fim do mês;
- não há como **cortar** um modelo específico sem desligar o produto todo.

A lição de origem é direta (`knowledge/origin-lessons.md` §E6): o fan-out no tier caro é que
esgota o orçamento — e o que não se mede não se governa.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Evento de uso** — um registo por chamada ao modelo: `modelo`, `funcionalidade`, `utilizador/org`,
  `tokensEntrada`, `tokensSaída`, `tokensCache`, `custo`, `latência`, `desfecho` (ok|erro|corte),
  `fingerprint` (para deduplicar retries).
- **Atribuição** — cada evento carrega as dimensões por que se vai fatiar: **por funcionalidade**
  (que parte do produto), **por modelo** (qual foi usado), **por utilizador/organização** (quem
  consumiu). Sem estas dimensões à cabeça, o dashboard não responde às perguntas úteis.
- **Tarifa** — tabela `modelo → preço por token de entrada/saída/cache`, versionada; o custo calcula-se
  da tarifa, não se adivinha. Alinha-se com o ledger de `modules/credit-management.md` quando há
  cobrança ao utilizador.
- **Painel** — agregações consultáveis: custo por dia × funcionalidade × modelo, top consumidores,
  tokens de cache vs frescos (para ver se o *caching* está mesmo a poupar).
- **Alerta de anomalia** — regra sobre a série: gasto/hora acima de baseline, taxa de erro alta, prompt
  médio a crescer. Aciona notificação, não silêncio.
- **Kill-switch por modelo** — desligar um modelo específico sem deploy (`modules/feature-flags.md`),
  com *fallback* declarado (outro modelo, ou degradação honesta).

## Regras inegociáveis (numeradas, verificáveis)

1. **Toda a chamada de IA emite um evento de uso.** Verificável: um teste/guardrail que falha se
   existir um caminho de chamada ao modelo sem instrumentação (varredura como
   `knowledge/proven-patterns.md` §7).
2. **Custo calculado da tarifa versionada, nunca hardcoded.** Verificável: mudar a tarifa muda o custo
   reportado; um preço embutido no código é um bug.
3. **Cada evento é atribuível às três dimensões** (funcionalidade, modelo, utilizador/org). Verificável:
   nenhum evento com dimensão em falta chega ao painel.
4. **Existe kill-switch por modelo com efeito imediato.** Verificável: desligar um modelo redireciona
   ou degrada no pedido seguinte, sem deploy (`modules/feature-flags.md`).
5. **Anomalias alertam, não passam em silêncio.** Verificável: injetar um pico simulado dispara o
   alerta configurado (`knowledge/proven-patterns.md` §10 — fallbacks visíveis).
6. **Pré-requisitos de otimização verificam-se antes de se confiar neles.** Antes de assumir que o
   *prompt caching* poupa, medir tokens de cache vs frescos no painel; uma otimização não-confirmada é
   uma suposição, não uma economia.
7. **Sem segredos nos eventos.** Prompts/respostas podem conter dados sensíveis; o que se regista para
   custo não inclui conteúdo por omissão, e nunca chaves (`knowledge/permanent-rules.md` §5).
8. **Retries não contam a dobrar por engano.** O `fingerprint` distingue uma chamada repetida de duas
   utilizações reais; o custo reflete o que foi mesmo gasto.

## Como se adota num produto novo (passos)

1. **Envolver todas as chamadas de IA numa porta única** — um cliente de modelo por onde tudo passa;
   é aí que a instrumentação vive (não espalhada por cada call-site).
2. **Definir o evento de uso e a tarifa versionada**; ligar a tarifa à documentação oficial de preços
   do fornecedor do modelo (ver o acoplamento a ferramentas em `adapters/claude-code.md`).
3. **Emitir o evento em todas as chamadas** via a porta, com as três dimensões de atribuição.
4. **Construir o painel** de custo/tokens/latência por dimensão (`agents/05-backend/observability-architect.md`).
5. **Configurar alertas** de anomalia com baseline e limiares acordados com o dono do orçamento.
6. **Ligar o kill-switch por modelo** às flags, com *fallback* declarado por funcionalidade.
7. **Rever periodicamente** com o `agents/13-guardians/cost-guardian.md`: onde poupar, que
   otimização confirmar, que modelo trocar por routing (`core/model-routing.md`).

## Variações e trade-offs

- **Instrumentação própria vs plataforma dedicada.** Própria (eventos na BD + painel simples): controlo
  total, zero dependência, suficiente para começar. Plataforma (Langfuse/Helicone/OpenTelemetry-GenAI/…):
  traces ricos e dashboards prontos, mais uma dependência e possível envio de conteúdo a terceiros —
  pesar contra a regra 7.
- **Medir só custo vs traços completos.** Custo por dimensão é o mínimo acionável; traços de
  prompt/resposta ajudam a depurar mas levantam privacidade e volume — amostrar em vez de guardar tudo.
- **Contabilizar vs cobrar.** Observar (este módulo) é ver o custo; **cobrar** ao utilizador é o ledger
  de `modules/credit-management.md`. Partilham a tarifa e o evento de uso, mas são responsabilidades
  distintas — nem todo o produto que observa também cobra.
- **Kill-switch duro vs degradação suave.** Cortar um modelo pode devolver erro honesto ou cair para um
  modelo mais barato; a escolha é por funcionalidade (uma sugestão opcional degrada; uma extração
  crítica falha visivelmente).

## Exemplo (multi-domínio)

**SaaS de suporte — resumos gerados por IA.** Cada resumo de ticket emite um evento
`{funcionalidade: resumo-ticket, modelo: X, org: 88, tokens_in, tokens_out, custo}`. O painel mostra
que uma organização gera 60% do custo por reprocessar resumos em loop; investiga-se e corta-se o loop.
Quando o fornecedor do modelo X tem incidente, o kill-switch redireciona `resumo-ticket` para o
modelo Y (mais barato, resumo mais curto) — degradação honesta, sinalizada na UI.

**Plataforma de dados — classificação de registos.** Antes de confiar que o *prompt caching* reduziria
a fatura, mede-se no painel a razão tokens-cache/tokens-frescos: estava a 5% (o prefixo não era
estável). Ajusta-se o prompt para maximizar o prefixo partilhado e confirma-se o salto para 70% —
otimização **verificada**, não assumida (regra 6).

## Armadilhas conhecidas

- **Instrumentação por call-site:** espalhar a contagem por cada chamada garante que uma escapa; a
  porta única (passo 1) é o que torna a regra 1 verificável.
- **Confiar numa otimização não medida:** o *prompt caching* só poupa se o prefixo for estável e
  suficientemente longo — assumir a poupança sem a ver no painel é auto-engano (regra 6).
- **Custo hardcoded que envelhece:** o fornecedor muda preços; um número no código diverge da fatura
  real. A tarifa é dados versionados (regra 2).
- **Registar prompts com dados pessoais/segredos:** transforma o log de custo num risco de privacidade;
  guardar métricas, não conteúdo (regra 7).
- **Retries contados como uso:** um backoff que rechama o modelo inflaciona o custo aparente se não se
  deduplicar por fingerprint (regra 8).
- **Dashboard sem atribuição:** um total global de custo não diz **onde** cortar; sem as três dimensões,
  o painel é bonito e inútil.

## Relacionados

- `core/model-routing.md` — escolher o modelo por tarefa é a maior alavanca de custo.
- `modules/credit-management.md` — o ledger que cobra o consumo observado, quando há faturação.
- `modules/feature-flags.md` — o kill-switch por modelo.
- `agents/13-guardians/cost-guardian.md` — quem vigia o custo em cadência e sugere otimizações.
- `agents/05-backend/observability-architect.md` — traces/logs/métricas onde estes eventos encaixam.
- `modules/single-source-of-content.md` — o catálogo que serve de grounding ao assistente de IA.
- `knowledge/origin-lessons.md` — §E6 (routing e fan-out no tier caro).
