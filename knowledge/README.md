# Conhecimento

A experiência destilada que a framework carrega. Enquanto `agents/`, `workflows/` e `modules/`
dizem **como fazer**, `knowledge/` diz **o que aprendemos a fazer assim** — cada regra com o
custo real que a originou. É o que impede um agente de "simplificar" uma salvaguarda por não perceber
porque existe.

## Ficheiros

- `knowledge/permanent-rules.md` — as regras de trabalho que valem em qualquer projeto:
  postura de dono, honestidade absoluta, reversibilidade, mudanças em massa, versões estáveis.
- `knowledge/origin-lessons.md` — lições generalizadas do projeto-mãe, cada uma com
  o *porquê* e o *como aplicar*. É a memória de defeitos que a framework herda.
- `knowledge/ai-pitfalls.md` — falhas típicas do desenvolvimento assistido por IA e como a
  framework as bloqueia por construção.
- `knowledge/proven-patterns.md` — padrões de arquitetura/operação validados em produção
  (fila com executor único, upsert por ID, SSOT, fallbacks visíveis, defesa em profundidade).
- `knowledge/candidates.md` — a sala de espera: lições reportadas por um projeto, à espera da
  segunda confirmação antes de serem promovidas (mantida pela `playbooks/framework-curation.md`).

## Como o conhecimento circula

A regra de ouro do circuito: **sinais sobem, releases descem.** Um projeto nunca escreve na
framework; a framework nunca muda por baixo de um projeto.

```
projeto real ──(no momento)──▶ FRAMEWORK-IMPROVEMENTS.md (na raiz do projeto)
                                        │  fecho de fase — playbooks/report-framework-improvements.md
                                        ▼
                       issues `melhorias` no repositório-mãe
                                        │  curadoria — playbooks/framework-curation.md
                                        ▼
        knowledge/candidates.md ──(≥2 confirmações)──▶ PR + merge humano ──▶ knowledge/ (MINOR)
                                                                                        │
projeto real ◀──(sincronização deliberada — playbooks/sync-framework.md)◀────────┘
```

1. **Para baixo (framework → projeto):** os agentes referenciam estes ficheiros em vez de repetir os
   princípios. Uma ficha que precise de invocar "reversibilidade" aponta para
   `knowledge/permanent-rules.md` — não reescreve a regra. As promoções chegam aos projetos
   por release (`_meta/VERSION.md`) e sincronização deliberada — nunca automaticamente.
2. **Para cima (projeto → framework):** a captura é **obrigatória e no momento** — cada projeto
   mantém desde F0 o seu `FRAMEWORK-IMPROVEMENTS.md`
   (`templates/project/FRAMEWORK-IMPROVEMENTS.md.template`), consolida-o nos fechos de fase
   (`checklists/definition-of-done.md`) e envia-o como issue à mãe
   (`playbooks/report-framework-improvements.md`). O `agents/14-meta/framework-curator.md`
   tria, gere `knowledge/candidates.md` (uma lição de **um** projeto espera pela segunda
   confirmação) e propõe promoções por **PR** — que só entram com merge do dono da framework, numa
   atualização MINOR. As lições do **produto** continuam no `STATE.md` §Lições
   (`core/project-memory.md`); ao ficheiro de melhorias vai o que é da **framework**. É assim
   que a Maestro fica mais sábia a cada produto.

## Regra de ouro deste diretório

Cada afirmação traz o **porquê** e o **como aplicar**. Uma lição sem porquê vira superstição; um
princípio sem aplicação vira decoração. Se não consegues escrever os dois, ainda não percebeste a
lição — não a escrevas.

## Relacionados

- `core/project-memory.md` — onde as lições vivem num projeto antes de subirem.
- `MANIFESTO.md` — os princípios que este conhecimento fundamenta.
- `playbooks/adversarial-audit.md` — o método que mais lições produz.
- `playbooks/report-framework-improvements.md` · `playbooks/framework-curation.md` — os dois
  lados do circuito para cima.
- `agents/14-meta/framework-curator.md` — quem cura o que os projetos reportam.
