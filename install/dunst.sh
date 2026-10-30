#!/bin/sh
# dunst.sh — 由 install.sh source
# 链接 dunst（dwm/X11）与本机 mako（Hyprland/Wayland）通知配置

DUNST_SRC="$SCRIPT_DIR/config/dunst/dunstrc"
DUNST_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/dunst/dunstrc"
MAKO_SRC="$SCRIPT_DIR/config/mako/config"
MAKO_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/mako/config"

if [ ! -f "$DUNST_SRC" ]; then
    error "缺少配置: $DUNST_SRC"
    exit 1
fi

if ! command -v dunst >/dev/null 2>&1; then
    warn "未找到 dunst（Arch: pacman -S dunst libnotify）；dwm 会话需要它"
fi

mkdir -p "$(dirname "$DUNST_DEST")"
safe_link "$DUNST_SRC" "$DUNST_DEST" "dunst"

if [ -f "$MAKO_SRC" ]; then
    mkdir -p "$(dirname "$MAKO_DEST")"
    safe_link "$MAKO_SRC" "$MAKO_DEST" "mako"
    if ! command -v mako >/dev/null 2>&1; then
        warn "未找到 mako（Wayland 通知；Arch: pacman -S mako）"
    fi
fi

info "通知配置完成（dunst → dwm；mako → Hyprland）"
