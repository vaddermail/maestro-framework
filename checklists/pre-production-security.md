# Segurança Antes de Produção

O gate de segurança do portão P7 → F8 (`core/quality-gates.md`): nenhum produto avança para
`checklists/go-live.md` sem esta checklist completa. Dono: `agents/09-security/security-coordinator.md`;
corre em F7 e repete-se a cada release relevante em F9.

## Headers e transporte

- [ ] Headers de segurança configurados (CSP, HSTS, `X-Content-Type-Options`, `frame-ancestors`) —
      `agents/09-security/http-headers-specialist.md`.
- [ ] TLS moderno em todos os pontos de entrada (sem TLS 1.0/1.1, cifras atuais) —
      `agents/09-security/tls-specialist.md`.
- [ ] Certificados com renovação automática verificada, não dependente de ação manual.

## Segredos

- [ ] Nenhum segredo no repositório Git, incluindo histórico — varrido por
      `agents/09-security/exposed-secrets-hunter.md`.
- [ ] Segredos de produção vivem fora do código, injetados em runtime, e são rodáveis sem novo deploy
      (`playbooks/secrets-management.md`).
- [ ] Rotação de segredos críticos tem procedimento e dono definidos
      (`agents/09-security/secrets-and-rotation-manager.md`).

## Scans automatizados

- [ ] SAST corrido sobre o código atual, sem achados críticos/altos abertos
      (`agents/09-security/sast-specialist.md`).
- [ ] Dependency scan sem CVEs críticos/altos sem tratamento
      (`agents/09-security/dependency-analyst.md`).
- [ ] Scan de containers/imagens sem vulnerabilidades críticas por corrigir
      (`agents/09-security/container-analyst.md`).
- [ ] Secrets scan do pipeline de CI limpo (`pipelines/ci-security.md`).
- [ ] Cada achado não corrigido tem risco aceite explicitamente pelo utilizador, com prazo de
      remediação — nunca ignorado em silêncio.

## Autenticação, autorização e least privilege

- [ ] Verificação ASVS no nível decidido para o produto corrida e sem falhas por resolver
      (`agents/09-security/asvs-specialist.md`).
- [ ] Cobertura OWASP Top 10 confirmada na revisão de código
      (`agents/09-security/owasp-top10-specialist.md`).
- [ ] Autorização e scoping confirmados como responsabilidade exclusiva do servidor — nenhuma decisão
      de acesso só no cliente (`modules/rbac-and-scoping.md`).
- [ ] Contas de serviço, credenciais de BD e permissões de cloud/CI seguem o mínimo necessário,
      verificado ponta a ponta (`agents/09-security/authorization-and-least-privilege-specialist.md`).
- [ ] Nenhuma credencial partilhada entre ambientes (dev/staging/produção).

## Backups e recuperação

- [ ] Backup automático configurado **e** testado com restauro real, não só agendado
      (`agents/06-data/backup-specialist.md`).
- [ ] RTO/RPO definidos e aceites pelo utilizador (`agents/06-data/disaster-recovery-planner.md`).

## Risco residual

- [ ] Lista de achados aceites (não corrigidos) com justificação, **assinada explicitamente pelo
      utilizador** — nunca uma decisão silenciosa do agente (`core/quality-gates.md`).

## Relacionados

- `core/quality-gates.md` — o portão P7 que esta checklist fecha.
- `checklists/go-live.md` — o portão seguinte, que depende desta.
- `pipelines/ci-security.md` — a automação dos scans.
- `agents/09-security/README.md` — a categoria completa e o mapa de cobertura.
- `playbooks/secrets-management.md` — detalhe de segredos e rotação.
- `agents/13-guardians/security-guardian.md` — a continuação em produção.
