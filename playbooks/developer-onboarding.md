# Playbook — Onboarding de Developer

Levar um **novo interveniente** de zero a operacional **com um comando**, e depois arrancar cada
sessão de forma disciplinada. "Interveniente" é tanto um **humano** (developer que se junta à equipa)
como um **agente de IA** (nova sessão do Claude Code/Cowork/outro) — ambos precisam do mesmo: código
sincronizado, ambiente reproduzível, acessos dedicados e a memória do projeto lida antes de tocar em
nada.

**Quando se executa:** quando alguém/algo se junta ao projeto (kit de arranque, passos 1–5); e **no
início de cada sessão de trabalho** (protocolo de arranque, passos 6–8). **Quem:** o próprio novo
interveniente, guiado por este playbook; um humano da equipa aprova a criação de acessos dedicados.

## Pré-condições

- [ ] Repositório acessível (clone por chave/deploy key, nunca token colado — `playbooks/secrets-management.md`).
- [ ] Existe um script de setup **idempotente** na raiz (ex.: `setup.sh`) — se não existir, criá-lo é o
      primeiro contributo (passo 3).
- [ ] `STATE.md`, `CLAUDE.md` (ou instruções da ferramenta — `adapters/`) e a árvore `product/`
      existem no projeto (criados no arranque, `workflows/W00-project-kickoff.md`).

## Passos

**Kit de arranque (uma vez, ao juntar-se):**

### 1. Obter o código
**Faz:** clonar o repositório pelo acesso dedicado (chave/deploy key). Confirmar que se está no
ambiente-alvo (ex.: VS Code sobre WSL, nunca PowerShell — regra de origem do projeto-mãe).
**Verifica:** `git status` limpo; `git log -1` mostra o commit mais recente do ramo de integração.
**Se falhar:** se o acesso não funciona, não colar tokens no chat — pedir/criar uma credencial
dedicada (passo 4) e registar o caminho, não o valor.

### 2. Ler a memória do projeto **antes** de mexer
**Faz:** ler, por esta ordem, `CLAUDE.md` (regras estáveis), `STATE.md` (feito/em curso/a seguir/
decisões pendentes/lições) e o índice de `product/`. Um agente de IA lê ainda o `START-HERE.md` e o
adaptador da sua ferramenta (`adapters/claude-code.md` ou `adapters/other-assistants.md`).
**Verifica:** consegues dizer em duas frases em que ponto está o projeto e qual é a próxima tarefa —
sem perguntar a ninguém.
**Se falhar:** se `STATE.md` não chega para retomar, é uma lacuna de memória — registá-la e pedir
contexto, **nunca adivinhar** (`knowledge/ai-pitfalls.md` §3, §8).

### 3. Sincronizar o ambiente com um comando
**Faz:** correr o script de setup idempotente (`./setup.sh`): instala runtime na versão fixada
(lockfile/`.nvmrc`/`engines` — `knowledge/permanent-rules.md` §6), dependências, extensões e
ferramentas. Correr duas vezes **não** deve partir nada.
**Verifica:** o script termina com código 0; correr uma segunda vez é idempotente (sem erros, sem
duplicados); lint e testes locais correm (`pipelines/ci-quality.md`).
**Se falhar:** se o setup não é idempotente ou falta um passo, **corrigir o script** (para o próximo
não tropeçar), não remendar à mão a máquina local — a correção do script é o valor.

### 4. Obter acessos dedicados e revogáveis
**Faz:** criar/receber credenciais **próprias** do interveniente (deploy key, token de escopo mínimo),
distintas das de outras pessoas e **revogáveis** sem partir as dos outros. Preencher segredos locais a
partir dos `*.example` (`playbooks/secrets-management.md`).
**Verifica:** o interveniente acede ao que precisa e **só** ao que precisa (least privilege); revogar a
sua credencial não afeta ninguém.
**Se falhar:** partilhar uma credencial "para ser rápido" é dívida de segurança — criar a dedicada,
mesmo que custe minutos.

### 5. Primeiro contributo guiado
**Faz:** escolher uma fatia **pequena e aditiva** (um fix, um teste, uma clarificação de doc) para
exercitar o ciclo completo: branch dedicado → alteração → verificação → PR verde → aviso ao colega
(`knowledge/permanent-rules.md` §8, `checklists/pre-merge.md`).
**Verifica:** o PR passa lint+testes (front e back correm separados — correr ambos); é revisto por
alguém que **não** é o autor (`knowledge/ai-pitfalls.md` §20).
**Se falhar:** se o primeiro PR não fica verde, é sinal de ambiente mal sincronizado (voltar ao passo 3)
ou de regra não lida (voltar ao passo 2) — resolver a causa, não forçar o merge.

**Protocolo de arranque de sessão (todas as vezes):**

### 6. Sincronizar código
**Faz:** `git fetch` + `git pull --rebase` do ramo de integração. Nunca assumir que o local é o mais
recente.
**Verifica:** o local está à frente ou igual ao remoto do ramo de integração, sem divergência por
resolver.
**Se falhar:** em divergência ou *working tree* partilhado sujo, **parar e esclarecer** em vez de
sobrescrever (`knowledge/permanent-rules.md` §8).

### 7. Sincronizar ambiente e ler o estado
**Faz:** correr o setup se houve mudanças de dependências; reler `STATE.md` (as lições e decisões
podem ter mudado desde a última sessão).
**Verifica:** ambiente verde (lint/testes locais) e estado lido antes de tocar em código.
**Se falhar:** se o ambiente não fica verde, resolver antes de avançar — não construir sobre base
partida.

### 8. Encerrar a sessão (sempre)
**Faz:** atualizar `STATE.md` (feito/em curso/a seguir, decisões tomadas e pendentes, lições
não-óbvias com o porquê); confirmar que tudo o tocado está em ficheiros, nada só na conversa
(`START-HERE.md` §2.5, `core/project-memory.md`).
**Verifica:** a próxima sessão (humana ou IA) consegue retomar só a partir do `STATE.md`.
**Se falhar:** trabalho meio-feito sem rasto perde-se entre sessões — registar o bloqueio com contexto
suficiente para retomar sem re-perguntar.

## Reversão

- Um interveniente que sai reverte-se **revogando os acessos dedicados** (passo 4) — por isso serem
  dedicados e revogáveis (o offboarding é o espelho deste playbook: `modules/entity-lifecycle.md`).
- O ambiente é descartável: o setup idempotente (passo 3) reconstrói do zero, logo não há estado
  manual a preservar na máquina.

## Relacionados

- `START-HERE.md` — arranque do projeto (a primeira sessão de todas).
- `workflows/W00-project-kickoff.md` — instanciação da memória que este playbook pressupõe.
- `core/project-memory.md` — `STATE.md` e passagem de testemunho entre sessões/pessoas/ferramentas.
- `playbooks/secrets-management.md` — os `*.example` e as credenciais dedicadas.
- `adapters/claude-code.md` · `adapters/other-assistants.md` — arranque específico por ferramenta de IA.
- `knowledge/permanent-rules.md` — §6 (versões fixadas), §8 (Git colaborativo).
- `checklists/pre-merge.md` · `pipelines/ci-quality.md` — o gate do primeiro contributo.
