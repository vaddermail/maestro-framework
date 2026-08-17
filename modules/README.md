# Módulos — capacidades reutilizáveis destiladas do projeto-mãe

Um **módulo** é uma capacidade de **produto** reutilizável — não uma biblioteca de código. Descreve o
desenho conceptual, as regras inegociáveis e as armadilhas de algo que **qualquer** produto novo pode
adotar: um ledger de créditos, um motor de aprovações, um trilho de auditoria. Onde um agente
(`agents/README.md`) diz *quem faz o trabalho* e um workflow (`workflows/README.md`) diz *em que
ordem*, um módulo diz *o quê construir e porquê construí-lo assim* — de forma agnóstica de stack,
cloud e domínio.

Os módulos são a destilação prática dos padrões em `knowledge/proven-patterns.md` e das
`knowledge/origin-lessons.md`: cada um encapsula uma classe de defeitos já resolvida, para não se
reaprender à custa dos mesmos bugs noutro produto.

## O que um módulo **não** é

- **Não é código nem uma dependência a instalar.** É o *quê/porquê*; o *como* concreto (linguagem,
  BD, framework) decide-se com `core/decision-engine.md` quando se instancia.
- **Não assume domínio.** Os exemplos são multi-domínio (e-commerce, SaaS, plataforma de dados, app
  interna) — a mecânica generaliza-se, o domínio não (`knowledge/origin-lessons.md` §O que não
  generalizar).
- **Não é obrigatório.** Adota-se o que acrescenta valor **ao ponto atual** do produto; o resto fica
  disponível para quando fizer sentido (`core/extensibility.md`).

## Como se adota um módulo num produto

Três passos, sempre nesta ordem:

1. **Escolher** — durante a especificação (`workflows/W05-specification.md`) ou uma evolução
   (`workflows/W10-feature-evolution.md`), identificar que o produto tem a necessidade que o módulo
   resolve. Na dúvida entre adotar já ou depois, adota-se quando a necessidade é **real e presente**,
   não especulativa.
2. **Instanciar no domínio** — traduzir os conceitos genéricos do módulo para a linguagem ubíqua do
   produto (`agents/01-requirements/glossary-curator.md`) e escrever as regras concretas nas specs
   (`agents/01-requirements/business-rules-modeler.md`). As "regras inegociáveis" do módulo
   copiam-se para as regras de negócio do produto **com a sua proveniência** — para nenhum agente
   futuro as "simplificar" sem perceber porque existem (`knowledge/origin-lessons.md` A2).
3. **Registar a adoção** — abrir um ADR (`templates/project/ADR-DECISION.md.template`) a dizer que o
   módulo foi adotado, em que variante e porquê; e deixar rasto em `STATE.md`
   (`core/project-memory.md`). Adoção não registada é adoção que a próxima sessão desconhece.

## Princípio do desacoplamento

**Os módulos não dependem uns dos outros.** Cada um adota-se isoladamente e faz sentido sozinho — é a
mesma propriedade open-closed dos agentes (`core/extensibility.md`): registar = existir, sem
cirurgia nos existentes. Podem, no entanto, **compor-se** quando o produto os adota em conjunto, e a
composição faz-se por **artefactos partilhados**, nunca por acoplamento direto:

- o `modules/approval-engine.md` **emite** transições que o `modules/state-machines.md`
  executa, e **ambos** escrevem no `modules/audit-and-provenance.md`;
- o `modules/rbac-and-scoping.md` decide *quem pode* transitar; a máquina de estados decide *se a
  transição é legal*.

Nenhum módulo importa outro para funcionar: um produto pode adotar só a auditoria, ou só os créditos.
Onde um módulo **assume** o resultado de outro, di-lo na secção "Relacionados" — não o embute.

## Esqueleto comum de um ficheiro de módulo

Todos os módulos (exceto este README) seguem **exatamente** esta estrutura, por esta ordem — para que
o leitor salte de um módulo para outro sem reaprender o formato:

| Secção | O que responde |
| --- | --- |
| `# Título · linha de contexto` | O que é o módulo, para quem, numa frase |
| `## O problema que resolve` | A classe de defeitos/necessidade que justifica o módulo |
| `## O modelo (conceitos e entidades, agnóstico de stack)` | As entidades e relações, sem escolher tecnologia |
| `## Regras inegociáveis (numeradas, verificáveis)` | As invariantes que qualquer instância tem de respeitar — cada uma confirmável |
| `## Como se adota num produto novo (passos)` | O caminho concreto de instanciação |
| `## Variações e trade-offs` | As decisões abertas e quando escolher cada opção |
| `## Exemplo (1–2, multi-domínio)` | Instâncias realistas em domínios diferentes |
| `## Armadilhas conhecidas` | Os erros típicos de quem implementa o módulo |
| `## Relacionados` | 3–8 caminhos que existam no `_meta/INVENTORY.md` |

## Os módulos da framework

| Módulo | O que oferece |
| --- | --- |
| `modules/credit-management.md` | Ledger genérico de créditos: contas, movimentos, tarifas, quotas, kill-switch; para IA, APIs, ferramentas, por utilizador/organização. |
| `modules/approval-engine.md` | Aprovações por escalão configurável (valor/risco), gate de validação de necessidade separado. |
| `modules/state-machines.md` | Fluxos críticos como máquinas de estado explícitas: estados, transições, efeitos, quem pode. |
| `modules/rbac-and-scoping.md` | Perfis, âmbitos por unidade organizacional, aplicação no servidor, cliente não-fiável. |
| `modules/audit-and-provenance.md` | Trilho de auditoria imutável; proveniência de dados tocados por IA com undo. |
| `modules/job-queue.md` | Fila com executor único: submissão múltipla, dedupe por fingerprint, retries, visibilidade. |
| `modules/feature-flags.md` | Flags e kill-switches: mudanças de risco desligáveis sem deploy; higiene de flags. |
| `modules/single-source-of-content.md` | SSOT de labels/descrições/ajuda: um ficheiro fonte serve UI, tooltips e grounding de IA. |
| `modules/ai-observability.md` | Consumo de IA contabilizado (tokens, custo, por funcionalidade/modelo/utilizador), alertas, kill-switch por modelo. |
| `modules/readonly-external-integrations.md` | Sistemas externos como contrato assumido: read-only, sincronização, campos geridos fora. |
| `modules/entity-lifecycle.md` | Onboarding/offboarding de entidades com libertação transacional de todos os recursos associados. |

## Relacionados

- `core/extensibility.md` — como se adiciona/adota um módulo sem partir os existentes.
- `knowledge/proven-patterns.md` — os padrões de produção que os módulos encapsulam.
- `knowledge/origin-lessons.md` — os defeitos concretos que os provaram.
- `core/decision-engine.md` — como se decide a variante concreta ao instanciar.
- `templates/project/ADR-DECISION.md.template` — onde se regista a adoção de um módulo.
- `agents/01-requirements/business-rules-modeler.md` — quem traduz as regras do módulo para o domínio.
