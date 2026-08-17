# Fonte Única de Conteúdos · um catálogo serve UI, tooltips e IA

> **Validação em produção:** 2.ª confirmação em domínio distinto do projeto-mãe (P2 — curadoria de 2026-08; nuance confirmada: vocabulário/dropdowns de uma fonte única,
> editável e auditada). O desenho mantém-se; a confiança sobe.

Módulo reutilizável para o **conteúdo textual do produto** — labels, descrições, mensagens, tooltips,
ajuda — viver numa **só fonte editável**, de onde tudo o resto deriva. É o padrão single-source-of-truth
(`knowledge/proven-patterns.md` §4) aplicado às strings que o utilizador lê.

## O problema que resolve

O mesmo texto tende a ser escrito muitas vezes: o label do botão, o tooltip que o explica, a entrada
no manual, a resposta que um assistente de IA dá sobre essa função. Quando estão duplicados, **divergem**
— o botão diz uma coisa, a ajuda diz outra, a IA inventa uma terceira. É a classe de bug mais teimosa
que existe, porque cada cópia parece correta isoladamente.

Pior no produto com IA: se o assistente de ajuda é *grounded* num texto diferente do que o ecrã mostra,
mente com confiança. A honestidade de conteúdo é tolerância zero (`knowledge/permanent-rules.md`
§2) — e só se garante se houver **uma** origem.

## O modelo (conceitos e entidades, agnóstico de stack)

- **Catálogo** — o ficheiro (ou conjunto tipado) que é a **única** origem editável de conteúdo. Cada
  entrada tem uma **chave estável** por convenção (`dominio.entidade.acao.aspeto`, ex.:
  `fatura.emitir.tooltip`).
- **Entrada de conteúdo** — para cada chave: o texto curto (label), a explicação (tooltip/descrição),
  e — quando aplicável — a **entrada de ajuda rica com exemplos**. A ajuda completa não é um documento
  à parte: é o mesmo catálogo, no seu nível mais detalhado.
- **Consumidores** — todos derivam, nenhum reescreve:
  - **UI** — o ecrã lê o label e o tooltip pela chave.
  - **Menu de ajuda** — renderiza as entradas ricas com exemplos.
  - **Grounding de IA** — qualquer assistente do produto responde a partir do **mesmo** catálogo; a
    ajuda que serve o humano é o contexto que serve a IA (`modules/ai-observability.md`).
  - **Testes/guardrails** — verificam cobertura e ausência de duplicação.
- **Proveniência de estado** — entradas de módulos ainda-por-construir marcam-se `Planeado`, para a IA
  saber que existem sem afirmar que já funcionam.

Distinto de, mas alinhado com, dois vizinhos: **tokens de design** (cores, espaçamento —
`agents/03-experience/design-system-architect.md`) são o SSOT do *visual*; **i18n**
(`agents/03-experience/internationalization-specialist.md`) é a mesma disciplina de strings
externas estendida a várias línguas. O catálogo é a fundação de ambos.

## Regras inegociáveis (numeradas, verificáveis)

1. **Nenhuma string de conteúdo hardcoded fora do catálogo.** Verificável: um teste que varre o código
   e falha se encontrar texto visível ao utilizador embutido (`knowledge/proven-patterns.md`
   §7).
2. **Uma chave, um texto.** O mesmo conceito não tem duas entradas; verificável por deteção de valores
   duplicados no catálogo.
3. **Toda a ação/controlo tem tooltip.** Verificável: um teste que percorre os componentes de ação e
   falha se algum não referencia uma chave de tooltip (`knowledge/origin-lessons.md` §D2).
4. **A ajuda e o grounding de IA leem o mesmo catálogo.** Não há um "documento de ajuda" paralelo nem
   um *prompt* com texto copiado; a IA é *grounded* na fonte, não numa cópia.
5. **Chaves seguem a convenção declarada.** Uma chave nova respeita o padrão `dominio.entidade.acao.aspeto`;
   verificável por lint de chaves.
6. **Entradas de módulos não-prontos marcam-se `Planeado`.** A IA nunca afirma que algo funciona por
   existir a entrada; o estado é explícito.
7. **Remover uma funcionalidade remove as suas entradas.** Sem chaves órfãs; verificável por deteção de
   chaves referenciadas-mas-inexistentes e existentes-mas-nunca-referenciadas.

## Como se adota num produto novo (passos)

1. **Definir o formato do catálogo** (`core/decision-engine.md`): um módulo tipado na linguagem do
   produto (ex.: `conteudos.ts`) é o mais simples e dá verificação em compilação; ficheiros de
   mensagens (i18n) quando há multilíngua desde o início.
2. **Fixar a convenção de chaves** e documentá-la no glossário do produto.
3. **Criar o acessor único** `t(chave, params?)` — o ponto por onde todo o consumidor lê.
4. **Forçar por construção:** componentes do design system que **não deixam** criar um botão/ação sem
   passar uma chave de tooltip (`knowledge/origin-lessons.md` §D3).
5. **Ligar os guardrails:** testes de "sem strings soltas", "toda a ação tem tooltip", "sem chaves
   órfãs", "sem duplicados".
6. **Apontar o assistente de IA ao catálogo** como fonte de grounding — a mesma que alimenta o menu de
   ajuda (`agents/11-documentation/user-help-writer.md`).
7. **Estender o padrão aos contratos**, se aplicável: uma só declaração de schema alimenta validação,
   tipos e documentação (`knowledge/origin-lessons.md` §C2) — o mesmo princípio noutra camada.

## Variações e trade-offs

- **Módulo tipado vs ficheiros i18n.** Tipado: erro de chave em compilação, refactor seguro, sem
  infra; mono-língua na base. i18n: multilíngua e pluralização de raiz, mas mais cerimónia e
  verificação em runtime. Se há hipótese realista de segunda língua, começar em i18n poupa migração.
- **Catálogo único vs por módulo.** Um ficheiro gigante não escala à leitura; partir por domínio
  (`conteudos/faturacao.ts`, `conteudos/suporte.ts`) mantendo o acessor único preserva a fonte única
  sem o monólito.
- **Ajuda inline vs base de conhecimento separada.** Mantê-las **na mesma fonte** é o ponto do módulo;
  se a base de conhecimento crescer para artigos longos, gera-se **a partir** do catálogo, nunca em
  paralelo a ele.
- **Onde reside o grounding de IA.** Compor o contexto da IA a partir do catálogo em runtime evita
  deriva, mas custa tokens; se cachear, invalidar sempre que o catálogo muda — a paridade não é
  negociável.

## Exemplo (multi-domínio)

**Plataforma SaaS — tooltip, ajuda e chatbot coerentes.** A ação "Arquivar projeto" tem
`projeto.arquivar.label` = "Arquivar", `projeto.arquivar.tooltip` = "Remove o projeto das listas
ativas; reversível em Definições > Arquivo", e `projeto.arquivar.ajuda` com um exemplo passo-a-passo.
O botão, o painel de ajuda e o chatbot de suporte leem as três da mesma entrada — quando o
comportamento muda (deixa de ser reversível), edita-se **um** sítio e os três consumidores acompanham.
O chatbot nunca contradiz o tooltip porque bebe da mesma fonte.

**Loja online — mensagem de erro única.** "Cartão recusado pelo banco emissor" vive em
`checkout.pagamento.recusado`. Aparece no ecrã de checkout, no email de falha e no artigo de ajuda
"Porque foi recusado o meu pagamento?" — sem três versões que envelhecem em separado.

## Armadilhas conhecidas

- **Strings soltas que reaparecem:** sem o teste-varredura (regra 1), o hardcoding volta ao terceiro
  sprint — a regra que não é verificada deixa de ser cumprida.
- **Prompt de IA com texto copiado:** copiar a ajuda para dentro de um *system prompt* recria a
  duplicação que o módulo elimina; o prompt referencia o catálogo, não o transcreve.
- **Chaves por posição/índice** (`msg_42`) em vez de semânticas: tornam o catálogo ilegível e o
  refactor perigoso.
- **Duplicar em vez de reutilizar** "porque este contexto é ligeiramente diferente": se o texto é o
  mesmo, é uma chave; se é mesmo diferente, é outra chave com nome próprio — nunca duas cópias iguais.
- **Ajuda que envelhece à parte do produto:** manter a ajuda como documento separado reintroduz a
  divergência; a ajuda **é** o catálogo no seu nível rico (`agents/13-guardians/documentation-guardian.md`).

## Relacionados

- `knowledge/proven-patterns.md` — §4 SSOT, §7 guardrails que varrem tudo.
- `agents/11-documentation/user-help-writer.md` — a ajuda completa com exemplos como fonte única.
- `agents/04-frontend/frontend-architect.md` — SSOT de conteúdos na app cliente.
- `agents/03-experience/design-system-architect.md` — o SSOT irmão, dos tokens visuais.
- `agents/03-experience/internationalization-specialist.md` — a mesma disciplina em várias línguas.
- `modules/ai-observability.md` — o catálogo como grounding do assistente do produto.
- `knowledge/origin-lessons.md` — §D1, §D2 (catálogo e guardrails), §C2 (contratos).
