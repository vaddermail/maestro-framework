# Glossário da Framework

Termos com significado preciso dentro da Maestro. Em caso de dúvida noutro documento, vale a
definição daqui.

| Termo | Definição |
| --- | --- |
| **Agente** | Um papel especializado de IA com uma única responsabilidade, definido por uma ficha (`agents/_template/AGENT-TEMPLATE.md`): objetivo, inputs, outputs, regras, limitações, workflow, exemplos, boas práticas, anti-padrões. |
| **Ficha (de agente)** | O documento que define um agente. A ficha é o agente — não há comportamento fora dela. |
| **Orquestrador** | O papel que a sessão principal assume para coordenar agentes, fases e portões (`core/orchestrator.md`). |
| **Árbitro** | Agente que decide entre propostas independentes de especialistas, contra critérios explícitos, produzindo um ADR (`core/decision-engine.md`). Nunca é um dos proponentes. |
| **Revisor** | Agente que examina trabalho alheio numa dimensão (segurança, UX, …) e produz um relatório. Quem produz nunca revê o próprio trabalho. |
| **Guardião** | Agente de operação contínua (F9) com cadência própria: monitoriza uma dimensão do produto em produção e propõe/executa correções (`agents/13-guardians/`). |
| **Coordenador** | Agente transversal que acompanha uma dimensão ao longo de várias fases (ex.: `agents/09-security/security-coordinator.md`). |
| **Artefacto** | Ficheiro com dono, estado e consumidores, produzido por um agente na árvore `product/` (`core/artifact-protocol.md`). A unidade de colaboração. |
| **Fase (F0–F9)** | Etapa do ciclo de vida do produto (`core/lifecycle.md`). |
| **Portão (de qualidade)** | Decisão binária e verificável que guarda uma transição; com critérios, verificador e aprovador definidos (`core/quality-gates.md`). |
| **Workflow (Wnn)** | Processo documentado que liga agentes e artefactos para cumprir uma fase ou um processo transversal (`workflows/`). |
| **Loop (Lnn)** | Ciclo "enquanto condição → agir", com condição de saída e salvaguarda anti-infinito (`loops/`). |
| **Módulo** | Capacidade de produto reutilizável e desacoplada, documentada de forma agnóstica de stack (`modules/`). |
| **Playbook** | Procedimento operacional passo-a-passo para uma situação concreta (`playbooks/`). |
| **Checklist** | Lista de critérios verificáveis usada em portões e revisões (`checklists/`). |
| **Template** | Documento pronto a instanciar num projeto, com placeholders `{{assim}}` (`templates/`). |
| **ADR** | Architecture Decision Record — registo de decisão estrutural: contexto, opções, decisão, consequências, reversão (`core/decision-engine.md`). |
| **Decisão fechada** | Decisão validada pelo utilizador que os agentes não reabrem sem novidade material — e nunca em silêncio. |
| **Decisão pendente** | Pergunta à espera do utilizador, registada em `STATE.md` com o que bloqueia. |
| **Perfil de esforço** | Calibração do processo ao tamanho/risco do projeto (protótipo → plataforma empresarial); dimensiona portões, nunca os elimina (`core/orchestrator.md`). |
| **Dossier** | Conjunto de artefactos de uma fase (ex.: dossier de descoberta = `product/00-discovery/`). |
| **Fatia vertical** | Unidade de construção em F6: uma funcionalidade completa (dados → backend → frontend → testes) entregue de ponta a ponta. |
| **Fonte de verdade (SSOT)** | O único lugar onde um facto se edita; tudo o resto deriva. Aplica-se a dados, labels, contratos e documentação. |
| **Invariante** | Propriedade do domínio que nunca pode ser violada (ex.: "um ativo, um responsável"); catalogada na spec e imposta no servidor/BD. |
| **Máquina de estados** | Modelação explícita de um ciclo de vida: estados, transições permitidas, efeitos; transições inválidas são rejeitadas no servidor (`modules/state-machines.md`). |
| **Expand-contract** | Estratégia de migração reversível: primeiro adicionar (expand), migrar dados/código, só depois remover o antigo (contract) (`playbooks/expand-contract-db-migration.md`). |
| **Kill-switch** | Interruptor para desligar uma funcionalidade/modelo/integração sem deploy; a mesma primitiva corta risco e corta custo (`modules/feature-flags.md`). |
| **Auditoria adversarial** | Verificação independente que tenta ativamente refutar as conclusões, em vez de as confirmar (`playbooks/adversarial-audit.md`). |
| **Prova live** | Verificação no sistema real a correr (não só testes verdes) — gate insubstituível antes de declarar "funciona". |
| **Proveniência** | Registo da origem de uma regra/dado (que defeito/decisão/fonte o criou); obrigatória em dados tocados por IA. |
| **Camada de modelo** | Nível de capacidade/custo de modelo de IA (topo/padrão/económico/mecânico) atribuído por tarefa (`core/model-routing.md`). |
| **Esforço (effort)** | Segundo eixo de custo de IA, ortogonal ao modelo: quanto raciocínio se pede por tarefa. |
| **Grounding** | Dar a uma IA a fonte de verdade (ajuda, specs) como base factual das respostas, em vez de deixá-la inventar (`modules/single-source-of-content.md`). |
| **Ledger (de créditos)** | Registo imutável de movimentos de consumo/carregamento de créditos; o saldo deriva-se, nunca se edita (`modules/credit-management.md`). |
| **Scoping** | Restrição de *que subconjunto de dados* um perfil vê/opera (por unidade organizacional, projeto, …). Eixo distinto de **autorização** (que *ações* pode fazer) — colapsá-los cria bugs nos dois sentidos (`modules/rbac-and-scoping.md`). |
| **Runbook** | Guia operacional testado para um procedimento em produção (deploy, restauro, incidente). |
| **Post-mortem** | Análise de incidente sem culpados: linha temporal, causas, ações com dono (`templates/technical/post-mortem.md.template`). |
| **RTO / RPO** | Recovery Time/Point Objective — quanto tempo de indisponibilidade e quanta perda de dados são toleráveis (`agents/06-data/disaster-recovery-planner.md`). |
| **Framework-mãe** | O repositório de origem da Maestro, onde a framework evolui por SemVer; os projetos trabalham sobre cópias e re-sincronizam deliberadamente (`_meta/VERSION.md`, `playbooks/sync-framework.md`). |
| **Reporte de melhorias** | O envio consolidado e sanitizado do `FRAMEWORK-IMPROVEMENTS.md` de um projeto para a framework-mãe, como issue com label `melhorias` (`playbooks/report-framework-improvements.md`). |
| **Candidata** | Lição/padrão reportado por um projeto, à espera de segunda confirmação antes de ser promovido à framework (`knowledge/candidates.md`). |
| **Curadoria (da framework)** | O processo que transforma reportes de melhorias em evolução curada da framework — triagem, candidatas, promoções por PR com merge humano (`playbooks/framework-curation.md`, `agents/14-meta/framework-curator.md`). |
| **Dossier de génese** | O registo, fase a fase, dos números de um projeto (custo de IA, dias, achados, retrabalho) que provam — ou desmentem — a promessa da framework (`templates/project/GENESIS.md.template`). |
| **Curva de aprendizagem (do ecossistema)** | A agregação dos dossiers de génese, produto a produto e por código, mantida pela curadoria (`knowledge/learning-curve.md`); onde se lê se cada produto saiu mesmo mais barato e melhor. |

## Relacionados

- `_meta/STYLE-GUIDE.md` — convenções de escrita que usam estes termos.
- `core/artifact-protocol.md` — IDs e estados dos artefactos (`RF-nnn`, `RN-nnn`, `P-nnn`, …).
