# Motor de Perguntas

Como a framework obtém informação do utilizador. É o mecanismo que torna real o princípio
**"nunca assumir"** (`MANIFESTO.md` §2) sem transformar o processo num interrogatório: perguntas
**inteligentes, em lotes, com opções e recomendação** — e tudo registado.

## Quando se pergunta

1. Um agente encontra uma **lacuna** num input obrigatório (a sua ficha diz o que precisa).
2. Uma decisão é **do utilizador por natureza**: âmbito, dinheiro, risco, gosto, prioridade
   (ver `core/orchestrator.md` §Aprovação humana).
3. Duas fontes **contradizem-se** e nenhuma é claramente a fonte de verdade.
4. Um default proposto tem consequências difíceis de reverter — confirma-se antes.

**Quando NÃO se pergunta:** o que se pode verificar nos artefactos ou no código, verifica-se;
o que tem convenção estabelecida na framework, segue-se a convenção e anota-se; o que é detalhe
sem impacto na decisão do utilizador, decide o agente e regista.

## O formato de cada pergunta

Toda a pergunta colocada ao utilizador leva **cinco elementos**:

```markdown
### P-014 · Autenticação dos utilizadores  [fase F3 · bloqueia: ADR-004]

**Contexto:** A aplicação vai ter utilizadores internos da empresa e clientes externos.
**Pergunta:** Como devem autenticar-se os utilizadores?
**Porque importa:** Define a arquitetura de identidade — mudar depois custa semanas e migração
de contas.
**Opções:**
1. **Entra ID / Google Workspace (SSO)** — sem passwords a gerir; exige que todos tenham conta
   corporativa. Custo ~0; melhor segurança.
2. **Email + password próprios** — funciona para qualquer pessoa; passa a haver reset de password,
   MFA e armazenamento seguro de credenciais para manter — mais superfície de risco.
3. **Híbrido (SSO interno + convites externos)** — cobre ambos; mais complexo de construir (+X dias).
**Recomendação:** Opção 1 se todos os utilizadores tiverem conta corporativa; caso contrário, 3.
**Se não responderes:** assumimos a opção recomendada **como provisória e reversível**, marcada
para confirmação antes do portão de F3.
```

Regras do formato:

1. **Linguagem simples.** Quem responde pode não ter formação técnica — trade-offs explicam-se por
   consequências (tempo, custo, risco, esforço futuro), não por jargão.
2. **Opções fechadas + escape.** 2–4 opções concretas; "outra ideia / não sei" é sempre resposta
   válida. "Não sei" ativa a recomendação por defeito, marcada como **provisória**.
3. **Recomendação sempre.** O agente que pergunta sem recomendar está a exportar o trabalho dele
   para o utilizador.
4. **ID único (`P-nnn`)** para rastreio: a resposta liga-se aos artefactos que desbloqueou.

## Quando se assume por defeito (a regra única)

Perante uma pergunta sem resposta, o Orquestrador assume a opção recomendada **apenas quando as
quatro condições se verificam**:

1. a pergunta incluiu a cláusula **"Se não responderes"** com essa consequência explícita;
2. o default é **reversível** sem custo material;
3. a decisão **não** pertence à aprovação humana obrigatória (`core/quality-gates.md` —
   âmbito, dinheiro, produção, dados pessoais, risco residual);
4. **não** é uma ambiguidade crítica de requisitos (`loops/L01-ambiguous-requirements.md`) — essas
   ficam pendentes, sempre.

O assumido regista-se como `assumida-por-defeito (provisória)` em `perguntas-e-respostas.md` e em
`STATE.md` §Decisões tomadas em nome do dono ausente, e **confirma-se no portão seguinte**. Tudo o
que falhar uma das condições fica em `STATE.md` §Decisões pendentes — bloqueio honesto vale mais
do que assunção silenciosa. Esta é a única regra sobre assumir por defeito: `core/orchestrator.md`
§Recuperação e os workflows remetem para aqui, não a redefinem.

## Lotes, não metralhadora

- As lacunas **sobem ao Orquestrador**, que as agrupa por tema/fase num **lote coerente**
  (idealmente 3–8 perguntas; nunca mais de 12).
- Um lote indica o que fica **bloqueado** por cada resposta em falta — o utilizador vê o custo de
  adiar.
- Perguntas urgentes (bloqueiam o trabalho de hoje) separam-se das que podem esperar pelo fim da
  fase.
- Nunca se repete uma pergunta já respondida: verifica-se primeiro o histórico (abaixo). Se a
  resposta anterior parecer errada à luz de nova informação, **cita-se a resposta antiga** e
  pergunta-se se mantém.

## Registo (auditável)

Todas as perguntas e respostas vivem em `product/01-requirements/questions-and-answers.md`
(mesmo as de outras fases — um único histórico, ordenado, pesquisável):

```markdown
## P-014 · Autenticação dos utilizadores
- **Estado:** respondida | pendente | assumida-por-defeito (provisória)
- **Colocada:** 2026-07-08 (F3) · **Respondida:** 2026-07-09
- **Resposta:** Opção 1 (SSO Entra ID). "Toda a gente tem conta da empresa."
- **Desbloqueou:** ADR-004, RF-031
```

- Perguntas **pendentes** espelham-se em `STATE.md` → "Decisões pendentes" (é aí que a próxima
  sessão as encontra).
- Respostas **assumidas por defeito** têm de ser confirmadas até ao portão da fase — o portão não
  passa com provisórias críticas.

## Loop associado

`loops/L01-ambiguous-requirements.md`: enquanto existirem ambiguidades/lacunas abertas → formular lote
→ perguntar → integrar respostas nos artefactos → reverificar. Sai quando não há lacunas críticas.
Salvaguarda: se o utilizador não responde, o loop **não** gira em vazio — as pendências ficam
registadas e o trabalho segue por onde não depende delas.

## Anti-padrões

- ❌ Perguntar o que já está respondido no histórico → ✅ ler `perguntas-e-respostas.md` primeiro.
- ❌ Pergunta aberta vaga ("o que achas da segurança?") → ✅ opções concretas com consequências.
- ❌ Assumir em silêncio → ✅ assumir **por defeito declarado**, marcado como provisório e visível.
- ❌ Interrogatório técnico ("REST ou GraphQL?") sem tradução → ✅ perguntar pelas consequências que
  o utilizador consegue avaliar; a tradução técnica é trabalho do agente.
- ❌ 30 perguntas de uma vez → ✅ lotes por tema, priorizados pelo que bloqueiam.

## Relacionados

- `core/orchestrator.md` — quem agrupa e coloca os lotes.
- `core/decision-engine.md` — o que acontece às respostas que viram decisões técnicas.
- `loops/L01-ambiguous-requirements.md` — o loop que este motor alimenta.
- `agents/01-requirements/ambiguity-hunter.md` — o principal produtor de lacunas.
