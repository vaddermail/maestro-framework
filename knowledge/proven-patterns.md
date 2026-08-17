# Padrões que se Provaram

Padrões de arquitetura e operação validados em produção real. Não são teoria de livro: cada um
resolveu uma classe concreta de defeitos no projeto-mãe. Os agentes de engenharia e os módulos
(`modules/`) implementam-nos; este ficheiro é o *porquê* por trás deles.

## 1. Fila de trabalho com executor único

Vários pontos podem **submeter** trabalho; **um** worker executa; deduplicação por *fingerprint*
estável.

- **Problema que resolve:** efeitos duplicados (dois emails, dois jobs), corridas entre produtores,
  reprocessamento após falha.
- **Como:** materializar o efeito como registo numa fila **dentro da transação** do facto que o
  origina (transactional outbox — ver §3), com dedupe por chave estável
  (`evento:origem:destinatário:contexto`) e `inserir-se-não-existe`. Um executor drena o backlog,
  desacoplado, com kill-switch por canal. Falhas **logadas**, nunca silenciosas; uma falha num item
  nunca aborta o lote.
- **Detalhe:** `modules/job-queue.md`, `modules/ai-observability.md`.

## 2. Upsert por ID estável, nunca insert cego

Sincronizações e importações fazem **upsert por identificador externo estável**, não inserts.

- **Problema que resolve:** duplicados a cada re-sincronização; perda de proveniência.
- **Como:** `inserir-ou-atualizar` com alvo no ID externo; guardar o payload bruto de origem como
  proveniência; carimbar origem + momento (`sincronizadoEm`). A verdade do sistema-mestre prevalece
  nos campos que ele gere.
- **Detalhe:** `modules/readonly-external-integrations.md`.

## 3. Transactional outbox — efeitos secundários dentro da transação

Emails, eventos e integrações materializam-se na mesma transação do facto que os causa.

- **Problema que resolve:** notificar algo que depois fez rollback; ou perder a notificação de algo
  que foi confirmado.
- **Como:** `emitirEvento(tx, …)` dentro da transação; a entrega é assíncrona por executor único
  (§1). Rollback ⇒ zero efeitos, sem código extra.

## 4. Single-source-of-truth para tudo o que se repete

Qualquer facto que apareça em mais de um lugar tem **uma** fonte editável; o resto **deriva**.

- **Problema que resolve:** as duas cópias divergem — a classe de bug mais teimosa que existe.
- **Aplica-se a:**
  - **Dados/relações:** guardar um lado da relação, derivar o inverso por consulta; estado calculável
    **nunca** é coluna (deriva-se). Ex.: o consumo de licença é o registo de *seat*; a lista de
    software por equipamento é informativa.
  - **Contratos front-back:** uma declaração de schema alimenta validação, tipos do servidor, tipos
    do cliente e documentação da API (`modules/single-source-of-content.md` §Como se adota num produto novo, passo 7 (contratos)).
  - **Conteúdo de UI:** labels, tooltips e ajuda num catálogo único que serve o ecrã **e** o
    grounding de qualquer IA de ajuda (`modules/single-source-of-content.md`).
- **Como garantir:** guardrails automáticos (um teste que varre tudo e falha se houver duplicação
  fora da fonte) — ver §7.

## 5. Invariantes impostos na camada mais baixa possível — E replicados acima

As regras que **nunca** podem ser violadas vivem como constraints da BD, **e** como guards de
aplicação por cima.

- **Problema que resolve:** um bug de código ou um caminho não previsto viola a regra; a app sozinha
  não chega.
- **Como:** exclusividade → `CHECK`; "≤1 relação aberta por entidade" → índice único **parcial**
  (`WHERE fim IS NULL`); a app dá o erro amigável e cedo; um teste insere a linha ilegal e **afirma
  a violação da constraint pelo nome**. Relações "estado atual" modelam-se como histórico com
  `inicio/fim`.
- **Detalhe:** `modules/state-machines.md`, `agents/06-data/data-modeler.md`.

## 6. Autorização e ocultação de dados exclusivas do servidor (cliente não-fiável)

Toda a decisão de autoridade, scoping e ocultação de campos sensíveis vive no servidor.

- **Problema que resolve:** qualquer verificação no cliente é contornável; qualquer campo enviado
  "só para não mostrar" é lido.
- **Como:** o cliente **declara** intenção (ex.: perfil ativo); o servidor **confirma** contra os
  papéis realmente concedidos. Filtrar na *query* pela identidade do servidor; "fora do meu scope"
  devolve **404, não 403** (não vaza existência). **Fail-closed:** sem perfil → nega, nunca assume
  super-utilizador. Dados sensíveis com **defesa em profundidade**: não emitir na query **e** redigir
  na saída por autorização.
- **Distinção crítica:** *autorização* (que ações) e *scoping* (que subconjunto de dados) são eixos
  **distintos** — colapsá-los cria bugs nos dois sentidos.
- **Detalhe:** `modules/rbac-and-scoping.md`, `agents/05-backend/authorization-specialist.md`.

## 7. Guardrails de qualidade como testes que varrem tudo

Regras de produto (SSOT de conteúdo, conformidade de UI, invariantes) só aderem se forem **impostas
por testes** que varrem tudo por convenção — não por boa vontade.

- **Problema que resolve:** boas intenções erodem; a regra que não é verificada deixa de ser cumprida
  ao terceiro sprint.
- **Como:** um teste que percorre todos os módulos/chaves e falha se algo escapa à convenção (toda a
  ação tem tooltip; todo o label vem do catálogo; todo o segredo está redigido). Componentes do
  design system que **forçam a regra por construção** (não dá para criar um botão sem tooltip).
- **Detalhe:** `modules/single-source-of-content.md`, `pipelines/ci-quality.md`.

## 8. Um serviço partilhado para operações com múltiplas vias de entrada

Uma operação acessível por várias interfaces (portal, backoffice, API, CLI) tem a **lógica de efeito
num único caso-de-uso partilhado**; as vias diferem só em apresentação e pré-condições.

- **Problema que resolve:** o *drift* onde uma via ganha um efeito que a outra esquece (uma
  devolução que atualiza os quilómetros num sítio e não no outro).
- **Como:** núcleo transacional único, reutilizado; cada via só trata da sua UX e das suas
  pré-condições (ex.: a via self-service fica "por validar"; a via do gestor valida num passo).

## 9. Estado em camadas ortogonais (base + overlay)

Quando duas preocupações competem pelo mesmo campo (permanente vs temporário, publicado vs
rascunho-de-edição, atribuição vs reserva), separá-las em **camadas independentes** e **derivar** o
estado apresentado — em vez de sobrescrever destrutivamente.

- **Problema que resolve:** a classe de bug em que uma ação temporária destrói estado permanente
  (uma reserva de curto prazo que apaga a afetação de base).
- **Como:** a entidade tem uma camada base e uma camada overlay que se aplica por cima sem a alterar;
  o estado exibido é derivado das duas; terminar o overlay reverte à base, não a um default global.
- **Smell a reconhecer:** "esta ação temporária escreve por cima de um campo que também guarda estado
  de longo prazo" → decompor em camadas.
- **Detalhe:** `modules/state-machines.md`.

## 10. Fallbacks visíveis, nunca silenciosos

Todo o caminho de erro/degradação é **logado**; nenhum é engolido em silêncio.

- **Problema que resolve:** o sistema "funciona" enquanto esconde falhas que só aparecem quando já
  são um incidente.
- **Como:** config ausente → no-op **logado**; falha de canal → marcada e visível; exceção 5xx →
  registada com correlação. Se um limite é atingido (truncar, saltar, amostrar), **diz-se** — silêncio
  lê-se como "cobriu tudo" quando não cobriu.

## Relacionados

- `modules/README.md` — a implementação reutilizável destes padrões.
- `knowledge/origin-lessons.md` — os defeitos concretos que os provaram.
- `agents/05-backend/README.md` · `agents/06-data/README.md` — quem os aplica.
