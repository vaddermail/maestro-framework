# Performance Web

Orçamentos e medições reais, não estimativas. Definida em F4 pelo
`agents/03-experience/web-performance-specialist.md`, medida ao longo de F6 e verificada em F7
antes do portão P7 (`core/quality-gates.md`). Em produção, o dono contínuo passa a ser o
`agents/13-guardians/performance-guardian.md`.

## Orçamentos definidos

- [ ] Alvos de LCP, CLS, INP e TTFB definidos por **tipo de rota** — nunca um alvo global único.
- [ ] Orçamento de peso (KB de JS/CSS) e número de pedidos por rota definido e tratado como limite
      **bloqueante**, não aspiracional.
- [ ] Dispositivo e rede de referência confirmados com o utilizador (ex.: gama média + 4G para rotas
      públicas; ver `agents/03-experience/web-performance-specialist.md`).

## Condições de medição

- [ ] Medido em viewport pequeno (~390px) **e** grande — não só num dos dois
      (`knowledge/permanent-rules.md` §7).
- [ ] Medido com throttling de CPU/rede ativo, simulando o dispositivo/rede de referência — nunca só
      no portátil do developer em fibra.
- [ ] Medido com cache fria (primeira visita), não só com recursos já em cache.

## Core Web Vitals

- [ ] LCP dentro do orçamento na rota medida; o recurso do LCP nunca depende de lazy-load nem de JS.
- [ ] INP dentro do orçamento nas interações críticas (formulários, listas densas).
- [ ] TTFB dentro do orçamento, com a origem do tempo confirmada (servidor vs. rede).

## Imagens e bundles

- [ ] Imagens em formato moderno, dimensões responsivas, `lazy` fora do primeiro ecrã.
- [ ] Bundle de JS por rota dentro do orçamento definido; código não crítico adiado
      (code-splitting).
- [ ] Fontes web com `font-display` e fallback métrico, sem bloquear a renderização.

## Estabilidade visual

- [ ] CLS dentro do orçamento (idealmente próximo de zero); dimensões reservadas para
      imagens/embeds/anúncios antes de carregarem.
- [ ] Nada visível salta de posição depois do carregamento inicial nos fluxos críticos.

## Relacionados

- `agents/03-experience/web-performance-specialist.md` — dono dos orçamentos e da verificação.
- `agents/03-experience/responsiveness-specialist.md` — o layout que a medição em ~390px cobre.
- `agents/13-guardians/performance-guardian.md` — a monitorização contínua a partir desta base.
- `agents/12-reviewers/performance-reviewer.md` — quem revê contra os orçamentos.
- `checklists/definition-of-done.md` — performance como critério de F4.
