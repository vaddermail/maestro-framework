# Auditoria e Proveniência · quem fez o quê, e de onde vieram os dados

> **Validação em produção:** 2.ª confirmação em domínio distinto do projeto-mãe (P2 — curadoria de 2026-08; nuances confirmadas: imutabilidade em 3 camadas — código sem
> UPDATE/DELETE → trigger+REVOKE na BD → hash-chain; particionar por mês **no dia 0**; least-privilege
> real do papel da aplicação). O desenho mantém-se; a confiança sobe.

Um módulo para dar a qualquer produto duas garantias que se pedem tarde e custam caro a acrescentar
depois: um **trilho de auditoria imutável** (quem fez o quê, quando, e o estado antes/depois) e a
**proveniência dos dados** — em especial dos que uma IA gerou ou enriqueceu, com origem, momento e um
caminho de **undo**. É a memória forense do sistema: responde a "quem autorizou isto?", "quem mudou este
valor e para quê era antes?" e "esta descrição foi escrita por uma pessoa ou sugerida por um modelo — e
como a reverto?".

## O problema que resolve

- **Não saber quem fez o quê.** Sem trilho, uma alteração indevida, um acesso suspeito ou uma decisão
  contestada não têm resposta — os próprios dados foram sobrescritos e o passado desapareceu.
- **Log de auditoria que se pode adulterar.** Um "histórico" que se edita ou apaga não é auditoria; é
  decoração. Se a mesma operação que altera o dado também pode reescrever o registo, não há garantia.
- **Enriquecimento por IA sem rasto.** Um modelo preenche um campo, sugere uma categoria, reescreve um
  texto — e ninguém distingue depois o que foi humano do que foi gerado, nem consegue desfazer uma
  sugestão que se revelou errada. Sem proveniência, o conteúdo de IA vira um facto irreversível de origem
  desconhecida (`knowledge/permanent-rules.md` §2).
- **Guardar tudo para sempre (ou nada).** Sem política de retenção, ou se acumula dados sensíveis
  indefinidamente (risco legal) ou se apaga o que era preciso para investigar.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Entrada de auditoria (`entradaAuditoria`)** — um registo **imutável** e append-only de um facto:
  **ator** (quem, ou que sistema/IA), **momento**, **ação**, **recurso** afetado, e o **antes/depois**
  (os valores mudados, não o objeto inteiro). Nunca se edita nem se apaga.
- **Proveniência (`proveniencia`)** — metadados sobre a **origem** de um dado: foi introduzido por um
  humano, importado de um sistema externo (`modules/readonly-external-integrations.md`), ou **gerado por
  IA**. No caso de IA, guarda o modelo/versão, o *prompt*/contexto de grounding, o momento e um nível de
  confiança quando exista — para o conteúdo ser *grounded* e reversível (`knowledge/origin-lessons.md`).
- **Undo/Reversão** — o caminho para desfazer uma alteração: como o trilho guarda o **antes**, um dado
  tocado por IA (ou por uma operação em massa) pode ser revertido ao valor anterior sem restauro manual
  heroico (`knowledge/permanent-rules.md` §3).
- **Correlação (`correlacao`)** — um identificador que amarra as entradas de uma mesma operação/pedido
  (várias mutações de uma transição são uma só história), ligando-se aos logs e traces
  (`agents/05-backend/logging-specialist.md`).
- **Política de retenção (`retencao`)** — por categoria de registo, quanto tempo se guarda e como se
  descarta (ou anonimiza) no fim, conciliando dever de auditoria e minimização de dados.

O trilho não é um `modules/job-queue.md` nem um log de aplicação: é um **facto de negócio persistido**,
tipicamente escrito na **mesma transação** do facto que descreve (como o outbox —
`knowledge/proven-patterns.md` §3), para nunca haver ação sem rasto nem rasto sem ação.

## Regras inegociáveis (numeradas, verificáveis)

1. **As entradas de auditoria são imutáveis e append-only.** Nenhum caminho de código as atualiza ou
   apaga (a expiração por retenção é a única remoção, e é ela própria auditada). Teste: tentar editar/apagar
   uma entrada é rejeitado pela camada de dados, não só pela app.
2. **Toda a ação sensível escreve trilho na mesma transação do facto.** Se o facto é confirmado, o rasto
   existe; se reverte, não fica rasto órfão. Teste: um rollback do facto deixa zero entradas; um facto
   confirmado tem sempre a sua entrada.
3. **Cada entrada identifica o ator, incluindo quando é IA ou sistema.** "Sistema" e "IA" são atores
   nomeados, não anónimos. Teste: nenhuma entrada tem ator vazio; uma alteração feita por IA identifica o
   modelo/versão.
4. **O trilho guarda o antes **e** o depois dos campos mudados.** Não basta "foi alterado"; guarda-se o
   valor anterior e o novo. Teste: a partir de uma entrada consegue-se reconstruir o valor prévio de cada
   campo tocado.
5. **Dados gerados/tocados por IA carregam proveniência e são reversíveis.** Origem (modelo, momento,
   grounding) registada e um caminho de undo ao valor anterior. Teste: um campo enriquecido por IA
   distingue-se de um humano e pode ser revertido sem restauro manual (`knowledge/permanent-rules.md`
   §2,§3).
6. **A auditoria não vaza o que a autorização esconde.** Ver o trilho respeita o RBAC e a redação por
   categoria de campo (`modules/rbac-and-scoping.md`): um campo sensível redigido no dado está redigido no
   antes/depois. Teste: quem não pode ver um campo também não o vê no histórico.
7. **Sem segredos no trilho.** PINs, chaves, tokens nunca se escrevem em claro numa entrada (guarda-se
   "alterado", não o valor). Teste: varrer o trilho não revela nenhum segredo (`knowledge/permanent-rules.md`
   §5).
8. **Existe política de retenção explícita por categoria.** Cada tipo de registo tem prazo e forma de
   descarte/anonimização. Teste: registos além do prazo são descartados/anonimizados conforme a política,
   e o descarte é ele próprio auditado.

## Como se adota num produto novo (passos)

1. **Listar as ações auditáveis** (as que mudam estado sensível, dinheiro, acessos, dados pessoais) e as
   **fontes de dados** que precisam de proveniência (importações, geração por IA).
2. **Modelar `entradaAuditoria` append-only** e a **proveniência** dos campos relevantes, impondo a
   imutabilidade na camada de dados (`knowledge/proven-patterns.md` §5;
   `agents/06-data/data-auditor.md`).
3. **Escrever o trilho dentro da transação** de cada facto (padrão outbox —
   `knowledge/proven-patterns.md` §3), com correlação partilhada com logs/traces.
4. **Ligar a proveniência de IA ao undo**: guardar o antes de cada campo enriquecido e expor a reversão
   (`knowledge/permanent-rules.md` §2,§3).
5. **Definir a retenção por categoria** e registá-la em ADR (`templates/project/ADR-DECISION.md.template`),
   conciliando auditoria com minimização/conformidade.
6. **Expor a auditoria com respeito pelo RBAC** (`modules/rbac-and-scoping.md`) e testar adversarialmente
   que nem segredos nem campos redigidos escapam (`playbooks/adversarial-audit.md`).

## Variações e trade-offs

- **Trilho aplicacional vs event sourcing.** Um trilho ao lado do estado atual é simples e chega à maioria
  dos produtos; event sourcing (o estado **é** a soma dos eventos) dá auditoria perfeita e *time-travel*,
  ao custo de complexidade grande — só quando o domínio o justifica.
- **Diff de campos vs snapshot completo.** Guardar só os campos mudados é compacto e legível; guardar o
  objeto inteiro a cada mudança é mais simples de reconstruir mas cresce depressa. O diff com antes/depois
  é o meio-termo habitual.
- **Retenção: longa (auditoria) vs curta (minimização).** Setores regulados exigem anos de trilho;
  proteção de dados pede minimizar. Resolve-se por categoria: reter o facto de auditoria, anonimizar os
  dados pessoais dentro dele quando o prazo destes expira.
- **Imutabilidade por convenção vs por construção.** Um trilho "que ninguém deve editar" erode; um trilho
  que a camada de dados **impede** de editar (append-only, permissões, hash encadeado) resiste
  (`knowledge/proven-patterns.md` §7).

## Exemplo (1–2, multi-domínio)

**Plataforma de conteúdo com IA de apoio.** Um editor usa um assistente que sugere título e resumo de um
artigo. Cada campo preenchido pela IA guarda **proveniência**: modelo, versão, momento e o contexto de
grounding (Regra 5). O editor vê um selo "sugerido por IA" e pode reverter ao valor anterior num clique
(o trilho guardou o antes — Regra 4). Se mais tarde se descobrir que o modelo alucinou uma data, todas as
sugestões daquela versão são localizáveis pela proveniência e revertíveis.

**Sistema bancário interno.** Cada alteração a uma conta (limite, morada, estado) escreve trilho na mesma
transação (Regra 2), com ator, antes/depois e correlação com o pedido. Os campos de IBAN e documento são
categoria sensível: quem não os pode ver no dado também não os vê no histórico (Regra 6). Nenhum segredo
(PIN, token) entra em claro no trilho (Regra 7). O trilho retém-se sete anos por obrigação legal; os
dados pessoais dentro dele anonimizam-se ao fim do prazo aplicável (Regra 8).

## Armadilhas conhecidas

- **Log de auditoria editável.** Se a app consegue reescrever o histórico, não é auditoria. Append-only
  imposto na camada de dados (Regra 1).
- **Escrever o trilho fora da transação do facto.** "Faço a alteração e depois registo" perde rasto quando
  a app cai no meio; ou regista algo que fez rollback (Regra 2).
- **Ator anónimo em ações de sistema/IA.** "Alterado automaticamente" sem dizer por que processo/modelo
  torna a auditoria inútil (Regra 3).
- **Enriquecimento de IA sem proveniência nem undo.** Conteúdo gerado que se funde com o humano e não se
  distingue nem se reverte viola a honestidade de dados (Regra 5,
  `knowledge/permanent-rules.md` §2).
- **Segredos em claro no antes/depois.** Auditar a mudança de uma chave guardando a chave transforma o
  trilho num alvo (Regra 7).
- **Trilho que ignora o RBAC.** Expor no histórico o que a autorização redige no dado é uma fuga por uma
  porta lateral (Regra 6).
- **Reter tudo indefinidamente.** Sem política, o trilho acumula dados pessoais para sempre — passivo
  legal em vez de ativo forense (Regra 8).

## Relacionados

- `modules/rbac-and-scoping.md` — a auditoria respeita a autorização e a redação por categoria.
- `modules/state-machines.md` — cada transição escreve a sua entrada de auditoria.
- `modules/readonly-external-integrations.md` — proveniência de dados importados de sistemas externos.
- `modules/credit-management.md` · `modules/approval-engine.md` — cada movimento/decisão é auditável.
- `knowledge/permanent-rules.md` — §2 (honestidade/proveniência) e §3 (reversibilidade/undo).
- `knowledge/proven-patterns.md` — §3 (outbox transacional) e §7 (imposto por testes).
- `agents/06-data/data-auditor.md` — quem desenha os trilhos, proveniência e retenção.
