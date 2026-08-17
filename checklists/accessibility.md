# Acessibilidade

Verificação WCAG prática, ecrã a ecrã. Definida em F4 pelo
`agents/03-experience/accessibility-specialist.md` (contrato de acessibilidade) e verificada
em F7, antes do portão P7 (`core/quality-gates.md`). Alimenta a revisão de
`agents/12-reviewers/ux-reviewer.md`.

## Estrutura semântica

- [ ] Hierarquia de cabeçalhos coerente (um só `h1` por ecrã, sem saltos de nível).
- [ ] Elementos nativos usados antes de ARIA (`button`, `nav`, `label`, `table`) — ARIA só onde o HTML
      não chega.
- [ ] Landmarks (`main`, `nav`, `header`, `footer`) presentes e sem duplicação ambígua.

## Teclado e foco

- [ ] Toda a ação alcançável e executável só com teclado, sem armadilha de foco fora do focus-trap
      deliberado de um modal.
- [ ] Ordem de tabulação segue a ordem visual/lógica do ecrã.
- [ ] Foco sempre visível (contorno ou equivalente), nunca suprimido sem substituto
      (`outline: none` sem alternativa é reprovado).
- [ ] Modais/diálogos devolvem o foco ao elemento que os abriu, ao fechar.

## Contraste e cor

- [ ] Texto normal com rácio de contraste ≥ 4.5:1, texto grande ≥ 3:1 (WCAG AA), calculado nos tokens
      reais do design system, não estimado.
- [ ] Nenhuma informação transmitida só por cor (erro/sucesso/seleção têm também ícone ou texto).
- [ ] Alvos de toque ≥ 44×44px em elementos interativos.

## Formulários

- [ ] Todo o campo tem `label` visível associado — nunca só `placeholder`.
- [ ] Erros de validação anunciados ao leitor de ecrã (`aria-describedby`, `role="alert"` ou
      equivalente), não só sinalizados por cor.
- [ ] Campos obrigatórios identificados de forma não visual (texto ou `aria-required`, não só
      asterisco colorido).

## Leitores de ecrã

- [ ] Imagens informativas com `alt` que descreve a função/informação; decorativas com `alt=""`.
- [ ] Testado com um leitor de ecrã real nos fluxos críticos — não só com scanner automático.
- [ ] Conteúdo dinâmico (toasts, contadores, validações assíncronas) anunciado via `aria-live`
      apropriado.

## Verificação

- [ ] Nível WCAG alvo confirmado com o utilizador (AA por defeito) —
      `agents/03-experience/accessibility-specialist.md`.
- [ ] Scan automático corrido (apanha ~30–40% dos problemas) **e** verificação manual por teclado
      **e** leitor de ecrã (`knowledge/permanent-rules.md` §7).
- [ ] Resultado por ecrã registado em `product/99-records/`.

## Relacionados

- `agents/03-experience/accessibility-specialist.md` — dono do contrato e da verificação.
- `agents/12-reviewers/ux-reviewer.md` — quem revê o resultado no fluxo real.
- `checklists/definition-of-done.md` — a acessibilidade como critério de F4.
- `modules/single-source-of-content.md` — os textos que os leitores de ecrã anunciam.
- `workflows/W04-experience.md` — onde o contrato de acessibilidade se define.
