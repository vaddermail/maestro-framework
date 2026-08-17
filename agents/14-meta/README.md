# 14-meta — a framework a trabalhar sobre si própria

Categoria fora do ciclo de vida dos projetos: os agentes daqui não constroem produto — mantêm a
**própria Maestro** a aprender com quem a usa. Atuam no **repositório-mãe da framework**
(nunca na cópia de um projeto), fecham o circuito descrito em `knowledge/README.md` §Como o
conhecimento circula, e respondem ao teste que valida a framework: *o produto nº N saiu mais barato
e melhor que o nº N−1?*

## Agentes

| Agente | Responsabilidade |
| --- | --- |
| `agents/14-meta/framework-curator.md` | Transforma os reportes de melhorias dos projetos (issues com label `melhorias`) em evolução curada da framework: tria, deduplica, gere `knowledge/candidates.md` e propõe PRs — nunca commits diretos. |

## O que distingue esta categoria

- **Palco diferente.** As categorias 00–13 trabalham dentro de um projeto; a 14 trabalha no
  repositório-mãe. O Orquestrador de um projeto **nunca** convoca estes agentes — o lado do projeto
  no circuito é só o `playbooks/report-framework-improvements.md`.
- **Cadência própria.** Não há fase que a dispare: dispara por acumulação de reportes, por fecho de
  fase num projeto ou por tempo — ver `playbooks/framework-curation.md` §Pré-condições.
- **Humano no portão.** O output é sempre uma proposta (PR com evidência); o merge é do dono da
  framework (`MANIFESTO.md` — o humano decide). Um erro na framework multiplica-se por todos os
  projetos que a copiam; por isso o portão daqui é o mais conservador de todos.

## Relacionados

- `knowledge/README.md` — o circuito do conhecimento que esta categoria fecha.
- `knowledge/candidates.md` — a sala de espera gerida pelo curador.
- `playbooks/framework-curation.md` — o procedimento de curadoria.
- `playbooks/report-framework-improvements.md` — o lado do projeto: como os reportes chegam.
- `core/extensibility.md` — as regras de adição que a curadoria respeita.
- `_meta/VERSION.md` — o SemVer que leva as promoções aos projetos.
