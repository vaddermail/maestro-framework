# Motor de Decisão

Como a framework toma decisões técnicas **sem opinião fixa e sem reabrir tudo eternamente**: opções
geradas por especialistas, comparadas por critérios explícitos, decididas por um árbitro (ou pelo
utilizador), registadas em ADR — e, quando validadas, **fechadas**.

## Tipos de decisão

| Tipo | Exemplos | Quem decide | Registo |
| --- | --- | --- | --- |
| **Produto/âmbito** | o que entra no MVP, prioridades, personas-alvo | Utilizador (com recomendação) | Artefacto da fase + `STATE.md` |
| **Estrutural** | estilo arquitetural, stack, cloud, modelo de identidade, estratégia de dados | Árbitro propõe → utilizador valida | **ADR obrigatório** |
| **Técnica local** | biblioteca de datas, nome de módulo, formato de log | Agente dono, dentro das convenções | Nota no artefacto/código |
| **De emergência** | mitigar incidente em produção | Runbook + humano em W11 | Post-mortem |

Regra de ouro: **quanto mais cara for a reversão, mais formal a decisão.** Uma decisão de um dia
não merece um ADR; uma de três meses não pode viver num comentário de código.

## O processo para decisões estruturais

1. **Enquadrar** — o Orquestrador define a pergunta de decisão e os **critérios com pesos**,
   derivados dos artefactos (requisitos, RNF, riscos, custos, equipa). Critérios típicos:
   adequação funcional, custo total (construção + operação), complexidade operacional, competência
   da equipa, reversibilidade, maturidade/estabilidade (`knowledge/permanent-rules.md`
   §versões estáveis), lock-in.
2. **Propor em painel** — 2–4 especialistas relevantes (ex.: `agents/02-architecture/`) produzem
   propostas **independentes e às cegas**, cada uma com: desenho, prós/contras honestos contra os
   critérios, custos, riscos e caminho de reversão. Um especialista que conclua "a minha abordagem
   não serve aqui" di-lo — isso é uma proposta válida e valiosa.
3. **Arbitrar** — o árbitro (ex.: `agents/02-architecture/architecture-arbiter.md`) compara
   contra os critérios, pode fundir ideias, e escreve a decisão fundamentada. O árbitro **nunca é**
   um dos proponentes.
4. **Validar com o utilizador** — em linguagem simples: o que se escolheu, o que se rejeitou e
   porquê, o que custa, como se reverte. Só depois o ADR passa a `aprovado`.
5. **Registar** — ADR em `product/02-architecture/decisions/ADR-nnn-title.md`
   (template: `templates/project/ADR-DECISION.md.template`).

## ADR — o que tem de conter

- **Contexto:** o problema e as forças em jogo (requisitos/RNF que pressionam).
- **Opções consideradas:** todas as do painel, com o essencial dos prós/contras — as rejeitadas
  ficam registadas para ninguém as re-propor sem novidade.
- **Decisão:** o que se escolheu, com os critérios que pesaram.
- **Consequências:** o que fica mais fácil, o que fica mais difícil, dívidas assumidas.
- **Reversão:** o que custaria mudar; sinais de alerta que justificariam revisitar.
- **Estado:** proposta → aprovada → (eventualmente) substituída por ADR-nnn.

## Decisões fechadas

Uma decisão validada pelo utilizador fica **fechada**: os agentes não a reabrem por iniciativa
própria. A lista de decisões fechadas vive no `CLAUDE.md` do projeto (secção "Decisões fechadas") —
é das primeiras coisas que qualquer sessão lê.

Reabrir exige **novidade material** (requisito novo, falha comprovada, mudança externa) e faz-se
às claras: "isto contraria a decisão fechada X, tomada porque Y — queres mesmo reabri-la?" Se o
utilizador pedir algo que colide com uma decisão fechada, **avisa-se antes de executar**
(`MANIFESTO.md` §8). Se reabrir, o ADR antigo marca-se `substituída por ADR-nnn` — nunca se apaga.

## Anti-padrões

- ❌ Decidir por moda ("toda a gente usa X") → ✅ decidir pelos critérios pesados do projeto.
- ❌ Painel de fachada (especialistas a validar uma escolha já feita) → ✅ propostas às cegas,
  árbitro independente.
- ❌ ADR-romance de 10 páginas → ✅ uma página densa; o detalhe vive nos artefactos ligados.
- ❌ Re-litigar decisões fechadas a cada sessão → ✅ fechadas ficam fechadas até haver novidade.
- ❌ Esconder a opção "não fazer nada" → ✅ o status quo é sempre uma das opções avaliadas.
- ❌ Tecnologia bleeding-edge por entusiasmo → ✅ estável e aborrecido por defeito; inovação onde é
  diferenciador, com razão registada.

## Relacionados

- `core/question-engine.md` — como as decisões do utilizador se obtêm.
- `agents/02-architecture/architecture-arbiter.md` — o árbitro por excelência.
- `agents/08-infrastructure/hosting-arbiter.md` — o mesmo padrão para infra.
- `templates/project/ADR-DECISION.md.template` — o template do registo.
- `core/quality-gates.md` — portões que exigem ADRs aprovados.
