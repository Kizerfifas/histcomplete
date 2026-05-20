#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
SHARE_DIR="${HOME}/.local/share/histcomplete"

mkdir -p "$BIN_DIR" "$SHARE_DIR"
install -m 755 "$ROOT/histcomplete" "$BIN_DIR/histcomplete"
install -m 644 "$ROOT/bash-integration.sh" "$SHARE_DIR/bash-integration.sh"
[[ -f "$ROOT/README.md" ]] && install -m 644 "$ROOT/README.md" "$SHARE_DIR/README.md"

if ! grep -q 'histcomplete/bash-integration' "${HOME}/.bashrc" 2>/dev/null; then
    cat >> "${HOME}/.bashrc" <<'EOF'

# histcomplete — автодополнение из истории команд
[[ -f "${HOME}/.local/share/histcomplete/bash-integration.sh" ]] && \
  source "${HOME}/.local/share/histcomplete/bash-integration.sh"
EOF
    echo "Добавлен source в ~/.bashrc"
else
    echo "Интеграция уже есть в ~/.bashrc"
fi

echo "Готово: $BIN_DIR/histcomplete"
echo "         $SHARE_DIR/bash-integration.sh"
echo "Перезапустите терминал или: source ~/.bashrc"
echo ""
echo "Обновление в будущем: git pull && ./install.sh  (из каталога репозитория)"
