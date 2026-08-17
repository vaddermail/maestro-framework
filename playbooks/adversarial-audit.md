# Playbook — Auditoria Adversarial

Uma revisão **extensa, adversarial e multidisciplinar** do produto, com **verificação independente de
cada conclusão** antes de a aceitar. Operacionaliza `knowledge/permanent-rules.md` §7 e as
armadilhas `knowledge/ai-pitfalls.md` §20 (auto-validação) e §21 (uma só perspetiva não chega).
É a escalada do painel de revisão normal (`agents/12-reviewers/README.md`): mais lentes, mandato de
**refutar**, e um filtro de verificação que só deixa entrar no relatório o que foi reproduzido.

**Quando se executa:** em **marcos** importantes, em **pré-produção** (antes do go-live,
`workflows/W07-quality-and-security.md`), na revisão global sob pedido
(`workflows/W12-global-review.md`), e sempre que o utilizador a pedir. **Quem:** o Orquestrador
(`core/orchestrator.md`) monta o painel; os auditores são agentes independentes, **nenhum autor do
que audita**.

## O que a distingue do painel normal de F7

| Painel normal (F7) | Auditoria adversarial |
| --- | --- |
| Cada revisor procura o que pode estar mal na **sua dimensão** | Cada auditor tem **mandato explícito de refutar** — a hipótese nula é "isto está errado" |
| Um achado plausível por inspeção pode entrar no relatório | Um achado **não reproduzido não entra** — verificação independente é gate |
| Convocado a cada fatia/release | Reservado a marcos, pré-produção e pedido (é caro por desenho) |
| Consolidação funde relatórios | Consolidação funde **e** re-verifica os bloqueadores antes de os promover |

## Pré-condições

- [ ] Âmbito congelado: que fatia/release/commits se auditam, com os artefactos disponíveis
      (`core/artifact-protocol.md`).
- [ ] Ambiente de prova-live real disponível (não só testes — `knowledge/ai-pitfalls.md` §2, §18).
- [ ] Camada de modelo por lente escolhida (`core/model-routing.md`); a verificação/juízo
      adversarial mais difícil justifica o tier de topo.

## Passos

### 1. Fixar âmbito e lentes
**Faz:** definir o âmbito exato e as **lentes** — no mínimo: **correção**, **segurança**,
**integridade de dados**, **silent failures**, **UX**, **testes** (acrescentar performance, arquitetura,
docs conforme o risco). Uma lente por auditor.
**Verifica:** cada lente tem um auditor atribuído e os artefactos de que precisa; nenhuma lente crítica
para este marco ficou sem dono.
**Se falhar:** se falta artefacto para uma lente, registar como "não verificável" (honestidade absoluta),
não deixar o auditor **assumir** (`knowledge/ai-pitfalls.md` §3).

### 2. Lançar auditores independentes, às cegas, um por lente
**Faz:** lançar os auditores **em paralelo**, cada um com o mesmo âmbito mas **sem ler os relatórios dos
outros** (a convergência de dois pareceres separados é sinal forte; a contaminação destrói-o —
`agents/12-reviewers/README.md`). Mandato a cada um: **encontrar o que está mal, não confirmar que está
bem.**
**Verifica:** nenhum auditor é autor do que audita; nenhum recebeu o relatório de outro enquanto
trabalhava.
**Se falhar:** se só há uma perspetiva disponível, isso **não** é auditoria adversarial — é uma revisão
simples; dizê-lo como tal (`knowledge/ai-pitfalls.md` §21).

### 3. Cada achado com cenário de falha concreto
**Faz:** cada auditor escreve no molde comum (`templates/technical/review-report.md.template`):
`id`, severidade (**bloqueador · maior · menor · nit**), localização (`ficheiro:linha`/artefacto), o
defeito em uma frase, o **cenário de falha concreto** (inputs/estado → resultado errado), a recomendação
e a **confiança** (`confirmado` se reproduzido, `plausível` se por inspeção).
**Verifica:** nenhum achado é vago ("parece frágil") — cada um diz **como** falha, com inputs.
**Se falhar:** um achado sem cenário concreto volta ao auditor; não avança para verificação sem os
inputs que o reproduzem.

### 4. Verificação independente de cada conclusão (o gate)
**Faz:** para cada achado, **um verificador que não é o autor do achado** tenta reproduzi-lo a partir do
cenário concreto. Achado reproduzido → `confirmado`. Não reproduzido → fica **fora do relatório** (ou
como pista a investigar, nunca como conclusão).
**Verifica:** todo o achado no relatório final é `confirmado` por reprodução independente; achados de
correção, autorização, dinheiro, dados pessoais e fluxos irreversíveis receberam o máximo escrutínio
(`MANIFESTO.md` §9).
**Se falhar:** **um achado não verificado não entra no relatório** — é a regra central deste playbook.
Reportar suspeitas como factos é a mesma falha que a auto-validação que a auditoria existe para evitar.

### 5. Consolidar num plano único priorizado
**Faz:** o `agents/12-reviewers/review-consolidator.md` funde os relatórios num plano único, sem
duplicados nem contradições, ordenado por **risco real** (um `confirmado` vale mais que dez suspeitas),
não por número de achados. Re-verificar os bloqueadores antes de os promover.
**Verifica:** o plano não tem achados repetidos por lentes diferentes nem recomendações que se
contradizem; cada bloqueador liga ao portão de qualidade (`core/quality-gates.md`).
**Se falhar:** contradições entre lentes resolvem-se re-verificando, não escolhendo a mais conveniente.

### 6. Encaminhar e fechar
**Faz:** os bloqueadores voltam à construção pelos loops respetivos (`loops/L02-failing-tests.md`,
`loops/L03-security-issues.md`, `loops/L04-code-smells.md`, `loops/L05-inconsistencies.md`); a
auditoria fecha quando o portão de F7 passa (`core/quality-gates.md`). Para segurança, o painel
integra o `agents/09-security/pentester.md`.
**Verifica:** cada bloqueador tem um loop/dono; o veredicto global (`passa` · `passa-com-ressalvas` ·
`bloqueia`) está registado — um único bloqueador basta para bloquear.
**Se falhar:** se um bloqueador não tem dono nem loop, a auditoria **não** fechou; não dar go-live com
bloqueadores por resolver.

## Reversão

A auditoria é **não-destrutiva por natureza** — só lê e relata, não altera o produto; não há o que
reverter no ato de auditar. As **correções** que ela desencadeia seguem a reversibilidade normal (branch,
PR verde, flags/kill-switch para mudanças de risco — `knowledge/permanent-rules.md` §3). A
convergência de **duas** auditorias independentes é confiança alta; mesmo essa se volta a verificar
antes de um go-live irreversível.

## Relacionados

- `agents/12-reviewers/README.md` — o painel de revisão que esta auditoria escala.
- `agents/12-reviewers/review-consolidator.md` — a consolidação num plano único.
- `knowledge/ai-pitfalls.md` — §20 (auto-validação), §21 (uma só perspetiva).
- `knowledge/permanent-rules.md` §7 — verificação e auditoria com máxima abrangência.
- `workflows/W07-quality-and-security.md` · `workflows/W12-global-review.md` · `core/quality-gates.md`
- `templates/technical/review-report.md.template` · `agents/09-security/pentester.md`
- `loops/L02-failing-tests.md` · `loops/L03-security-issues.md` · `loops/L05-inconsistencies.md`
