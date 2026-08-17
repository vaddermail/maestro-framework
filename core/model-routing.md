# Roteamento de Modelos de IA

Como se escolhe **que modelo e que esforço** usar em cada tarefa do desenvolvimento. O princípio:
**o modelo escolhe-se por tarefa, nunca é fixo** — qualidade máxima onde o raciocínio é distintivo,
custo mínimo onde o trabalho é mecânico. Este mecanismo foi aprendido à conta de orçamentos
esgotados no projeto-mãe (`knowledge/origin-lessons.md`): o que esgota créditos não é usar um
modelo forte no problema difícil — é **replicar o modelo caro em todos os subagentes, incluindo os
mecânicos**.

> Os nomes de camadas abaixo são abstratos de propósito: os modelos concretos mudam a cada
> trimestre; as camadas não. O projeto mapeia camadas→modelos no seu `CLAUDE.md` (a partir de
> `templates/project/CLAUDE.md.template`) e **revisita o mapeamento deliberadamente** quando os
> preços/capacidades mudam — as regras de custo são versionadas com o porquê, como qualquer decisão.

## As quatro camadas

| Camada | Para quê | Exemplos de tarefas |
| --- | --- | --- |
| **Topo** | Raciocínio difícil e distintivo, onde acertar à primeira poupa retrabalho caro | Desenho de RBAC multi-perfil, máquinas de estado, fluxos críticos com reversibilidade, migrações expand-contract, arbitragem de arquitetura, **verificação adversarial** |
| **Padrão** | O default do dia-a-dia: implementação e revisão de código com regras de negócio | Fatias verticais, lógica de domínio, revisão de PRs, consolidação de relatórios |
| **Económico** | Trabalho padronizado com spec clara | Replicar ecrãs, escrever testes a partir de plano, espelhar mocks, CRUD direto, atualizar docs/ajuda |
| **Mecânico** | Trivial e repetitivo | Find/replace em massa, mover ficheiros, correções de lint, regenerar snapshots |

## O segundo eixo: esforço (effort/thinking)

Ortogonal ao modelo. Regra provada: **modelo forte com esforço baixo bate modelo fraco com esforço
máximo** em tarefas de raciocínio. Começar em médio/alto e subir só se necessário — nunca esforço
máximo por reflexo. O custo de uma tarefa é `modelo × esforço × volume de contexto`; os três
gerem-se, não só o primeiro.

## Regras de routing

1. **Default = camada Padrão.** Qualquer tarefa sem classificação clara vai para Padrão — incluindo,
   na dúvida, qualquer subagente.
2. **Descer é deliberado:** só quando a tarefa é **claramente mecânica/padronizada** (spec completa,
   zero ambiguidade, falha barata de detetar).
3. **Subir é deliberado:** só para raciocínio difícil e distintivo ou **verificação/juízo adversarial**
   — e afinando o esforço em vez de saltar para o máximo.
4. **A sessão orquestradora mantém-se forte** (Padrão ou Topo no problema difícil): coordenar,
   decidir e verificar é onde os erros custam mais caro.
5. **Fan-out é onde o orçamento morre.** Antes de lançar N subagentes, classifica a tarefa deles —
   N × topo × esforço alto é a receita comprovada para esgotar créditos num dia.
6. **Dar a spec completa à cabeça.** Um prompt completo corta turnos de ida-e-volta — é a otimização
   de custo mais barata que existe.
7. **Exceções com razão registada.** Sair desta tabela é legítimo com justificação concreta escrita
   (em `STATE.md` ou no plano da tarefa).

## Observabilidade do custo (o "sistema de créditos" do desenvolvimento)

- **Contabilizar por unidade de trabalho:** cada bloco/fatia regista no `STATE.md` o consumo
  aproximado (tokens/custo) e o que produziu — o custo liga-se a valor, não a um total opaco.
- **Rever a tendência:** o `agents/13-guardians/cost-guardian.md` inclui o custo de IA do
  desenvolvimento na sua análise (não só a infra do produto).
- **Kill-switch:** a mesma primitiva que corta risco corta custo — poder desligar um modelo/camada
  (ex.: "sem créditos da camada Topo → tudo o que era Topo passa a Padrão + verificação redobrada")
  sem parar o projeto. Regras interinas destas ficam **com prazo e condição de reversão** escritos.
- **Ceticismo com otimizações:** não confiar em poupanças (caching de prompts, batch, contexto
  reutilizado) sem verificar os pré-requisitos reais — otimização presumida é custo escondido.
- **Contexto é custo recorrente:** ferramentas/documentos carregados em todas as sessões pagam-se em
  todas as sessões. Adotar ferramentas quando acrescentam valor **agora**, remover quando deixam de
  o fazer (adoção evolutiva — `adapters/claude-code.md`).

## Para o produto (não confundir)

Este documento governa o custo de **construir** o produto. Se o próprio produto consumir IA/APIs
pagas, isso governa-se com os módulos `modules/credit-management.md` (ledger, quotas, tarifas por
utilizador/organização) e `modules/ai-observability.md` (contabilização, alertas, kill-switch
por modelo) — os mesmos princípios, desacoplados e dentro do produto.

## Relacionados

- `core/orchestrator.md` — quem aplica o routing ao delegar.
- `modules/credit-management.md` · `modules/ai-observability.md` — os equivalentes de produto.
- `knowledge/origin-lessons.md` — a história que originou estas regras.
- `adapters/claude-code.md` — mapeamento concreto de camadas em ferramentas reais.
