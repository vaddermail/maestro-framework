# Memória do Projeto

Como um projeto conduzido por agentes de IA **se lembra de tudo** — entre sessões, entre pessoas,
entre ferramentas e entre anos. A regra fundadora: **a memória vive no repositório, em ficheiros
locais versionáveis — nunca na sessão de uma ferramenta.** Qualquer agente, em qualquer ferramenta,
pega no projeto lendo ficheiros; nada de relevante pode existir só na memória efémera de uma
conversa.

## As camadas de memória (e a ordem de leitura)

Fontes de verdade estratificadas, lidas por esta ordem — com **precedência explícita** e regra de
desempate escrita (quando duas divergem, ganha a de cima e regista-se a divergência):

| # | Ficheiro/pasta | Natureza | Muda |
| --- | --- | --- | --- |
| 1 | `CLAUDE.md` (ou equivalente) | **Regras estáveis**: como trabalhar, guardrails, decisões fechadas, mapeamento de modelos | Raramente, com peso |
| 2 | `STATE.md` | **Memória viva**: feito / em curso / a seguir / pendências / lições | Toda a sessão |
| 3 | `product/` | **Artefactos canónicos**: descoberta, requisitos, spec, ADRs (`core/artifact-protocol.md`) | Por fase/fatia |
| 4 | Código + testes | A implementação da spec (se divergir, a spec ganha — atualiza-se uma ou outro, às claras) | Continuamente |
| 5 | `CHANGELOG.md` | História do *o que mudou e porquê*, por marco | Por marco |

## STATE.md — o testemunho

O ficheiro mais importante do dia-a-dia: é onde uma sessão **passa o testemunho** à seguinte (ou ao
colega humano). Estrutura (instanciada de `templates/project/STATE.md.template`):

1. **Cabeçalho de situação** — fase atual, workflow ativo, perfil de esforço, versão da framework.
2. **Feito** — blocos concluídos (o quê, evidência de verificação).
3. **Em curso** — o que está a meio, com o suficiente para outro retomar **sem re-perguntar**.
4. **A seguir** — próximos passos ordenados.
5. **Decisões pendentes** — perguntas à espera do utilizador (`P-nnn`), com contexto e o que bloqueiam.
6. **Decisões tomadas em nome do dono ausente** — quando foi preciso avançar, registadas
   explicitamente como revisitáveis.
7. **Lições** — o **não-óbvio** aprendido, cada uma com o *porquê* e o *como aplicar*. Bugs que se
   repetiram, armadilhas de ferramenta, correções de rumo. (Antes de acrescentar: verificar
   duplicados — atualizar em vez de duplicar; apagar o que se revelou errado.)
8. **Registo histórico** — sessões anteriores, colapsado/resumido (ver §Higiene).

Disciplina associada:

- **Início de sessão:** protocolo de arranque — sincronizar (pull), ler `STATE.md`, confirmar o
  ambiente, só depois trabalhar (`workflows/W00-project-kickoff.md`).
- **Fim de sessão:** atualizar `STATE.md` **sempre** (`START-HERE.md` §2.5). Uma sessão que não
  atualiza o estado é trabalho meio-perdido.

## Onde vive cada tipo de conhecimento

| Tipo | Onde | Anti-exemplo |
| --- | --- | --- |
| Regra estável de trabalho | `CLAUDE.md` | Repetida em cada sessão oralmente |
| Estado e pendências | `STATE.md` | Na cabeça da última sessão |
| Decisão estrutural + porquê | ADR em `product/02-architecture/decisions/` | Num comentário de commit |
| Regra de negócio | `product/04-specification/` | Só no código |
| Lição não-óbvia | `STATE.md` §Lições | Reaprendida à conta de repetir o bug |
| Melhoria que é da framework (não do produto) | `FRAMEWORK-IMPROVEMENTS.md` na raiz | Morre nos commits e na cabeça; a framework não aprende (`playbooks/report-framework-improvements.md`) |
| Pergunta/resposta do utilizador | `product/01-requirements/questions-and-answers.md` | Re-perguntada de 3 em 3 sessões |
| Proveniência de regra | Anotação na própria spec ("origem: defeito X") | Perdida — a spec vira dogma sem contexto |

**Regras com proveniência:** anotar nas specs a origem de cada regra dura (o defeito/decisão que a
criou) transforma a especificação em memória de defeitos — impede que um agente futuro a "simplifique"
por não perceber porque existe.

## Higiene da memória

- **Topo detalhado, histórico colapsado.** O `STATE.md` cresce; o topo mantém-se hiper-detalhado
  sobre o presente e o histórico resume-se por marcos (o detalhe antigo fica no Git/CHANGELOG).
  Um `STATE.md` de 200KB onde ninguém encontra nada deixou de ser memória.
- **Sem segredos.** Nunca em nenhum ficheiro versionado — referências por caminho
  (`playbooks/secrets-management.md`).
- **Experiências falhadas registam-se com o motivo exato** — para ninguém repetir a tentativa três
  sessões depois.
- **Memórias de ferramenta ≠ memória do projeto.** Estados de sessão de ferramentas (projeto ativo
  de um MCP, cache de um plugin) não persistem nem se assumem — o que interessa passa para os
  ficheiros do projeto.

## Anti-padrões

- ❌ "Eu lembro-me do que decidimos" → ✅ está escrito ou não existe.
- ❌ Atualizar o estado "no fim do dia" e a sessão morrer antes → ✅ atualizar ao fim de cada bloco.
- ❌ Lição escrita sem porquê ("cuidado com X") → ✅ porquê + como aplicar, senão vira superstição.
- ❌ Duplicar a mesma lição com palavras novas → ✅ procurar e atualizar a existente.
- ❌ Memória em ferramenta proprietária (notas da sessão, threads) → ✅ repositório, sempre.

## Relacionados

- `templates/project/STATE.md.template` · `templates/project/CLAUDE.md.template` — os instanciáveis.
- `core/artifact-protocol.md` — a memória canónica por artefactos.
- `core/decision-engine.md` — ADRs e decisões fechadas.
- `knowledge/README.md` — como as lições sobem de projeto para a framework.
