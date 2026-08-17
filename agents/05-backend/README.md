# 05 — Backend (engenharia do servidor)

Os agentes que constroem o **lado fiável** do sistema: o servidor onde vivem a autorização, o
scoping, a integridade transacional, a ocultação de campos sensíveis e os contratos que o cliente
consome. O princípio que atravessa toda a categoria: **o cliente é não-fiável** — declara intenção,
o servidor confirma e decide (`knowledge/origin-lessons.md` §C1, `modules/rbac-and-scoping.md`).

## Fase(s) e quando entra

Fase dominante **F5–F6** (`core/lifecycle.md`). Divide-se em dois momentos:

- **F5 (especificação):** o `desenhador-de-apis.md` fixa o **contrato** — recursos, erros, paginação,
  versionamento — como fonte única que alimenta validação, tipos do servidor, tipos do cliente e a
  documentação (`knowledge/origin-lessons.md` §C2). Nada de código ainda; é o *quê* da API.
- **F6 (construção):** os especialistas implementam esse contrato em fatias verticais
  (`workflows/W06-build.md`), na ordem dados → backend → frontend, com testes contínuos.

## Anatomia uniforme de módulo (a regra que unifica a categoria)

Todo o módulo de backend desta framework tem **três camadas**, sempre pela mesma ordem
(`knowledge/origin-lessons.md` §C3):

| Camada | Responsabilidade | O que **não** faz |
| --- | --- | --- |
| **Bordo fino** (protocolo) | Traduz HTTP/gRPC/mensagem em chamada tipada; valida a *forma* do input; devolve o formato de erro padrão | Não decide autorização nem regra de negócio |
| **Orquestração** | Confirma autoridade e scoping (servidor), abre transação, compõe os passos, aciona efeitos secundários via outbox | Não fala protocolo; não contém a regra pura |
| **Domínio puro/transacional** | A regra de negócio como função que recebe a ligação de BD (ou dados já carregados); testável sem HTTP, componível dentro de transações maiores | Não conhece HTTP, headers, nem o formato de resposta |

*Porquê:* a lógica difícil fica testável sem rede e reutilizável dentro de transações maiores — e a
mesma operação servida por várias vias (portal, backoffice, API, CLI) partilha o núcleo transacional,
diferindo só no bordo (`knowledge/proven-patterns.md` §8). Os revisores verificam esta
separação em `agents/12-reviewers/backend-reviewer.md`.

## Agentes da categoria

**Contrato e estilos de API**
- `agents/05-backend/api-designer.md` — desenha o contrato (recursos, erros, paginação) e escolhe o estilo com o utilizador; SSOT do contrato.
- `agents/05-backend/rest-specialist.md` — REST: recursos, verbos, códigos, HATEOAS pragmático, OpenAPI.
- `agents/05-backend/graphql-specialist.md` — GraphQL: schema, resolvers, N+1, autorização por campo.
- `agents/05-backend/grpc-specialist.md` — gRPC: protobuf, streaming, versionamento de mensagens.
- `agents/05-backend/api-versioning-specialist.md` — versiona e depreca APIs sem partir clientes.

**Identidade e acesso**
- `agents/05-backend/authentication-specialist.md` — authn: OIDC/OAuth2, sessões vs tokens, MFA, contas de serviço.
- `agents/05-backend/authorization-specialist.md` — authz: RBAC/ABAC, scoping no servidor, cliente não-fiável, fail-closed.

**Desempenho e assíncrono**
- `agents/05-backend/caching-specialist.md` — caching por camadas, chaves, TTL, invalidação, estampede.
- `agents/05-backend/queue-specialist.md` — filas de trabalho: executor único, dedupe por fingerprint, retries, DLQ.
- `agents/05-backend/events-specialist.md` — eventos de domínio/integração: outbox, ordering, idempotência.
- `agents/05-backend/scalability-architect.md` — escala horizontal/vertical, gargalos, backpressure, limites.

**Observabilidade**
- `agents/05-backend/logging-specialist.md` — logging estruturado, níveis, correlação, sem segredos nos logs.
- `agents/05-backend/metrics-specialist.md` — métricas RED/USE, SLIs, cardinalidade sob controlo.
- `agents/05-backend/observability-architect.md` — traces + logs + métricas correlacionados; alertas acionáveis; custos de IA visíveis.
- `agents/05-backend/ai-features-specialist.md` — funcionalidades LLM: grounding na fonte única, prompts versionados, evals executáveis, guardrails/fallback, créditos e observabilidade de IA aplicados.

## Ordem de trabalho recomendada

1. **Contrato primeiro** (`desenhador-de-apis`) — decide o estilo com o utilizador e escreve o
   contrato; é o input de todos os outros.
2. **Identidade e acesso** (`especialista-de-autenticacao` → `especialista-de-autorizacao`) — antes de
   qualquer endpoint que devolva dados; authn estabelece *quem*, authz decide *o quê/qual subconjunto*.
3. **Implementação do estilo escolhido** (um de `rest`/`graphql`/`grpc`) sobre a anatomia de três
   camadas, fatia a fatia.
4. **Desempenho e assíncrono** conforme a fatia exige — caching, filas, eventos.
5. **Observabilidade** desde a primeira fatia — logging e métricas não são um retoque final.

## Como o Orquestrador a convoca

O `core/orchestrator.md` monta o grafo de dependências a partir das secções **Inputs**/**Interações**
de cada ficha. Em F5 chama só o `desenhador-de-apis`; em F6 chama os especialistas na ordem acima,
por fatia vertical, coordenando com `agents/06-data/` (a montante — o modelo persistido) e
`agents/04-frontend/` (a jusante — o consumidor do contrato). Autorização, scoping, integridade e
ocultação de sensíveis são **responsabilidade exclusiva** desta camada (`templates/specification/backend-contract.md.template`).

## Relacionados

- `agents/06-data/README.md` — a verdade persistida que o backend orquestra.
- `agents/04-frontend/README.md` — o cliente não-fiável que consome os contratos.
- `modules/rbac-and-scoping.md` · `modules/job-queue.md` · `modules/state-machines.md` — capacidades reutilizáveis que os agentes aplicam.
- `knowledge/proven-patterns.md` · `knowledge/origin-lessons.md` §C — os padrões que a categoria implementa.
