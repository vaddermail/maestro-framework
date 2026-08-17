# 09 — Segurança

Robustez em profundidade, ao longo de **todo** o ciclo de vida. Ao contrário das outras categorias,
segurança **não é uma fase** — é uma dimensão transversal (F1–F9): entra na descoberta (o que
protegemos e de quem), no desenho (ameaças e controlos), na construção (código sem as falhas do
OWASP), na verificação (ASVS, pentest, scans) e na operação (guardião de segurança, CVEs). Por isso
esta categoria tem um **coordenador** com assento em todas as fases, e não apenas especialistas
pontuais.

## O princípio: cliente não-fiável, servidor única autoridade

Toda a categoria assenta numa regra herdada do projeto-mãe (`knowledge/origin-lessons.md`):
**autorização, scoping e ocultação de dados sensíveis vivem no servidor; o cliente só declara
intenção.** Blur no cliente é cosmético; um dado que um perfil não pode ver **não sai** do servidor.
Os agentes de autorização e least-privilege ecoam o `modules/rbac-and-scoping.md`.

## Agentes desta categoria

| Agente | Uma linha | Fase dominante |
| --- | --- | --- |
| `agents/09-security/security-coordinator.md` | Orquestra a segurança transversal; dono do risco residual | F1–F9 |
| `agents/09-security/threat-modeler.md` | Threat modeling (STRIDE ou equivalente) por funcionalidade crítica | F5 |
| `agents/09-security/owasp-top10-specialist.md` | Cobertura sistemática do OWASP Top 10 no design e na revisão | F3, F7 |
| `agents/09-security/asvs-specialist.md` | Verificação ASVS por nível (L1–L3) conforme o risco | F7 |
| `agents/09-security/cis-benchmarks-specialist.md` | Benchmarks CIS para SO, BD, cloud e containers | F8 |
| `agents/09-security/hardening-specialist.md` | Hardening de servidores/serviços: superfícies mínimas | F8 |
| `agents/09-security/http-headers-specialist.md` | CSP, HSTS, frame-ancestors e restantes headers de segurança | F6, F8 |
| `agents/09-security/secure-authentication-specialist.md` | Autenticação robusta: sessões, credenciais, MFA, recuperação de conta | F5–F6 |
| `agents/09-security/authorization-and-least-privilege-specialist.md` | Autorização e least privilege no servidor, papel a papel | F5–F7 |
| `agents/09-security/sast-specialist.md` | Análise estática do código no CI: regras, triagem, zero ruído tolerado | F6–F7 |
| `agents/09-security/dast-specialist.md` | Testes dinâmicos sobre a aplicação a correr | F7 |
| `agents/09-security/pentester.md` | Pentest com âmbito, regras de empenhamento e relatório acionável | F7 |
| `agents/09-security/dependency-analyst.md` | Vulnerabilidades nas dependências: audit, triagem, correção deliberada | F6–F9 |
| `agents/09-security/supply-chain-specialist.md` | Cadeia de fornecimento: builds reprodutíveis, proveniência, pacotes maliciosos | F6–F8 |
| `agents/09-security/sbom-manager.md` | Inventário SBOM do que se entrega e das suas licenças/vulnerabilidades | F8–F9 |
| `agents/09-security/exposed-secrets-hunter.md` | Segredos no código, histórico e logs: deteção, rotação, resposta | F6–F9 |
| `agents/09-security/secrets-and-rotation-manager.md` | Política de segredos: onde vivem, quem acede, rotação e resposta a fuga | F5–F9 |
| `agents/09-security/container-analyst.md` | Segurança de imagens/containers: base mínima, non-root, scan | F7–F8 |
| `agents/09-security/infrastructure-analyst.md` | Auditoria de segurança da infra/cloud desenhada pela categoria 08 | F8 |
| `agents/09-security/tls-specialist.md` | Política TLS da aplicação: versões, cifras, renovação | F8 |
| `agents/09-security/waf-specialist.md` | WAF: regras, exceções documentadas, modo de bloqueio gradual | F8 |
| `agents/09-security/privacy-specialist.md` | RGPD por desenho: mapa de dados pessoais, bases legais, DPIA, direitos dos titulares | F2, F5, F7 |
| `agents/09-security/ai-security-specialist.md` | Segurança das funcionalidades LLM: prompt injection, output não-fiável, agency, BYOK | F5–F9 |

## Mapa de cobertura: design → build → verify → operate

| Momento | Quem entra | O que produz |
| --- | --- | --- |
| **Design (F1–F5)** | `coordenador-de-seguranca`, `modelador-de-ameacas`, `especialista-owasp-top10` | Ameaças por funcionalidade crítica, controlos exigidos, requisitos de segurança |
| **Build (F6)** | `especialista-owasp-top10`, `especialista-de-headers-http` | Código sem as falhas do Top 10; headers de segurança configurados |
| **Verify (F7)** | `especialista-asvs`, `revisor-de-seguranca`, `pentester` | Verificação ASVS por nível, revisão contra threat model, pentest |
| **Operate (F8–F9)** | `especialista-cis-benchmarks`, `especialista-de-hardening`, `guardiao-de-seguranca` | Infra endurecida, benchmarks aplicados, vigilância contínua de CVEs |

## Ordem de trabalho recomendada

1. **Coordenador** abre a dimensão em F1 e define o **perfil de risco** do produto (calibra o esforço
   de todos os outros — L1 vs L3 no ASVS, STRIDE completo vs superficial).
2. **Modelador de ameaças** corre por cada funcionalidade crítica assim que a especificação (F5)
   estabiliza; alimenta o design com controlos.
3. **Especialista OWASP Top 10** acompanha o desenho e a construção (F3, F6) e revê o código (F7).
4. **ASVS** verifica em F7 contra o nível de risco decidido.
5. **CIS, hardening e headers** endurecem a infra e o serviço em F8, antes do go-live.
6. O coordenador **fecha a dimensão** consolidando o risco residual, que o utilizador assina.

## Como o Orquestrador a convoca

O `core/orchestrator.md` **não trata segurança como uma paragem única**: inscreve o coordenador
como participante permanente e convoca cada especialista no portão da sua fase
(`core/quality-gates.md`). O gate de segurança do go-live é a
`checklists/pre-production-security.md`; a automação corre em `pipelines/ci-security.md`; os
problemas encontrados alimentam o `loops/L03-security-issues.md` (e o `loops/L07-cves.md` na
operação). A revisão independente é do `agents/12-reviewers/security-reviewer.md`.

## Relacionados

- `agents/13-guardians/security-guardian.md` — a continuação em produção desta categoria.
- `modules/rbac-and-scoping.md` · `modules/audit-and-provenance.md` — capacidades que a segurança exige.
- `checklists/pre-production-security.md` · `pipelines/ci-security.md`
- `workflows/W07-quality-and-security.md` — a fase onde a categoria se concentra.
