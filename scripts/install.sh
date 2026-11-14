#!/usr/bin/env bash
set -euo pipefail
TARGET="${CLAUDE_DIR:-$HOME/.claude}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "→ Установка в $TARGET"
mkdir -p "$TARGET"
install_dir() {
  local name="$1"
  local from="$SRC/$name"
  local to="$TARGET/$name"
  [ -d "$from" ] || return 0
  mkdir -p "$to"
  local n=0 skipped=0
  for f in "$from"/*; do
    [ -e "$f" ] || continue
    local base
    base="$(basename "$f")"
    if [ -e "$to/$base" ]; then
      skipped=$((skipped + 1))
      continue
    fi
    cp -a "$f" "$to/$base"
    n=$((n + 1))
  done
  printf '  %-10s +%d новых, %d уже было\n' "$name" "$n" "$skipped"
}
install_dir commands
install_dir agents
install_dir skills
install_dir rules
echo
echo "✓ Готово. Проверить: ls $TARGET/commands"
