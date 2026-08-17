# CI de Segurança (Security CI)

Pipeline que corre em paralelo ao `pipelines/ci-quality.md`, dedicado a encontrar problemas de
segurança antes de chegarem a produção: código, dependências, segredos, imagens e, em cadência
própria, o próprio ambiente de teste em execução. Materializado por
`agents/07-devops/github-actions-specialist.md` (ou fornecedor equivalente); as regras de scan
concretas vêm de `agents/09-security/`.

## Princípios

- **Shift-left, mas sem fadiga de alertas.** Os scans correm o mais cedo possível (a cada push), mas
  só **bloqueiam por severidade**, não por qualquer achado — ruído sem prioridade ensina a equipa a
  ignorar o pipeline.
- **Secrets scan cobre diff E histórico.** Um segredo commitado há 40 commits é tão real como um no
  último — o scan de diff apanha o novo a cada push, o scan de histórico completo (periódico) apanha
  o esquecido.
- **Achado sem correção imediata não desaparece — vira loop.** O que não se resolve no próprio job
  entra em `loops/L03-security-issues.md` (achados abertos) ou `loops/L07-cves.md` (CVEs de
  dependências), com dono e prazo por severidade.
- **SBOM é artefacto vivo**, gerado a cada build — não um documento produzido uma vez e esquecido; é a
  base da resposta a um CVE anunciado no dia seguinte (`agents/09-security/sbom-manager.md`).
- **DAST não corre em cada PR.** É lento e precisa de um ambiente implantado; corre agendado contra um
  ambiente de teste estável, não a cada alteração de uma linha.

## Estágios

1. **Gatilho** — SAST, secrets scan (diff) e dependency scan correm em todo `push`/PR (suficientemente
   rápidos). Container scan corre ao construir a imagem. DAST e o secrets scan de histórico completo
   correm **agendados** (ex.: nocturno/semanal), nunca por PR.
2. **SAST** — análise estática do código-fonte por regras de segurança
   (`agents/09-security/sast-specialist.md`); bloqueia por limiar de severidade acordado.
3. **Secrets scan (diff)** — em todo commit novo, verifica só o que mudou; qualquer segredo confirmado
   bloqueia de imediato e dispara `playbooks/secrets-management.md` (rotação de emergência).
4. **Secrets scan (histórico completo)** — periódico, varre o repositório inteiro
   (`agents/09-security/exposed-secrets-hunter.md`). Um achado **confirmado real e vivo**
   dispara de imediato a rotação de emergência (`playbooks/secrets-management.md` — revogar +
   rodar), como no estágio 3; os restantes (falsos positivos, dummies, e a decisão de limpar ou
   reescrever o histórico) abrem item em `loops/L03-security-issues.md` para triagem — não
   se corrige sozinho o passado.
5. **Dependency scan (SCA)** — CVEs conhecidas em dependências diretas e transitivas
   (`agents/09-security/dependency-analyst.md`); bloqueia por severidade, alimenta
   `loops/L07-cves.md` para o resto.
6. **Container scan** — imagem construída, antes do *push* ao registry
   (`agents/09-security/container-analyst.md`); bloqueia em crítico/alto.
7. **Geração de SBOM** — a cada build, anexado ao artefacto e versionado
   (`agents/09-security/sbom-manager.md`); consumido por resposta a CVE futura
   (`playbooks/cve-response.md`).
8. **DAST agendado** — contra o ambiente de teste, cadência regular (ex.: diária/semanal)
   (`agents/09-security/dast-specialist.md`); achados entram na mesma triagem de severidade.

## Triagem de findings (o que bloqueia)

| Severidade | Efeito |
| --- | --- |
| Crítica / Alta | Bloqueia merge (código) ou promoção (container/DAST); corrige antes de avançar |
| Média | Não bloqueia; entra em `loops/L03-security-issues.md` ou `loops/L07-cves.md` com prazo |
| Baixa / informativa | Registada, revista em cadência pelo `agents/13-guardians/security-guardian.md`, sem bloquear |

Um segredo confirmado bloqueia sempre, independentemente da severidade atribuída pela ferramenta —
não existe "segredo de baixa severidade" (`knowledge/permanent-rules.md` §5).

## Exemplo (pseudocódigo neutro, ilustrativo)

```yaml
pipeline: ci-seguranca
gatilhos: [push, pull_request, agendado(diario)]
estagios:
  - job: sast
    corre_em: [push, pull_request]
    bloqueia_se: severidade >= alta
  - job: secrets-scan-diff
    corre_em: [push, pull_request]
    bloqueia_se: achado_confirmado
  - job: dependency-scan
    corre_em: [push, pull_request]
    bloqueia_se: severidade >= alta
    senao: abre_item(loops/L07-cves.md)
  - job: container-scan
    corre_em: [build_imagem]
    bloqueia_se: severidade >= critica
  - job: gerar-sbom
    corre_em: [build_imagem]
    produz: sbom-versionado
  - job: secrets-scan-historico
    corre_em: [agendado(semanal)]
    senao: abre_item(loops/L03-security-issues.md)
  - job: dast
    corre_em: [agendado(diario)]
    alvo: ambiente-de-teste
```

## Relacionados

- `pipelines/README.md` · `pipelines/ci-quality.md` · `pipelines/cd-delivery.md`
- `loops/L03-security-issues.md` · `loops/L07-cves.md`
- `checklists/pre-production-security.md` · `playbooks/secrets-management.md` · `playbooks/cve-response.md`
- `agents/09-security/security-coordinator.md` · `agents/09-security/sbom-manager.md`
