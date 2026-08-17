# L03 — Problemas de Segurança

> Loop `L03` da framework Maestro — persiste enquanto existirem achados de segurança abertos,
> resolvendo pela severidade real (não pela ordem de deteção). Segue a anatomia de `loops/README.md`.

Um achado de segurança não resolvido não desaparece por se ignorar — fica à espera de ser explorado.
Este loop existe para que nenhum achado fique "para depois" sem que essa decisão seja explícita,
assinada pelo utilizador, e nunca do agente.

## Identificação

| Campo | Valor |
| --- | --- |
| **Quando corre** | F7 (painel de revisão + pentest, antes do lançamento); F9 (contínuo, cadência do guardião) |
| **Agente que executa a ação** | `agents/09-security/security-coordinator.md` tria e prioriza; o especialista dono da área do achado (`especialista-owasp-top10`, `especialista-de-autenticacao-segura`, `especialista-de-autorizacao-e-least-privilege`, …) corrige; `agents/09-security/pentester.md` e os scanners de `pipelines/ci-security.md` alimentam achados novos |
| **Modelo sugerido** | Topo para triagem de severidade crítica/alta e desenho da correção; Padrão para aplicar uma mitigação já conhecida (`core/model-routing.md`) |

## Métrica de progresso

Número de achados de segurança em estado `aberto`, com contagem separada por severidade
(crítico/alto/médio/baixo) — a métrica que decide a saída é **crítico + alto**, não o total bruto.

## Condição de entrada

Existe ≥1 achado de segurança em estado `aberto` — de pentest, SAST/DAST, revisão de segurança
(`agents/12-reviewers/security-reviewer.md`) ou threat model.

## Ação (o corpo da iteração)

1. Triar por **severidade real**: score bruto (CVSS ou equivalente) cruzado com explorabilidade no
   sistema concreto (threat model) — um "crítico" num componente não exposto pode valer menos do que
   um "médio" no caminho de autenticação.
2. Resolver primeiro o de maior severidade real, nunca o mais fácil de corrigir.
3. Aplicar a correção com caminho de reversão (flag se o risco de regressão for alto —
   `modules/feature-flags.md`).
4. Validar: regressão verde + prova-live que confirma que a exploração deixou de funcionar.

## Condição de saída (sucesso)

Zero achados críticos/altos em estado `aberto`. Achados médios/baixos podem transitar para **risco
residual aceite** — mas só por decisão explícita do utilizador, registada em
`product/05-security/residual-risk.md`, nunca fechados por decreto do agente.

## Salvaguarda anti-loop-infinito

- **Estagnação:** 3 iterações sobre o mesmo achado sem o mover de estado → parar esse achado
  especificamente (os outros continuam).
- **Oscilação:** corrigir um achado reintroduz outro (ex.: apertar CSP quebra um fluxo que reabre um
  achado de autorização) → parar de imediato, é sinal de correção pontual em vez de estrutural.
- **Teto duro:** 4 tentativas por achado individual. Ultrapassado, o achado sobe a candidato a **risco
  residual** — nunca fica silenciado; o utilizador decide aceitar o risco, cortar a funcionalidade, ou
  redesenhar (subir a `agents/09-security/threat-modeler.md` se for estrutural).

## Registo em STATE.md

```
L03 · segurança · métrica 5→3→3 · iter 3 (teto 4) · último progresso: iter 2 · estado: EM RISCO
```

## Exemplo (app interna — portal de RH)

O `pentester` reporta um achado crítico: um colaborador consegue ver a ficha salarial de outro
alterando o `id` na URL (IDOR). O `coordenador-de-seguranca` classifica-o crítico e explorável (não
exige credenciais especiais). O `especialista-de-autorizacao-e-least-privilege` corrige: a rota passa
a filtrar sempre pela identidade do servidor, nunca pelo `id` do pedido, e devolve 404 (não 403) fora
do scope. Regressão verde; prova-live confirma que o `id` de outro colaborador já devolve 404. O
achado fecha como corrigido-e-validado, documentado com a causa (falta de scoping no servidor,
`knowledge/proven-patterns.md` §6).

## Relacionados

- `agents/09-security/security-coordinator.md` — dono da triagem e do risco residual.
- `agents/09-security/README.md` — o mapa de especialistas que corrigem cada tipo de achado.
- `agents/09-security/pentester.md` — principal produtor de achados em F7.
- `checklists/pre-production-security.md` — o portão que este loop tem de satisfazer.
- `core/quality-gates.md` — P7 não passa com crítico/alto aberto.
- `playbooks/adversarial-audit.md` — o escrutínio que alimenta achados adicionais.
