# Pré-Merge

Corre antes de qualquer merge para o ramo de integração — a evidência do portão P6 por fatia
(`core/quality-gates.md`). Complementa `checklists/pr-review.md` (a qualidade e correção
do código) com o estado do repositório e do pipeline: sem isto verde, não se integra.

## Qualidade automática

- [ ] Lint sem erros nem avisos novos introduzidos pela mudança.
- [ ] Typecheck sem erros, no frontend **e** no backend, corridos **separadamente**
      (`knowledge/permanent-rules.md` §7).
- [ ] Build de produção conclui sem erros.

## Testes

- [ ] Testes do frontend correm e passam, isolados do backend
      (`agents/04-frontend/frontend-test-engineer.md`).
- [ ] Testes do backend correm e passam, isolados do frontend.
- [ ] Testes cobrem a lógica de risco tocada (regras de negócio, autorização, reversibilidade) — não
      só o caminho feliz.
- [ ] Nenhum teste foi desativado, apagado ou enfraquecido para "fazer passar"; a causa foi corrigida,
      nunca o detetor (`loops/L02-failing-tests.md`).

## Revisão

- [ ] Revisão feita por alguém que não é o autor da alteração — `checklists/pr-review.md`
      cumprida.
- [ ] Achados da revisão resolvidos ou explicitamente aceites, com o porquê registado.

## Segredos e segurança

- [ ] Diff varrido — sem chaves, passwords, tokens ou credenciais (`playbooks/secrets-management.md`).
- [ ] Nenhum ficheiro de configuração local/segredo (`.env` ou equivalente) staged por engano.
- [ ] Dependências novas sem CVE crítico/alto conhecido por tratar
      (`agents/09-security/dependency-analyst.md`).

## Reversibilidade

- [ ] A mudança tem caminho de reversão claro: revert simples, flag, ou migração com plano de down
      (`knowledge/permanent-rules.md` §3).
- [ ] Alteração de esquema de BD é aditiva (expand) ou já entrou na contração planeada — nunca as duas
      no mesmo passo (`playbooks/expand-contract-db-migration.md`).
- [ ] Mudança de risco fica atrás de flag/kill-switch quando o rollback por redeploy é lento
      (`modules/feature-flags.md`).

## Memória e documentação

- [ ] `STATE.md` atualizado com o que mudou.
- [ ] Documentação ou ajuda ao utilizador sincronizada, se a mudança afeta comportamento visível
      (`agents/11-documentation/user-help-writer.md`).
- [ ] `CHANGELOG.md` atualizado, se for um marco.

## Relacionados

- `checklists/pr-review.md` — a qualidade do código que este portão pressupõe.
- `checklists/definition-of-done.md` — a definição de pronto por alteração de código.
- `core/quality-gates.md` — o portão P6 que esta checklist evidencia.
- `pipelines/ci-quality.md` — a automação que corre estes itens.
- `playbooks/secrets-management.md` — o detalhe do varrimento de segredos.
- `knowledge/permanent-rules.md` — reversibilidade, testes e disciplina de Git.
