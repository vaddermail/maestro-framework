#!/usr/bin/env bash
# _meta/verify-project.sh — o portão do PROJETO ("portões, não sensações", aplicado à execução).
# O verificar.sh valida a framework; este valida se um projeto a está a SEGUIR: fundação no lugar,
# artefactos existentes para as fases que o STATE.md declara fechadas, memória fresca, génese em
# dia, cópia íntegra. Corre-se da raiz do projeto (ou de qualquer lado — reposiciona-se sozinho):
#   bash Maestro/_meta/verify-project.sh
# Sai com 1 se houver falhas. Avisos não bloqueiam, mas ficam à vista. Gancho natural: fim de cada
# sessão (START-HERE.md §2.5) e o CI do projeto (pipelines/ci-quality.md).
set -uo pipefail
cd "$(dirname "$0")/../.."

falhas=0; avisos=0
falha() { printf '✗ %s\n' "$*"; falhas=$((falhas + 1)); }
aviso() { printf '! %s\n' "$*"; avisos=$((avisos + 1)); }
ok() { printf '✓ %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 0. Isto é a raiz de um projeto Maestro?
# ---------------------------------------------------------------------------
if [ ! -f STATE.md ] || [ ! -d Maestro ]; then
  printf '✗ raiz de projeto não encontrada (esperava STATE.md e Maestro/ em %s)\n' "$(pwd)"
  printf '  Corre a partir do projeto: bash Maestro/_meta/verify-project.sh\n'
  exit 1
fi

# ---------------------------------------------------------------------------
# 1. Fundação de F0: os ficheiros que o W00 cria existem
# ---------------------------------------------------------------------------
fund_ko=0
for f in STATE.md FRAMEWORK-IMPROVEMENTS.md produto; do
  [ -e "$f" ] || { falha "FUNDAÇÃO EM FALTA: $f (workflows/W00-project-kickoff.md)"; fund_ko=1; }
done
[ -f CLAUDE.md ] || aviso "sem CLAUDE.md na raiz (ou equivalente da ferramenta — adapters/)"
[ "$fund_ko" -eq 0 ] && ok "fundação de F0 no lugar"

# ---------------------------------------------------------------------------
# 2. O STATE.md declara o essencial: fase, versão da framework, repositório-mãe
# ---------------------------------------------------------------------------
fase=$(grep -iE 'fase atual|current phase' STATE.md | grep -oE 'F[0-9]' | head -1 || true)
if [ -z "$fase" ]; then
  falha "STATE.md não declara a fase atual|current phase (F0–F9)"
  fase=F0
else
  ok "fase declarada: $fase"
fi
grep -qiE 'versão da framework' STATE.md && ok "versão da framework registada" \
  || falha "STATE.md sem a versão da framework copiada (pré-condição da sincronização)"
grep -qiE 'repositório da framework-mãe|framework-mãe|upstream framework repository' STATE.md \
  && ok "repositório-mãe registado" \
  || aviso "STATE.md sem o repositório-mãe (o destino dos reportes de melhorias)"

# ---------------------------------------------------------------------------
# 3. Artefactos por fase fechada: se a fase atual|current phase é FN, as anteriores deixaram rasto
#    (perfil protótipo colapsa pastas num dossier único — aceita-se qualquer conteúdo)
# ---------------------------------------------------------------------------
tem_conteudo() { [ -d "$1" ] && [ -n "$(find "$1" -type f -name '*.md' 2>/dev/null | head -1)" ]; }
n=${fase#F}
art_ko=0
verifica_fase() { # $1=nº mínimo da fase atual|current phase  $2=pasta  $3=descrição
  [ "$n" -ge "$1" ] || return 0
  tem_conteudo "$2" || { falha "SEM RASTO de $3 ($2/) com fase atual|current phase $fase"; art_ko=1; }
}
verifica_fase 2 product/00-descoberta "F1 Descoberta"
verifica_fase 3 product/01-requisitos "F2 Requisitos"
verifica_fase 4 product/02-arquitetura "F3 Arquitetura"
verifica_fase 5 product/03-experiencia "F4 Experiência"
verifica_fase 6 product/04-especificacao "F5 Especificação"
verifica_fase 8 product/05-seguranca "F7 Qualidade & Segurança"
[ "$n" -ge 4 ] && { tem_conteudo product/02-architecture/decisoes \
  || aviso "sem ADRs em product/02-architecture/decisions/ com arquitetura fechada"; }
[ "$art_ko" -eq 0 ] && ok "artefactos das fases fechadas deixaram rasto"

# ---------------------------------------------------------------------------
# 4. Memória fresca: a última atualização do STATE.md não está fossilizada
# ---------------------------------------------------------------------------
ult=$(grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' STATE.md | sort -r | head -1 || true)
if [ -n "$ult" ] && command -v date >/dev/null; then
  dias=$(( ( $(date +%s) - $(date -d "$ult" +%s 2>/dev/null || echo 0) ) / 86400 ))
  if [ "$dias" -gt 45 ]; then
    aviso "STATE.md sem datas há $dias dias (última: $ult) — memória a fossilizar?"
  else
    ok "memória viva (data mais recente no ESTADO: $ult)"
  fi
fi

# ---------------------------------------------------------------------------
# 5. Circuito de melhorias: envios acompanham os fechos de fase pesada
# ---------------------------------------------------------------------------
if [ -f FRAMEWORK-IMPROVEMENTS.md ]; then
  if [ "$n" -ge 8 ] && ! grep -qE '#[0-9]+' FRAMEWORK-IMPROVEMENTS.md; then
    aviso "fase $fase sem nenhum envio no §Registo de envios (a checklist manda enviar no fecho de F7/P6b)"
  else
    ok "circuito de melhorias coerente com a fase"
  fi
fi

# ---------------------------------------------------------------------------
# 6. Dossier de génese: uma linha por fase fechada (a medição da promessa)
# ---------------------------------------------------------------------------
if [ -f product/99-records/genesis.md ]; then
  linhas=$(grep -cE '^\| F[0-9] ' product/99-records/genesis.md || true)
  if [ "$n" -ge 2 ] && [ "${linhas:-0}" -eq 0 ]; then
    aviso "genese.md sem linhas de fase fechada (templates/project/GENESIS.md.template)"
  else
    ok "dossier de génese acompanha as fases ($linhas linha(s))"
  fi
else
  [ "$n" -ge 1 ] && aviso "sem product/99-records/genesis.md — a curva do ecossistema fica cega a este projeto"
fi

# ---------------------------------------------------------------------------
# 7. Integridade da cópia da framework (quando veio de uma release com manifesto)
# ---------------------------------------------------------------------------
if [ -f Maestro/_meta/SHA256SUMS ]; then
  if bash Maestro/_meta/verify.sh --integridade >/dev/null 2>&1; then
    ok "cópia da framework íntegra (idêntica à release de origem)"
  else
    falha "cópia da framework DIVERGE da release (bash Maestro/_meta/verify.sh --integridade)"
  fi
else
  aviso "cópia sem manifesto de integridade (anterior à 2.5.0, ou clone da mãe)"
fi

# ---------------------------------------------------------------------------
printf '\n'
if [ "$falhas" -gt 0 ]; then
  printf '✗ Projeto FORA do processo: %d falha(s), %d aviso(s).\n' "$falhas" "$avisos"
  exit 1
fi
printf '✓ Projeto a seguir o processo (%d aviso(s)).\n' "$avisos"
