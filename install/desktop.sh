#!/bin/sh
# desktop.sh — 由 install.sh source；必须带 INSTALL_SUB

install_suckless() {
    ensure_submodule vendor/suckless

    SUCKLESS_DIR="$SCRIPT_DIR/vendor/suckless"
    PREFIX="${SUCKLESS_PREFIX:-$HOME/.local}"

    for c in dwm st dmenu; do
        src="$SUCKLESS_DIR/$c"
        if [ ! -d "$src" ]; then
            error "缺少 $src（suckless 嵌套 submodule 未检出）"
            exit 1
        fi
        info "编译安装 $c → $PREFIX"
        (
            cd "$src"
            rm -f config.h
            make PREFIX="$PREFIX" install
            make clean
            rm -f config.h
        )
    done

    if [ "${INSTALL_POLKIT:-}" = "1" ]; then
        info "编译安装 mini-polkit（需要 sudo）"
        (
            cd "$SUCKLESS_DIR/mini-polkit"
            make
            sudo make install
        )
    else
        info "跳过 mini-polkit（仅 dwm/X 会话需要）。安装: INSTALL_POLKIT=1 $0 desktop:suckless"
    fi

    link_fontconfig
    info "suckless 完成。dwm 需在 X 会话启动；PATH 需包含 $PREFIX/bin"
}

install_hyprland() {
    ensure_submodule vendor/hyprland

    HYPR_DIR="$SCRIPT_DIR/vendor/hyprland"
    for comp in hypr foot wofi; do
        if [ -d "$HYPR_DIR/$comp" ]; then
            safe_link "$HYPR_DIR/$comp" "$XDG_CONFIG_HOME/$comp" "$comp"
        else
            warn "hyprland 仓中没有 $comp/，跳过"
        fi
    done

    link_fontconfig
    info "hyprland 配置链接完成"
}

case "$INSTALL_SUB" in
    suckless)
        install_suckless
        ;;
    hyprland)
        install_hyprland
        ;;
    *)
        error "未知桌面子模块: ${INSTALL_SUB:-（空）}（用 desktop:suckless 或 desktop:hyprland）"
        exit 1
        ;;
esac
