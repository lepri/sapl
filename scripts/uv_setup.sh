#!/usr/bin/env bash
# Prepara o ambiente local de desenvolvimento com uv (macOS/Linux).
#
# Dependências nativas no macOS:
#   brew install glib pango libmagic libpq freetype
set -euo pipefail

cd "$(dirname "$0")/.."

# reportlab 3.6.13 não tem wheel para Python 3.12 e, no macOS arm64, o build
# baixa m1stuff.tar.gz via urllib, que o servidor da ReportLab bloqueia (403).
# Baixamos com curl para o cache que o setup.py do reportlab consulta.
export RL_CACHE_DIR="${RL_CACHE_DIR:-$HOME/.cache/reportlab}"
if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" && ! -f "$RL_CACHE_DIR/m1stuff/.done" ]]; then
    mkdir -p "$RL_CACHE_DIR/m1stuff"
    curl -fsSL https://www.reportlab.com/ftp/m1stuff.tar.gz | tar xz -C "$RL_CACHE_DIR/m1stuff"
    date -u +%Y%m%dU%H%M%S > "$RL_CACHE_DIR/m1stuff/.done"
fi

uv sync "$@"

if [[ "$(uname -s)" == "Darwin" ]]; then
    cat <<'MSG'

WeasyPrint e python-magic carregam libs do Homebrew em tempo de execução.
Adicione ao seu ~/.zshrc:

    export DYLD_FALLBACK_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_FALLBACK_LIBRARY_PATH"
MSG
fi
