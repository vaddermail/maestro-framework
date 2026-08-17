# Inventário da Framework Maestro

Manifesto completo de todos os ficheiros da framework, com uma linha por ficheiro.
**Regra:** todo o ficheiro de **conteúdo** da framework (`.md`, `.template`, `.sh`) está aqui; todo o caminho referenciado noutro documento existe aqui. Ficheiros de infraestrutura do repositório (`.github/`, `.gitignore`) vivem fora do inventário e do portão.
Ao adicionar/remover ficheiros (ver `playbooks/add-an-agent.md`), atualizar este inventário no mesmo passo.

## Raiz

- `README.md` — porta de entrada: o que é a framework, mapa de navegação, como se usa.
- `MANIFESTO.md` — filosofia e princípios inegociáveis do desenvolvimento assistido por IA.
- `START-HERE.md` — bootstrap de um projeto novo: instruções para o humano e para a primeira sessão de IA.
- `CONTRIBUTING.md` — how contributions flow: field reports up, curated releases down (the improvement circuit, adapted to open source).

## _meta/

- `_meta/INVENTORY.md` — este ficheiro.
- `_meta/STYLE-GUIDE.md` — convenções de escrita e formato de todos os documentos.
- `_meta/VERSION.md` — versão da framework e registo de alterações da própria framework.
- `_meta/verify.sh` — auto-verificação da consistência interna (inventário↔disco, referências cruzadas, secções das fichas, língua); o portão da própria framework.
- `_meta/DO-NOT-DISTRIBUTE` — lista de ficheiros só-da-mãe excluídos do ZIP de release (a alavanca de confidencialidade mãe→cópias).
- `_meta/verify-project.sh` — o portão do PROJETO: fundação, rasto das fases fechadas, memória fresca, génese, integridade da cópia.

## core/ — o sistema operativo

- `core/orchestrator.md` — o Orquestrador: quem chama quem, quando, dependências, aprovações, recuperação de falhas.
- `core/lifecycle.md` — as fases F0–F9 do produto, da ideia à evolução contínua, com portões entre fases.
- `core/artifact-protocol.md` — contrato de informação entre agentes: a árvore `product/`, formatos, donos, consumidores.
- `core/question-engine.md` — como se pergunta ao utilizador: lotes, contexto, opções com trade-offs, defaults, registo de respostas.
- `core/decision-engine.md` — como se decidem escolhas técnicas: matriz de critérios, árbitros, ADR obrigatório, decisões fechadas.
- `core/quality-gates.md` — gates entre fases: definição de pronto, quem valida, o que bloqueia, aprovação humana.
- `core/project-memory.md` — memória em ficheiros locais: STATE.md, decisões, registos; passagem de testemunho entre sessões/pessoas/ferramentas.
- `core/model-routing.md` — routing de modelos de IA por tarefa (camadas topo/padrão/económico/mecânico + esforço), custos sob controlo.
- `core/extensibility.md` — como adicionar agentes, módulos, workflows e loops sem alterar os existentes.
- `core/glossary.md` — termos da framework (agente, artefacto, portão, loop, guardião, árbitro, fase, ADR, …).

## agents/

- `agents/README.md` — índice global de agentes, tipos de agente, como ler uma ficha.
- `agents/_template/AGENT-TEMPLATE.md` — template canónico de agente (todas as secções obrigatórias).

### agents/00-discovery/ — da ideia ao âmbito

- `agents/00-discovery/README.md` — índice e ordem de trabalho da categoria.
- `agents/00-discovery/idea-analyst.md` — transforma a ideia bruta numa descrição estruturada e testável.
- `agents/00-discovery/problem-definer.md` — isola o problema real, o público e o custo de não resolver.
- `agents/00-discovery/stakeholder-mapper.md` — identifica stakeholders, papéis, poder/interesse e canais.
- `agents/00-discovery/persona-builder.md` — personas com objetivos, dores e contexto de utilização.
- `agents/00-discovery/use-case-modeler.md` — casos de utilização/jornadas de ponta a ponta.
- `agents/00-discovery/business-goals-analyst.md` — objetivos de negócio mensuráveis e restrições.
- `agents/00-discovery/kpi-definer.md` — KPIs e métricas de sucesso, baseline e alvos.
- `agents/00-discovery/roadmap-planner.md` — roadmap por horizontes, incluindo funcionalidades futuras.
- `agents/00-discovery/mvp-scoper.md` — corta o MVP mínimo demonstrável e o que fica de fora.
- `agents/00-discovery/risk-analyst.md` — riscos de negócio/técnicos/legais com mitigação e dono.
- `agents/00-discovery/cost-estimator.md` — ordem de grandeza de custos (construção, infra, IA, operação).
- `agents/00-discovery/prioritizer.md` — prioriza funcionalidades (valor × esforço × risco), resolve empates com o utilizador.

### agents/01-requirements/ — o quê, sem ambiguidade

- `agents/01-requirements/README.md` — índice e ordem de trabalho da categoria.
- `agents/01-requirements/requirements-engineer.md` — levanta e estrutura requisitos funcionais rastreáveis.
- `agents/01-requirements/ambiguity-hunter.md` — deteta ambiguidade/contradição/lacuna e abre o loop L01.
- `agents/01-requirements/acceptance-criteria-writer.md` — critérios de aceitação verificáveis por requisito.
- `agents/01-requirements/nfr-specifier.md` — RNF: desempenho, disponibilidade, segurança, conformidade.
- `agents/01-requirements/business-rules-modeler.md` — regras de negócio explícitas, invariantes e máquinas de estado.
- `agents/01-requirements/glossary-curator.md` — linguagem ubíqua do domínio, termos e sinónimos proibidos.

### agents/02-architecture/ — como se constrói

- `agents/02-architecture/README.md` — índice, ordem de trabalho e como o árbitro usa os especialistas.
- `agents/02-architecture/architecture-arbiter.md` — compara propostas dos especialistas e decide com ADR justificado.
- `agents/02-architecture/stack-selector.md` — escolhe tecnologias concretas (versões estáveis, LTS, lockfiles).
- `agents/02-architecture/monolith-specialist.md` — proposta e justificação de monólito clássico.
- `agents/02-architecture/modular-monolith-specialist.md` — monólito modular: fronteiras, módulos, quando escala.
- `agents/02-architecture/microservices-specialist.md` — microserviços: custos operacionais, quando se justifica.
- `agents/02-architecture/event-driven-specialist.md` — arquitetura orientada a eventos: brokers, garantias, idempotência.
- `agents/02-architecture/cqrs-specialist.md` — CQRS (com/sem event sourcing): quando compensa a complexidade.
- `agents/02-architecture/clean-architecture-specialist.md` — Clean Architecture: camadas, dependências, custos.
- `agents/02-architecture/hexagonal-specialist.md` — Ports & Adapters: isolamento do domínio e testabilidade.
- `agents/02-architecture/ddd-specialist.md` — DDD estratégico e tático: bounded contexts, agregados.
- `agents/02-architecture/vertical-slice-specialist.md` — vertical slices: organização por funcionalidade.
- `agents/02-architecture/serverless-specialist.md` — serverless/FaaS: custos, cold starts, lock-in.
- `agents/02-architecture/edge-computing-specialist.md` — edge: latência, dados na borda, restrições de runtime.

### agents/03-experience/ — UX e UI antes do código

- `agents/03-experience/README.md` — índice e ordem de trabalho da categoria.
- `agents/03-experience/ux-researcher.md` — fluxos, jornadas, arquitetura de informação; valida com personas.
- `agents/03-experience/wireframer.md` — wireframes de baixa fidelidade (texto/ASCII/descrição) por ecrã.
- `agents/03-experience/ui-designer.md` — direção visual, hierarquia, densidade; tema claro por defeito.
- `agents/03-experience/design-system-architect.md` — tokens centrais (cores, tipografia, espaçamento), nunca hardcoded.
- `agents/03-experience/component-architect.md` — inventário de componentes reutilizáveis e respetivos estados.
- `agents/03-experience/responsiveness-specialist.md` — layout real mobile-first (≈390px) e desktop; armadilhas de grid.
- `agents/03-experience/accessibility-specialist.md` — WCAG, teclado, contraste, leitores de ecrã.
- `agents/03-experience/web-performance-specialist.md` — LCP/CLS/INP/TTFB, orçamentos de performance.
- `agents/03-experience/seo-specialist.md` — SEO técnico: SSR/meta/sitemaps/dados estruturados (quando aplicável).
- `agents/03-experience/internationalization-specialist.md` — i18n/l10n: strings externas, formatos, RTL, pluralização.

### agents/04-frontend/ — engenharia do cliente

- `agents/04-frontend/README.md` — índice e ordem de trabalho da categoria.
- `agents/04-frontend/frontend-architect.md` — estrutura da app cliente: routing, camadas, convenções, SSOT de conteúdos.
- `agents/04-frontend/screen-implementer.md` — constrói ecrãs a partir de wireframes + design system, com tooltips e filtros.
- `agents/04-frontend/api-integrator.md` — cliente de API tipado, mocks espelhados (MSW ou equivalente), estados de erro.
- `agents/04-frontend/state-and-cache-specialist.md` — estado do cliente, cache, sincronização e invalidação.
- `agents/04-frontend/frontend-test-engineer.md` — testes de componentes/ecrãs e smoke E2E do cliente.

### agents/05-backend/ — engenharia do servidor

- `agents/05-backend/README.md` — índice e ordem de trabalho da categoria.
- `agents/05-backend/api-designer.md` — desenha o contrato da API (recursos, erros, paginação) e escolhe o estilo com o utilizador.
- `agents/05-backend/rest-specialist.md` — REST: recursos, verbos, códigos, HATEOAS pragmático, OpenAPI.
- `agents/05-backend/graphql-specialist.md` — GraphQL: schema, resolvers, N+1, autorização por campo.
- `agents/05-backend/grpc-specialist.md` — gRPC: protobuf, streaming, versionamento de mensagens.
- `agents/05-backend/authentication-specialist.md` — authn: OIDC/OAuth2, sessões vs tokens, MFA, contas de serviço.
- `agents/05-backend/authorization-specialist.md` — authz: RBAC/ABAC, scoping no servidor, cliente não-fiável.
- `agents/05-backend/caching-specialist.md` — caching por camadas, chaves, TTL, invalidação, estampede.
- `agents/05-backend/queue-specialist.md` — filas de trabalho: executor único, dedupe por fingerprint, retries, DLQ.
- `agents/05-backend/events-specialist.md` — eventos de domínio/integração: outbox, ordering, idempotência.
- `agents/05-backend/logging-specialist.md` — logging estruturado, níveis, correlação, sem segredos nos logs.
- `agents/05-backend/metrics-specialist.md` — métricas RED/USE, SLIs, cardinalidade sob controlo.
- `agents/05-backend/observability-architect.md` — traces + logs + métricas correlacionados; alertas acionáveis; custos de IA visíveis.
- `agents/05-backend/ai-features-specialist.md` — (AI Features Engineer) constrói funcionalidades LLM: grounding/RAG na fonte única, prompts versionados, evals, guardrails e fallback; aplica créditos e observabilidade de IA.
- `agents/05-backend/api-versioning-specialist.md` — versionamento e deprecação de APIs sem partir clientes.
- `agents/05-backend/scalability-architect.md` — escala horizontal/vertical, gargalos, backpressure, limites.

### agents/06-data/ — a verdade persistida

- `agents/06-data/README.md` — índice e ordem de trabalho da categoria.
- `agents/06-data/data-modeler.md` — modelo lógico agnóstico → físico; invariantes e relações bidirecionais coerentes.
- `agents/06-data/migration-engineer.md` — migrações expand-contract, sempre reversíveis, com plano de down.
- `agents/06-data/indexing-specialist.md` — índices por padrão de acesso; custo de escrita vs leitura.
- `agents/06-data/db-performance-optimizer.md` — planos de execução, queries lentas, particionamento.
- `agents/06-data/data-auditor.md` — trilhos de auditoria, proveniência, retenção e qualidade de dados.
- `agents/06-data/schema-versioning-manager.md` — versionamento do schema, seeds, ambientes sincronizados.
- `agents/06-data/backup-specialist.md` — backups automáticos, testes de restauro, RPO.
- `agents/06-data/disaster-recovery-planner.md` — DR: RTO/RPO, runbooks de recuperação, exercícios.

### agents/07-devops/ — do commit à produção

- `agents/07-devops/README.md` — índice e ordem de trabalho da categoria.
- `agents/07-devops/docker-specialist.md` — imagens mínimas, multi-stage, non-root, scanning.
- `agents/07-devops/kubernetes-specialist.md` — workloads, probes, limits, RBAC do cluster, quando NÃO usar k8s.
- `agents/07-devops/terraform-specialist.md` — IaC declarativa: estado, módulos, planos revistos antes de aplicar.
- `agents/07-devops/ansible-specialist.md` — configuração idempotente de servidores; inventários e vault.
- `agents/07-devops/github-specialist.md` — fluxo Git: branches, PRs, proteções, CODEOWNERS, releases por tags.
- `agents/07-devops/github-actions-specialist.md` — pipelines GitHub Actions: caching, matrizes, segredos, ambientes.
- `agents/07-devops/azure-devops-specialist.md` — Azure Pipelines/Boards/Repos: equivalências e especificidades.
- `agents/07-devops/gitlab-ci-specialist.md` — GitLab CI: stages, runners, environments, review apps.
- `agents/07-devops/cloudflare-specialist.md` — DNS, proxy, WAF, cache e Workers na Cloudflare.
- `agents/07-devops/nginx-specialist.md` — reverse proxy, TLS termination, rate limiting, headers.
- `agents/07-devops/apache-specialist.md` — httpd: vhosts, mod_security, quando preferir a nginx.
- `agents/07-devops/load-balancing-specialist.md` — balanceamento L4/L7, health checks, sticky sessions.
- `agents/07-devops/cdn-specialist.md` — CDN: cache de estáticos, invalidação, edge rules.
- `agents/07-devops/secrets-manager.md` — segredos fora do Git: vaults, rotação, injeção em runtime, varrimento.
- `agents/07-devops/deployment-strategist.md` — deploy/rollback, blue-green, canary; backup antes, hard-block contra infra errada.
- `agents/07-devops/feature-flags-specialist.md` — flags/kill-switches: mudanças de risco desligáveis sem deploy.

### agents/08-infrastructure/ — onde corre

- `agents/08-infrastructure/README.md` — índice e ordem de trabalho da categoria.
- `agents/08-infrastructure/hosting-arbiter.md` — decide cloud/on-prem/híbrido por custos, dados, equipa e conformidade.
- `agents/08-infrastructure/aws-specialist.md` — mapeamento das necessidades para serviços AWS, custos e armadilhas.
- `agents/08-infrastructure/azure-specialist.md` — idem para Microsoft Azure (incl. integração Entra ID).
- `agents/08-infrastructure/google-cloud-specialist.md` — idem para GCP.
- `agents/08-infrastructure/hetzner-specialist.md` — idem para Hetzner (custo/benefício europeu, dedicados).
- `agents/08-infrastructure/ovh-specialist.md` — idem para OVH.
- `agents/08-infrastructure/digitalocean-specialist.md` — idem para DigitalOcean (simplicidade primeiro).
- `agents/08-infrastructure/on-premises-specialist.md` — on-prem: VMs, hipervisores, redes internas, responsabilidade total.
- `agents/08-infrastructure/network-architect.md` — VPN, firewall, DNS, proxies, segmentação, exposição mínima.
- `agents/08-infrastructure/tls-ssl-specialist.md` — certificados, renovação automática, TLS moderno em todo o lado.
- `agents/08-infrastructure/storage-specialist.md` — blocos/objetos/ficheiros, ciclos de vida, encriptação em repouso.
- `agents/08-infrastructure/infra-backup-specialist.md` — backup de infra e configuração; restauro testado.
- `agents/08-infrastructure/high-availability-architect.md` — HA: redundância, failover, zonas, graceful degradation.

### agents/09-security/ — robustez em profundidade

- `agents/09-security/README.md` — índice, ordem de trabalho e mapa de cobertura (design → build → verify → operate).
- `agents/09-security/security-coordinator.md` — orquestra a segurança transversal às fases; dono do risco residual.
- `agents/09-security/threat-modeler.md` — threat modeling (STRIDE ou equivalente) por funcionalidade crítica.
- `agents/09-security/owasp-top10-specialist.md` — cobertura sistemática do OWASP Top 10 no design e na revisão.
- `agents/09-security/asvs-specialist.md` — verificação ASVS por nível (L1–L3) conforme o risco do produto.
- `agents/09-security/cis-benchmarks-specialist.md` — benchmarks CIS para SO, BD, cloud e containers.
- `agents/09-security/hardening-specialist.md` — hardening de servidores e serviços: superfícies mínimas.
- `agents/09-security/http-headers-specialist.md` — CSP, HSTS, frame-ancestors e restantes headers de segurança.
- `agents/09-security/tls-specialist.md` — política TLS: versões, cifras, mTLS onde se justifica.
- `agents/09-security/waf-specialist.md` — WAF: regras, tuning de falsos positivos, modo de bloqueio.
- `agents/09-security/privacy-specialist.md` — (Privacy & Data Protection Specialist) RGPD por desenho: mapa de dados pessoais, bases legais, DPIA, direitos dos titulares.
- `agents/09-security/ai-security-specialist.md` — (AI/LLM Security Specialist) segurança das funcionalidades LLM: prompt injection, output não-fiável, excessive agency, BYOK.
- `agents/09-security/secure-authentication-specialist.md` — revisão de authn: credenciais, sessões, MFA, recuperação de conta.
- `agents/09-security/authorization-and-least-privilege-specialist.md` — least privilege ponta a ponta: app, BD, cloud, CI.
- `agents/09-security/secrets-and-rotation-manager.md` — política de segredos: inventário, rotação de chaves, quebra de emergência.
- `agents/09-security/pentester.md` — testes de intrusão autorizados no próprio produto, com âmbito e relatório.
- `agents/09-security/supply-chain-specialist.md` — cadeia de fornecimento: lockfiles, proveniência, dependências confiáveis.
- `agents/09-security/sbom-manager.md` — SBOM gerado e mantido; base para resposta a CVEs.
- `agents/09-security/dependency-analyst.md` — dependency scan contínuo, triagem de vulnerabilidades.
- `agents/09-security/sast-specialist.md` — análise estática de código no CI, gestão de findings.
- `agents/09-security/dast-specialist.md` — análise dinâmica contra ambientes de teste.
- `agents/09-security/exposed-secrets-hunter.md` — secrets scan no histórico, CI e artefactos.
- `agents/09-security/container-analyst.md` — scan de imagens e runtime de containers.
- `agents/09-security/infrastructure-analyst.md` — scan de infra/cloud (config errada, exposições públicas).

### agents/10-quality/ — provar que funciona

- `agents/10-quality/README.md` — índice e ordem de trabalho da categoria.
- `agents/10-quality/test-strategist.md` — pirâmide/estratégia de testes focada na lógica de risco; fakes para I/O externo.
- `agents/10-quality/unit-test-engineer.md` — testes unitários das regras de negócio e invariantes.
- `agents/10-quality/integration-test-engineer.md` — integração: BD real, contratos, transações.
- `agents/10-quality/e2e-test-engineer.md` — E2E multi-perfil × páginas + fluxos críticos; smoke live no fim.
- `agents/10-quality/performance-test-engineer.md` — carga, stress, perfis de tráfego, limites conhecidos.
- `agents/10-quality/regression-test-engineer.md` — harness de regressão automatizado e atualizado a cada fluxo novo.
- `agents/10-quality/coverage-auditor.md` — cobertura orientada ao risco (não à percentagem cega) e buracos de teste.

### agents/11-documentation/ — conhecimento vivo

- `agents/11-documentation/README.md` — índice e ordem de trabalho da categoria.
- `agents/11-documentation/documentation-architect.md` — estrutura documental do projeto (specs, ADRs, runbooks, ajuda) e fontes de verdade.
- `agents/11-documentation/technical-writer.md` — escreve/atualiza documentação técnica sincronizada com o código.
- `agents/11-documentation/user-help-writer.md` — menu de Ajuda completo com exemplos, fonte única (ecrã + grounding de IA).
- `agents/11-documentation/api-documenter.md` — referência de API gerada do contrato (OpenAPI/schema), sempre atual.

### agents/12-reviewers/ — olhos independentes

- `agents/12-reviewers/README.md` — índice: como se monta um painel de revisão e o formato do relatório.
- `agents/12-reviewers/architecture-reviewer.md` — revê aderência à arquitetura decidida e fronteiras entre módulos.
- `agents/12-reviewers/frontend-reviewer.md` — revê código/UX do cliente: SSOT de conteúdos, tokens, estados, erros.
- `agents/12-reviewers/backend-reviewer.md` — revê servidor: autorização, transações, integridade, contratos.
- `agents/12-reviewers/ux-reviewer.md` — revê fluxos reais contra personas e casos de utilização.
- `agents/12-reviewers/devops-reviewer.md` — revê pipelines, deploys, rollback e segredos.
- `agents/12-reviewers/performance-reviewer.md` — revê orçamentos de performance, queries e caching.
- `agents/12-reviewers/security-reviewer.md` — revê contra threat model, OWASP e least privilege.
- `agents/12-reviewers/documentation-reviewer.md` — revê sincronia docs↔código e completude da ajuda.
- `agents/12-reviewers/test-reviewer.md` — revê a estratégia e a substância dos testes (não só a existência).
- `agents/12-reviewers/review-consolidator.md` — funde os relatórios num plano único priorizado, sem duplicados nem contradições.

### agents/13-guardians/ — a equipa permanente de produção

- `agents/13-guardians/README.md` — índice: cadências, deveres comuns e relatórios dos guardiões.
- `agents/13-guardians/security-guardian.md` — (Security Guardian) monitoriza CVEs/deps/containers/SO/cloud; analisa impacto → plano → patch → testes → validação → documentação.
- `agents/13-guardians/dependency-guardian.md` — (Dependency Guardian) atualização contínua e deliberada de dependências.
- `agents/13-guardians/performance-guardian.md` — (Performance Guardian) CPU, RAM, queries, APIs, cache, LCP/CLS/TTFB.
- `agents/13-guardians/cost-guardian.md` — (Cost Guardian) custos de infra, APIs e IA; sugere otimizações com evidência.
- `agents/13-guardians/quality-guardian.md` — (Quality Guardian) code smells, duplicação, complexidade, cobertura, arquitetura.
- `agents/13-guardians/documentation-guardian.md` — (Documentation Guardian) mantém documentação sincronizada com o produto.
- `agents/13-guardians/backup-guardian.md` — (Backup Guardian) verifica backups e exercita restauros periodicamente.
- `agents/13-guardians/value-guardian.md` — (Value Guardian) verifica em produção, KPI a KPI, se o valor prometido na descoberta aconteceu; escala alvos falhados como decisão de produto.
- `agents/13-guardians/feature-evolution-agent.md` — (Feature Evolution Agent) recebe pedidos futuros: impacto → arquitetura → docs → implementação → testes → pipelines.

### agents/14-meta/ — a framework a trabalhar sobre si própria

- `agents/14-meta/README.md` — índice: a categoria fora do ciclo dos projetos; atua no repositório-mãe.
- `agents/14-meta/framework-curator.md` — (Framework Curator) tria os reportes de melhorias dos projetos, gere candidatas e propõe promoções por PR — nunca commit direto.

## workflows/ — processos que ligam agentes

- `workflows/README.md` — como se lê/executa um workflow; convenções; relação com fases e portões.
- `workflows/W00-project-kickoff.md` — F0: copiar a framework, instanciar memória, protocolo de arranque de sessão.
- `workflows/W01-discovery.md` — F1: da ideia bruta ao dossier de descoberta aprovado.
- `workflows/W02-requirements.md` — F2: requisitos, RNF, regras de negócio e glossário sem ambiguidades.
- `workflows/W03-architecture.md` — F3: propostas em painel, arbitragem, ADRs, stack fixada.
- `workflows/W04-experience.md` — F4: UX → wireframes → design system → mapa de ecrãs aprovado.
- `workflows/W05-specification.md` — F5: especificação funcional canónica (regras, fluxos, máquinas de estado, modelo de dados lógico, contrato backend).
- `workflows/W06-build.md` — F6: construção em fatias verticais (dados → backend → frontend) com testes contínuos.
- `workflows/W07-quality-and-security.md` — F7: painel de revisores + auditoria adversarial + pentest antes do lançamento.
- `workflows/W08-launch.md` — F8: infra, pipelines, go-live com rollback pronto.
- `workflows/W09-continuous-operation.md` — F9: guardiões em cadência, loops de manutenção, relatórios.
- `workflows/W10-feature-evolution.md` — pedido novo em produção: impacto → decisão → especificação → implementação → release.
- `workflows/W11-incident-response.md` — incidente: triagem, mitigação, comunicação, post-mortem sem culpados.
- `workflows/W12-global-review.md` — revisão multidisciplinar completa sob pedido (painel + consolidação).

## loops/ — persistência inteligente

- `loops/README.md` — o motor de loops: condição de entrada, ação, condição de saída, salvaguardas anti-loop-infinito, registo.
- `loops/L01-ambiguous-requirements.md` — enquanto existirem requisitos ambíguos → perguntar ao utilizador (em lotes).
- `loops/L02-failing-tests.md` — enquanto existirem testes falhados → corrigir a causa (nunca o teste, salvo teste errado provado).
- `loops/L03-security-issues.md` — enquanto existirem problemas de segurança → resolver por severidade.
- `loops/L04-code-smells.md` — enquanto existirem code smells acima do limiar → melhorar sem mudar comportamento.
- `loops/L05-inconsistencies.md` — enquanto existirem inconsistências (docs↔código↔dados) → reconciliar com fonte de verdade.
- `loops/L06-outdated-documentation.md` — enquanto existir documentação desatualizada → atualizar da fonte.
- `loops/L07-cves.md` — enquanto existirem CVEs por triar → analisar impacto e tratar (liga ao Security Guardian).
- `loops/L08-technical-debt.md` — enquanto existir dívida técnica registada → reduzir de forma planeada e reversível.

## modules/ — capacidades reutilizáveis destiladas do projeto-mãe

- `modules/README.md` — o que é um módulo, como se adota num produto, princípio do desacoplamento.
- `modules/credit-management.md` — ledger genérico de créditos: contas, movimentos, tarifas, quotas, kill-switch; para IA, APIs, ferramentas, por utilizador/organização.
- `modules/approval-engine.md` — aprovações por escalão configurável (valor/risco), gate de validação de necessidade separado.
- `modules/state-machines.md` — fluxos críticos como máquinas de estado explícitas: estados, transições, efeitos, quem pode.
- `modules/rbac-and-scoping.md` — perfis, âmbitos por unidade organizacional, aplicação no servidor, cliente não-fiável.
- `modules/audit-and-provenance.md` — trilho de auditoria imutável; proveniência de dados tocados por IA com undo.
- `modules/job-queue.md` — fila com executor único: submissão múltipla, dedupe por fingerprint, retries, visibilidade.
- `modules/feature-flags.md` — flags e kill-switches: mudanças de risco desligáveis sem deploy; higiene de flags.
- `modules/single-source-of-content.md` — SSOT de labels/descrições/ajuda: um ficheiro fonte serve UI, tooltips e grounding de IA.
- `modules/ai-observability.md` — consumo de IA contabilizado (tokens, custo, por funcionalidade/modelo/utilizador), alertas, kill-switch por modelo.
- `modules/readonly-external-integrations.md` — sistemas externos como contrato assumido: read-only, sincronização, campos geridos fora.
- `modules/entity-lifecycle.md` — onboarding/offboarding de entidades com libertação transacional de todos os recursos associados.

## templates/ — documentos prontos a instanciar

- `templates/README.md` — como instanciar templates; convenção de placeholders `{{assim}}`.
- `templates/project/CLAUDE.md.template` — instruções de projeto para agentes de IA (regras estáveis do produto novo).
- `templates/project/STATE.md.template` — memória viva partilhada: feito, em curso, a seguir, decisões pendentes, registo de lições.
- `templates/project/ADR-DECISION.md.template` — registo de decisão de arquitetura (contexto, opções, decisão, consequências, reversão).
- `templates/project/CHANGELOG.md.template` — histórico do que mudou e porquê, por versão.
- `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` — registo acumulado, desde o dia 0, do que o projeto ensina à framework; enviado à mãe nos fechos de fase.
- `templates/project/GENESIS.md.template` — dossier de génese: os números da promessa por fase; o Fecho alimenta a curva do ecossistema.
- `templates/discovery/idea.md.template` — descrição estruturada da ideia.
- `templates/discovery/problem.md.template` — definição do problema e custo de não resolver.
- `templates/discovery/stakeholders.md.template` — mapa de stakeholders.
- `templates/discovery/persona.md.template` — persona individual.
- `templates/discovery/use-case.md.template` — caso de utilização/jornada.
- `templates/discovery/goals-and-kpis.md.template` — objetivos de negócio e KPIs.
- `templates/discovery/risks.md.template` — registo de riscos com dono e mitigação.
- `templates/discovery/roadmap.md.template` — roadmap por horizontes.
- `templates/discovery/mvp.md.template` — âmbito do MVP e cortes explícitos.
- `templates/specification/functional-requirement.md.template` — requisito com critérios de aceitação.
- `templates/specification/business-rules.md.template` — regras e invariantes de um módulo.
- `templates/specification/state-machine.md.template` — máquina de estados de um fluxo crítico.
- `templates/specification/logical-data-model.md.template` — entidades, relações e invariantes, agnóstico de BD.
- `templates/specification/backend-contract.md.template` — responsabilidades do servidor: authz, scoping, integridade, campos sensíveis.
- `templates/technical/threat-model.md.template` — modelo de ameaças de uma funcionalidade/sistema.
- `templates/technical/test-plan.md.template` — plano de testes orientado ao risco.
- `templates/technical/runbook.md.template` — runbook operacional de um procedimento.
- `templates/technical/migration-plan.md.template` — migração expand-contract com plano de reversão.
- `templates/technical/post-mortem.md.template` — post-mortem sem culpados, com ações e donos.
- `templates/technical/review-report.md.template` — relatório de um revisor (formato comum ao painel).
- `templates/technical/guardian-report.md.template` — relatório periódico de um guardião.

## checklists/ — verificação objetiva

- `checklists/README.md` — como se usam as checklists nos portões e nos loops.
- `checklists/definition-of-done.md` — definição de pronto por fase (F1–F9) e por alteração de código.
- `checklists/pre-merge.md` — antes de integrar: lint, testes (front e back), revisão, sem segredos, reversível.
- `checklists/pre-production-security.md` — gate de segurança do go-live (headers, TLS, segredos, scans, least privilege).
- `checklists/accessibility.md` — verificação WCAG prática por ecrã.
- `checklists/web-performance.md` — orçamentos e medições reais em viewport pequeno e grande.
- `checklists/go-live.md` — lançamento: backups, rollback ensaiado, monitorização, donos contactáveis.
- `checklists/post-incident.md` — depois de um incidente: post-mortem, ações, prevenção verificada.
- `checklists/pr-review.md` — revisão de código: correção, regras de negócio, testes, reversibilidade.

## playbooks/ — procedimentos passo-a-passo

- `playbooks/README.md` — o que é um playbook e quando se executa.
- `playbooks/cve-response.md` — da notificação do CVE ao patch validado e documentado.
- `playbooks/dependency-updates.md` — atualização deliberada: changelog, testes, lockfile, nunca à deriva.
- `playbooks/release-and-rollback.md` — release com backup prévio, verificação e reversão ensaiada.
- `playbooks/expand-contract-db-migration.md` — migração aditiva → migrar dados/código → contrair; nunca partir o que está em uso.
- `playbooks/secrets-management.md` — segredos fora do Git, por caminho de ficheiro, rotação e resposta a fuga.
- `playbooks/developer-onboarding.md` — novo interveniente operacional com um comando (setup + protocolo de arranque).
- `playbooks/add-an-agent.md` — estender a framework: template → ficha → índices → inventário, sem tocar nos existentes.
- `playbooks/adversarial-audit.md` — auditoria extensa, adversarial e multidisciplinar com verificação independente das conclusões.
- `playbooks/sync-framework.md` — trazer a cópia da framework de um projeto para uma versão mais recente, deliberadamente e com reversão.
- `playbooks/report-framework-improvements.md` — o lado do projeto no circuito de aprendizagem: consolidar o reporte de melhorias e enviá-lo à mãe como issue, sanitizado.
- `playbooks/framework-curation.md` — o lado da mãe: triar reportes, gerir candidatas e propor promoções por PR com merge humano.
- `playbooks/demo-data.md` — dados de demonstração como código: idempotentes, sem PII real, envio externo nulo, smoke test em CI, separados dos reais.
- `playbooks/large-scale-mechanical-migration.md` — varredura mecânica de muitos ficheiros/call-sites sem partir o ramo: guarda primeiro, gates verdes ao longo, idempotente.

## pipelines/ — automação de referência

- `pipelines/README.md` — princípios: CI separado por app, tudo verde antes de merge, pipelines como código.
- `pipelines/ci-quality.md` — pipeline de qualidade: lint, typecheck, testes front/back separados, artefactos.
- `pipelines/ci-security.md` — pipeline de segurança: SAST, secrets scan, dependency scan, container scan, SBOM, DAST agendado.
- `pipelines/cd-delivery.md` — pipeline de entrega: ambientes, aprovações, blue-green/canary, rollback automático.

## knowledge/ — a experiência destilada

- `knowledge/README.md` — como o conhecimento se acumula e volta a alimentar os agentes.
- `knowledge/origin-lessons.md` — lições generalizadas do projeto-mãe: o que se provou, com o porquê e o como aplicar.
- `knowledge/ai-pitfalls.md` — armadilhas típicas do desenvolvimento assistido por IA e como a framework as bloqueia.
- `knowledge/permanent-rules.md` — regras permanentes de trabalho (postura de dono, honestidade, reversibilidade, mudanças em massa, versões estáveis).
- `knowledge/proven-patterns.md` — padrões de arquitetura/operacão validados em produção (fila única, upsert por ID, SSOT, fallbacks visíveis).
- `knowledge/candidates.md` — a sala de espera: lições de um só projeto à espera de segunda confirmação, com contagem e estados terminais.
- `knowledge/learning-curve.md` — a curva do ecossistema: uma linha de números por produto (por código), agregada pela curadoria no fecho de F8.

## adapters/ — ligação a ferramentas concretas

- `adapters/README.md` — a framework é agnóstica de ferramenta; o acoplamento vive aqui.
- `adapters/claude-code.md` — mapear agentes→subagents/skills/workflows, memória→CLAUDE.md/STATE.md, toolset versionado no repo.
- `adapters/other-assistants.md` — princípios de adaptação a outros assistentes (Cursor, Copilot, Codex, aider, …).

## starters/ — o arranque executável

- `starters/README.md` — o contrato do starter (fatia 0 verde no dia 0), agnóstico de stack; implementações opcionais em starters/starter-<stack>/, nascidas de projetos reais via curadoria.
