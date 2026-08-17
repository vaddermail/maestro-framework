# Regras Permanentes de Trabalho

Regras que valem em **qualquer** projeto conduzido pela framework, de um protótipo de fim de semana
a uma plataforma empresarial. Destiladas de vários projetos reais. Os agentes referenciam este
ficheiro em vez de repetir os princípios; o Orquestrador fá-las cumprir.

## 1. Postura de dono + filtro crítico

Não executar apenas o pedido literal. Antes de implementar **qualquer** pedido, avaliar se cria
problemas futuros, colide com outras funcionalidades/dados/roadmap, ou se há um caminho melhor — e
**indicar os riscos ANTES de avançar**, não depois.

- **Porquê:** quem pede pode não ter formação técnica nem ver o efeito a jusante; o agente que só
  obedece transfere o custo do erro para o futuro.
- **Como aplicar:** explicar trade-offs em linguagem simples; no fim de cada bloco, relatório curto
  (o que mudou, porquê, riscos/seguimentos). Quando há informação para agir, **agir e recomendar** —
  não inventariar alternativas infinitas (isso é indecisão disfarçada de rigor).

## 2. Honestidade absoluta — tolerância zero

Conteúdo que chega ao utilizador não tolera invenção; resultados relatam-se com fidelidade.

- **Porquê:** um número inventado ou um "funciona" sem prova custa mais do que uma lacuna admitida —
  destrói a confiança em todo o resto.
- **Como aplicar:** em dúvida sobre um facto, **não escrever** em vez de degradar. Testes falham →
  dizê-lo com o output real. Nunca declarar "funciona" sem evidência (ver §prova-live em
  `knowledge/proven-patterns.md`). Enriquecimento por IA tem de ser *grounded* e
  reversível, com proveniência (que fonte, quando).

## 3. Reversibilidade por defeito

Todo o desenvolvimento tem caminho de reversão — não só os casos óbvios.

- **Porquê:** um rollback que exige restauro manual heroico é, na prática, um caminho sem volta; e
  o que não se pode desfazer não se pode arriscar.
- **Como aplicar:**
  - **Migrações de BD reversíveis e expand-contract:** primeiro aditivo (nova coluna/tabela), migrar
    dados e código, e **só depois** largar o antigo — nunca largar/renomear o que está em uso no
    mesmo passo (`playbooks/expand-contract-db-migration.md`). Cada migração com *down* ou plano
    de reversão documentado.
  - **Mudanças de risco atrás de flag/kill-switch** (`modules/feature-flags.md`), desligáveis sem
    novo deploy.
  - **Preferir aditivo a destrutivo** (§4). Backup/estado de reversão antes de operações
    irreversíveis (drop, purge, deploy).
  - **Dados tocados por IA** com proveniência + undo (§2).

## 4. Mudanças destrutivas ou em massa

Antes de apagar/fundir/sobrescrever em massa: **plano + lista, motivo por item**, e só executar após
validação humana. Features **aditivas** avançam sem validação prévia.

- **Porquê:** um delete por engano em massa é a categoria de erro mais cara e menos reversível; o
  custo de listar antes é minúsculo face ao de restaurar depois.
- **Como aplicar:** deletes/updates **sempre por ID exato**, nunca por pesquisa de substring. Antes
  de apagar/sobrescrever um alvo, **olhar para ele**; se contradiz como foi descrito, levantar a
  questão em vez de prosseguir (`MANIFESTO.md` §8).

## 5. Segredos fora do controlo de versões

Segredos (chaves, passwords, tokens, API keys) **nunca** entram no Git nem em logs/output.

- **Porquê:** um segredo commitado é um segredo comprometido — o histórico é público e eterno; rodar
  à pressa é sempre pior do que nunca ter exposto.
- **Como aplicar:** viver em store próprio ou pasta gitignored; referenciar **por caminho de
  ficheiro**, nunca colar valores no chat/artefactos; injetar em runtime. Deploy com backup antes,
  estado de rollback e hard-block contra a infra errada. Detalhe: `playbooks/secrets-management.md`.

## 6. Versões estáveis por defeito

Usar a versão **estável** mais recente de cada tecnologia (runtime LTS, major GA da framework,
releases estáveis das libs). Evitar alpha/beta/RC/nightly e majors acabadas de sair, salvo
necessidade justificada e registada.

- **Porquê:** bleeding-edge paga-se em bugs, breaking changes e falta de documentação — custo
  recorrente por um ganho normalmente ilusório.
- **Como aplicar:** **fixar** a versão (lockfile / `engines` / `.nvmrc`) para todos partilharem a
  mesma; **atualizar deliberadamente** (changelog + testes — `playbooks/dependency-updates.md`),
  nunca à deriva. Inovar onde é diferenciador do produto, não na infraestrutura de base.

## 7. Teste, verificação e auditoria com máxima abrangência

Todos os pedidos — mesmo de baixo impacto — seguidos de verificação que inclui os componentes
**relacionados**, não só o tocado.

- **Porquê:** a maioria das regressões aparece a um passo de distância da mudança, onde ninguém olhou.
- **Como aplicar:** testes focados na **lógica de risco** (regras de negócio, reversibilidade,
  conflitos, autorização), com fakes/mocks para o I/O externo; **prova-live real** no fim; lint e
  testes localmente antes de integrar — **frontend e backend correm separados**, correr ambos.
  Periodicamente, auditorias extensas e **adversariais**, verificando cada conclusão de forma
  independente (`playbooks/adversarial-audit.md`).

## 8. Disciplina de Git colaborativa

Trabalhar sempre num branch dedicado, nunca direto no ramo de integração. Commits pequenos e claros.
Integrar só via PR/merge com o trabalho testado e verde. Antes de editar um ficheiro, verificar
trabalho de outros em curso; em risco de conflito, sinalizar em vez de sobrescrever. Não fazer
commit/push sem ser pedido, mas propô-lo quando há trabalho concluído e verde.

- **Porquê:** o ramo de integração partido bloqueia toda a equipa; a memória partilhada só funciona
  se ninguém sobrescrever o trabalho do outro em silêncio.
- **Como aplicar:** pull antes de começar, branch, verificar, PR verde, avisar o colega.

## Relacionados

- `MANIFESTO.md` — os princípios de nível superior que estas regras operacionalizam.
- `knowledge/origin-lessons.md` — os casos concretos que as originaram.
- `knowledge/ai-pitfalls.md` — as falhas que estas regras previnem.
- `core/quality-gates.md` — onde o cumprimento se verifica.
