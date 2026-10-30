#!/bin/sh
# dunst.sh — 由 install.sh source；链接 dunstrc

DUNST_SRC="$SCRIPT_DIR/config/dunst/dunstrc"
DUNST_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/dunst/dunstrc"

if [ ! -f "$DUNST_SRC" ]; then
    error "缺少配置: $DUNST_SRC"
    exit 1
fi

if ! command -v dunst >/dev/null 2>&1; then
    warn "未找到 dunst，请先安装（Arch: pacman -S dunst libnotify）"
fi

mkdir -p "$(dirname "$DUNST_DEST")"
safe_link "$DUNST_SRC" "$DUNST_DEST" "dunst"
info "dunst 配置完成（dwm 会话里由 xinitrc 启动）"
