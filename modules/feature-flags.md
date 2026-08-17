# Feature Flags e Kill-Switches · desligar o risco sem deploy

Módulo reutilizável para **separar deploy de ativação**: código novo ou arriscado entra em produção
desligado, liga-se de forma controlada e — o mais importante — **desliga-se sem novo deploy** quando
corre mal. Operacionaliza a reversibilidade por defeito (`knowledge/permanent-rules.md` §3).

## O problema que resolve

Sem flags, cada mudança de risco fica acoplada ao ciclo de deploy: para a desligar é preciso reverter
código, reconstruir e reimplantar — minutos ou horas durante os quais o incidente continua. E não há
como expor uma funcionalidade a 5% dos utilizadores, nem cortar uma integração cara em segundos.

Flags dão **três alavancas** que o deploy sozinho não dá: lançar gradualmente, cortar de imediato, e
experimentar com um subconjunto — todas reversíveis num interruptor. O risco é gerir a **higiene**:
uma flag esquecida é dívida técnica que ninguém ousa remover.

## O modelo (conceitos e entidades, agnóstico de stack)

Duas naturezas de flag, que **não se confundem**:

- **Flag de lançamento (release flag)** — temporária. Esconde código incompleto ou arriscado até estar
  pronto; existe para ser **removida** quando a funcionalidade estabiliza. Vida esperada: dias a
  semanas.
- **Flag operacional (kill-switch / operational flag)** — permanente. Um interruptor de operação que
  fica para sempre: desligar um canal de notificações, um modelo de IA (`modules/ai-observability.md`),
  uma integração externa em manutenção. Existe para ser **usada**, não removida.

Entidades:

- **Flag** — `chave`, `natureza` (lançamento|operacional), `estado`, `dono`, `dataDeRemocao` (nas de
  lançamento), `descrição`, `default seguro`.
- **Regra de resolução** — como se decide o valor para um pedido: global, por percentagem, por
  segmento/perfil/organização, por utilizador.
- **Avaliador** — o ponto único que responde `estaLigada(chave, contexto)`. Nunca se lê a flag de
  forma dispersa; passa **sempre** pelo avaliador.
- **Default seguro** — o valor assumido quando o serviço de flags **falha** ou a chave não existe.
  Numa flag de lançamento é normalmente **desligado** (a funcionalidade nova não aparece); num
  kill-switch de proteção pode ser **ligado** (o corte de segurança fica ativo). Decide-se por flag.

## Regras inegociáveis (numeradas, verificáveis)

1. **Toda a mudança de risco entra atrás de uma flag.** Verificável em revisão: uma fatia que altera
   comportamento crítico sem flag não passa o portão (`core/quality-gates.md`).
2. **Toda a flag tem dono e (se de lançamento) data de remoção.** Verificável: um registo/teste que
   lista flags sem dono ou sem data de remoção e falha se existirem — a mesma disciplina de guardrail
   de `knowledge/proven-patterns.md` §7.
3. **Default seguro quando o serviço de flags falha.** Verificável: simular indisponibilidade do
   avaliador e afirmar que cada flag resolve para o seu default documentado, nunca crasha nem assume
   "ligado" por omissão.
4. **Lançamento ≠ operacional, marcado explicitamente.** Uma flag declara a natureza; as de lançamento
   entram no relógio de remoção, as operacionais não.
5. **Leitura só pelo avaliador.** Nenhum código lê a fonte de flags diretamente; um único ponto
   resolve, para o kill-switch ser fiável e testável.
6. **Kill-switch tem efeito imediato, sem deploy.** Verificável: alternar a flag muda o comportamento
   no pedido seguinte (sem reinício).
7. **Estado das flags é auditável.** Quem ligou/desligou o quê e quando fica registado
   (`modules/audit-and-provenance.md`) — um kill-switch acionado num incidente é evidência.
8. **Remover a flag remove os dois caminhos.** Ao retirar uma flag de lançamento, apaga-se o código do
   ramo morto **e** a chave — não fica um `if` sempre-verdadeiro nem uma chave órfã.

## Como se adota num produto novo (passos)

1. **Escolher o mecanismo** (`core/decision-engine.md`): começar simples — uma tabela de
   configuração na BD com um avaliador em memória cobre a maioria dos produtos. Serviço dedicado
   (LaunchDarkly/Unleald/Flagsmith/…) só quando o *targeting* fino e a escala o justificarem.
2. **Definir o registo de Flag** com `dono` e `dataDeRemocao` obrigatórios por natureza.
3. **Implementar o avaliador único** `estaLigada(chave, contexto)` com default seguro e fail-safe.
4. **Ligar o guardrail de higiene:** um teste que falha se houver flag sem dono, ou de lançamento
   vencida (`dataDeRemocao` no passado ainda ligada).
5. **Integrar com os kill-switches dos outros módulos:** canais da `modules/job-queue.md`, modelos
   da `modules/ai-observability.md`, integrações da `modules/readonly-external-integrations.md`.
6. **Documentar cada flag** na fonte única de conteúdos se afetar UI (`modules/single-source-of-content.md`).
7. **Fechar o ciclo:** ao estabilizar uma funcionalidade, agendar a remoção da flag como tarefa de
   dívida técnica (`loops/L08-technical-debt.md`).

## Variações e trade-offs

- **Config na BD vs serviço dedicado.** BD: zero infra nova, transacional, versionável; targeting
  limitado. Serviço: percentagens, segmentos, experiências A/B, mas mais uma dependência de runtime —
  e por isso a regra 3 (default seguro na falha) torna-se crítica.
- **Flag booleana vs multivariante.** Comece booleana. Multivariante (escolher entre várias
  implementações) só quando fizer experiências reais; até lá é complexidade sem retorno.
- **Estático (build-time) vs dinâmico (runtime).** Flags de build eliminam o ramo morto do bundle mas
  **não** desligam sem deploy — não servem de kill-switch. Kill-switches são sempre runtime.
- **Targeting por percentagem vs por segmento.** Percentagem é o rollout mais simples; segmento
  (perfil, organização, região) alinha-se com o `modules/rbac-and-scoping.md` e é preferível quando o
  risco é desigual entre grupos.

## Exemplo (multi-domínio)

**SaaS B2B — novo motor de faturação.** A reescrita do cálculo de faturas entra atrás de
`faturacao-motor-v2` (lançamento, dono: equipa Billing, remoção: fim do trimestre). Liga-se a 5% das
organizações; um erro de arredondamento aparece; alterna-se para 0% em segundos, sem reverter o deploy
que já traz outras correções. Corrigido e reativado gradualmente até 100%, a flag é removida com o
ramo antigo.

**App interna — integração de email.** `envio-email` é um kill-switch operacional (permanente). Numa
manutenção do fornecedor SMTP, desliga-se: os jobs de email da `modules/job-queue.md` acumulam-se
em `pendente` em vez de falharem em cascata; religa-se e a fila drena. Se o avaliador de flags ficar
indisponível, o **default seguro** de `envio-email` é "ligado", para não silenciar notificações por
acidente — decisão registada por ser um desvio ao default de lançamento.

## Armadilhas conhecidas

- **Flag zombie:** a funcionalidade estabilizou há meses e a flag continua, com ambos os ramos vivos —
  ninguém sabe se é seguro remover. A regra 2 (data de remoção) e o loop de dívida técnica existem
  para isto.
- **Default fail-open perigoso:** assumir "ligado" quando o serviço de flags cai pode expor código
  incompleto — ecoa o `?? "ADMIN"` de `knowledge/origin-lessons.md` §C1. O default é uma decisão
  consciente por flag.
- **Leitura dispersa:** ler a flag em dez sítios diferentes torna o kill-switch não-fiável; centralizar
  no avaliador (regra 5).
- **Flag a fazer de configuração de negócio:** limiares de aprovação, tarifas e permissões **não** são
  flags — são dados de configuração do domínio (`modules/approval-engine.md`). Flags ligam/desligam
  caminhos de código; não guardam parâmetros de negócio.
- **Explosão combinatória:** muitas flags interdependentes criam estados impossíveis de testar; manter
  poucas, independentes e de vida curta.

## Relacionados

- `agents/07-devops/feature-flags-specialist.md` — o agente que desenha e implementa flags.
- `agents/07-devops/deployment-strategist.md` — flags como par do rollback no lançamento.
- `knowledge/permanent-rules.md` — §3 reversibilidade por defeito.
- `modules/ai-observability.md` — kill-switch por modelo de IA.
- `modules/job-queue.md` — kill-switch por canal/tipo de job.
- `modules/audit-and-provenance.md` — trilho de quem ligou/desligou.
- `loops/L08-technical-debt.md` — remoção deliberada de flags de lançamento vencidas.
