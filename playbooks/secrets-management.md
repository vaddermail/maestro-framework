# Playbook — Gestão de Segredos

Procedimento ponta a ponta para manter segredos (chaves, passwords, tokens, API keys, *connection
strings*, certificados) **fora do controlo de versões** e fora de logs/output. Operacionaliza
`knowledge/permanent-rules.md` §5 e é o passo-a-passo que o `agents/07-devops/secrets-manager.md`
segue, executando a política do `agents/09-security/secrets-and-rotation-manager.md`.

**Quando se executa:** no arranque do fluxo de segredos (F8, `workflows/W08-launch.md`); ao
integrar um novo segredo/ambiente/serviço; na rotação periódica; e — com prioridade máxima — perante
suspeita ou confirmação de fuga. **Quem:** o Gestor de Segredos, sob a política de segurança. O
utilizador aprova a escolha de *store* e é avisado antes de qualquer rotação que possa cortar serviço.

## Pré-condições

- [ ] *Store*/vault decidido com o utilizador (ver passo 2) ou decisão registada em `STATE.md`.
- [ ] Inventário das credenciais que os serviços precisam (de `agents/05-backend/*`, `agents/06-data/*`,
      `agents/07-devops/deployment-strategist.md`).
- [ ] Acessos entregues **por caminho de ficheiro**, nunca colados no chat (regra inegociável — passo 6).

## Passos

### 1. Inventariar o que conta como segredo
**Faz:** lista tudo o que, se vazar, dá acesso ou identidade — passwords, tokens, API keys, chaves
SSH/privadas, *connection strings*, segredos de assinatura, certificados. Regista o inventário (nome,
onde é usado, quem o emite, cadência de rotação) **sem valores**.
**Verifica:** cada credencial usada em código/config aparece no inventário; nenhuma entrada tem o valor.
**Se falhar:** se aparecer um valor no inventário, apaga-o e substitui por um caminho/nome; se houver
credencial usada mas não inventariada, é uma lacuna — não avançar sem a fechar.

### 2. Decidir onde vivem (pasta gitignored ou vault)
**Faz:** escolhe com o utilizador (formato `core/question-engine.md`): **vault gerido** (cloud
KMS/Secrets Manager) se já há cloud; **vault self-hosted** para on-prem com equipa; ou **ficheiros
gitignored com `chmod 600`** como início honesto on-prem simples — sempre com caminho de migração para
vault escrito, nunca como destino final.
**Verifica:** a decisão está em `STATE.md`; a pasta de segredos local (se aplicável) está fora do repo
ou coberta pelo `.gitignore` (passo 3).
**Se falhar:** sem decisão, o agente termina **bloqueado** e regista em `STATE.md` → decisões pendentes.

### 3. Trancar o repositório
**Faz:** `.gitignore` com *allowlist* — ignora a pasta/ficheiros de segredos e permite **só** os
`*.example`. Instala um guardrail de *pre-commit* que barra padrões de segredo (ex.: `sk_live_`, chaves
`BEGIN PRIVATE KEY`, *connection strings*) e o *scan* correspondente no `pipelines/ci-security.md`.
**Verifica:** planta um segredo de teste falso num *commit* — o guardrail **rejeita-o**; `git status`
não mostra ficheiros de segredo por rastrear.
**Se falhar:** se o guardrail não morde, corrige o padrão antes de confiar nele (um guardrail que não
rejeita é pior que nenhum — dá falsa confiança, `knowledge/ai-pitfalls.md`).

### 4. Materializar *templates* `*.example`
**Faz:** para cada ficheiro de segredos, cria o `*.example` com as **chaves** e valores fictícios
(`API_KEY=coloca-aqui-a-tua`), versionado. Serve o `playbooks/developer-onboarding.md`.
**Verifica:** o `*.example` não contém nenhum valor real; abrir o projeto de raiz com o `*.example`
diz a um novo interveniente exatamente o que preencher.
**Se falhar:** se um valor real escapou para o `*.example`, trata-o como fuga (passo 8).

### 5. Injetar em runtime
**Faz:** cada serviço/pipeline recebe os segredos do *store* por variável de ambiente ou ficheiro
montado; o código referencia por **nome/caminho**, nunca o valor *hardcoded*.
**Verifica:** prova-live — o serviço arranca lendo do *store*; procurar o valor no código/imagem/logs
não devolve nada.
**Se falhar:** se o serviço só arranca com o valor colado, o segredo não está a ser injetado — corrigir
a injeção, não *hardcodar* "temporariamente".

### 6. Aceder por caminho, nunca no chat/output
**Faz:** sempre que precisares de um segredo, pede/usa o **caminho do ficheiro**; nunca o eco no chat,
em logs, em mensagens de erro ou em artefactos.
**Verifica:** varre o output da sessão e os logs — nenhum valor de segredo aparece.
**Se falhar:** um valor colado numa conversa está comprometido — trata como fuga (passo 8).

### 7. Rotação (periódica e sob evento)
**Faz:** executa a cadência de rotação da política de segurança — gerar credencial nova, injetar,
**verificar o serviço a funcionar com a nova**, e só depois revogar a antiga (expand-contract aplicado
a segredos, `knowledge/permanent-rules.md` §3).
**Verifica:** o serviço funciona com a credencial nova antes de a antiga ser revogada; a antiga fica
inutilizada após revogação.
**Se falhar:** se a nova não funciona, **não revogar a antiga** — reverter para a antiga (ainda válida)
e investigar.

### 8. Resposta a fuga (irreversível — agir já)
**Faz, por esta ordem:** (1) **revogar** a credencial exposta imediatamente; (2) **rodar** — emitir uma
nova e injetá-la (passos 5/7); (3) **varrer o histórico** com o `agents/09-security/exposed-secrets-hunter.md`
para achar todas as ocorrências e outras exposições; (4) **post-mortem** sem culpados
(`templates/technical/post-mortem.md.template`) via `workflows/W11-incident-response.md`.
**Verifica:** a credencial antiga já não autentica; o *scan* do histórico está limpo dali para a frente;
o incidente está registado com a credencial rodada.
**Se falhar / não esquecer:** **nunca** basta "apagar o *commit*" — o histórico Git é eterno e pode já
estar clonado. Qualquer segredo que **alguma vez** esteve no Git conta como comprometido: rodar, não
racionalizar.

## Reversão

- **Rotação/injeção** são reversíveis enquanto a credencial antiga não for revogada: reverter é
  reapontar para a antiga. Por isso a ordem é sempre *nova a funcionar → revogar a antiga*, nunca o
  inverso.
- **Fuga não é reversível** — não se "desfaz" uma exposição; o único caminho é revogar+rodar. Daí a
  prevenção (passos 3–6) valer mais que qualquer remediação.
- **Escolha de *store*** é reversível por migração deliberada (ficheiros → vault), com o caminho escrito
  desde o passo 2.

## Relacionados

- `agents/07-devops/secrets-manager.md` — o agente que executa este playbook.
- `agents/09-security/secrets-and-rotation-manager.md` — a política que este playbook concretiza.
- `agents/09-security/exposed-secrets-hunter.md` — *scan* do histórico na resposta a fuga.
- `knowledge/permanent-rules.md` — §5 (segredos fora do Git), §3 (reversibilidade).
- `playbooks/developer-onboarding.md` — consome os `*.example`.
- `workflows/W11-incident-response.md` · `templates/technical/post-mortem.md.template` · `pipelines/ci-security.md`
- `checklists/pre-production-security.md` — o gate onde isto se verifica no go-live.
