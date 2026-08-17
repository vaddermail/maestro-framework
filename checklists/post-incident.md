# Pós-Incidente

Corre depois de qualquer incidente mitigado, antes de o considerar encerrado
(`workflows/W11-incident-response.md`). Garante que o incidente produz aprendizagem **verificada**
— não só um relatório arquivado que ninguém volta a olhar.

## Post-mortem

- [ ] Post-mortem escrito (`templates/technical/post-mortem.md.template`) com linha do tempo factual
      dos eventos.
- [ ] Causa raiz identificada — não só o sintoma que disparou o alerta.
- [ ] Post-mortem **sem culpados**: descreve o que falhou no sistema/processo, não quem "fez asneira"
      (`knowledge/permanent-rules.md`).
- [ ] Impacto quantificado (duração, utilizadores/pedidos afetados, dados perdidos se houver).

## Ações de prevenção

- [ ] Cada ação de prevenção tem um dono nomeado e um prazo concreto.
- [ ] Ações cobrem a causa raiz, não só um patch pontual do sintoma que disparou o alerta.
- [ ] Ações destrutivas ou de alto risco propostas passam por aprovação humana antes de executar
      (`knowledge/permanent-rules.md` §4).

## Verificação

- [ ] Cada ação marcada como concluída tem **evidência de verificação independente** — não a palavra
      de quem a implementou (`core/quality-gates.md`).
- [ ] Quando a prevenção é um teste novo, o teste reproduz o incidente original (falha antes da
      correção, passa depois) — confirmado, não presumido.
- [ ] Quando aplicável, um simulacro real confirma que as mesmas condições já não reproduzem o
      incidente.

## Memória

- [ ] Lição registada em `STATE.md` §Lições, com o **porquê** e o **como aplicar** — não só
      "cuidado com X" (`core/project-memory.md`).
- [ ] Verificado que a lição não duplica uma já existente — atualiza-se a existente em vez de
      duplicar.
- [ ] Post-mortem arquivado em local acessível a sessões futuras (`product/99-records/`).

## Relacionados

- `workflows/W11-incident-response.md` — o workflow que abre esta checklist.
- `templates/technical/post-mortem.md.template` — o formato do post-mortem.
- `core/project-memory.md` — onde a lição fica registada.
- `knowledge/permanent-rules.md` — honestidade e mudanças destrutivas.
- `core/quality-gates.md` — a regra de verificação independente.
