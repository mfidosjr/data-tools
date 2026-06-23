#!/bin/bash
# SCP OCR Preprocessor
# Converte PDFs escaneados (provas manuscritas) em arquivos TXT via Tesseract
#
# Dependências: poppler (pdftoppm), tesseract, tesseract-lang-por
#   brew install poppler tesseract tesseract-lang
#
# Uso:
#   ./scp_ocr.sh <pasta>          # processa todos os PDFs da pasta
#   ./scp_ocr.sh <pasta> --force  # reprocessa mesmo que TXT já exista
#
# Exemplo:
#   ./scp_ocr.sh "/Users/marcofidos/Downloads/agente de correcao de provas/AB1 G3"

set -e

PASTA="$1"
FORCE="${2:-}"

check_deps() {
  command -v pdftoppm >/dev/null || { echo "ERRO: instale poppler — brew install poppler"; exit 1; }
  command -v tesseract >/dev/null || { echo "ERRO: instale tesseract — brew install tesseract tesseract-lang"; exit 1; }
  tesseract --list-langs 2>/dev/null | grep -q "por" || { echo "ERRO: pacote de idioma português não instalado — brew install tesseract-lang"; exit 1; }
}

ocr_pdf() {
  local pdf_path="$1"
  local out_txt="${pdf_path%.pdf}.txt"
  local base_name
  base_name="$(basename "$pdf_path" .pdf)"
  local work_dir
  work_dir="$(mktemp -d)"

  echo "  OCR: $base_name"

  pdftoppm -r 200 -jpeg "$pdf_path" "$work_dir/pg" 2>/dev/null

  : > "$out_txt"
  local page_count=0
  for img in "$work_dir"/pg-*.jpg; do
    [ -f "$img" ] || continue
    tesseract "$img" - -l por+eng 2>/dev/null >> "$out_txt"
    printf "\n" >> "$out_txt"
    ((page_count++)) || true
  done

  rm -rf "$work_dir"

  local lines
  lines=$(wc -l < "$out_txt" | tr -d ' ')
  echo "    -> $lines linhas extraídas ($page_count páginas)"
}

# Validações
if [ -z "$PASTA" ]; then
  echo "Uso: $0 <pasta> [--force]"
  exit 1
fi

if [ ! -d "$PASTA" ]; then
  echo "ERRO: pasta não encontrada: $PASTA"
  exit 1
fi

check_deps

echo "=== SCP OCR Preprocessor ==="
echo "Pasta: $PASTA"
echo ""

total=0
skipped=0
erros=0

for pdf in "$PASTA"/*.pdf; do
  [ -f "$pdf" ] || continue
  txt="${pdf%.pdf}.txt"

  if [ -f "$txt" ] && [ -s "$txt" ] && [ "$FORCE" != "--force" ]; then
    echo "  SKIP: $(basename "$pdf")"
    ((skipped++)) || true
    continue
  fi

  if ocr_pdf "$pdf"; then
    ((total++)) || true
  else
    echo "  ERRO ao processar: $(basename "$pdf")"
    ((erros++)) || true
  fi
done

echo ""
echo "Concluído: $total processados, $skipped ignorados, $erros erros."
[ "$total" -gt 0 ] && echo "Execute o workflow no n8n para iniciar as correções."
