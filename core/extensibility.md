# Extensibilidade

Como a framework cresce **sem se partir**: novos agentes, workflows, loops, módulos e templates
acrescentam-se **por adição, nunca por cirurgia** aos existentes. É o princípio open-closed aplicado
a documentação executável — e é o que permite que a Maestro acompanhe um produto durante anos.

## Porque funciona

Três propriedades estruturais tornam a adição segura:

1. **Contratos por artefactos, não por chamadas.** Os agentes não se conhecem uns aos outros —
   conhecem artefactos (`core/artifact-protocol.md`). Um agente novo que produza/consuma
   artefactos existentes encaixa sem que nenhum existente saiba dele.
2. **Descoberta por índices, não por hardcoding.** O Orquestrador encontra agentes pelos índices
   (`agents/README.md` + README de categoria + `_meta/INVENTORY.md`), montando o grafo de
   dependências a partir das fichas. Registar = existir.
3. **Fichas autocontidas.** Cada ficha declara tudo (inputs, outputs, regras, interações); não há
   comportamento escondido noutro ficheiro que fosse preciso editar.

## Adicionar um agente

Processo completo em `playbooks/add-an-agent.md`. O essencial:

1. Confirmar que é mesmo **um agente novo** (uma responsabilidade que nenhum existente tem) e não
   uma secção em falta numa ficha existente.
2. Copiar `agents/_template/AGENT-TEMPLATE.md` para a categoria certa; preencher **todas** as
   secções.
3. Declarar inputs/outputs em termos de artefactos existentes — ou, se cria artefactos novos,
   acrescentá-los ao `core/artifact-protocol.md` (adição de linhas, não alteração das
   existentes).
4. Registar nos índices: README da categoria + `_meta/INVENTORY.md`.
5. Se o agente entra num workflow, acrescentar o passo no workflow respetivo — como **passo novo**,
   sem reordenar os existentes salvo razão registada.

**O que nunca é preciso:** editar outras fichas de agentes, o Orquestrador, ou o template.
Se a adição parecer exigir isso, o desenho está errado — voltar ao passo 1.

## Adicionar uma categoria de agentes

Nova pasta `agents/NN-nome/` com README-índice próprio + entrada no `agents/README.md` e no
inventário. Os números não se reciclam (como os IDs de artefactos — `core/artifact-protocol.md`).

## Adicionar workflows, loops, módulos, templates, checklists, playbooks

Mesmo padrão em todos: **criar o ficheiro seguindo a convenção da pasta (ver o README respetivo) →
registar no índice da pasta → registar no inventário.** Loops declaram sempre condição de entrada,
de saída e salvaguarda anti-infinito (`loops/README.md`); módulos declaram-se desacoplados e
adotáveis isoladamente (`modules/README.md`).

## Alterar os existentes (a exceção)

Às vezes é mesmo preciso mudar um contrato (template de agente, protocolo de artefactos, ciclo de
vida). Isso é uma **mudança MAJOR** da framework (`_meta/VERSION.md`):

- Justifica-se por escrito (o quê, porquê, o que parte).
- Preferir o caminho expand-contract também aqui: introduzir o novo ao lado, migrar as fichas,
  retirar o antigo — nunca partir tudo num passo.
- Projetos existentes **não herdam a mudança automaticamente**: re-sincronizam deliberadamente.

## Descontinuar

Nada se apaga às cegas: uma ficha/documento descontinuado marca-se `obsoleto` no topo, com apontador
para o substituto, e sai dos índices ativos. (O mesmo princípio de reversibilidade de sempre —
`MANIFESTO.md` §5.)

## Relacionados

- `playbooks/add-an-agent.md` — o passo-a-passo.
- `agents/_template/AGENT-TEMPLATE.md` — o molde.
- `_meta/INVENTORY.md` — o registo que faz um ficheiro "existir".
- `_meta/VERSION.md` — versionamento da própria framework.
- `playbooks/framework-curation.md` — de onde vêm muitas das adições: o circuito de melhorias
  reportadas pelos projetos (`knowledge/README.md` §Como o conhecimento circula).
