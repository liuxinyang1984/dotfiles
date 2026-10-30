#!/bin/sh
# keyd.sh — 由 install.sh source；安装 /etc/keyd/default.conf 并启用 keyd

KEYD_SRC="$SCRIPT_DIR/config/keyd/default.conf"
KEYD_DEST="/etc/keyd/default.conf"

run_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v doas >/dev/null 2>&1; then
        doas "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        error "写入 /etc/keyd 需要 root（doas 或 sudo）"
        exit 1
    fi
}

if [ ! -f "$KEYD_SRC" ]; then
    error "缺少配置: $KEYD_SRC"
    exit 1
fi

if ! command -v keyd >/dev/null 2>&1; then
    error "未找到 keyd，请先安装（Arch: pacman -S keyd）"
    exit 1
fi

if ! keyd check "$KEYD_SRC"; then
    error "keyd 配置校验失败: $KEYD_SRC"
    exit 1
fi

run_root mkdir -p /etc/keyd
run_root cp "$KEYD_SRC" "$KEYD_DEST"
info "已安装 $KEYD_DEST"

if command -v systemctl >/dev/null 2>&1; then
    run_root systemctl enable --now keyd
    run_root systemctl reload keyd 2>/dev/null || run_root systemctl restart keyd
    info "keyd 服务已启用"
else
    warn "无 systemctl，请自行启动 keyd 守护进程"
fi

info "keyd 完成"
