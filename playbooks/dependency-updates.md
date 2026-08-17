# Atualização de Dependências

Procedimento de atualização **deliberada** de bibliotecas, frameworks e runtimes — nunca "à deriva",
nunca por reflexo de um bot. Executado pelo `agents/13-guardians/dependency-guardian.md` em
cadência semanal (rotina) e mensal (majors/EOL), ou dentro de `workflows/W06-build.md` quando uma
fatia precisa de uma versão mais recente. Majors com breaking changes sobem sempre ao utilizador.

## Pré-condições

- Lockfiles/manifests existentes e a verdade do que está instalado.
- Harness de regressão a funcionar, com frontend e backend separados. Sem ele, este playbook **não
  atualiza às cegas**: sinaliza a lacuna ao Orquestrador e regista-a.
- `product/02-architecture/stack.md` com as versões-alvo e política de suporte.

## Passos

1. **Listar desatualizadas.** Comparar lockfile/manifest com o upstream; anotar o salto (patch/minor/
   major) e o estado de suporte (EOL?) de cada uma. *Verifica-se* revendo manualmente o output da
   ferramenta de dependências — nunca aceite tal-e-qual. *Se a lista vier de um bot automático*:
   trata-se como input a triar, nunca como decisão pronta a fazer merge.

2. **Priorizar.** EOL e majors de segurança adiadas primeiro; depois minors com correções úteis;
   patches triviais agrupados em lote leve. *Verifica-se* que cada item tem uma prioridade escrita.

3. **Ler o changelog de cada dependência relevante — obrigatório antes de qualquer bump.** Procurar
   breaking changes, funções removidas/depreciadas, mudanças de comportamento silenciosas (ex.:
   mapeamento de erros que muda sem aviso — `knowledge/ai-pitfalls.md` §16). *Verifica-se* com
   um resumo escrito do changelog, não uma impressão. *Se não houver changelog acessível*: trata-se
   como major de risco (sobe ao utilizador) até prova em contrário.

4. **Agrupar em lote pequeno e coerente.** Um PR por dependência, ou por grupo coeso (ex.: todas as
   libs de teste de uma área) — nunca um "atualizar tudo" num PR só. *Verifica-se* que o diff toca
   apenas lockfile + manifest + o código de adaptação estritamente necessário.

5. **Aplicar o bump e regenerar o lockfile.** Subir a versão no manifest; regenerar o lockfile de
   forma determinística. *Verifica-se* que um rebuild do lockfile dá o mesmo resultado. *Se a versão
   não ficar fixada exatamente*: falhar o passo — sem versão fixada não há atualização deliberada
   (`knowledge/permanent-rules.md` §6).

6. **Correr o harness completo.** Regressão de frontend e de backend, em separado, ambos verdes, mais
   a suíte específica do que a dependência toca. *Verifica-se* com o output real anexado. *Se falhar*:
   investigar a causa antes de culpar a dependência por reflexo; se confirmado que é uma breaking
   change não documentada, registar como lição.

7. **Smoke test live nos caminhos tocados.** Exercitar manualmente (ou via harness) os fluxos reais que
   a dependência afeta, no ambiente-alvo. *Verifica-se* com evidência concreta (output/captura) — não
   "deve funcionar".

8. **Decidir majors com breaking changes.** Nunca à deriva: escrever o plano (custo de migração, ganho,
   janela sugerida) e subir ao utilizador via `core/question-engine.md`. *Verifica-se* pela
   decisão explícita registada antes de aplicar. *Se a major chegar a EOL sem substituto*: escalar como
   risco de segurança futura, não como rotina.

9. **Fixar deliberadamente quando não se sobe.** Se a versão nova larga uma funcionalidade em uso,
   decide-se não subir — registar o porquê e um prazo de revisão em `STATE.md` /
   `loops/L08-technical-debt.md`. *Verifica-se* que a justificação existe por escrito, para não
   reaparecer como ruído na próxima cadência.

10. **Merge via PR verde e documentar.** Relatório do ciclo em
    `product/99-records/guardians/dependencias-AAAA-MM-DD.md`
    (`templates/technical/guardian-report.md.template`); dívida adiada/fixada registada; lições
    não-óbvias em `STATE.md`.

## Reversão

Cada bump é revertível por revert cirúrgico do PR + lockfile anterior — é por isso que o passo 4 isola
cada dependência ou grupo coeso num PR próprio (um "bump geral" que parte algo obriga a bissetar à
mão). Majors de risco que mudam comportamento entram atrás de `modules/feature-flags.md`, desligáveis
sem novo deploy. Uma dependência fixada (passo 9) não é uma reversão pendente — é uma decisão registada
com prazo de revisão, não um esquecimento.

## Relacionados

- `agents/13-guardians/dependency-guardian.md` — quem executa este playbook.
- `agents/13-guardians/security-guardian.md` — passa as correções urgentes que exigem major.
- `playbooks/cve-response.md` — quando a atualização é uma correção de segurança urgente, não rotina.
- `loops/L08-technical-debt.md` — onde a dívida de versões adiada/fixada se reduz de forma planeada.
- `checklists/pre-merge.md` — o gate comum a todo o PR antes de integrar.
- `knowledge/permanent-rules.md` §6 · `knowledge/ai-pitfalls.md` §16.
