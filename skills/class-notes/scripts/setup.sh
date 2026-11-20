#!/usr/bin/env bash
# Check (and with --install, install) everything the skill needs. Safe to rerun.
# Usage: setup.sh [--install]
set -uo pipefail
INSTALL="${1:-}"
ok() { printf '  ✅ %s\n' "$1"; }
miss() { printf '  ❌ %s\n' "$1"; MISSING=1; }
MISSING=0

echo "Herramientas:"
for tool in yt-dlp ffmpeg; do
  if command -v "$tool" >/dev/null; then ok "$tool"
  elif [ "$INSTALL" = "--install" ] && command -v brew >/dev/null; then brew install "$tool" && ok "$tool (instalado)" || miss "$tool"
  else miss "$tool  →  brew install $tool"; fi
done

if [ "$(uname -s)-$(uname -m)" = "Darwin-arm64" ]; then PKG=mlx-whisper; MOD=mlx_whisper; else PKG=openai-whisper; MOD=whisper; fi
if python3 -c "import $MOD" 2>/dev/null; then ok "$PKG"
elif [ "$INSTALL" = "--install" ]; then python3 -m pip install --user "$PKG" && ok "$PKG (instalado)" || miss "$PKG"
else miss "$PKG  →  python3 -m pip install --user $PKG"; fi

echo "Configuración (~/.class-notes):"
C="$HOME/.class-notes"
if [ "$INSTALL" = "--install" ]; then mkdir -p "$C" && chmod 700 "$C"; fi
[ -s "$C/config.json" ] && ok "config.json" || miss "config.json (pedile a Claude que agregue un curso)"
[ -s "$C/cookies.txt" ] && ok "cookies.txt" || miss "cookies.txt (exportá las cookies de Vimeo, ver README)"

[ "$MISSING" = 0 ] && echo "LISTO" || echo "FALTAN COSAS"
