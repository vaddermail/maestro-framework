# Lições de Origem

Lições **generalizadas** do projeto-mãe — um produto real construído de
raiz com IA, que passou de protótipo HTML a monorepo TypeScript real através de ~40 fatias verticais,
duas auditorias adversariais e um processo de equipa maduro. O domínio do projeto-mãe fica de
fora; o que se generaliza é o **sistema de trabalho** e os padrões de engenharia.

Cada lição traz o *porquê* e o *como aplicar*. São a memória de defeitos que a framework herda para
não os repetir noutro produto.

---

## A. Especificação e memória

**A1. Spec estratificada, numerada, com precedência explícita e agnóstica de tecnologia.**
As fontes de verdade organizam-se em camadas com ordem de leitura **e** de precedência declaradas,
mais uma regra de desempate escrita (protótipo diverge da spec → a spec ganha, regista-se a
divergência). A spec descreve o *quê/porquê* (regras, fluxos, estados) e nunca o *como* (stack, BD) —
esse vive em ADRs separados.
- *Porquê:* dá aos agentes um caminho **determinístico** para resolver contradições sem inventar; e
  permite trocar de stack sem reescrever a intenção do produto.
- *Aplicar:* `core/artifact-protocol.md` + `core/project-memory.md`; specs em
  `product/04-specification/`, decisões em ADRs.

**A2. A spec é também memória de defeitos.** Anotar cada regra dura com a sua **proveniência** (o
defeito/decisão que a originou).
- *Porquê:* impede que um agente futuro "simplifique" uma salvaguarda por não perceber porque existe.
- *Aplicar:* proveniência obrigatória (`core/project-memory.md` §Higiene).

**A3. STATE.md passa o testemunho: topo hiper-detalhado, histórico colapsado.**
- *Porquê:* um estado que cresce sem higiene deixa de ser encontrável — memória que não se lê não é
  memória.
- *Aplicar:* `core/project-memory.md`; registar também **decisões tomadas em nome do dono
  ausente**, como revisitáveis.

**A4. Dar a spec completa à cabeça e planos autocontidos, tarefa a tarefa.**
- *Porquê:* corta turnos de ida-e-volta e reduz custo de IA; um implementador com contexto completo
  erra menos.
- *Aplicar:* `core/model-routing.md` §6; `workflows/W06-build.md`.

---

## B. Regras de negócio e integridade

**B1. Três mecanismos de controlo ortogonais que não se substituem:** gate de elegibilidade (bloqueia
o fluxo cedo) ≠ aprovação de autorização (fecha o fluxo) ≠ escalão proporcional a um valor. Limiares
**configuráveis em dados, nunca fixos por perfil nem em código**; toda a decisão persiste a via usada.
- *Porquê:* colapsar os mecanismos torna o sistema rígido e a auditoria impossível.
- *Aplicar:* `modules/approval-engine.md`.

**B2. Autoridade ≠ scoping — eixos distintos.** *Autoridade* = que ações posso fazer; *scoping* = que
subconjunto de dados vejo. Colapsá-los cria bugs nos dois sentidos.
- *Porquê:* foi fonte real de defeitos; um perfil pode ter autoridade ampla e scoping estreito, ou o
  inverso.
- *Aplicar:* `modules/rbac-and-scoping.md`.

**B3. Uma fonte de verdade por facto; o inverso deriva-se.** Relações bidirecionais guardam um lado e
derivam o outro; estado calculável **nunca** é coluna.
- *Porquê:* duas cópias editáveis do mesmo facto divergem — a classe de bug mais teimosa.
- *Aplicar:* `knowledge/proven-patterns.md` §4; `agents/06-data/data-modeler.md`.

**B4. Invariantes duros na BD + guards na app.** Constraint é a última linha de defesa; a app dá o
erro amigável. Testar a constraint inserindo a linha ilegal e afirmando a violação pelo nome.
- *Aplicar:* `knowledge/proven-patterns.md` §5.

**B5. Estado em camadas ortogonais (base + overlay).** Uma ação temporária nunca deve destruir estado
permanente; decompor e derivar o estado apresentado.
- *Aplicar:* `modules/state-machines.md`; `knowledge/proven-patterns.md` §9.

**B6. Uma operação com N vias de entrada = um serviço partilhado.** As vias diferem só em apresentação
e pré-condições; o efeito é o mesmo código.
- *Aplicar:* `knowledge/proven-patterns.md` §8.

**B7. Semear dados de demo com datas relativas a uma data-âncora, nunca absolutas.**
- *Porquê:* um demo com datas fixas "envelhece" e passa a mostrar tudo como atrasado/expirado.
- *Aplicar:* `agents/06-data/data-modeler.md` (seeds).

---

## C. Backend e dados (engenharia)

**C1. Cliente não-fiável: autorização, scoping e ocultação de sensíveis 100% no servidor.** O cliente
declara intenção (perfil ativo por header); o servidor confirma. Fora-de-scope → 404, não 403.
Fail-closed (sem perfil → nega, nunca super-utilizador).
- *Porquê:* um `?? "ADMIN"` fail-open transformou "sem perfil" em "acesso total" — existiu e foi
  corrigido.
- *Aplicar:* `modules/rbac-and-scoping.md`; `agents/05-backend/authorization-specialist.md`.

**C2. Contrato de dados numa só declaração alimenta validação + tipos servidor + tipos cliente + doc
da API.** Um snapshot intermédio (ex.: OpenAPI) desacopla o ritmo do frontend sem perder tipagem.
- *Porquê:* elimina a deriva entre "o que se valida", "o que o tipo diz" e "o que a doc promete".
- *Aplicar:* `modules/single-source-of-content.md` §Como se adota num produto novo, passo 7 (contratos); `agents/05-backend/api-designer.md`.

**C3. Anatomia uniforme de módulo:** bordo fino (protocolo) → orquestração (autorização + composição)
→ regra de negócio (função pura/transacional que recebe a ligação de BD).
- *Porquê:* a lógica difícil fica testável sem HTTP e componível dentro de transações maiores.
- *Aplicar:* `agents/05-backend/README.md`.

**C4. Operações críticas numa transação, com locks pessimistas.** `FOR UPDATE` em quem muta o
agregado central, lock partilhado na operação inversa que só precisa que ele não mude. Fecha janelas
TOCTOU.
- *Aplicar:* `knowledge/proven-patterns.md` §1,§5; `modules/entity-lifecycle.md`.

**C5. Transactional outbox para efeitos secundários.** Emitir evento dentro da transação; entrega por
executor único idempotente por fingerprint; kill-switch por canal; falhas logadas.
- *Aplicar:* `modules/job-queue.md`.

**C6. Erros que a UI aciona carregam payload estruturado, não só string.** Formato de erro único e
padrão em toda a API (ex.: problem+json), com membros de extensão para a UI reagir sem parsing frágil.
- *Aplicar:* `agents/05-backend/api-designer.md`; `agents/04-frontend/api-integrator.md`.

**C7. Migrações expand-contract; validar constraints em duas fases com dados legados.** CHECK novo
aplicado sem validar o legado, depois backfill + validação. Nunca largar/renomear o que está em uso.
- *Aplicar:* `playbooks/expand-contract-db-migration.md`.

**C8. Distinguir NULL de FALSE e fechar TOCTOU são detalhes que mordem.** Um CHECK só rejeita em FALSE
estrito (NULL passa); ler-decidir-escrever sem lock tem corrida.
- *Aplicar:* `agents/06-data/data-modeler.md` (armadilhas SQL).

**C9. Integração externa atrás de uma porta, com adapter fake em dev e upsert idempotente por ID
externo.** Guardar payload bruto como proveniência; escrita-de-volta como porta desde cedo (mesmo
no-op).
- *Aplicar:* `modules/readonly-external-integrations.md`.

---

## D. Frontend e conteúdo

**D1. Catálogo único de conteúdo de UI (labels + tooltips + ajuda), tipado, com convenção de chaves.**
Serve o ecrã **e** o grounding de qualquer IA de ajuda — inclusive dos módulos ainda-por-construir,
marcados "Planeado".
- *Aplicar:* `modules/single-source-of-content.md`; `agents/11-documentation/user-help-writer.md`.

**D2. Regras de produto só aderem se forem impostas por testes que varrem tudo por convenção.** Tooltip
em toda a ação, label sempre do catálogo, sem cores hardcoded → um teste que falha se algo escapa.
- *Aplicar:* `knowledge/proven-patterns.md` §7; `pipelines/ci-quality.md`.

**D3. Encapsular workarounds de biblioteca em componentes do design system, com o porquê inline.**
- *Porquê:* há bugs só-de-browser (ex.: tooltip que não dispara em botão desativado) que ninguém deve
  reencontrar.
- *Aplicar:* `agents/03-experience/component-architect.md`.

**D4. Tokens de design centrais com camada semântica; tema claro por defeito; mobile-first testado no
viewport real.** Armadilha recorrente: grids que rebentam por falta de `min-width:0` nos filhos.
- *Aplicar:* `agents/03-experience/design-system-architect.md`,
  `agents/03-experience/responsiveness-specialist.md`, `checklists/web-performance.md`.

**D5. Mocks espelham o servidor com a mesma lógica** (upsert por id, dedupe, formato de erro) e mantêm
paridade; validação de forma em runtime ligada só em dev/test.
- *Aplicar:* `agents/04-frontend/api-integrator.md`.

---

## E. Processo, verificação e custo

**E1. A prova-live real apanha defeitos que centenas de testes verdes não veem.** É gate
insubstituível antes de declarar "funciona".
- *Aplicar:* `checklists/definition-of-done.md` §Por alteração de código — a prova-live real é o
  gate; a materialização por ferramenta vive em `adapters/claude-code.md`.

**E2. A revisão adversarial final da branch apanha regressões cross-fatia que as reviews por fatia
não veem.** A convergência de duas auditorias independentes é confiança alta — mas mesmo essa se
verifica.
- *Aplicar:* `playbooks/adversarial-audit.md`; `workflows/W12-global-review.md`.

**E3. Guardrails como testes de CI + pipeline de dois níveis** (testes rápidos in-memory + job de
paridade real). E ter sempre um **gate de merge local** para quando o CI hospedado fica indisponível
(custo/minutos).
- *Aplicar:* `pipelines/ci-quality.md`, `pipelines/ci-security.md`.

**E4. Snapshots/artefactos gerados (OpenAPI, clientes, schemas) regeneram-se por comando, nunca à
mão.** E o snapshot de contrato é idêntico entre consumidores.
- *Aplicar:* `agents/05-backend/api-designer.md`; `pipelines/ci-quality.md`.

**E5. Toolset do agente versionado no repo, com adoção evolutiva.** A equipa usa as mesmas ferramentas;
adota-se o que acrescenta valor **agora**, remove-se o que deixa de acrescentar — cada mudança
registada com o porquê. Experiências falhadas de tooling registam-se para não se repetirem.
- *Aplicar:* `adapters/claude-code.md`.

**E6. Routing de modelos por tarefa; o fan-out no tier caro é que esgota o orçamento.** Modelo forte
com esforço baixo bate modelo fraco com esforço máximo. As regras de custo evoluem com o orçamento e
versionam-se com o porquê.
- *Aplicar:* `core/model-routing.md`.

**E7. Subagentes morrem em suites longas ou ao ceder a um monitor; o controlador fecha-os
explicitamente.** Suites pesadas (WASM/BD-em-memória) em paralelo rebentam a máquina por OOM.
- *Aplicar:* `agents/10-quality/README.md`; `knowledge/ai-pitfalls.md` §14.

**E8. Postura de dono: sinalizar riscos ANTES de implementar; mudanças destrutivas/em massa com plano
+ lista.**
- *Aplicar:* `knowledge/permanent-rules.md` §1,§4.

---

## O que **não** generalizar (avisos)

- Nomes e regras específicas do domínio de origem (offboarding de 3 vias, escalões por valor,
  pool de SIMs) são **exemplos** da mecânica — generaliza-se o padrão (transação atómica, outbox,
  invariantes duplos, authority services), não o domínio.
- Escolhas concretas de stack (motor de BD leve em dev, combinação exata de bibliotecas, "numeric como
  string" para dinheiro) são trade-offs daquele projeto — o padrão interessa, a escolha decide-se caso
  a caso (`core/decision-engine.md`).
- Idiomatismos de framework (guards/decoradores de um framework específico) ilustram a *ideia* (duas
  camadas de autorização, política em BD), não a implementação a copiar.

## Relacionados

- `knowledge/permanent-rules.md` · `knowledge/proven-patterns.md` · `knowledge/ai-pitfalls.md`
- `modules/README.md` — os módulos que encapsulam estas lições.
- `core/project-memory.md` — como novas lições sobem de um projeto para aqui.
