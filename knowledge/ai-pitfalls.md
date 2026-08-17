# Armadilhas do Desenvolvimento Assistido por IA

Falhas típicas de quem constrói software com agentes de IA — e como a Maestro as **bloqueia por
construção**, não por lembrete. Cada armadilha traz o mecanismo da framework que a neutraliza. Para o
Orquestrador e para os revisores, é uma lista de *smells* a caçar.

## Raciocínio e verdade

**1. Alucinação confiante.** A IA inventa uma API, um facto, um número — com toda a segurança.
→ Bloqueio: honestidade absoluta (`knowledge/permanent-rules.md` §2); grounding obrigatório na
fonte de verdade (`modules/single-source-of-content.md`); em dúvida, não escrever. Revisores
verificam factos contra artefactos, não contra a fluência do texto.

**2. "Funciona" sem prova.** Typecheck e testes verdes tomados como prova de que o sistema faz o que
devia. → Bloqueio: **prova-live real** é gate insubstituível (`checklists/definition-of-done.md`
§Por alteração de código; `core/quality-gates.md`).
Testes verdes provam que o código não parte; não provam que resolve o problema.

**3. Assumir em vez de perguntar.** Preencher lacunas com pressupostos plausíveis. → Bloqueio: o
motor de perguntas (`core/question-engine.md`) e o loop L01; um input em falta **para** o agente,
não o convida a adivinhar.

**4. Aceitar o brief como infalível.** Implementar fielmente uma spec que contém um bug. → Bloqueio:
postura de dono (`knowledge/permanent-rules.md` §1) — o implementador **questiona** a spec; um
especialista pode concluir "o que me pedem está errado" e isso é output válido.

## Escopo e deriva

**5. Fazer mais do que o pedido (scope creep silencioso).** "Aproveitei e refiz também…" →
Bloqueio: fatias verticais delimitadas (`workflows/W06-build.md`); mudanças fora do âmbito são
decisão do utilizador (portões). Aditivo avança; destrutivo/lateral pergunta.

**6. Reabrir decisões fechadas.** Re-litigar a cada sessão o que já foi decidido. → Bloqueio:
decisões fechadas (`core/decision-engine.md`); reabrir exige novidade material e faz-se às claras.

**7. Duas fontes de verdade que divergem.** A IA duplica um facto/label/regra "para ser rápido". →
Bloqueio: SSOT com guardrails automáticos (`knowledge/proven-patterns.md` §4, §7).

## Memória e continuidade

**8. Estado na cabeça da sessão.** Confiar que "me lembro do que decidimos". → Bloqueio: memória em
ficheiros (`core/project-memory.md`); está escrito ou não existe. Cada sessão começa por ler
`STATE.md`.

**9. Perder o testemunho entre sessões/ferramentas.** Trabalho meio-feito sem rasto para retomar. →
Bloqueio: protocolo de fim de sessão (`START-HERE.md` §2.5); pendências e decisões-em-nome-do-dono
registadas.

**10. Lição reaprendida à conta de repetir o bug.** → Bloqueio: `STATE.md` §Lições com *porquê* +
*como aplicar*; promoção a `knowledge/` quando se prova geral. Regra: anotar a **proveniência** das
regras duras para ninguém as "simplificar" sem perceber porque existem.

## Custo e escala do próprio processo de IA

**11. Modelo de topo para tudo.** Correr trabalho mecânico e todos os subagentes no modelo mais caro.
→ Bloqueio: routing por tarefa (`core/model-routing.md`); o que esgota o orçamento é o
**fan-out no tier caro**, não o modelo forte no problema difícil.

**12. Confiar em otimizações de custo não verificadas.** Assumir que o caching/batch está a poupar.
→ Bloqueio: ceticismo obrigatório — verificar pré-requisitos reais antes de contar com a poupança.

**13. Ferramentas/contexto a mais.** Carregar plugins/documentos que não acrescentam valor **agora**
e pagam custo em todas as sessões. → Bloqueio: adoção evolutiva (`adapters/claude-code.md`):
adotar quando faz sentido, remover quando deixa de fazer.

## Concorrência, ambiente e ferramentas (armadilhas de execução)

**14. Suites/tarefas pesadas em paralelo rebentam a máquina.** Testes WASM/BD-em-memória em paralelo
→ OOM no ambiente de dev. → Bloqueio: correr suites pesadas em série; o controlador de subagentes
fecha-os explicitamente em vez de os deixar pendurados num monitor (`agents/10-quality/README.md`).

**15. O motor de dev esconde bugs de concorrência.** Um motor de BD leve que serializa corridas que a
produção não serializa. → Bloqueio: testar locks/transações também contra o motor real; paridade real
é gate quando a fatia mexe em dados (`agents/06-data/migration-engineer.md`).

**16. Upgrade de dependência que parte algo em silêncio.** Ex.: mapeamento de erros muda sem aviso. →
Bloqueio: atualização deliberada com changelog + testes (`playbooks/dependency-updates.md`);
o Guardião de Dependências (`agents/13-guardians/dependency-guardian.md`) valida antes de
adotar.

**17. Mudar um componente/label partilhado e partir testes distantes.** → Bloqueio: verificação de
**máxima abrangência** que varre também o que está a um passo (`knowledge/permanent-rules.md` §7).

**18. Bugs que só existem no browser/runtime real.** Componentes que se comportam diferente do que o
teste unitário sugere. → Bloqueio: prova-live real (§2) e smoke E2E no ambiente-alvo.

**19. Matar processos pelo nome, não pela porta.** Um "kill pelo nome" mata o processo errado ou
falha o certo. → Bloqueio: operar por identificador exato (eco de `knowledge/permanent-rules.md`
§4 — por ID, nunca por substring), incluindo ao gerir processos.

## Verificação

**20. Auto-validação.** A IA que produziu declara o próprio trabalho pronto. → Bloqueio: verificação
independente sempre (`core/quality-gates.md`); quem produz nunca é quem valida.

**21. Confiar numa única perspetiva.** Um só revisor/verificador dá luz verde. → Bloqueio: painéis e
**auditoria adversarial** (`playbooks/adversarial-audit.md`) — a convergência de duas auditorias
independentes é confiança alta, mas mesmo essa se verifica.

## Relacionados

- `knowledge/permanent-rules.md` — as regras que estas armadilhas justificam.
- `knowledge/origin-lessons.md` — os casos reais de onde vieram.
- `core/orchestrator.md` §Orchestrator anti-patterns — as armadilhas específicas do papel coordenador.
- `playbooks/adversarial-audit.md` — o método que as caça em lote.
