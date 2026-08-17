# Guia de Estilo da Framework Maestro

Convenções obrigatórias para **todos** os ficheiros da framework. Um leitor deve conseguir saltar de
qualquer documento para qualquer outro sem mudar de "dialeto".

## Língua e tom

1. **Português de Portugal** (utilizador, equipa, ficheiro, gestão, ecrã — nunca usuário/arquivo/tela).
   Termos técnicos consagrados ficam em inglês (deploy, rollback, cache, pipeline, backlog) — não se
   traduzem à força.
2. Tom direto e prático, dirigido a quem vai **executar**: frases completas, sem prosa de marketing.
   Explicar trade-offs em linguagem simples — o leitor pode não ter formação técnica (princípio da
   postura de dono: avisar riscos antes de avançar).
3. Tudo o que for regra é **verificável**: evita "deve ser de qualidade"; escreve o critério que se
   consegue confirmar.

## Nomes e estrutura

4. Ficheiros e pastas em **kebab-case PT-PT** (`guardiao-de-seguranca.md`). Alias internacional no
   título quando existir: `# Guardião de Segurança (Security Guardian)`.
5. Cada ficheiro começa com `# Título` e uma linha de contexto (o que é, para quem). Documentos de
   agente seguem **exatamente** o `agents/_template/AGENT-TEMPLATE.md` — todas as secções, pela
   mesma ordem.
6. Workflows numerados `Wnn-nome.md`, loops `Lnn-nome.md`, fases do ciclo de vida `F0`–`F9`.
7. Referências cruzadas sempre como caminho relativo à raiz da framework entre crases:
   `core/orchestrator.md`, `agents/09-security/pentester.md`. Nunca "ver o documento de segurança".
   **Todo o caminho referido tem de existir** no `_meta/INVENTORY.md`.

## Conteúdo

8. **Nunca assumir**: onde faltar informação do utilizador, o documento remete para o
   `core/question-engine.md` com as perguntas concretas — não inventa respostas.
9. Exemplos são **realistas e multi-domínio** (e-commerce, SaaS, app interna, plataforma de dados) —
   a framework é agnóstica de domínio; nada de exemplos presos ao domínio de origem.
10. Conhecimento de origem: quando uma prática vem da experiência do projeto-mãe,
    referencia-se `knowledge/origin-lessons.md` em vez de repetir a história.
11. Tabelas para factos enumeráveis; prosa para raciocínio. Checklists com `- [ ]`.
12. Cada documento fecha, quando aplicável, com **"Relacionados"**: lista de 3–8 caminhos para onde
    o leitor segue naturalmente.

## Princípios que atravessam tudo (não repetir, referenciar)

13. Reversibilidade por defeito → `knowledge/permanent-rules.md`.
14. Honestidade de dados/resultados — tolerância zero a invenção → `knowledge/permanent-rules.md`.
15. Aprovação humana antes de ações destrutivas/em massa → `core/quality-gates.md`.
16. Memória do projeto em ficheiros locais versionáveis → `core/project-memory.md`.
17. Um agente, uma responsabilidade → `MANIFESTO.md`.

## O que a framework não faz

18. A framework **não executa nada sozinha** — descreve como agentes de IA (em qualquer ferramenta:
    Claude Code, Cowork, outros) devem trabalhar. O acoplamento a ferramentas concretas vive apenas
    em `adapters/`.
19. Nenhum documento assume domínio, stack, cloud ou orçamento — tudo se decide com o utilizador via
    motor de perguntas e motores de decisão.
