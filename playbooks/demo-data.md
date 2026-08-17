# Dados de Demonstração

Como criar e manter dados de demonstração — para explorar o produto, mostrar a um cliente/stakeholder,
ou popular um ambiente de análise. Dados de demo são **código que apodrece com o esquema**: partem-se
em silêncio quando o modelo muda (um evento, um invariante ou um campo de que o seed dependia deixa de
existir), e são um risco quando se confundem com dados reais. Executado por
`agents/06-data/migration-engineer.md` ou pelo agente de dados do módulo em causa, dentro de uma
fatia de `workflows/W06-build.md` ou como preparação de uma demonstração.

## Pré-condições

- Esquema/migrações no estado alvo (o seed corre contra o modelo atual, não um antigo).
- Uma forma de correr seeds/fixtures reproduzível (comando único).
- Separação clara entre dados de demo e dados reais — um ambiente dedicado, ou uma guarda que impeça
  o seed de correr sobre dados de produção.

## Passos

1. **Escrever o seed idempotente e guardado.** Corre duas vezes sem duplicar e não colide com dados
   existentes (guarda por marcador ou por contagem). *Verifica-se* correndo duas vezes e confirmando
   que não duplica. *Se falhar*: acrescentar a guarda — um seed que duplica não é reproduzível.
2. **Só dados fictícios — nunca PII real nem segredos.** Nomes, contactos e endereços são inventados.
   Efeitos externos que o seed possa disparar (e-mails, SMS, webhooks para os contactos de demo) correm
   com o transporte em modo nulo/log, **nunca a enviar para o mundo** — endereços de demo geram
   *bounces* e sujam a reputação do domínio. *Verifica-se* que nenhum envio real sai para endereços de
   demo. *Se falhar*: forçar o transporte nulo durante o seed.
3. **Cobrir a largura do produto, não o caminho feliz.** O valor de uma demo é mostrar todos os estados
   e fluxos que o observador deve ver (casos limite, estados de erro, histórico), não uma linha de cada.
4. **Smoke test em CI que corre o seed contra um esquema fresco.** É a única defesa contra o seed
   apodrecer sem se notar. *Verifica-se* pelo job de CI verde. *Se falhar*: corrigir o seed como
   qualquer código — a falha é real (o produto mudou por baixo do seed).
5. **Manter demo e real separados até ao fim.** O seed de demo **nunca** entra no seed de produção por
   omissão. Antes de um ambiente passar a uso real, limpar a demo e arrancar com dados verdadeiros —
   registar essa transição em `STATE.md`.

## Reversão

Apagar os dados de demo pelo marcador que os identifica, ou recriar a base de dados a partir das
migrações. Num ambiente que vá passar a produção, a limpeza da demo é obrigatória, não opcional.

## Relacionados

- `workflows/W06-build.md` — onde os seeds nascem, a acompanhar as fatias.
- `checklists/pre-merge.md` — o portão que o smoke test do seed reforça.
- `playbooks/secrets-management.md` — porque nunca há PII/segredos reais em dados de demo.
- `agents/06-data/migration-engineer.md` — dono típico dos seeds e fixtures.
- `agents/10-quality/integration-test-engineer.md` — o smoke test que trava o apodrecimento.
