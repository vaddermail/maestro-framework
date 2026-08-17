# Playbooks — procedimentos passo-a-passo

Um **playbook** é o procedimento operacional de **uma** operação recorrente e arriscada, ao nível de
detalhe em que qualquer agente ou humano o segue sem inventar passos: aplicar um patch de segurança,
atualizar uma dependência, fazer um release, migrar um esquema de BD, gerir um segredo, aumentar a
equipa, estender a framework, conduzir uma auditoria. Onde um workflow (`workflows/README.md`)
coordena **vários agentes ao longo de uma fase inteira** do ciclo de vida, um playbook é tipicamente
executado por **um** agente (ou pelo humano) — é a unidade de execução mais fina e mais verificável da
framework: cada passo diz o que faz, como se confirma que funcionou, e o que fazer se falhar.

## Quando se executa

- **Dentro de um workflow**, como o "como" de um dos seus passos — ex.: `workflows/W08-launch.md`
  passo 6 executa `playbooks/release-and-rollback.md`.
- **Por evento**, fora de qualquer fase — ex.: um CVE publicado dispara
  `playbooks/cve-response.md`.
- **Por cadência**, como o corpo do trabalho de um guardião (`agents/13-guardians/README.md`) — ex.:
  o varrimento semanal do `agents/13-guardians/dependency-guardian.md` executa
  `playbooks/dependency-updates.md`.

Um playbook **não decide** âmbito nem arquitetura — isso já foi decidido a montante (spec, ADR,
workflow que o invoca). O playbook assume a decisão tomada e executa-a com disciplina.

## Esqueleto comum de um playbook

Todos os playbooks (exceto este README) seguem esta estrutura, por esta ordem:

| Secção | O que responde |
| --- | --- |
| `# Título · linha de contexto` | O que é, quando se executa, quem o executa (humano, agente, ou ambos) |
| `## Pré-condições` | O que tem de existir/estar verdadeiro antes do primeiro passo |
| `## Passos` | Numerados, executáveis: o que faz → como verifica → o que fazer se falhar |
| `## Reversão` | Como desfazer, quando aplicável (`knowledge/permanent-rules.md` §3) |
| `## Relacionados` | 3–8 caminhos que existam no `_meta/INVENTORY.md` |

Antes das Pré-condições pode existir uma secção **opcional** de contexto/enquadramento (a
`playbooks/adversarial-audit.md` usa-a); as quatro secções obrigatórias e a sua ordem
mantêm-se.

## Os playbooks da framework

| Playbook | O que cobre |
| --- | --- |
| `playbooks/cve-response.md` | Da notificação do CVE ao patch validado e documentado. |
| `playbooks/dependency-updates.md` | Atualização deliberada: changelog, testes, lockfile, nunca à deriva. |
| `playbooks/release-and-rollback.md` | Release com backup prévio, verificação e reversão ensaiada. |
| `playbooks/expand-contract-db-migration.md` | Migração aditiva → migrar dados/código → contrair; nunca partir o que está em uso. |
| `playbooks/secrets-management.md` | Segredos fora do Git, por caminho de ficheiro, rotação e resposta a fuga. |
| `playbooks/developer-onboarding.md` | Novo interveniente operacional com um comando (setup + protocolo de arranque). |
| `playbooks/add-an-agent.md` | Estender a framework: template → ficha → índices → inventário, sem tocar nos existentes. |
| `playbooks/adversarial-audit.md` | Auditoria extensa, adversarial e multidisciplinar com verificação independente das conclusões. |
| `playbooks/sync-framework.md` | Trazer a cópia da framework de um projeto para uma versão mais recente, deliberadamente e com reversão. |
| `playbooks/report-framework-improvements.md` | O lado do projeto no circuito de aprendizagem: consolidar o `FRAMEWORK-IMPROVEMENTS.md` e enviá-lo à mãe como issue, sanitizado. |
| `playbooks/framework-curation.md` | O lado da mãe: triar reportes, gerir `knowledge/candidates.md` e propor promoções por PR — nunca commit direto. |
| `playbooks/demo-data.md` | Dados de demo como código: idempotentes, sem PII real, envio externo em modo nulo, smoke test em CI, separados dos reais. |
| `playbooks/large-scale-mechanical-migration.md` | Varredura de muitos ficheiros/call-sites sem partir o ramo: guarda primeiro, superfície pública antes da interna, gates verdes ao longo. |

## Relacionados

- `workflows/README.md` — a diferença entre coordenar uma fase e executar um procedimento.
- `core/quality-gates.md` — os portões que muitos playbooks fecham (P6, P8).
- `checklists/README.md` — as checklists que os passos de verificação consultam.
- `knowledge/permanent-rules.md` — os princípios (reversibilidade, honestidade, mudanças em
  massa) que todo o playbook operacionaliza.
- `agents/13-guardians/README.md` — quem executa os playbooks de cadência.
