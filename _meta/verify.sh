#!/usr/bin/env bash
# _meta/verify.sh — o portão da própria framework ("portões, não sensações", MANIFESTO.md §7).
# Verifica a consistência interna da Maestro. Correr da raiz da framework ou de qualquer lado
# (o script reposiciona-se sozinho). Sai com código 1 se houver falhas — serve de gate em CI ou no
# playbooks/add-an-agent.md.
set -uo pipefail
cd "$(dirname "$0")/.."

# Modo --integridade: compara a cópia local com o manifesto da release
# (_meta/SHA256SUMS, gerado pelo release.yml da mãe). Deteta deriva silenciosa
# da regra "a cópia é read-only" em qualquer sessão, sem esperar pela sincronização.
if [ "${1:-}" = "--integridade" ]; then
  if [ ! -f _meta/SHA256SUMS ]; then
    printf '✗ sem manifesto _meta/SHA256SUMS (clone da mãe, ou cópia de release anterior à 2.5.0)\n'
    exit 1
  fi
  if sha256sum -c --quiet _meta/SHA256SUMS 2>/dev/null; then
    printf '✓ integridade: a cópia é idêntica à release de origem.\n'
    exit 0
  else
    printf '✗ integridade: a cópia DIVERGE da release de origem — cada diferença é uma edição local\n'
    printf '  a reconciliar (playbooks/sync-framework.md passo 2) e, quase sempre, uma entrada\n'
    printf '  para o FRAMEWORK-IMPROVEMENTS.md do projeto.\n'
    sha256sum -c _meta/SHA256SUMS 2>/dev/null | grep -v ': OK$' | head -20
    exit 1
  fi
fi

falhas=0
falha() { printf '✗ %s\n' "$*"; falhas=$((falhas + 1)); }
ok() { printf '✓ %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. Inventário → disco: todo o caminho listado em _meta/INVENTORY.md existe
# ---------------------------------------------------------------------------
em_falta=0
while IFS= read -r p; do
  [ -e "$p" ] || { falha "FALTA NO DISCO (está no inventário): $p"; em_falta=1; }
done < <(grep -oE '^- `[^`]+`' _meta/INVENTORY.md | sed 's/^- `//;s/`$//')
[ "$em_falta" -eq 0 ] && ok "inventário → disco: todos os caminhos existem"

# ---------------------------------------------------------------------------
# 2. Disco → inventário: todo o ficheiro de conteúdo está listado no inventário
# ---------------------------------------------------------------------------
fora=0
while IFS= read -r f; do
  grep -qF "\`$f\`" _meta/INVENTORY.md || { falha "FORA DO INVENTÁRIO: $f"; fora=1; }
done < <(find . -type f \( -name '*.md' -o -name '*.template' \) ! -path './.git/*' ! -path './.github/*' | sed 's|^\./||')
[ "$fora" -eq 0 ] && ok "disco → inventário: nenhum ficheiro por registar"

# ---------------------------------------------------------------------------
# 3. Referências cruzadas: todo o caminho da framework citado em crase existe
#    (ignora placeholders documentados: NN-categoria, Wnn/Lnn, {{...}}, etc.)
# ---------------------------------------------------------------------------
quebradas=0
while IFS= read -r p; do
  case "$p" in
    *NN-* | *nome-do-agente* | *Wnn* | *Lnn* | *dimensao* | *AAAA* | *SHA256SUMS* | *'{{'*) continue ;;
  esac
  [ -e "$p" ] || { falha "REFERÊNCIA QUEBRADA: $p"; quebradas=1; }
done < <(grep -rhoE '`(core|agents|workflows|loops|modules|templates|checklists|playbooks|pipelines|knowledge|adapters|starters|_meta)/[A-Za-z0-9._{}/-]+`' \
  --include='*.md' --include='*.template' . | sed 's/`//g' | sort -u)
[ "$quebradas" -eq 0 ] && ok "referências cruzadas: todas resolvem"

# ---------------------------------------------------------------------------
# 4. Fichas de agente: todas as secções do TEMPLATE-AGENTE presentes
#    (exclui READMEs e o próprio template)
# ---------------------------------------------------------------------------
seccoes_pt=(
  '## Identificação' '## Objetivo' '## Quando inicia' '## Quando termina'
  '## Inputs' '## Outputs' '## Perguntas ao utilizador' '## Regras'
  '## Limitações' '## Workflow' '## Exemplos' '## Boas práticas'
  '## Anti-padrões' '## Interações' '## Critérios de pronto'
)
seccoes_en=(
  '## Identification' '## Objective' '## When it starts' '## When it ends'
  '## Inputs' '## Outputs' '## Questions to the user' '## Rules'
  '## Limitations' '## Workflow' '## Examples' '## Best practices'
  '## Anti-patterns' '## Interactions' '## Done criteria'
)
# transição PT→EN: uma ficha passa se TODAS as secções de UM dos conjuntos existirem (e por ordem)
conjunto_da_ficha() { # devolve pt|en|nenhum
  if grep -qF '## Identification' "$1"; then echo en; elif grep -qF '## Identificação' "$1"; then echo pt; else echo nenhum; fi
}
fichas_ko=0
while IFS= read -r f; do
  cj=$(conjunto_da_ficha "$f")
  [ "$cj" = nenhum ] && { falha "FICHA SEM SECÇÕES RECONHECÍVEIS: $f"; fichas_ko=1; continue; }
  if [ "$cj" = en ]; then lista=("${seccoes_en[@]}"); else lista=("${seccoes_pt[@]}"); fi
  for s in "${lista[@]}"; do
    grep -qF "$s" "$f" || { falha "FICHA SEM SECÇÃO '$s': $f"; fichas_ko=1; }
  done
done < <(find agents -mindepth 2 -type f -name '*.md' ! -name 'README.md' ! -name 'AGENT-TEMPLATE.md')
[ "$fichas_ko" -eq 0 ] && ok "fichas de agente: todas as secções do template presentes"

# ---------------------------------------------------------------------------
# 5. Língua: PT-PT (deteção dos brasileirismos mais comuns)
#    (o GUIA-DE-ESTILO está isento: menciona os termos proibidos como exemplo)
# ---------------------------------------------------------------------------
if grep -rliE 'usuário|deletar|gerenciar|gerenciamento|banco de dados|\barquivos\b|\bregistros?\b|\bcontatos?\b|cadastr|\bacessar\b|planejam|algalgures' \
  --include='*.md' --include='*.template' --exclude='STYLE-GUIDE.md' . ; then
  falha "PT-BR detetado nos ficheiros acima (usar utilizador/apagar/gerir/base de dados)"
else
  ok "língua: sem brasileirismos detetados"
fi

# ---------------------------------------------------------------------------
# 6. Grafo de artefactos: caminhos product/… só dentro da árvore canónica
#    (core/artifact-protocol.md) e sem aliases não-canónicos.
#    (_meta/VERSION.md isento: o changelog descreve os nomes antigos como história.)
# ---------------------------------------------------------------------------
grafo_ko=0
while IFS= read -r p; do
  case "$p" in
    product | product/ | product/00-discovery* | product/01-requirements* | product/02-architecture* | \
    product/03-experience* | product/04-specification* | product/05-security* | product/06-tests* | \
    product/07-operations* | product/08-documentation* | product/99-records*) ;;
    *) falha "PASTA FORA DA ÁRVORE CANÓNICA (core/artifact-protocol.md): $p"; grafo_ko=1 ;;
  esac
done < <(grep -rhoE '`product/[A-Za-z0-9._/-]*' --include='*.md' --include='*.template' --exclude='VERSION.md' . | sed 's/^`//' | sort -u)
if grep -rnE 'product/01-requirements/(requirements\.md|non-functional-requirements\.md)|product/00-discovery/priorities\.md|product/02-architecture/adr' \
  --include='*.md' --include='*.template' --exclude='VERSION.md' . ; then
  falha "ALIAS NÃO-CANÓNICO de artefacto (canonical names: functional-requirements.md, nfr.md, prioritization.md, decisions/)"
  grafo_ko=1
fi
[ "$grafo_ko" -eq 0 ] && ok "grafo de artefactos: todos os caminhos product/ na árvore canónica"

# ---------------------------------------------------------------------------
# 7. Fichas de agente: as 15 secções pela ORDEM do template (o check 4 só via presença)
# ---------------------------------------------------------------------------
ordem_ko=0
while IFS= read -r f; do
  cj=$(conjunto_da_ficha "$f")
  if [ "$cj" = en ]; then lista=("${seccoes_en[@]}"); else lista=("${seccoes_pt[@]}"); fi
  prev=0
  for s in "${lista[@]}"; do
    ln=$(grep -nF "$s" "$f" | head -1 | cut -d: -f1)
    if [ -n "$ln" ]; then
      if [ "$ln" -lt "$prev" ]; then falha "SECÇÕES FORA DE ORDEM: $f ('$s')"; ordem_ko=1; break; fi
      prev=$ln
    fi
  done
done < <(find agents -mindepth 2 -type f -name '*.md' ! -name 'README.md' ! -name 'AGENT-TEMPLATE.md')
[ "$ordem_ko" -eq 0 ] && ok "fichas de agente: secções pela ordem do template"

# ---------------------------------------------------------------------------
# 8. Âncoras §: toda a referência `ficheiro` §Secção aponta a um título existente
#    (tolerante a prosa colada: encurta a âncora palavra a palavra antes de acusar)
# ---------------------------------------------------------------------------
anc_ko=0
while IFS='|' read -r alvo sec; do
  [ -e "$alvo" ] || continue
  case "$sec" in [0-9]* | regra* | Regra*) continue ;; esac   # §N/§regra N referem itens numerados de listas, não títulos
  s="$sec"; achou=0
  while [ -n "$s" ]; do
    if grep -E '^#{1,6} ' "$alvo" | grep -qiF "$s"; then achou=1; break; fi
    novo="${s% *}"; [ "$novo" = "$s" ] && break; s="$novo"
  done
  # IDs de item (A1, C4, RF-12, …) não são títulos: basta existirem como token no alvo
  if [ "$achou" -eq 0 ]; then
    prim=${sec%% *}
    prim1=$(printf '%s' "$prim" | grep -oE '^[A-Za-z]{1,3}-?[0-9]+' || true)
    if printf '%s' "$prim" | grep -qE '^[A-Za-z]{1,3}-?[0-9]+([–-][A-Za-z]{0,3}-?[0-9]+)?$' && [ -n "$prim1" ] && grep -qE "(^|[^A-Za-z0-9])${prim1}([^A-Za-z0-9]|$)" "$alvo"; then
      achou=1
    fi
  fi
  [ "$achou" -eq 1 ] || { falha "ÂNCORA ÓRFÃ: \`$alvo\` §$sec"; anc_ko=1; }
done < <(grep -rhoE '`(core|agents|workflows|loops|modules|templates|checklists|playbooks|pipelines|knowledge|adapters|starters|_meta)/[A-Za-z0-9._/-]+` §[A-Za-z0-9][^`,;:)]*' \
  --include='*.md' --include='*.template' . | sed 's/^`//; s/` §/|/; s/\. .*$//; s: · .*$::; s/[ .]*$//' | sort -u)
[ "$anc_ko" -eq 0 ] && ok "âncoras §: todas apontam a títulos existentes"

# ---------------------------------------------------------------------------
# 9. Referências aos ficheiros de raiz (MANIFESTO, COMECAR-AQUI, README) resolvem
# ---------------------------------------------------------------------------
raiz_ko=0
while IFS= read -r p; do
  [ -e "$p" ] || { falha "REFERÊNCIA QUEBRADA (raiz): $p"; raiz_ko=1; }
done < <(grep -rhoE '`(MANIFESTO\.md|COMECAR-AQUI\.md|README\.md)`' --include='*.md' --include='*.template' . | sed 's/`//g' | sort -u)
[ "$raiz_ko" -eq 0 ] && ok "referências de raiz: resolvem"

# ---------------------------------------------------------------------------
# 10. Índices de categoria: toda a ficha está citada no README da sua categoria
# ---------------------------------------------------------------------------
idx_ko=0
while IFS= read -r f; do
  cat=$(dirname "$f")
  [ -f "$cat/README.md" ] || continue
  grep -qF "$(basename "$f")" "$cat/README.md" || { falha "FICHA FORA DO ÍNDICE DA CATEGORIA: $f"; idx_ko=1; }
done < <(find agents -mindepth 2 -type f -name '*.md' ! -name 'README.md' ! -name 'AGENT-TEMPLATE.md')
[ "$idx_ko" -eq 0 ] && ok "índices de categoria: todas as fichas indexadas"

# ---------------------------------------------------------------------------
# 11. Formato canónico de referências: sem links markdown internos, sem caminhos
#     de categoria sem o prefixo de pasta de topo (GUIA-DE-ESTILO §7)
# ---------------------------------------------------------------------------
if grep -rnE '\]\([A-Za-z0-9_./-]+\)' --include='*.md' --include='*.template' --exclude='README.md' --exclude='CONTRIBUTING.md' . | grep -v '](http' | grep -v '](#' ; then
  falha "LINK MARKDOWN interno (a convenção é caminho entre crases)"
else
  ok "sem links markdown internos"
fi
if grep -rnE '`[0-9]{2}-[a-z][a-z-]*/[A-Za-z0-9._-]+`' --include='*.md' --include='*.template' . ; then
  falha "CAMINHO SEM PREFIXO de pasta de topo (ex.: usar agents/NN-categoria/…)"
else
  ok "caminhos sempre com prefixo de topo"
fi

# ---------------------------------------------------------------------------
# 12. Playbooks: esqueleto obrigatório (playbooks/README.md)
# ---------------------------------------------------------------------------
pb_ko=0
while IFS= read -r f; do
  for s in '## Pré-condições' '## Passos' '## Reversão' '## Relacionados'; do
    grep -qF "$s" "$f" || { falha "PLAYBOOK SEM SECÇÃO '$s': $f"; pb_ko=1; }
  done
done < <(find playbooks -type f -name '*.md' ! -name 'README.md')
[ "$pb_ko" -eq 0 ] && ok "playbooks: esqueleto obrigatório presente"

# ---------------------------------------------------------------------------
# 13. Contagens da prosa viva = disco (o histórico do changelog não se toca)
# ---------------------------------------------------------------------------
decl=$(grep -oE '[0-9]+ (especialistas|specialists)' README.md | grep -oE '[0-9]+' | head -1)
real=$(find agents -mindepth 2 -type f -name '*.md' ! -name 'README.md' ! -name 'AGENT-TEMPLATE.md' | wc -l)
if [ -n "$decl" ] && [ "$decl" != "$real" ]; then
  falha "CONTAGEM DESSINCRONIZADA: README.md declara $decl especialistas, o disco tem $real"
else
  ok "contagens: README ($decl) = disco ($real)"
fi

# ---------------------------------------------------------------------------
printf '\n'
if [ "$falhas" -gt 0 ]; then
  printf '✗ Verificação FALHOU: %d problema(s).\n' "$falhas"
  exit 1
fi
printf '✓ Framework consistente.\n'
