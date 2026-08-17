# 11 · Documentação — conhecimento vivo

Categoria **transversal** (F1→F9). Enquanto as outras categorias produzem o produto, esta garante
que o produto se **explica a si próprio** — a quem o constrói, a quem o opera e a quem o usa — e que
essa explicação **não mente nem envelhece**. A documentação aqui não é um relatório final: é um
artefacto vivo, derivado das fontes de verdade e sincronizado com o código a cada fatia.

Princípio-âncora da categoria: **cada facto tem uma fonte única** (`modules/single-source-of-content.md`).
A ajuda ao utilizador serve o ecrã **e** o grounding de qualquer IA de ajuda; a referência de API
gera-se do contrato; os docs técnicos derivam do código. Nada se escreve à mão duas vezes — o que se
duplica, diverge (`knowledge/origin-lessons.md`).

## Agentes desta categoria

| Agente | Uma linha | Tipo |
| --- | --- | --- |
| `agents/11-documentation/documentation-architect.md` | Desenha a **estrutura documental** (specs, ADRs, runbooks, ajuda) e declara as fontes de verdade e a precedência entre elas. | Especialista |
| `agents/11-documentation/technical-writer.md` | Escreve e **atualiza a documentação técnica** (README, arquitetura, onboarding) sincronizada com o código. | Especialista |
| `agents/11-documentation/user-help-writer.md` | Mantém o **menu de Ajuda completo, com exemplos**, como fonte única que serve o ecrã e o grounding de IA. | Especialista |
| `agents/11-documentation/api-documenter.md` | Produz a **referência de API gerada do contrato** (OpenAPI/schema), sempre atual e nunca escrita à mão. | Especialista |

## Ordem de trabalho recomendada

1. **`arquiteto-de-documentacao`** primeiro (cedo, em F1): define o mapa documental, onde cada
   documento vive, quem é o seu dono e qual a fonte de que deriva. Sem este mapa, os redatores
   escrevem para sítios inconsistentes.
2. **`redator-tecnico`**, **`redator-de-ajuda-ao-utilizador`** e **`documentador-de-apis`** em
   **paralelo**, cada um na sua camada, conforme as fontes vão existindo (o código para o técnico, a
   content-layer para a ajuda, o contrato para a API). Não há dependência entre eles — só partilham o
   mapa do arquiteto.

## Como o Orquestrador a convoca

- **Em cada fatia de construção (F6)** o Orquestrador invoca o redator relevante para atualizar a
  documentação tocada — a fatia só fecha com docs em dia (`core/quality-gates.md`).
- **Por drift**, o `loops/L06-outdated-documentation.md` (aberto pelo
  `agents/13-guardians/documentation-guardian.md` ou pelo `agents/12-reviewers/documentation-reviewer.md`)
  reconvoca o redator certo para reconciliar documentação e realidade.
- **Em F1** o Orquestrador chama o `arquiteto-de-documentacao` para instalar a estrutura.

## A que fases pertence

Fase dominante: **transversal (F1–F9)**. O arquiteto trabalha em F1 e revisita a estrutura em cada
marco; os redatores acompanham a construção (F5–F6) e a operação (F9). A **vigilância** da sincronia
em cadência é do guardião (F9); a **revisão** independente é do revisor (F7) — esta categoria
**escreve**, não se auto-fiscaliza.

## Relacionados

- `agents/13-guardians/documentation-guardian.md` — vigia o drift em cadência; abre o loop.
- `agents/12-reviewers/documentation-reviewer.md` — revê sincronia docs↔código antes do marco.
- `modules/single-source-of-content.md` — o alicerce SSOT de labels, descrições e ajuda.
- `loops/L06-outdated-documentation.md` — o loop que reconvoca os redatores.
- `agents/_template/AGENT-TEMPLATE.md` · `_meta/INVENTORY.md`
