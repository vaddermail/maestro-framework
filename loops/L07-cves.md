# L07 — CVEs

> Loop `L07` da framework Maestro — persiste enquanto existirem CVEs por triar, conduzindo cada
> um a um estado terminal (corrigido, mitigado, ou não-aplicável). Segue a anatomia de
> `loops/README.md`.

Um CVE publicado sobre um componente que usamos não é uma tarefa opcional — é uma janela de tempo que
se fecha a favorecer quem ataca. Este loop existe para que nenhum CVE fique "em análise" sem dono nem
prazo.

## Identificação

| Campo | Valor |
| --- | --- |
| **Quando corre** | F9 — cadência de varrimento diário + por evento (publicação de CVE que afete o SBOM) |
| **Agente que executa a ação** | `agents/13-guardians/security-guardian.md`, seguindo `playbooks/cve-response.md`; coordena com `agents/13-guardians/dependency-guardian.md` quando a correção é um bump de dependência |
| **Modelo sugerido** | Padrão para triagem e CVEs de severidade baixa/média; Topo para análise de impacto e plano de patch de CVEs críticos (`core/model-routing.md`) |

## Métrica de progresso

Número de CVEs aplicáveis (afetam um componente do SBOM) ainda sem **estado terminal**
(corrigido-e-validado / mitigado-com-risco-aceite / não-aplicável-justificado).

## Condição de entrada

Um feed de CVE, um aviso de dependência, ou um scanner de `pipelines/ci-security.md` reporta ≥1 CVE
que afeta um componente presente no SBOM (`agents/09-security/sbom-manager.md`), ainda sem estado
terminal.

## Ação (o corpo da iteração)

Segue `playbooks/cve-response.md` passo a passo:

1. Confirmar aplicabilidade contra o SBOM (versão afetada, componente realmente usado).
2. Analisar impacto real cruzando com o threat model (explorabilidade no contexto concreto, não só o
   score).
3. Planear: patch disponível? risco de regressão? mitigação temporária possível?
4. Aplicar o patch (ou acionar o `guardiao-de-dependencias` para o bump) atrás de flag se o risco de
   regressão for alto.
5. Validar: regressão verde + prova-live que confirma que a vulnerabilidade fechou.

## Condição de saída (sucesso)

Zero CVEs aplicáveis sem estado terminal. Cada um documentado: corrigido e validado, mitigado com
risco residual assinado pelo utilizador, ou não-aplicável com a justificação escrita.

## Salvaguarda anti-loop-infinito

- **Estagnação:** 3 iterações sobre o mesmo CVE sem o mover de estado → parar esse CVE especificamente.
- **Oscilação:** aplicar o patch de um CVE reintroduz outro (o bump quebra uma dependência que volta a
  ficar vulnerável numa versão diferente) → parar de imediato, tratar como decisão de arquitetura de
  dependências, não como mais uma tentativa.
- **Teto duro:** 4 iterações por CVE. Ultrapassado, o CVE sobe a candidato a **risco residual** — nunca
  fica silenciado sem decisão; o utilizador decide aceitar (com prazo de revisão), mitigar de outra
  forma, ou financiar a migração maior que o resolve.

## Registo em STATE.md

```
L07 · CVEs · métrica 4→2→2 · iter 3 (teto 4) · último progresso: iter 2 · estado: EM RISCO
```

## Exemplo (e-commerce — checkout com processamento de imagens de produto)

O varrimento diário sinaliza um CVE crítico numa biblioteca de processamento de imagens usada para
gerar miniaturas de produto ao carregar novos artigos. Confirmado no SBOM: versão afetada até 3.2.1,
usamos 3.2.0. Threat model: a biblioteca processa ficheiros carregados por fornecedores autenticados
no painel de catálogo — explorável, superfície limitada a esse papel. Patch disponível em 3.2.2, sem
breaking changes. Aplica-se já; regressão verde; prova-live com uma imagem malformada conhecida
(rejeitada corretamente). O CVE fecha como corrigido-e-validado, SBOM atualizado, lição registada:
"processamento de imagem de terceiros: manter na última patch; superfície = upload de fornecedores."

## Relacionados

- `agents/13-guardians/security-guardian.md` — dono do ciclo completo deste loop.
- `playbooks/cve-response.md` — o procedimento passo-a-passo que a ação segue.
- `agents/09-security/sbom-manager.md` — o inventário sem o qual não há análise de impacto fiável.
- `agents/13-guardians/dependency-guardian.md` — executa os bumps de correção.
- `checklists/pre-production-security.md` — o portão que este loop tem de satisfazer antes do go-live.
- `workflows/W09-continuous-operation.md` — a cadência de F9 onde este loop corre por defeito.
