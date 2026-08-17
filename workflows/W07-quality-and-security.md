# W07 — Qualidade & Segurança (Fase F7)

O escrutínio independente entre o "MVP aceite" e o "mundo real": um **painel de revisores** que olha
o produto por várias dimensões ao mesmo tempo, uma **auditoria adversarial** que tenta parti-lo de
propósito, e um **gate de segurança pré-produção** com pentest autorizado. Nada aqui constrói — tudo
aqui **verifica**, e o princípio que justifica a fase é uma armadilha concreta de IA: **quem produz
nunca valida o próprio trabalho** e **uma só perspetiva não chega** (`knowledge/ai-pitfalls.md`
§20–21).

> **Fase:** F7 · **Portão de entrada:** P6b (MVP aceite vs spec; harness de regressão verde)
> · **Portão de saída:** P7 (zero achados críticos/altos abertos; risco residual assinado)
> · **Workflow anterior:** `workflows/W06-build.md` · **seguinte:** `workflows/W08-launch.md`
> · **Convocado também por:** `workflows/W12-global-review.md` (mesma mecânica, âmbito global).

## Objetivo

Dar ao utilizador uma decisão fundamentada — **lança-se ou não?** — assente em evidência
independente, não na palavra de quem construiu. F7 produz um **plano consolidado de correções** e um
**registo de risco residual assinado**; sai limpa ou não sai.

## Pré-condições (portão de entrada)

- [ ] P6b passou: MVP completo confrontado com `product/04-specification/`, todos os RF do MVP com
      código e teste rastreável, harness de regressão verde no ambiente-alvo.
- [ ] `product/05-security/threat-model.md` (de F5) existe e está `aprovado` — dá o mapa de ataque
      ao painel e ao pentester.
- [ ] Dívida técnica conhecida **registada** (`loops/L08-technical-debt.md`), não escondida.
- [ ] Build reprodutível num ambiente equivalente ao de produção (senão o pentest testa o quê?).

Se algo falta, **não se abre F7** — devolve-se à construção (`core/lifecycle.md` regra 2).

## Passos (agente → artefacto)

Três blocos: o painel corre **em paralelo e às cegas**; a auditoria e a segurança correm sobre a mesma
base; a consolidação funde tudo. Todos os relatórios vivem em `product/99-records/`.

| # | Agente | Artefacto | Depende de |
| --- | --- | --- | --- |
| 1 | Painel `agents/12-reviewers/` (arquitetura, backend, frontend, ux, devops, performance, segurança, documentação, testes) | um relatório por revisor em `product/99-records/reviews/<dimensao>-AAAA-MM-DD.md` (molde `templates/technical/review-report.md.template`) | MVP + specs |
| 2 | `agents/09-security/security-coordinator.md` (coordena OWASP, ASVS, least-privilege, headers, TLS, segredos expostos, dependências, containers, infra) | `checklists/pre-production-security.md` preenchida + achados em `product/05-security/` | threat-model |
| 3 | `agents/09-security/pentester.md` | relatório de intrusão autorizada (âmbito + provas de exploração) em `product/99-records/audits/pentest-AAAA-MM-DD.md` | build tipo-produção |
| 4 | `playbooks/adversarial-audit.md` (multidisciplinar, verificação independente de cada conclusão) | `product/99-records/audits/adversarial-AAAA-MM-DD.md` | 1–3 |
| 5 | `agents/12-reviewers/review-consolidator.md` | **plano consolidado** priorizado, sem duplicados nem contradições, em `product/99-records/reviews/plano-consolidado-AAAA-MM-DD.md` | 1–4 |

**Painel às cegas (`agents/12-reviewers/README.md`):** cada revisor recebe os mesmos artefactos e o
mesmo âmbito mas **não lê os relatórios dos outros** — a convergência de dois pareceres separados é
sinal forte; a contaminação destrói-o. O `consolidador-de-revisoes` é o **único** que lê tudo, e só
**depois** de todos terem escrito. O `coordenador-de-seguranca` tem assento transversal
(`core/lifecycle.md` §5): segurança não é um passo, é uma dimensão presente em todos.

> **Escala ao perfil:** num protótipo, o painel colapsa no mínimo (segurança + arquitetura) e o
> Orquestrador consolida; numa plataforma empresarial corre o painel completo, ASVS nível 2+ e a
> auditoria adversarial é obrigatória antes do go-live (`core/orchestrator.md` §Perfis).

## Pontos de decisão

- **Severidade → destino.** Cada achado do plano consolidado tem severidade (**bloqueador · maior ·
  menor · nit**). **Bloqueadores e maiores voltam à construção** (`workflows/W06-build.md`) pelos
  loops certos; menores/nits podem ser dívida registada se o utilizador aceitar.
- **Aprovação humana obrigatória (P7):** o **risco residual** é decisão do utilizador — os achados
  que se decide **não** corrigir ficam em `product/05-security/residual-risk.md` **assinados** por
  ele, com o porquê e o risco assumido (`core/orchestrator.md` §Aprovação humana). O agente
  recomenda; nunca aceita risco em nome do utilizador.
- **Derrogação de critério** (um item da checklist que não passa mas se decide seguir na mesma) é do
  utilizador e regista-se (`core/quality-gates.md`) — nunca um atalho do Orquestrador.

Exemplo multi-domínio: num **SaaS B2B**, o revisor-de-backend confirma que um utilizador do tenant A
não vê dados do tenant B (fora-de-scope → 404); num **e-commerce**, o pentester tenta forjar o preço
no carrinho e o coordenador-de-segurança verifica que o total é sempre recalculado no servidor; numa
**app interna**, o revisor-de-ux percorre o offboarding real e confirma que liberta **todos** os
recursos da pessoa, não só o primeiro.

## Loops que abre

- `loops/L03-security-issues.md` — enquanto houver problema de segurança aberto, resolve-se por
  severidade; alimentado pelo coordenador, pelo pentester e pelo revisor-de-seguranca.
- `loops/L02-failing-tests.md` — regressões descobertas no escrutínio corrigem-se na causa, nunca no
  teste. Não se fecha F7 com vermelho.
- `loops/L04-code-smells.md` — smells acima do limiar apontados pelos revisores melhoram-se sem mudar
  comportamento.
- `loops/L05-inconsistencies.md` — divergência docs↔código↔dados detetada pelo painel reconcilia-se
  com a fonte de verdade (a spec ganha).
- `loops/L07-cves.md` — CVEs em dependências levantados pela análise de supply-chain entram na triagem.

Salvaguarda anti-loop (`loops/README.md`): três iterações sem progresso param o loop e sobem ao
utilizador com diagnóstico — não se insiste às cegas.

## Portão de saída (P7)

`core/quality-gates.md`:

- [ ] **Zero achados críticos/altos (bloqueadores/maiores) por resolver** no plano consolidado — os
      resolvidos com prova de correção, os aceites assinados como risco residual.
- [ ] `checklists/pre-production-security.md` **completa** (headers, TLS, segredos fora do Git,
      SAST/DAST/dependency/container scan, least privilege).
- [ ] Pentest sem exploração crítica em aberto; achados do pentester tratados ou aceites.
- [ ] Plano consolidado **limpo** e `product/05-security/residual-risk.md` **assinado pelo utilizador**.

**Quem verifica:** o `consolidador-de-revisoes` (substância) + o Orquestrador (completude da checklist).
**Quem aprova:** o utilizador (risco residual). Com P7 fechado, arranca `workflows/W08-launch.md`.
Enquanto houver bloqueador, F7 **não passa** — o produto volta à construção e reentra no painel.

## Perfis de esforço

| Perfil | Profundidade de F7 |
| --- | --- |
| **Protótipo** | Painel mínimo (segurança + arquitetura), consolidação pelo Orquestrador, sem pentest formal; a checklist de segurança corre na mesma no essencial. |
| **Produto interno** | Painel nos fluxos críticos; scans automatizados; pentest leve; risco residual assinado. |
| **Produto comercial** | Painel completo; **auditoria adversarial obrigatória** antes do go-live; pentest completo; guardiões já preparados para F9. |
| **Plataforma empresarial** | + ASVS nível 2+, verificação independente de cada conclusão, revisão global periódica (`workflows/W12-global-review.md`). |

## Anti-padrões

- ❌ Revisor omnisciente que passa por tudo com pouca profundidade → ✅ uma dimensão por revisor.
- ❌ Painel que lê os pareceres uns dos outros → ✅ revisões às cegas, consolidação depois.
- ❌ "Sem achados críticos, logo seguro" sem pentest nem auditoria → ✅ tentar parti-lo de propósito.
- ❌ Agente a "aceitar" risco residual → ✅ só o utilizador assina o que fica por corrigir.

## Relacionados

- `agents/12-reviewers/README.md` — o painel, o formato de relatório e a consolidação.
- `agents/09-security/README.md` — a cobertura de segurança (design → build → verify → operate).
- `playbooks/adversarial-audit.md` — o escrutínio máximo desta fase.
- `checklists/pre-production-security.md` · `checklists/pr-review.md` · `checklists/pre-merge.md`
- `core/quality-gates.md` — P7 em detalhe.
- `workflows/W06-build.md` (de onde vem) · `workflows/W08-launch.md` (para onde vai) · `workflows/W12-global-review.md`.
