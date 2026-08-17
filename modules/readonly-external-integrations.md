# Integrações Externas Read-Only · o sistema-mestre é contrato assumido

Módulo reutilizável para dados cuja **verdade vive noutro sistema**: um diretório de identidade, um
ERP, um sistema de projetos, um catálogo de produtos. O produto **lê** e reflete, **nunca edita** os
campos que a origem gere — e comporta-se com honestidade quando a origem está indisponível.

## O problema que resolve

Muitos produtos consomem dados que não lhes pertencem. A tentação é copiá-los e passar a tratá-los
como próprios — e então:

- os campos geridos lá fora ficam **editáveis** aqui, as duas cópias divergem, e ninguém sabe qual é a
  verdade (a classe de bug de `knowledge/proven-patterns.md` §4);
- cada re-sincronização cria **duplicados** por se fazer insert cego em vez de upsert;
- quando a origem cai, o produto ou mostra dados velhos como se fossem frescos, ou rebenta — em vez de
  dizer honestamente o que sabe.

A postura correta é tratar o sistema externo como **contrato assumido**: read-only, com carimbo de
origem, e um comportamento degradado explícito.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Sistema-mestre** — a origem que **detém** um conjunto de campos. O produto é, para esses campos,
  um **espelho** — nunca um coautor.
- **Réplica local** — a cópia que o produto guarda para poder funcionar e fazer *joins*. Cada registo
  carrega o **ID externo estável**, o **carimbo** (`origem`, `sincronizadoEm`) e, idealmente, o
  **payload bruto** de origem como proveniência (`modules/audit-and-provenance.md`).
- **Campos geridos externamente vs campos locais.** Uma entidade pode ter campos que vêm da origem
  (read-only) **e** campos que são do produto (editáveis) — a fronteira é explícita, não implícita.
  Ex.: o nome e o departamento de um colaborador vêm do diretório; a preferência de tema é local.
- **Porta de integração (adapter)** — o único ponto que fala com o sistema externo, atrás de uma
  interface. Em dev/test, um **adapter fake** devolve dados de exemplo (`knowledge/origin-lessons.md`
  §C9).
- **Sincronização** — o processo que traz dados da origem: `upsert por ID externo`, nunca insert cego
  (`knowledge/proven-patterns.md` §2). Corre por executor único (`modules/job-queue.md`).
- **Escrita-de-volta (opcional)** — quando o produto *precisa* de propor mudanças à origem, é **também**
  uma porta, desde cedo, mesmo que comece no-op; não se dilui na lógica local.

## Regras inegociáveis (numeradas, verificáveis)

1. **Campos geridos pela origem são read-only no produto.** Verificável: não existe formulário nem
   endpoint que os edite; uma tentativa é rejeitada pelo servidor, não só escondida na UI
   (`knowledge/proven-patterns.md` §6).
2. **Sincronização é upsert por ID externo estável.** Verificável: sincronizar o mesmo lote N vezes não
   cria duplicados (teste de idempotência).
3. **Todo o registo replicado carrega carimbo de origem.** `origem` + `sincronizadoEm` presentes;
   verificável por schema/teste. A UI pode mostrar "atualizado há X".
4. **A origem prevalece nos campos que gere.** Num conflito, a verdade do sistema-mestre ganha nos seus
   campos; os campos locais não são tocados pela sincronização.
5. **Comportamento honesto quando a origem está indisponível.** Verificável: com o adapter a falhar, o
   produto serve a última réplica **marcada como possivelmente desatualizada** (ou recusa
   explicitamente), e **loga** a degradação — nunca finge frescura (`knowledge/proven-patterns.md`
   §10).
6. **Todo o acesso externo passa pela porta.** Nenhuma chamada dispersa ao sistema-mestre; verificável
   por a existência de um único adapter e um fake em test.
7. **Escrita-de-volta, se existir, é explícita e reversível.** Nunca uma edição local silenciosa que
   "talvez" chegue à origem; é uma operação nomeada, com desfecho observável.

## Como se adota num produto novo (passos)

1. **Mapear a fronteira de propriedade** com o utilizador (`core/question-engine.md`): que campos
   são da origem (read-only) e quais são locais (editáveis). Esta lista é a decisão central.
2. **Definir a réplica local** com ID externo, carimbo e (se viável) payload bruto.
3. **Desenhar a porta de integração** e escrever o **adapter fake** antes do real — dev não depende do
   sistema externo estar de pé.
4. **Implementar a sincronização** por upsert idempotente, agendada via `modules/job-queue.md`.
5. **Definir o comportamento degradado** por caso: servir stale-com-aviso, ou recusar; sempre logado.
6. **Bloquear a edição dos campos geridos** no servidor (não só na UI) e marcá-los como read-only no
   catálogo de conteúdos (`modules/single-source-of-content.md`).
7. **Se houver escrita-de-volta**, criar a porta desde já, mesmo no-op, para o desenho não a esquecer.

## Variações e trade-offs

- **Pull agendado vs push por webhook vs on-demand.** Pull agendado é o mais simples e robusto (a
  origem não precisa de saber de nós). Webhook dá frescura mas exige endpoint fiável e reconciliação
  na mesma. On-demand (buscar à origem a cada leitura) evita réplica mas acopla a disponibilidade e a
  latência — raramente vale a pena.
- **Réplica completa vs cache com TTL.** Réplica permite *joins* e funciona offline da origem; cache
  com TTL é mais leve mas não serve consultas ricas. A escolha segue o padrão de acesso
  (`agents/06-data/data-modeler.md`).
- **Stale-com-aviso vs recusar na indisponibilidade.** Para dados de contexto (nome, foto), servir
  stale com aviso é aceitável; para decisões sensíveis (permissões efetivas, saldos), recusar é mais
  honesto. Decide-se por campo, não em bloco.
- **Guardar payload bruto ou só campos usados.** O bruto é proveniência e à-prova-de-futuro (campos
  que ainda não usamos), ao custo de espaço; recomendado quando o espaço não é crítico.

## Exemplo (multi-domínio)

**App interna — identidade a partir do diretório corporativo.** Nome, email e departamento vêm do
Entra/LDAP: read-only, com `sincronizadoEm`. A app junta-lhes campos locais (preferências, atribuições
internas) que **edita à vontade**. Uma sincronização noturna faz upsert por `objectId`; correr duas
vezes não duplica ninguém. Se o diretório estiver em baixo à hora do login, mostra-se o perfil da
última sincronização com "dados de HH:MM" e regista-se a degradação — não se inventa um perfil.

**E-commerce — catálogo vindo do PIM.** Título, descrição e preço-base são do PIM (read-only); stock e
promoções da loja são locais. O feed do PIM faz upsert por SKU; um SKU que desaparece do feed marca-se
`descontinuado`, não se apaga (reversibilidade — `knowledge/permanent-rules.md` §4). Se o PIM
falha, a loja continua a vender com o último catálogo, sinalizando internamente que está stale.

## Armadilhas conhecidas

- **Insert cego na sincronização:** duplica a cada corrida e perde proveniência — a regra 2 (upsert por
  ID externo) existe exatamente para isto.
- **Campos geridos editáveis "só desta vez":** a exceção torna-se a regra e as cópias divergem; a
  fronteira de propriedade (passo 1) tem de ser dura.
- **Fingir frescura na indisponibilidade:** servir dados velhos **sem** aviso lê-se como atuais e leva
  a decisões erradas; o silêncio é a falha (`knowledge/proven-patterns.md` §10).
- **Acoplar dev ao sistema externo:** sem adapter fake, ninguém desenvolve com a origem em baixo e os
  testes ficam frágeis (`knowledge/origin-lessons.md` §C9).
- **Chamadas dispersas ao mestre:** sem porta única, uma escapa à instrumentação e ao fake; centralizar
  (regra 6).
- **Apagar em vez de marcar removido:** um registo que sai do feed pode voltar; marcar `descontinuado`
  é reversível, apagar não.

## Relacionados

- `knowledge/proven-patterns.md` — §2 upsert por ID estável, §4 SSOT, §10 fallbacks visíveis.
- `agents/06-data/data-modeler.md` — réplica, chaves externas e padrões de acesso.
- `modules/job-queue.md` — a sincronização por executor único.
- `modules/audit-and-provenance.md` — payload bruto e carimbo de origem como proveniência.
- `modules/single-source-of-content.md` — marcar campos geridos externamente como read-only.
- `knowledge/origin-lessons.md` — §C9 (porta + adapter fake + upsert idempotente).
