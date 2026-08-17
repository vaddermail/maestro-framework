# Reportar melhorias à framework-mãe

O lado do projeto no circuito de aprendizagem (`knowledge/README.md` §Como o conhecimento
circula): consolidar o `FRAMEWORK-IMPROVEMENTS.md` do projeto e entregá-lo ao repositório-mãe
como **issue** — sinais sobem, releases descem; um projeto nunca escreve diretamente na framework.
Executa-o o Orquestrador do projeto (`core/orchestrator.md`) no fecho de F6/F7/F8 (item da
`checklists/definition-of-done.md`) e, em F9, na cadência do perfil de esforço. Várias pessoas e
projetos podem reportar em simultâneo sem conflito — issues são independentes; a serialização
acontece depois, na curadoria (`playbooks/framework-curation.md`).

## Pré-condições

- `FRAMEWORK-IMPROVEMENTS.md` existe na raiz do projeto (instanciado em F0 a partir de
  `templates/project/FRAMEWORK-IMPROVEMENTS.md.template`) e tem entradas novas desde o último
  envio — **se não tem, não há envio**: este playbook nunca fabrica conteúdo para cumprir
  calendário; a captura é por evento, só o envio é por marco.
- O utilizador do projeto tem conta com permissão para **abrir issues** no repositório-mãe (mais
  nada — não é preciso acesso de escrita ao código). Sem acesso, ver passo 5 (fallback).
- O nome/URL do repositório-mãe está registado no `STATE.md` do projeto (fica lá desde o arranque,
  junto à versão da framework copiada).

## Passos

1. **Consolidar.** Reler as entradas novas (sem marca `(enviado #nnn)`) das cinco secções. Cada uma
   tem o quê, porquê, evidência e destino sugerido? As incompletas completam-se agora ou ficam para
   o próximo envio — nunca se enviam entradas sem porquê e evidência. **Varrimento de recuperação:**
   antes de fechar a consolidação, cruzar o `STATE.md` (§Lições e §Feito desde o último envio) e,
   se for barato, o `git log` do período com as entradas do ficheiro — qualquer lição da framework
   que tenha escapado à captura no momento entra agora, marcada `(recuperada)`. Não substitui a
   captura no momento; apanha o que lhe fugiu. **Confirmação de candidatas:** reler
   `knowledge/candidates.md` da cópia e preencher a secção de confirmações do artefacto
   (por ID `C-nnn`, com evidência) — confirmar ou infirmar o que outros projetos reportaram é
   tão valioso como reportar de novo, e é o que destrava promoções. **No fecho de F8**, incluir
   também o bloco "Fecho" do dossier de génese (`product/99-records/genesis.md`) — é com ele que a
   curadoria atualiza a curva do ecossistema (`knowledge/learning-curve.md`).
2. **Sanitizar.** Verificação explícita, entrada a entrada: sem dados pessoais, sem nomes de
   clientes, sem segredos, sem detalhe confidencial do domínio. A lição na forma geral; a evidência
   por caminho/commit, sem colar conteúdo sensível. Na dúvida sobre uma entrada, pergunta ao
   utilizador antes de a incluir (`core/question-engine.md`). Fechar com um **varrimento
   mecânico** do corpo consolidado ("portões, não sensações" — é o único passo irreversível do
   circuito): padrões de segredos e PII (chaves, tokens, e-mails pessoais, IBAN/NIF) mais a lista
   local de termos proibidos do projeto (nomes de clientes, termos confidenciais do domínio —
   mantida num ficheiro do projeto, **nunca enviada**). Só se avança com o varrimento limpo; o
   resultado anota-se no §Registo de envios.
3. **Abrir o issue** no repositório-mãe, com label `melhorias`:

   ```
   gh issue create --repo {{repositorio-da-framework-mae, ex.: vaddermail/maestro-framework}} \
     --label melhorias \
     --title "[melhorias] {{nome-do-projeto}} — {{marco, ex.: fecho de F7}}" \
     --body-file {{ficheiro-consolidado}}
   ```

   O corpo é autocontido (o curador pode não conseguir ler o repositório do projeto):

   ```
   Projeto: {{nome}} · Domínio (1 linha, sanitizado): {{…}}
   Versão da framework copiada: {{X.Y.Z}} · Marco: {{fase fechada / cadência}}

   ## Armadilhas novas
   {{entradas novas desta secção, completas}}

   ## Padrões provados (com ganho medido)
   ## Validação cruzada de padrões existentes
   ## Atrito e omissões
   ## Blocos reutilizáveis
   {{idem — secções sem entradas novas omitem-se}}
   ```

4. **Registar o envio.** No `FRAMEWORK-IMPROVEMENTS.md`: marcar as entradas enviadas com
   `(enviado #nnn)` e acrescentar a linha ao §Registo de envios. No `STATE.md`: uma linha em
   "Feito" com o número do issue. Quando o veredito da curadoria chegar (comentário no issue),
   atualizar a coluna "Resultado" do registo.
5. **Fallback sem acesso a issues.** Se o utilizador não tem conta/permissão no repositório-mãe:
   entregar o mesmo corpo consolidado ao dono da framework pelo canal combinado (e-mail, mensagem,
   ficheiro partilhado) e registar o envio na mesma — quem o recebe abre ele próprio o issue,
   **marcado como procuração** (ex.: `[proxy: e-mail]` no título), para a fila da curadoria ficar
   completa e o veredito saber voltar pelo mesmo canal (`playbooks/framework-curation.md`
   passo 8). O que não pode acontecer é a lição morrer no projeto.

**Caso especial — edições locais à cópia da framework:** quando o passo 2 de
`playbooks/sync-framework.md` encontra diferenças na cópia, cada diferença vira primeiro uma
entrada em "Atrito e omissões" (ou "Blocos reutilizáveis") e segue neste playbook — só depois se
reconcilia a cópia. Uma edição local é o reporte involuntário mais forte que existe: alguém
precisou que a framework fosse diferente.

## Reversão

Enviar um issue não muda nada no projeto nem na framework — um envio por engano fecha-se com um
comentário a explicar, e as marcas `(enviado #nnn)` corrigem-se no ficheiro. Risco irreversível
real só há um: **conteúdo sensível publicado no issue** — por isso a sanitização é um passo
explícito e anterior ao envio; se acontecer, apagar/editar o issue imediatamente e tratar como
incidente de dados no projeto (`workflows/W11-incident-response.md`).

## Relacionados

- `templates/project/FRAMEWORK-IMPROVEMENTS.md.template` — o artefacto que este playbook envia.
- `playbooks/framework-curation.md` — o que acontece do outro lado ao teu reporte.
- `knowledge/README.md` — o circuito completo; `knowledge/candidates.md` — onde as lições
  de 1 projeto esperam a segunda confirmação.
- `checklists/definition-of-done.md` — os fechos de fase que exigem este envio.
- `playbooks/sync-framework.md` — o caminho inverso: como as promoções voltam ao projeto.
