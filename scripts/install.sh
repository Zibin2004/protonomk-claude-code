#!/usr/bin/env bash
# Установка Protonomk Claude Code в ~/.claude/
# Не перезаписывает существующие файлы. Хуки и goal ставятся отдельно.
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

# ── goal: CLI + хук ──────────────────────────────────────────────────
echo
echo "→ Установка /goal"
mkdir -p "$TARGET/scripts"
cp -a "$SRC/scripts/goal" "$TARGET/scripts/goal"
chmod +x "$TARGET/scripts/goal"
printf '  %-10s %s\n' "goal" "$TARGET/scripts/goal"

# Симлинк в PATH, чтобы работала короткая команда
BIN_DIR="${PREFIX:-/usr/local}/bin"
if [ -w "$(dirname "$BIN_DIR")" ] || [ -w "$BIN_DIR" ]; then
  mkdir -p "$BIN_DIR" 2>/dev/null || true
  ln -sf "$TARGET/scripts/goal" "$BIN_DIR/goal" 2>/dev/null && \
    printf '  %-10s %s\n' "симлинк" "$BIN_DIR/goal" || \
    printf '  %-10s пропущен (нет прав на %s)\n' "симлинк" "$BIN_DIR"
fi

# ── Хуки: дописать в settings.json, не затирая чужие ─────────────────
SETTINGS="$TARGET/settings.json"
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

node - "$SETTINGS" "$TARGET" <<'NODEEOF'
const [settingsPath, target] = process.argv.slice(2);
const fs = require("node:fs");

let settings;
try {
  settings = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
} catch {
  console.error("  ⚠ settings.json не разобран, хуки пропущены");
  process.exit(0);
}

settings.hooks ??= {};

const goalContext = {
  hooks: [
    {
      type: "command",
      command: `node "${target}/scripts/goal" --hook-context 2>/dev/null || true`,
      timeout: 5,
    },
  ],
  description: "Подмешать активную цель в контекст",
};
const goalStop = {
  hooks: [
    {
      type: "command",
      command: `node "${target}/scripts/goal" --hook-stop 2>&1 || true`,
      timeout: 5,
    },
  ],
  description: "Напомнить, что цель не закрыта",
};

const hasGoal = (arr) =>
  Array.isArray(arr) &&
  arr.some((h) => JSON.stringify(h).includes("scripts/goal"));

let added = 0;
if (!hasGoal(settings.hooks.UserPromptSubmit)) {
  (settings.hooks.UserPromptSubmit ??= []).push(goalContext);
  added++;
}
if (!hasGoal(settings.hooks.Stop)) {
  (settings.hooks.Stop ??= []).push(goalStop);
  added++;
}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + "\n");
console.log(`  ${"хуки".padEnd(10)} +${added} новых`);
NODEEOF

echo
echo "✓ Готово."
echo
echo "  Проверить цель:   goal"
echo "  Поставить цель:   goal <что получить и как проверить>"
echo "  Закрыть:          goal done"
echo
echo "  Команда /goal в Claude Code — из commands/goal.md."
echo "  Состояние живёт в $TARGET/goal.json."
echo
echo "  Перезапустите Claude Code, чтобы подхватились команды и хуки."
