# Portões de Qualidade

Um portão é uma **decisão binária e verificável**: ou o trabalho cumpre os critérios e avança, ou
não cumpre e fica. Os portões existem para substituir "parece pronto" por evidência — e para
garantir que as decisões que são do humano chegam mesmo ao humano.

## Anatomia de um portão

Todo o portão declara:

1. **O que guarda** — a transição (fase→fase, fatia→merge, release→produção).
2. **Critérios** — checklist verificável (vive em `checklists/`), sem itens subjetivos.
3. **Quem verifica** — nunca quem produziu (revisores, harness de testes, ou o Orquestrador para
   critérios formais).
4. **Quem aprova** — o utilizador, quando a decisão é dele (ver matriz abaixo); caso contrário, o
   Orquestrador declara a passagem.
5. **Registo** — resultado em `STATE.md` (e em `product/99-records/` quando produz relatório).

**Não há passagem parcial.** Um portão com um critério falhado não passa; o que há é o utilizador
poder **derrogar explicitamente** um critério — e a derrogação fica registada com o porquê e o risco
assumido (é uma decisão dele, não um atalho do agente).

## Os portões do ciclo de vida

| Portão | Transição | Critérios principais | Aprovação humana? |
| --- | --- | --- | --- |
| **P0** | F0 → F1 | Memória instanciada; perfil de esforço calibrado | Sim (perfil) |
| **P1** | F1 → F2 | Dossier de descoberta completo; MVP e prioridades definidos; riscos com dono | **Sim** (âmbito) |
| **P2** | F2 → F3 | Zero ambiguidades críticas (L01 fechado); RNF quantificados; regras de negócio numeradas | **Sim** (requisitos) |
| **P3** | F3 → F4 | ADRs aprovados com reversão; stack fixada em versões estáveis; custos validados | **Sim** (ADRs + custos) |
| **P4** | F4 → F5 | Wireframes dos fluxos críticos validados; tokens do design system definidos; plano de acessibilidade | **Sim** (UX) |
| **P5** | F5 → F6 | Especificação aprovada; máquinas de estado dos fluxos críticos; modelo de dados lógico; contrato backend; revisão mínima (arquitetura+segurança+UX) | **Sim** — desbloqueia código |
| **P6** | por fatia, F6 | `checklists/definition-of-done.md` + `checklists/pre-merge.md`; testes verdes (front e back); spec respeitada | Não (salvo âmbito novo) |
| **P6b** | F6 → F7 | MVP completo vs spec; harness de regressão verde; dívida registada | Sim (aceitação do MVP) |
| **P7** | F7 → F8 | Zero achados críticos/altos abertos; `checklists/pre-production-security.md`; risco residual assinado | **Sim** (risco residual) |
| **P8** | F8 → produção | `checklists/go-live.md`; rollback ensaiado; backups verificados; monitorização ativa | **Sim, sempre** — produção é do humano |
| **P9** | contínuo, F9 | Cadências dos guardiões cumpridas; loops sem pendências críticas | Por exceção (relatórios) |

## Matriz de aprovação humana

Independentemente do portão, exigem humano **sempre** (ver `core/orchestrator.md` §Aprovação
humana): âmbito e prioridades · dinheiro e compromissos · ações destrutivas/em massa · produção ·
risco residual de segurança · dados pessoais · reabertura de decisões fechadas.

E **nunca** precisam de humano: correr testes, lint e scans; escrever rascunhos; refactors sem
mudança de comportamento dentro de uma fatia; perguntas ao próprio código (análise). Automatizar a
verificação é desejável; automatizar a **aprovação**, proibido.

## Portões e perfis de esforço

O perfil (`core/orchestrator.md` §Perfis) dimensiona a **profundidade da evidência**, não a
existência do portão: num protótipo, P5 pode ser "spec de 3 páginas revista pelo próprio
Orquestrador + OK do utilizador"; numa plataforma empresarial é painel completo. A tabela de cada
checklist indica o que é dispensável por perfil — o que não estiver marcado como dispensável,
não é.

## Anti-padrões

- ❌ Portão de borracha ("falta pouco, passa") → ✅ ou passa, ou fica; derrogação é do utilizador,
  registada.
- ❌ Auto-validação (quem fez declara pronto) → ✅ verificação independente sempre.
- ❌ "Testado" sem output → ✅ evidência anexa (resultado real dos testes) — honestidade absoluta.
- ❌ Portão surpresa (critérios revelados na hora) → ✅ critérios conhecidos desde o início da fase.
- ❌ Acumular tudo para um mega-portão final → ✅ portões pequenos e frequentes (P6 por fatia).

## Relacionados

- `checklists/README.md` e todas as checklists — os critérios concretos.
- `core/lifecycle.md` — onde os portões se encaixam.
- `core/orchestrator.md` — quem os faz cumprir.
- `playbooks/adversarial-audit.md` — o escrutínio máximo, usado em P7.
