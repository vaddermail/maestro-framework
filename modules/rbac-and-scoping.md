# RBAC e Scoping · autoridade e âmbito, sempre no servidor

> **Validação em produção:** 2.ª confirmação em domínio distinto do projeto-mãe (P2 — curadoria de 2026-08; nuance confirmada: scoping como **predicado SQL composável** nos
> caminhos quentes, não um conjunto em memória). O desenho mantém-se; a confiança sobe.

Um módulo para responder, em qualquer produto multi-utilizador, a duas perguntas **distintas**: *que
ações é que este ator pode fazer?* (autorização/RBAC) e *sobre que subconjunto de dados?* (scoping por
unidade organizacional). São **eixos ortogonais** — um gestor de uma filial tem autoridade ampla mas
âmbito estreito; um auditor tem âmbito total mas autoridade só de leitura. A regra que atravessa tudo:
a decisão vive **100% no servidor**, porque o cliente é não-fiável; falha em **fail-closed**; e os
campos sensíveis são redigidos **por categoria de campo**, não por um único portão de tudo-ou-nada.

## O problema que resolve

- **Colapsar autoridade e âmbito.** Tratá-los como uma coisa só gera bugs nos dois sentidos: dá a alguém
  acesso a dados de outra unidade porque tinha a "ação", ou nega uma ação legítima porque o âmbito não
  batia certo (`knowledge/origin-lessons.md` B2).
- **Confiar no cliente.** Qualquer verificação feita no browser é contornável; qualquer campo enviado
  "só para não mostrar" é lido no payload. Esconder no frontend não é segurança.
- **Fail-open.** Um `perfil ?? "ADMIN"` que transforma "sem perfil" em "acesso total" é um defeito real e
  catastrófico (`knowledge/origin-lessons.md` C1). A ausência de permissão tem de **negar**.
- **Redação tudo-ou-nada.** Um único gate "vê tudo / não vê nada" não modela a realidade: o mesmo
  utilizador pode ver o email de um cliente mas não o seu número de cartão. A ocultação é **por categoria
  de campo**.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Ator (`ator`)** — quem faz o pedido: um utilizador, uma conta de serviço, um sistema integrado.
- **Perfil/Papel (`papel`)** — um conjunto nomeado de **permissões** (ações). Um ator tem um ou mais
  papéis; o cliente pode **declarar** qual está ativo, mas o servidor **confirma** contra os papéis
  realmente concedidos.
- **Permissão (`permissao`)** — a autoridade para uma ação sobre um tipo de recurso (`ler-fatura`,
  `aprovar-despesa`, `eliminar-utilizador`). É o eixo **autoridade**.
- **Âmbito/Scope (`ambito`)** — o subconjunto de dados que o ator alcança, tipicamente por unidade
  organizacional (departamento, região, cliente, projeto, tenant). É o eixo **scoping**, independente da
  autoridade.
- **Política (`politica`)** — a regra que combina papel + âmbito + recurso para produzir *permitir/negar*.
  Vive perto dos dados (idealmente também na BD, não só na app).
- **Categoria de campo sensível (`categoriaCampo`)** — uma classificação dos campos por sensibilidade
  (`identificador-pessoal`, `segredo`, `financeiro`, `saúde`). A redação decide-se **por categoria**, com
  a permissão de ver aquela categoria — não por um flag global.

O padrão de fundo é o do `knowledge/proven-patterns.md` §6: o cliente declara intenção, o
servidor decide; a *query* filtra pela identidade do servidor; a saída redige por autorização.

## Regras inegociáveis (numeradas, verificáveis)

1. **Autorização e scoping são eixos separados.** A decisão avalia os dois independentemente; nunca um
   serve de proxy do outro. Teste: um papel com autoridade ampla e âmbito estreito vê **menos** dados, e
   um âmbito amplo com autoridade de leitura **não** consegue escrever.
2. **A decisão vive no servidor; o cliente só declara intenção.** Nenhuma autoridade se decide no cliente.
   Teste: um pedido forjado (perfil/âmbito adulterado no payload) é recusado pelo servidor.
3. **Fail-closed por defeito.** Sem papel resolúvel, sem política aplicável ou em dúvida → **negar**;
   nunca assumir super-utilizador. Teste: um ator sem perfil recebe negação, não acesso total
   (`knowledge/origin-lessons.md` C1).
4. **O scoping filtra na origem da query, não na apresentação.** Os dados fora do âmbito **não saem** da
   base; não se buscam-todos-e-filtram-no-fim. Teste: a query devolve só o subconjunto do âmbito, mesmo
   que a UI peça mais.
5. **Fora-do-âmbito devolve "não existe", não "não autorizado".** Um recurso fora do scope responde como
   inexistente (404), não como proibido (403), para não vazar a sua existência. Teste: pedir um recurso de
   outra unidade é indistinguível de pedir um recurso que não existe.
6. **Campos sensíveis redigem-se por categoria, com defesa em profundidade.** Não emitir na query **e**
   redigir na saída, por categoria de campo (`knowledge/proven-patterns.md` §6). Teste: sem
   permissão para a categoria `segredo`, o campo não aparece no payload — não basta estar oculto no ecrã.
7. **A autoridade confirma-se por operação, não uma vez à entrada.** Cada ação sensível revalida; não se
   confia numa verificação feita no login. Teste: mudar o papel a meio da sessão altera o que a próxima
   ação permite.
8. **As políticas são auditáveis e versionáveis.** Quem tem que papel e que âmbito é rastreável e o
   histórico de concessões/revogações fica registado (`modules/audit-and-provenance.md`). Teste: uma
   concessão de acesso reconduz a quem a deu e quando.

## Como se adota num produto novo (passos)

1. **Enumerar os papéis e as ações** do produto (a matriz autoridade) e, **separadamente**, as **unidades
   de âmbito** (por que dimensão se particionam os dados: tenant, região, departamento, projeto).
2. **Classificar os campos sensíveis por categoria** e mapear que papel vê que categoria
   (`agents/06-data/data-modeler.md`, `agents/09-security/README.md`).
3. **Escrever o contrato de backend** que declara: authz no servidor, filtragem na query, 404-fora-de-âmbito,
   redação por categoria (`templates/specification/backend-contract.md.template`).
4. **Impor a política perto dos dados** — políticas na BD além dos guards de app
   (`knowledge/proven-patterns.md` §5,§6) — e escolher o modelo (RBAC puro vs ABAC — ver
   Variações), registando em ADR (`templates/project/ADR-DECISION.md.template`).
5. **Ligar à autenticação** (`agents/05-backend/authentication-specialist.md`): a identidade vem do
   authn, a autoridade e o âmbito deste módulo.
6. **Testar adversarialmente**: forjar perfil/âmbito, pedir recursos de outra unidade, ler payloads à
   procura de campos que deviam estar redigidos (`playbooks/adversarial-audit.md`).

## Variações e trade-offs

- **RBAC puro vs ABAC (atributos).** RBAC (papel → permissões) é simples, legível e chega à maioria dos
  produtos; ABAC (decisão por atributos do ator/recurso/contexto) é mais expressivo — necessário quando a
  regra depende de dados dinâmicos ("o dono do registo", "durante o horário laboral") — mas mais difícil
  de auditar. Muitos produtos são RBAC com um punhado de regras ABAC (ownership).
- **Âmbito hierárquico vs plano.** Unidades em árvore (região → filial → equipa) permitem herança de
  âmbito (quem alcança a região alcança as filiais), ao custo de complexidade na avaliação; âmbitos
  planos são triviais mas não modelam a herança.
- **Multi-tenant: isolamento por linha vs por schema/BD.** Filtrar por `tenant_id` em cada query é simples
  e barato mas depende de nunca esquecer o filtro (impor na camada baixa); isolar por schema/BD é mais
  forte mas mais pesado de operar.
- **Redação no servidor vs projeções por papel.** Redigir campos na saída é flexível; ter *views*/projeções
  distintas por papel é mais seguro (o campo nem existe na projeção) mas multiplica os contratos.

## Exemplo (1–2, multi-domínio)

**Plataforma de gestão de clínicas (multi-tenant).** Cada clínica é um tenant (âmbito). Um rececionista
tem autoridade de agendar mas **não** de ver o histórico clínico; um médico vê o histórico dos **seus**
pacientes (âmbito por médico dentro do tenant). Os campos de saúde são categoria sensível: o rececionista
recebe o payload **sem** esses campos (Regra 6). Pedir um paciente de outra clínica responde "não existe"
(Regra 5). Sem perfil resolvido, nega (Regra 3).

**Ferramenta interna de faturação (empresa com filiais).** O eixo de âmbito é a filial. Um contabilista
de filial tem autoridade ampla (criar, editar, fechar faturas) mas só da **sua** filial; o controller do
grupo tem âmbito total mas autoridade só de leitura e exportação — os dois eixos cruzam-se de forma
oposta (Regra 1). Os IBAN e dados fiscais são categoria `financeiro`, redigidos para quem não os precisa.

## Armadilhas conhecidas

- **Fail-open (`?? "ADMIN"`).** O default que transforma ausência de perfil em acesso total — o defeito
  mais perigoso deste módulo (Regra 3, `knowledge/origin-lessons.md` C1).
- **Filtrar no cliente/na apresentação.** Buscar tudo e esconder no ecrã envia os dados no payload;
  filtra-se **na query** (Regra 4).
- **403 em vez de 404 fora de âmbito.** Responder "não autorizado" confirma que o recurso existe — vaza
  informação. Fora de âmbito é "não existe" (Regra 5).
- **Redação tudo-ou-nada.** Um gate único não modela "vê o email mas não o cartão"; redige-se por
  categoria de campo (Regra 6).
- **Confiar numa verificação de entrada.** Autorizar só no login e não revalidar por operação deixa a
  sessão com poderes que já foram revogados (Regra 7).
- **Confundir autenticação com autorização.** Saber *quem é* (authn) não diz *o que pode* nem *sobre que
  dados*; são camadas distintas (`agents/05-backend/authentication-specialist.md`).

## Relacionados

- `modules/audit-and-provenance.md` — concessões, revogações e acessos deixam rasto imutável.
- `modules/state-machines.md` — a autoridade de cada transição confirma-se com este módulo.
- `modules/approval-engine.md` — a autoridade do aprovador vem daqui.
- `knowledge/proven-patterns.md` — §6: autorização e ocultação exclusivas do servidor.
- `knowledge/origin-lessons.md` — B2 (autoridade ≠ scoping) e C1 (fail-closed).
- `agents/05-backend/authorization-specialist.md` — quem implementa a política no servidor.
- `templates/specification/backend-contract.md.template` — onde se declara authz, scoping e redação.
