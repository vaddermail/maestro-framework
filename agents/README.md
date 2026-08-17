# Agentes

A equipa de especialistas da framework. Cada agente tem **uma responsabilidade**, uma ficha
autocontida (`agents/_template/AGENT-TEMPLATE.md`) e um lugar no ciclo de vida. Os agentes não se
conhecem uns aos outros — colaboram por **artefactos** (`core/artifact-protocol.md`),
coordenados pelo `core/orchestrator.md`.

## Como ler uma ficha

Toda a ficha segue o template: Identificação · Objetivo · Quando inicia · Quando termina · Inputs ·
Outputs · Perguntas ao utilizador · Regras · Limitações · Workflow · Exemplos · Boas práticas ·
Anti-padrões · Interações · Critérios de pronto. Se uma secção diz "Não aplicável", diz **porquê**.

## Tipos de agente

| Tipo | Papel | Exemplos |
| --- | --- | --- |
| **Especialista** | Produz um artefacto na sua área | `analista-da-ideia`, `modelador-de-dados`, `especialista-rest` |
| **Árbitro** | Decide entre propostas independentes, com ADR | `arbitro-de-arquitetura`, `arbitro-de-alojamento` |
| **Revisor** | Examina trabalho alheio numa dimensão, com relatório | `12-revisores/`, exceto o consolidador (coordenador) |
| **Guardião** | Vigia uma dimensão em produção, em cadência | `13-guardioes/` (e o `curador-da-framework`, que vigia a mãe), exceto o agente de evolução (coordenador) |
| **Coordenador** | Acompanha uma dimensão ao longo de várias fases | `coordenador-de-seguranca`, `consolidador-de-revisoes`, `agente-de-evolucao-de-features` |

## As 15 categorias (por fase dominante do ciclo de vida)

| # | Categoria | Fase | O que produz |
| --- | --- | --- | --- |
| 00 | `00-descoberta/` | F1 | Entender o problema: ideia, personas, casos de uso, KPIs, MVP, riscos, custos |
| 01 | `01-requisitos/` | F2 | O quê sem ambiguidade: requisitos, regras, critérios de aceitação, glossário |
| 02 | `02-arquitetura/` | F3 | Como construir: estilo arquitetural (painel + árbitro), stack, integrações |
| 03 | `03-experiencia/` | F4 | UX/UI antes do código: fluxos, wireframes, design system, acessibilidade |
| 04 | `04-frontend/` | F6 | Engenharia do cliente: ecrãs, integração de API, estado, testes de UI |
| 05 | `05-backend/` | F5–F6 | Engenharia do servidor: APIs, authn/z, filas, eventos, observabilidade |
| 06 | `06-dados/` | F5–F6 | A verdade persistida: modelo, migrações, índices, backups, DR |
| 07 | `07-devops/` | F8 | Do commit à produção: containers, IaC, CI/CD, deploy, flags, segredos |
| 08 | `08-infraestrutura/` | F8 | Onde corre: cloud/on-prem (árbitro), rede, TLS, storage, alta disponibilidade |
| 09 | `09-seguranca/` | F1–F9 | Robustez em profundidade: threat modeling, OWASP/ASVS, hardening, scans, pentest |
| 10 | `10-qualidade/` | F6–F7 | Provar que funciona: estratégia e execução de testes, cobertura ao risco |
| 11 | `11-documentacao/` | F1–F9 | Conhecimento vivo: docs técnicos, ajuda ao utilizador, referência de API |
| 12 | `12-revisores/` | F7 | Olhos independentes: painel de revisão por dimensão + consolidação |
| 13 | `13-guardioes/` | F9 | A equipa permanente de produção: segurança, deps, performance, custos, docs, backups, evolução |
| 14 | `14-meta/` | — | Fora do ciclo dos projetos: a framework a aprender com quem a usa — curadoria dos reportes de melhorias, no repositório-mãe |

> A "fase dominante" indica onde a categoria trabalha mais — não onde trabalha só. Segurança e
> documentação atravessam todo o ciclo; os revisores voltam a cada marco. A categoria 14 é a
> exceção estrutural: não atua em projetos, atua na própria framework
> (`agents/14-meta/README.md`) — o Orquestrador de um projeto nunca a convoca.

## Como os agentes se encaixam no ciclo

Cada categoria é convocada pelo workflow da sua fase (`workflows/`). O Orquestrador monta o grafo de
dependências a partir das secções **Inputs**/**Interações** das fichas — registar um agente nos
índices é o que o torna descobrível (`core/extensibility.md`).

## Adicionar um agente

`playbooks/add-an-agent.md`: copiar o template → preencher tudo → registar no README da
categoria e no `_meta/INVENTORY.md`. Sem tocar nos agentes existentes.

## Relacionados

- `agents/_template/AGENT-TEMPLATE.md` — o molde de toda a ficha.
- `core/orchestrator.md` — quem dirige a equipa.
- `core/lifecycle.md` — quando cada categoria entra.
- `_meta/INVENTORY.md` — a lista completa e canónica.
