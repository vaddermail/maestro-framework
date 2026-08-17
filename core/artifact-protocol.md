# Protocolo de Artefactos

O contrato de informação entre agentes. Os agentes não colaboram por conversa — colaboram por
**artefactos**: ficheiros com dono, localização, estado e consumidores conhecidos. Este protocolo é
o que permite trocar de ferramenta, de modelo ou de pessoa sem perder nada.

## Princípios

1. **Output que não fica escrito não existe.** Todo o resultado de agente vive num ficheiro da
   árvore `product/` (ou no código). A conversa é efémera; o artefacto é a verdade.
2. **Um artefacto, um dono de cada vez.** O dono é o agente que o escreve/atualiza; todos os outros
   leem. Mudar de dono é explícito (regista-se no cabeçalho do artefacto).
3. **Estados explícitos.** Todo o artefacto declara o seu estado no cabeçalho:
   `rascunho` → `em-revisao` → `aprovado` (→ `obsoleto`, quando substituído — nunca se apaga, marca-se).
   Agentes a jusante só consomem `aprovado`, salvo indicação do Orquestrador.
4. **Rastreabilidade em cadeia:** ideia → descoberta → requisito (`RF-nnn`) → regra de negócio
   (`RN-nnn`) → especificação de módulo → código → teste. Cada artefacto referencia os IDs a montante
   que satisfaz. Um requisito sem teste é detetável; um teste sem requisito também.
5. **Formato:** Markdown, com cabeçalho-padrão (abaixo). Diagramas em texto (Mermaid/ASCII) para
   serem versionáveis e legíveis por agentes.

## Cabeçalho-padrão de artefacto

```markdown
# {{Título}}

> **Estado:** rascunho | em-revisao | aprovado | obsoleto
> **Dono:** agents/NN-categoria/nome-do-agente.md
> **Fase:** F1 | … | F9 · **Atualizado:** AAAA-MM-DD
> **Satisfaz:** RF-012, RN-003 (IDs a montante, quando aplicável)
> **Consumidores:** (agents/fases que dependem deste artefacto)
```

## A árvore `product/` do projeto

Criada em F0 (`workflows/W00-project-kickoff.md`) na raiz do projeto novo:

```
<projeto>/
├── CLAUDE.md                       ← instruções estáveis para agentes (templates/project/CLAUDE.md.template)
├── STATE.md                       ← memória viva (core/project-memory.md)
├── Maestro/                   ← a framework (referência, read-only durante o projeto)
├── product/
│   ├── 00-descoberta/
│   │   ├── ideia.md                ← analista-da-ideia
│   │   ├── problema.md             ← definidor-do-problema
│   │   ├── stakeholders.md         ← mapeador-de-stakeholders
│   │   ├── personas/               ← construtor-de-personas (um ficheiro por persona)
│   │   ├── casos-de-utilizacao/    ← modelador-de-casos-de-utilizacao (um por caso, CU-nnn)
│   │   ├── objetivos-e-kpis.md     ← analista-de-objetivos-de-negocio + definidor-de-kpis
│   │   ├── riscos.md               ← analista-de-riscos (R-nnn)
│   │   ├── custos.md               ← estimador-de-custos
│   │   ├── roadmap.md              ← planeador-de-roadmap
│   │   ├── mvp.md                  ← delimitador-de-mvp
│   │   └── priorizacao.md          ← priorizador
│   ├── 01-requisitos/
│   │   ├── requisitos-funcionais.md      ← engenheiro-de-requisitos (RF-nnn)
│   │   ├── rnf.md                        ← especificador-de-requisitos-nao-funcionais (RNF-nnn)
│   │   ├── regras-de-negocio.md          ← modelador-de-regras-de-negocio (RN-nnn)
│   │   ├── criterios-de-aceitacao.md     ← redator-de-criterios-de-aceitacao (CA por RF)
│   │   ├── glossario.md                  ← curador-do-glossario
│   │   └── perguntas-e-respostas.md      ← motor de perguntas (histórico Q&A com o utilizador)
│   ├── 02-arquitetura/
│   │   ├── visao-arquitetural.md   ← arbitro-de-arquitetura (estilo escolhido + porquê)
│   │   ├── propostas/              ← propostas às cegas dos especialistas de estilo (uma por especialista)
│   │   ├── decisoes/               ← ADR-nnn-titulo.md (motor-de-decisao; nunca se apagam) — a ÚNICA casa dos ADRs
│   │   ├── stack.md                ← selecionador-de-stack (tecnologias + versões fixadas)
│   │   └── integracoes.md          ← contratos com sistemas externos (modules/readonly-external-integrations.md)
│   ├── 03-experiencia/
│   │   ├── fluxos-e-jornadas.md    ← investigador-de-ux
│   │   ├── wireframes/             ← wireframer (um por ecrã/fluxo)
│   │   ├── direcao-visual.md       ← designer-de-ui
│   │   ├── design-system.md        ← arquiteto-de-design-system (tokens)
│   │   ├── componentes.md          ← arquiteto-de-componentes
│   │   ├── mapa-de-ecras.md        ← investigador-de-ux + designer-de-ui
│   │   ├── acessibilidade.md       ← especialista-de-acessibilidade
│   │   ├── responsividade.md       ← especialista-de-responsividade
│   │   ├── performance-web.md      ← especialista-de-performance-web (orçamentos por rota)
│   │   ├── seo.md                  ← especialista-de-seo (quando aplicável)
│   │   └── internacionalizacao.md  ← especialista-de-internacionalizacao (quando aplicável)
│   ├── 04-especificacao/           ← a fonte de verdade funcional (sobrevive ao código)
│   │   ├── README.md               ← índice dos módulos especificados
│   │   ├── modules/<modulo>.md     ← spec por módulo: regras, fluxos, estados, permissões
│   │   ├── maquinas-de-estado.md   ← fluxos críticos como estados/transições/efeitos
│   │   ├── modelo-de-dados-logico.md ← modelador-de-dados (agnóstico de BD)
│   │   ├── contrato-backend.md     ← desenhador-de-apis (authz/scoping/integridade no servidor)
│   │   ├── contrato-api.md         ← desenhador-de-apis + especialistas REST/GraphQL/gRPC (a API exposta)
│   │   ├── api/                    ← especificações de endpoints por módulo (quando o detalhe o exigir)
│   │   ├── backend/                ← engenharia do servidor: logging.md, eventos.md, filas.md, observabilidade.md, metricas.md, escalabilidade.md, versionamento-api.md (← agents/05-backend)
│   │   └── frontend/               ← engenharia do cliente: convencoes-frontend.md e afins (← agents/04-frontend)
│   ├── 05-seguranca/
│   │   ├── perfil-de-risco.md      ← coordenador-de-seguranca (F1; calibra o esforço da dimensão)
│   │   ├── threat-model.md         ← modelador-de-ameacas
│   │   ├── requisitos-asvs.md      ← especialista-asvs (nível escolhido + verificações)
│   │   ├── owasp-top10.md          ← especialista-owasp-top10 (vereditos por categoria)
│   │   ├── mapa-de-dados-pessoais.md ← especialista-de-privacidade (registo de tratamentos + bases legais)
│   │   ├── dpia.md                 ← especialista-de-privacidade (quando os gatilhos disparam)
│   │   ├── direitos-dos-titulares.md ← especialista-de-privacidade (fluxos com prazos, testáveis)
│   │   ├── seguranca-de-ia.md      ← especialista-de-seguranca-de-ia (fronteiras de confiança e guardrails das funcionalidades LLM)
│   │   ├── (políticas e estados)   ← politica-tls.md · politica-waf.md · least-privilege.md · supply-chain.md · dependencias.md · inventario-de-segredos.md · segredos-expostos.md · sast-findings.md · infraestrutura.md (← especialistas de 09-seguranca)
│   │   └── risco-residual.md       ← coordenador-de-seguranca (aceites pelo utilizador)
│   ├── 06-testes/
│   │   ├── estrategia-de-testes.md ← estratega-de-testes (escrita antes da fatia 0 — W06 §Pré-condições)
│   │   ├── plano-de-testes.md      ← plano orientado ao risco (liga RF/RN → testes)
│   │   └── planos-de-teste/        ← planos por fatia/módulo, quando um só ficheiro não chega
│   ├── 07-operacao/
│   │   ├── runbooks/               ← um por procedimento operacional (inclui os dos especialistas de devops)
│   │   ├── slos.md                 ← objetivos de serviço + alertas
│   │   ├── observabilidade.md      ← o que se mede e onde se vê (inclui custos de IA)
│   │   ├── plano-dr.md             ← disaster recovery (RTO/RPO + exercícios)
│   │   ├── fluxo-git.md            ← especialista-github (branches, proteções, releases)
│   │   ├── imagem-container.md     ← especialista-docker
│   │   ├── pipelines-github.md / pipelines-azure.md / pipelines-gitlab.md ← um, conforme a plataforma escolhida
│   │   ├── ansible.md / kubernetes.md ← quando a decisão de infra os convocar
│   │   ├── segredos/               ← gestor-de-segredos (inventário e rotação; nunca valores)
│   │   ├── flags/                  ← catálogo de feature flags (especialista-de-feature-flags)
│   │   ├── dados/                  ← engenharia de dados em operação: backups.md, disaster-recovery.md, migracoes/, seeds/, indices/, retencao.md, ambientes.md, qualidade.md, desempenho/, auditoria.md (← agents/06-dados)
│   │   ├── infra/                  ← desenho e propostas de infraestrutura: propostas de alojamento (aws.md, azure.md, …), rede.md, dns.md, vpn.md, storage.md, certificados.md, iac/, runbooks/, … (← agents/08-infraestrutura)
│   │   └── (borda, conforme a infra) ← proxy/ · cdn/ · borda/ · balanceamento/ · deploy/ (← especialistas respetivos)
│   ├── 08-documentacao/            ← conhecimento vivo do produto (agents/11-documentacao)
│   │   ├── mapa-de-documentacao.md ← fonte única do que existe, onde vive e quando foi revisto
│   │   └── (ajuda, referência de API, guias — conforme o produto)
│   └── 99-registos/                ← histórico auditável
│       ├── revisoes/               ← relatórios de revisores + consolidação (por data)
│       ├── auditorias/             ← auditorias adversariais
│       ├── guardioes/              ← relatórios periódicos dos guardiões (F9)
│       ├── evolucoes/              ← um registo por evolução de feature (workflows/W10-feature-evolution.md)
│       ├── incidentes/             ← registo de incidente + post-mortem sem culpados (workflows/W11-incident-response.md)
│       ├── genese.md               ← dossier de génese: os números da promessa, fase a fase (templates/project/GENESIS.md.template)
│       └── decisoes-pendentes.md   ← Orquestrador: espelho das pendências (fonte: STATE.md; sincroniza-se no fecho de cada fase; opcional em perfis leves)
└── (código conforme a arquitetura: apps/, packages/, infra/, …)
```

> **Escala ao perfil de esforço:** num protótipo, várias subpastas colapsam num único ficheiro por
> fase (ex.: `product/00-discovery/dossier.md`). A estrutura acima é o máximo, não o mínimo — mas os
> **nomes e IDs** mantêm-se, para a rastreabilidade não se perder quando o projeto crescer.

## Fluxo entre fases (quem produz → quem consome)

| Artefacto | Produzido em | Consumido por |
| --- | --- | --- |
| Dossier de descoberta | F1 | Todos os agentes de F2–F4; `estimador-de-custos` realimenta F3/F8 |
| Requisitos + regras + critérios | F2 | Arquitetura (F3), Especificação (F5), Testes (F6/F7), Revisores |
| ADRs + stack | F3 | Construção (F6), DevOps/Infra (F8), Guardiões (F9) |
| Wireframes + design system | F4 | Frontend (F6), revisor-de-ux (F7) |
| Especificação funcional | F5 | **Tudo** a jusante — é a fonte de verdade; divergência → spec ganha |
| Threat model | F5/F7 | Backend, DevOps, Pentester, Security Guardian |
| Código + testes | F6 | Revisores (F7), Pipelines (F8), Guardiões (F9) |
| Runbooks + SLOs | F8 | Operação (F9), resposta a incidentes (W11) |
| Relatórios de guardiões | F9 | Orquestrador → utilizador; realimentam loops e evolução (W10) |

## Regras de manuseamento

1. **Nunca apagar artefactos aprovados** — marcam-se `obsoleto` com apontador para o substituto.
   (Reversibilidade por defeito; o histórico é parte do produto.)
2. **Atualizar é do dono.** Outro agente que precise de mudança num artefacto alheio pede-a ao
   Orquestrador — não edita por cima.
3. **IDs são eternos:** `RF-012` nunca se reutiliza para outro requisito, mesmo que o original morra.
4. **Divergência código↔spec:** a spec ganha. Se o código está certo e a spec errada, atualiza-se a
   spec **primeiro** (com aprovação) e depois o código-referência. Regista-se em `STATE.md`.
5. **Nada de segredos em artefactos** — segredos vivem fora do controlo de versões
   (`playbooks/secrets-management.md`); artefactos referem-nos por caminho, nunca por valor.

## Relacionados

- `core/project-memory.md` — STATE.md e a passagem de testemunho.
- `core/orchestrator.md` — quem faz cumprir este protocolo.
- `templates/README.md` — templates que instanciam estes artefactos.
- `core/quality-gates.md` — estados exigidos em cada portão.
