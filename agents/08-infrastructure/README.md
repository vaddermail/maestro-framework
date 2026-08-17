# 08 — Infraestrutura

**Onde o produto corre.** Esta categoria decide e desenha a fundação física/virtual sobre a qual
tudo o resto assenta: alojamento (cloud, on-prem ou híbrido), rede, TLS, storage, backup de infra e
alta disponibilidade. A pergunta que a categoria responde é "onde e sobre que máquinas isto vive, a
que custo, com que garantias e com que caminho de saída" — nunca "que tecnologia usamos no código"
(isso é `agents/02-architecture/`) nem "como levamos o commit até lá" (isso é `agents/07-devops/`).

## Fase dominante

**F8 — lançamento** (`workflows/W08-launch.md`). A **decisão** de alojamento, porém, é
estrutural e cara de reverter, por isso o `arbitro-de-alojamento.md` é convocado já em **F3**
(`workflows/W03-architecture.md`), a par da arquitetura, e apenas **executada** em F8. Storage, rede e
HA são revisitados sempre que a escala ou os requisitos de disponibilidade mudam (F9).

## Agentes desta categoria

| Agente | Tipo | O que produz |
| --- | --- | --- |
| `agents/08-infrastructure/hosting-arbiter.md` | Árbitro | ADR de alojamento (cloud/on-prem/híbrido) por custo, dados, equipa e conformidade |
| `agents/08-infrastructure/aws-specialist.md` | Especialista | Proposta AWS: necessidades → serviços, custo mensal, armadilhas, lock-in |
| `agents/08-infrastructure/azure-specialist.md` | Especialista | Proposta Azure (forte quando há Entra ID / Microsoft 365) |
| `agents/08-infrastructure/google-cloud-specialist.md` | Especialista | Proposta GCP (dados/analytics, Kubernetes maduro) |
| `agents/08-infrastructure/hetzner-specialist.md` | Especialista | Proposta Hetzner (custo/benefício europeu, dedicados e cloud) |
| `agents/08-infrastructure/ovh-specialist.md` | Especialista | Proposta OVH (soberania europeia, bare-metal, anti-DDoS) |
| `agents/08-infrastructure/digitalocean-specialist.md` | Especialista | Proposta DigitalOcean (simplicidade primeiro, PaaS gerido) |
| `agents/08-infrastructure/on-premises-specialist.md` | Especialista | Proposta on-prem: VMs, hipervisores, responsabilidade total |
| `agents/08-infrastructure/network-architect.md` | Especialista | VPN, firewall, DNS, segmentação, exposição mínima |
| `agents/08-infrastructure/tls-ssl-specialist.md` | Especialista | Certificados, renovação automática, TLS moderno em todo o lado |
| `agents/08-infrastructure/storage-specialist.md` | Especialista | Blocos/objetos/ficheiros, ciclos de vida, encriptação em repouso |
| `agents/08-infrastructure/infra-backup-specialist.md` | Especialista | Backup de infra e configuração, restauro testado |
| `agents/08-infrastructure/high-availability-architect.md` | Especialista | Redundância, failover, zonas, graceful degradation |

## Como o árbitro usa os especialistas

O `arbitro-de-alojamento.md` **não vende nenhuma plataforma** — aplica o `core/decision-engine.md`:
enquadra a pergunta com critérios pesados (custo total, competência da equipa, conformidade/soberania
de dados, reversibilidade/lock-in, maturidade), convoca 2–4 especialistas para proporem **às cegas** o
mapeamento das necessidades do produto para a sua plataforma (com custo mensal e armadilhas honestas),
compara e escreve o ADR. Cada especialista **avalia a sua cloud, não a defende**: um especialista que
conclua "para este caso a minha plataforma é cara ou excessiva" está a dar uma proposta válida.

## Ordem de trabalho recomendada

1. **F3 —** o `arbitro-de-alojamento` corre o painel de especialistas → ADR de alojamento aprovado.
2. **F8 —** o especialista da plataforma escolhida detalha o desenho (rede, storage, TLS, HA) em
   articulação com `agents/07-devops/` (IaC, containers, deploy).
3. **F9 —** revisitar custo (`agents/13-guardians/cost-guardian.md`) e disponibilidade quando a
   escala muda; qualquer troca de plataforma reabre o ADR (`core/decision-engine.md`).

## Como o Orquestrador a convoca

O `core/orchestrator.md` monta o grafo a partir das secções **Inputs**/**Interações** das fichas.
A entrada natural é o portão de F3 exigir um ADR de alojamento aprovado antes de arquitetura de infra,
e o portão de F8 (`core/quality-gates.md`) exigir a infra desenhada, com TLS, backup e
rollback prontos, antes do go-live.

## Relacionados

- `agents/07-devops/` — leva o commit até esta infra (IaC, containers, CI/CD, deploy).
- `agents/02-architecture/` — decide o estilo/stack do software que aqui corre.
- `agents/09-security/infrastructure-analyst.md` — audita a infra desenhada.
- `core/decision-engine.md` · `agents/README.md` · `_meta/INVENTORY.md`
