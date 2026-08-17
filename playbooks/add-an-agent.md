# Playbook — Adicionar um Agente

Estender a framework com um agente novo **por adição, nunca por cirurgia** aos existentes (princípio
open-closed — `core/extensibility.md`). Este é o passo-a-passo que o `agents/_template/AGENT-TEMPLATE.md`
e a `core/extensibility.md` descrevem; segui-lo garante que o novo agente fica descobrível pelo
Orquestrador sem partir nada.

**Quando se executa:** quando aparece uma **responsabilidade que nenhum agente existente tem** e que
não cabe como secção de uma ficha existente. **Quem:** quem estende a framework (tipicamente numa
sessão de manutenção da própria Maestro), em branch dedicado e PR verde
(`knowledge/permanent-rules.md` §8).

## Pré-condições

- [ ] A necessidade está descrita numa frase ("uma linha" ao estilo do `_meta/INVENTORY.md`).
- [ ] Sabes a **categoria** de destino (`agents/NN-categoria/`) e a **fase** dominante do agente
      (`core/lifecycle.md`).

## Passos

### 1. Confirmar que é mesmo um agente novo
**Faz:** varrer o `_meta/INVENTORY.md` e o README da categoria à procura de sobreposição. Testar a
regra do MANIFESTO: se a responsabilidade precisa de "e" para se descrever (duas coisas independentes),
são dois agentes; se cabe como secção de uma ficha existente, **não** é agente novo.
**Verifica:** consegues nomear a **única** responsabilidade numa frase e apontar por que nenhum agente
atual a cobre.
**Se falhar:** se há sobreposição com um agente existente, **para** — ou a necessidade é uma clarificação
na ficha existente (PATCH, não novo agente), ou a fronteira entre os dois tem de ser redesenhada antes
de avançar. Nunca criar um agente que duplica responsabilidade (`MANIFESTO.md` §1,
`knowledge/ai-pitfalls.md` §7).

### 2. Copiar o template para a categoria certa
**Faz:** copiar `agents/_template/AGENT-TEMPLATE.md` para `agents/NN-categoria/nome-do-agente.md`
(nome em kebab-case PT-PT, alias internacional no título se existir — `_meta/STYLE-GUIDE.md`).
**Verifica:** o ficheiro existe no sítio certo com o nome na convenção.
**Se falhar:** se a categoria certa não existe, é preciso **adicionar uma categoria** primeiro (nova
pasta + README + entradas nos índices — `core/extensibility.md`), não forçar o agente numa categoria
que não é a sua.

### 3. Preencher **todas** as secções
**Faz:** completar Identificação · Objetivo · Quando inicia · Quando termina · Inputs · Outputs ·
Perguntas ao utilizador · Regras · Limitações · Workflow · Exemplos · Boas práticas · Anti-padrões ·
Interações · Critérios de pronto. Nenhuma é opcional; se uma não se aplica, escrever "Não aplicável,
porque …". Declarar inputs/outputs em termos de **artefactos existentes** (`core/artifact-protocol.md`);
escolher a camada de modelo em `core/model-routing.md`.
**Verifica:** nenhuma secção ficou com texto de *placeholder* do template; as **Limitações** nomeiam o
agente vizinho responsável por cada coisa excluída (fronteiras explícitas, sem sobreposição).
**Se falhar:** uma secção que não consegues preencher é sinal de que a responsabilidade ainda está
difusa — voltar ao passo 1.

### 4. Tratar artefactos novos (se os houver)
**Faz:** se o agente **cria** um artefacto que ainda não existe, acrescentá-lo ao
`core/artifact-protocol.md` como **linha nova** (nunca alterar as linhas existentes).
**Verifica:** o artefacto novo tem dono, localização e consumidores declarados; os existentes ficaram
intactos.
**Se falhar:** se parece preciso **alterar** um artefacto existente, isso é uma mudança de contrato
(MAJOR — passo 7 de exceção da `core/extensibility.md`), não um simples "adicionar agente".

### 5. Registar nos índices **no mesmo passo**
**Faz:** adicionar a linha do agente ao README da categoria (`agents/NN-categoria/README.md`) **e** ao
`_meta/INVENTORY.md`, com a mesma "uma linha". Se o agente entra num workflow, acrescentar o passo no
workflow respetivo como **passo novo**, sem reordenar os existentes salvo razão registada.
**Verifica:** o agente aparece nos **dois** índices com descrições coerentes entre si; registar = existir
(`core/extensibility.md`). Um agente fora do inventário é invisível ao Orquestrador.
**Se falhar:** se só ficou num índice, o agente fica meio-registado — corrigir antes de fechar (é a
causa clássica de cross-refs partidas).

### 6. Verificar as referências cruzadas
**Faz:** confirmar que **todos** os caminhos citados na ficha nova existem no `_meta/INVENTORY.md`, e
que as **Interações** declaradas batem certo com as fichas dos agentes vizinhos (a montante/jusante/
paralelo). Confirmar que **nenhuma ficha existente foi editada** para acomodar o novo.
**Verifica:** `grep` dos caminhos citados contra o inventário não deixa nenhum órfão; `git diff` mostra
**apenas** ficheiros novos + as adições aos índices/protocolo, nunca alterações a fichas de agentes
existentes.
**Se falhar:** se a adição exigiu editar outra ficha, o Orquestrador ou o template, **o desenho está
errado** — voltar ao passo 1 (`core/extensibility.md`: "o que nunca é preciso").

### 7. Bump de versão da framework
**Faz:** incrementar a versão **MINOR** em `_meta/VERSION.md` (novo agente = extensão aditiva) e
registar a entrada no changelog da framework.
**Verifica:** `_meta/VERSION.md` reflete a nova versão MINOR com a linha do agente adicionado.
**Se falhar:** se a mudança afinal quebrou um contrato entre agentes, não é MINOR — é MAJOR, e precisa
da justificação escrita e do caminho expand-contract da `core/extensibility.md`.

## Reversão

Adição pura é trivialmente reversível: remover o ficheiro do agente e as **duas** linhas de índice
(README da categoria + inventário), a linha de artefacto (se criada) e o bump de VERSÃO — nada mais foi
tocado, por construção. Se um agente deixar de fazer sentido mais tarde, **não se apaga às cegas**:
marca-se `obsoleto` no topo com apontador para o substituto e sai dos índices ativos
(`core/extensibility.md` §Descontinuar).

## Relacionados

- `agents/_template/AGENT-TEMPLATE.md` — o molde a copiar e preencher por inteiro.
- `core/extensibility.md` — porque a adição é segura e o que nunca é preciso tocar.
- `_meta/INVENTORY.md` · `agents/README.md` — os índices onde registar = existir.
- `core/artifact-protocol.md` — onde se declaram artefactos novos (por adição).
- `_meta/VERSION.md` — o bump MINOR e o changelog da framework.
- `core/model-routing.md` — a camada de modelo do agente novo.
- `MANIFESTO.md` — um agente, uma responsabilidade (o teste do passo 1).
