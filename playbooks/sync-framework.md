# Sincronizar a framework num projeto existente

Um projeto copia a Maestro uma vez, no arranque (`workflows/W00-project-kickoff.md`); a
framework-mãe continua a evoluir no seu próprio repositório, por SemVer (`_meta/VERSION.md`). Este
playbook traz um projeto para uma versão mais recente — **deliberadamente, nunca automaticamente**.
Executa-o o Orquestrador do projeto (`core/orchestrator.md`), com o utilizador a aprovar o salto
de versão. A regra que torna a sincronização segura é uma só: **a cópia da framework num projeto é
só-de-leitura** — extensões locais vivem em ficheiros do projeto (fora de `Maestro/`) ou
promovem-se à mãe (`knowledge/README.md` §Como o conhecimento circula); nunca se edita a cópia.

## Pré-condições

- O `STATE.md` do projeto regista a versão da framework copiada (obrigatório desde
  `START-HERE.md` §2.2). Se não regista, descobre-a primeiro (`Maestro/_meta/VERSION.md` da
  cópia) e regista — não sincronizes sem saber de onde partes.
- Working tree do projeto limpo (sem alterações por commitar) — a sincronização tem de ser um commit
  isolado, revertível de uma vez.
- Acesso à **release-alvo** da framework-mãe (o ZIP publicado por tag — a fonte canónica de
  distribuição, já sanitizada pela lista `_meta/DO-NOT-DISTRIBUTE` da mãe) e ao registo de alterações
  (`_meta/VERSION.md`).

## Passos

1. **Ler o registo de alterações** da mãe entre a versão do projeto e a versão-alvo
   (`_meta/VERSION.md`). Classificar o salto: PATCH/MINOR seguem este playbook; **MAJOR exige ler as
   notas de rutura e avaliar impacto antes de continuar** — se o contrato entre agentes mudou
   (protocolo de artefactos, ciclo de vida, template de agente), lista o que muda para ESTE projeto
   e obtém o OK do utilizador.
2. **Verificar que a cópia não foi editada localmente**: `diff -rq` entre a cópia do projeto e a
   versão da mãe que o projeto diz ter. Se houver diferenças → **parar**. Para cada diferença,
   decidir com o utilizador: promover à mãe (é uma melhoria geral — regista-a em
   `FRAMEWORK-IMPROVEMENTS.md` e envia-a pelo `playbooks/report-framework-improvements.md`; a
   incorporação segue a curadoria e `core/extensibility.md`) ou descartar (era uma edição
   indevida — mas o atrito que a motivou merece, quase sempre, uma entrada no mesmo reporte: uma
   edição local é o sinal mais forte de que a framework estorvou). Só continuar com a cópia
   reconciliada.
3. **Substituir a cópia** pelo conteúdo do ZIP da release-alvo (cópia integral com remoção do que
   deixou de existir — ex.: extrair para pasta temporária e `rsync -a --delete`). É seguro porque,
   pela regra acima, nada de específico do projeto vive dentro de `Maestro/`.
4. **Correr a auto-verificação** da versão instalada: `Maestro/_meta/verify.sh`. Tem de
   sair verde; se falhar, a cópia ficou corrompida — reverter (ver Reversão) e recomeçar.
5. **Avaliar impacto nos artefactos do projeto**: instâncias antigas de templates **não se tocam**
   (foram válidas quando escritas); portões/checklists novos aplicam-se ao trabalho **futuro**;
   agentes novos ficam disponíveis sem cerimónia. Só há trabalho a fazer se o registo de alterações
   o disser explicitamente (ex.: um MAJOR que renomeie artefactos).
6. **Registar em `STATE.md`**: nova versão da framework, data, salto (de → para), e qualquer
   decisão tomada nos passos 1–2.
7. **Commit isolado** ("sincroniza Maestro X.Y.Z → A.B.C"), proposto ao utilizador.

**Deteção contínua de deriva:** entre sincronizações, qualquer sessão pode correr
`bash Maestro/_meta/verify.sh --integridade` — compara a cópia com o manifesto
`_meta/SHA256SUMS` da release de origem e acusa edições locais no momento, em vez de as deixar
acumular até ao passo 2 da próxima sincronização.

## Alternativas de distribuição (equipas com Git maduro)

A cópia por ZIP de release é o **default** (simples, sanitizada pela lista `_meta/DO-NOT-DISTRIBUTE`,
sem exigir Git a quem arranca). Duas alternativas, com trade-offs honestos:

- **Submodule pinado a tag** — integridade por hash nativa do Git e updates explícitos
  (`git submodule update`); em troca, fricção operacional conhecida dos submodules e **sem
  sanitização** (aponta ao repositório-mãe completo — só aceitável quando toda a equipa pode ver a
  mãe).
- **Subtree** — histórico único e updates por merge; mais simples no dia-a-dia do que o submodule,
  mas mistura o histórico da framework com o do projeto e também **não é sanitizado**.

Qualquer alternativa mantém as regras de sempre: cópia read-only, salto de versão deliberado,
registo em `STATE.md`.

## Reversão

O commit do passo 7 é a unidade de reversão: `git revert` (ou repor a pasta da versão anterior a
partir do histórico) devolve o projeto ao estado exato pré-sincronização. Nenhum artefacto do
projeto foi tocado pelos passos 1–4, por isso a reversão não tem efeitos colaterais.

## Relacionados

- `_meta/VERSION.md` — SemVer da framework e registo de alterações.
- `workflows/W00-project-kickoff.md` — onde a cópia inicial acontece e a versão se regista.
- `core/extensibility.md` — como se estende a framework sem editar o existente.
- `knowledge/README.md` — o circuito que promove lições do projeto à mãe.
- `playbooks/add-an-agent.md` — o caminho certo quando a "edição local" era um agente novo.
- `playbooks/report-framework-improvements.md` — o destino das edições locais que eram melhorias.
- `checklists/pre-merge.md` — aplica-se ao commit de sincronização como a qualquer outro.
