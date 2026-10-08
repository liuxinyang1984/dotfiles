#!/bin/sh
# desktop.sh — 由 install.sh source；必须带 INSTALL_SUB
# suckless：默认 sudo/doas make install（/usr/local）；个人装: SUCKLESS_USER=1

install_suckless() {
    ensure_submodule vendor/suckless
    dest="$SCRIPT_DIR/vendor/suckless"
    inst="$dest/install.sh"
    if [ ! -f "$inst" ]; then
        error "vendor/suckless 缺少 install.sh"
        exit 1
    fi
    info "调用 vendor/suckless/install.sh"
    set --
    [ "${SUCKLESS_USER:-}" = "1" ] && set -- "$@" --user
    [ "${INSTALL_POLKIT:-}" = "1" ] && set -- "$@" --polkit
    # 例: SUCKLESS_COMPONENTS="dwm st" ./install.sh desktop:suckless
    # shellcheck disable=SC2086
    [ -n "${SUCKLESS_COMPONENTS:-}" ] && set -- "$@" $SUCKLESS_COMPONENTS
    sh "$inst" "$@"

    # fontconfig 仍属本仓，不在 suckless 子仓里
    # shellcheck source=install/fontconfig.sh
    . "$SCRIPT_DIR/install/fontconfig.sh"
    info "suckless 完成。dwm 需在 X 会话启动"
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

    # shellcheck source=install/fontconfig.sh
    . "$SCRIPT_DIR/install/fontconfig.sh"
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
