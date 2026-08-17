# Templates — Documentos Prontos a Instanciar

Documentos-tipo em `.md.template` que qualquer agente (ou pessoa) preenche para produzir um
artefacto real do projeto (`core/artifact-protocol.md`). Não se editam aqui — copiam-se
para o projeto e preenchem-se lá.

## Como instanciar um template

1. **Copiar** o `.template` para o destino certo (ver tabela abaixo), **tirando o sufixo
   `.template`** — ex.: `templates/project/STATE.md.template` → `STATE.md` na raiz do projeto.
2. **Preencher os placeholders** `{{assim}}` — ver convenção abaixo. Nenhum `{{...}}` deve sobrar
   no ficheiro final.
3. **Remover as orientações**: o bloco inicial "**Como usar**" e os comentários em itálico dentro
   das secções existem só para guiar o preenchimento — saem do documento instanciado.
4. **Commitar** o ficheiro instanciado no projeto (nunca dentro de `Maestro/`, que fica
   read-only como referência de processo).

## Convenção de placeholders

Todo o texto entre chavetas duplas é para substituir: `{{nome-do-produto}}`, `{{aaaa-mm-dd}}`,
`{{numero-adr}}`. O nome dentro das chavetas descreve o que lá vai, em kebab-case — não é código,
é instrução de preenchimento. Um ficheiro instanciado nunca deve conter `{{ }}` por preencher; onde
faltar informação, segue-se `core/question-engine.md` (pergunta-se ao utilizador, não se
inventa — `MANIFESTO.md` §2).

## Índice de templates

### `templates/project/` — memória e governação (raiz do projeto)

| Template | Destino instanciado | O que é |
| --- | --- | --- |
| `CLAUDE.md.template` | `CLAUDE.md` | Instruções de projeto para agentes de IA (regras estáveis do produto novo). |
| `STATE.md.template` | `STATE.md` | Memória viva partilhada: feito, em curso, a seguir, decisões pendentes, registo de lições. |
| `DECISAO-ADR.md.template` | `product/02-architecture/decisions/ADR-nnn-title.md` | Registo de decisão de arquitetura (contexto, opções, decisão, consequências, reversão). |
| `CHANGELOG.md.template` | `CHANGELOG.md` | Histórico do que mudou e porquê, por versão. |
| `FRAMEWORK-IMPROVEMENTS.md.template` | `FRAMEWORK-IMPROVEMENTS.md` | Registo acumulado, desde o dia 0, do que o projeto ensina à framework; enviado à mãe nos fechos de fase (`playbooks/report-framework-improvements.md`). |
| `GENESE.md.template` | `product/99-records/genesis.md` | Dossier de génese: os números da promessa (custo, dias, achados, retrabalho), fase a fase; o Fecho alimenta `knowledge/learning-curve.md`. |

### `templates/discovery/` — F1, `product/00-discovery/`

| Template | O que é |
| --- | --- |
| `ideia.md.template` | Descrição estruturada da ideia. |
| `problema.md.template` | Definição do problema e custo de não resolver. |
| `stakeholders.md.template` | Mapa de stakeholders. |
| `persona.md.template` | Persona individual. |
| `caso-de-utilizacao.md.template` | Caso de utilização/jornada. |
| `objetivos-e-kpis.md.template` | Objetivos de negócio e KPIs. |
| `riscos.md.template` | Registo de riscos com dono e mitigação. |
| `roadmap.md.template` | Roadmap por horizontes. |
| `mvp.md.template` | Âmbito do MVP e cortes explícitos. |

### `templates/specification/` — F2/F5, `product/01-requirements/` e `product/04-specification/`

| Template | O que é |
| --- | --- |
| `requisito-funcional.md.template` | Requisito com critérios de aceitação. |
| `regras-de-negocio.md.template` | Regras e invariantes de um módulo. |
| `maquina-de-estados.md.template` | Máquina de estados de um fluxo crítico. |
| `modelo-de-dados-logico.md.template` | Entidades, relações e invariantes, agnóstico de BD. |
| `contrato-backend.md.template` | Responsabilidades do servidor: authz, scoping, integridade, campos sensíveis. |

### `templates/technical/` — segurança, testes, operação e revisão (várias fases)

| Template | O que é |
| --- | --- |
| `threat-model.md.template` | Modelo de ameaças de uma funcionalidade/sistema. |
| `plano-de-testes.md.template` | Plano de testes orientado ao risco. |
| `runbook.md.template` | Runbook operacional de um procedimento. |
| `plano-de-migracao.md.template` | Migração expand-contract com plano de reversão. |
| `post-mortem.md.template` | Post-mortem sem culpados, com ações e donos. |
| `relatorio-de-revisao.md.template` | Relatório de um revisor (formato comum ao painel). |
| `relatorio-de-guardiao.md.template` | Relatório periódico de um guardião. |

> Todos os templates do índice acima estão escritos e prontos a instanciar; o índice reflete o
> `_meta/INVENTORY.md` completo.

## Relacionados

- `_meta/INVENTORY.md` — a lista oficial de todos os ficheiros da framework.
- `core/artifact-protocol.md` — a árvore `product/` onde cada instanciado vive.
- `core/project-memory.md` — `CLAUDE.md`/`STATE.md` em detalhe.
- `core/decision-engine.md` — o ADR em detalhe.
- `workflows/W00-project-kickoff.md` — quando se instanciam os templates de `projeto/`.
