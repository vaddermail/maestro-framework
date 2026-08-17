# Curadoria da framework

O lado da framework-mãe no circuito de aprendizagem: transformar a fila de issues `melhorias` em
evolução curada — candidatas, promoções por PR e vereditos — sem nunca deixar um reporte sem
resposta. Executa-o o `agents/14-meta/framework-curator.md` **no repositório-mãe**, com o dono
da framework como aprovador único. A cadência vive aqui, não nos projetos: os projetos reportam
quando fecham marcos; a mãe cura quando os gatilhos abaixo disparam.

## Pré-condições

- **Gatilho de cadência** (qualquer um; o que vier primeiro): ≥3 issues abertos com label
  `melhorias` · um projeto fechou F6 (P6b), F7 ou F8 e reportou · 3 meses desde a data em
  `knowledge/candidates.md`, tabela do topo · pedido do dono.
- Clone do repositório-mãe limpo e atualizado (`git status` limpo, `main` ao dia); `gh` autenticado
  com acesso ao repositório.
- `_meta/verify.sh` verde **antes de começar** — não se cura sobre uma framework inconsistente.
- `knowledge/candidates.md` lido, incluindo as rejeitadas (não reabrir sem novidade material).

## Passos

1. **Recolher a fila e triar:** `gh issue list --label melhorias --state open`. Ler todos antes de
   julgar qualquer um — o sinal mais forte é a repetição entre projetos, e só aparece no conjunto.
   **Triagem de entrada** quando a fila excede o lote: primeiro segurança/dados/portões, depois por
   idade. **Lote máximo: 10 issues por ronda** — os restantes recebem o comentário "agendado para a
   próxima ronda" (com data prevista) e **nenhum issue passa 2 rondas sem destino**.
2. **Validar à entrada,** issue a issue: formato (o quê + porquê + evidência + destino sugerido) e
   sanitização — **re-correr o varrimento mecânico** de segredos/PII sobre o corpo do issue (o
   segundo portão independente do único passo irreversível do circuito; o primeiro correu no
   projeto, `playbooks/report-framework-improvements.md` passo 2). Incompleto → comentar a pedir
   os campos e saltar nesta ronda. Com dados sensíveis → pedir reenvio sanitizado, editar/apagar o
   conteúdo exposto, saltar.
3. **Deduplicar e agrupar** por tema: entre os issues da ronda, contra `knowledge/candidates.md`
   e contra o conhecimento já promovido (`knowledge/`, módulos, checklists, templates). Anotar
   por item: novo · reforço de candidata (as confirmações/infirmações por ID `C-nnn` da secção de
   confirmação dos reportes somam-se diretamente à candidata certa) · cross-validação de
   conhecimento existente · repetição de
   rejeitada.
4. **Classificar cada item** num branch de curadoria (`git checkout -b curadoria/AAAA-MM`):
   - **Duplicado/cross-validação** → somar a confirmação (na candidata, ou nota de "confirmado
     também em {…}" no ficheiro promovido). Sem conteúdo novo, é PATCH.
   - **Específico do domínio** → veredito escrito no issue; registar como rejeitada em candidatas.
   - **Novo, 1 projeto** → entrada em candidatas (`aguarda-confirmação`, contagem 1, link ao issue).
   - **Confirmado (≥2 projetos)** → promover no passo 5. Exceção "obviamente geral com 1": só com
     pergunta explícita ao dono, nunca por iniciativa (`agents/14-meta/framework-curator.md`
     §Regras).
5. **Redigir as promoções,** por adição (`core/extensibility.md`): o conteúdo no destino certo,
   generalizado mas com evidência e proveniência **por código de projeto** (P2, P3, … + issue —
   nunca o nome nem a stack, porque candidatas e anotações viajam nas cópias:
   `knowledge/candidates.md` §Regras); entrada de changelog e salto
   de versão proposto em `_meta/VERSION.md` (MINOR para conteúdo novo, PATCH para clarificações;
   qualquer coisa que mude contratos para de imediato → pergunta de MAJOR ao dono). Atualizar
   `knowledge/candidates.md` (linhas promovidas/novas/rejeitadas + cabeçalho da ronda;
   **re-avaliar as candidatas expiradas** pela regra 6 — corre mesmo quando a ronda disparou por
   outro gatilho — e **mover para o §Arquivo** as promovidas/rejeitadas com mais de 2 rondas).
   Verificar também a validade da tabela camadas→modelos de `adapters/claude-code.md` (carimbo
   com mais de 3 meses → a ronda inclui a sua atualização em PATCH). Se algum reporte da ronda é um
   **fecho de F8** com bloco de génese, acrescentar a linha do produto (por código P-n) a
   `knowledge/learning-curve.md` e escrever a leitura no PR. Correr
   `_meta/verify.sh` — verde obrigatório.
6. **Abrir o PR** (nunca commit direto a `main`): tabela-resumo *item → origem → destino →
   classificação*, um bloco **"Métricas da ronda"** (issues processados/adiados, tempo mediano
   issue→veredito, candidatas ativas e idade média, promoções/rejeições/adormecidas — os
   cumulativos atualizam-se no cabeçalho de `knowledge/candidates.md`), perguntas pendentes em
   formato de lote (`core/question-engine.md`), e a nota de versão proposta. Curadorias grandes dividem-se em PRs temáticos revisáveis em ~10
   minutos — cada um em branch `curadoria/AAAA-MM-<tema>` e a tocar **só** nos ficheiros do seu
   tema; um **PR final de fecho de ronda** agrega o salto de versão (`_meta/VERSION.md`), o
   changelog e o `knowledge/candidates.md`, e faz merge em último — é o único PR da ronda
   autorizado a tocar nesses ficheiros partilhados.
7. **Portão humano:** o dono revê, ajusta e faz merge — ou devolve com comentários. O curador nunca
   faz merge nem responde às próprias perguntas.
8. **Fechar o ciclo, após o merge:** comentar e fechar cada issue com o veredito e a versão que o
   incorporou (promovida em X.Y.Z / candidata à espera de confirmação / rejeitada porque {…}). O
   projeto de origem atualiza a coluna "Resultado" do seu registo de envios quando sincronizar.
   Para issues marcados como procuração (`[proxy: …]`), o fecho inclui **reencaminhar o
   comentário-veredito pelo mesmo canal de entrada** — o ciclo só conta como fechado quando o
   veredito chega a quem reportou. Um issue fechado sem veredito é curadoria que não aconteceu.

## Reversão

A unidade de reversão é o merge do PR: `git revert` devolve a framework ao estado anterior e os
issues afetados reabrem-se com um comentário a explicar. Nada nos projetos é tocado por este
playbook — eles só recebem mudanças quando re-sincronizam deliberadamente
(`playbooks/sync-framework.md`), o que torna qualquer reversão da mãe sem efeitos colaterais
imediatos no terreno.

## Relacionados

- `agents/14-meta/framework-curator.md` — a ficha de quem executa (regras e limitações).
- `knowledge/candidates.md` — a sala de espera que este playbook mantém.
- `playbooks/report-framework-improvements.md` — de onde vem a fila de issues.
- `core/extensibility.md` — as regras de adição que as promoções respeitam.
- `_meta/VERSION.md` — SemVer e changelog; `_meta/verify.sh` — o portão técnico do PR.
- `playbooks/sync-framework.md` — como as promoções chegam finalmente aos projetos.
