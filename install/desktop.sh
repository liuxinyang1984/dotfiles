#!/bin/sh
# desktop.sh — 由 install.sh source；必须带 INSTALL_SUB
# suckless：默认 sudo/doas make install（/usr/local）；个人装: SUCKLESS_USER=1
# 装完 kiosk/suckless 后可选落地多启动（见 install/x11.sh）

install_suckless() {
    ensure_submodule vendor/suckless
    dest="$SCRIPT_DIR/vendor/suckless"
    inst="$dest/install.sh"
    if [ ! -f "$inst" ]; then
        error "vendor/suckless 缺少 install.sh"
        exit 1
    fi
    info "调用 vendor/suckless/install.sh${INSTALL_ARGS:+ ← $INSTALL_ARGS}"
    set --
    [ "${SUCKLESS_USER:-}" = "1" ] && set -- "$@" --user
    [ "${INSTALL_POLKIT:-}" = "1" ] && set -- "$@" --polkit
    # CLI：./install.sh desktop:suckless dwm st
    # 兼容：SUCKLESS_COMPONENTS="dwm st" ./install.sh desktop:suckless
    # shellcheck disable=SC2086
    if [ -n "${INSTALL_ARGS:-}" ]; then
        set -- "$@" $INSTALL_ARGS
    elif [ -n "${SUCKLESS_COMPONENTS:-}" ]; then
        set -- "$@" $SUCKLESS_COMPONENTS
    fi
    sh "$inst" "$@"

    # fontconfig 仍属本仓，不在 suckless 子仓里
    # shellcheck source=install/fontconfig.sh
    . "$SCRIPT_DIR/install/fontconfig.sh"

    # 显式点了组件名且不含 dwm → 跳过 dwm-session；仅 --user 等选项仍装
    _want_dwm=1
    _has_comp=0
    for _t in ${INSTALL_ARGS:-} ${SUCKLESS_COMPONENTS:-}; do
        case "$_t" in
            dwm|st|dmenu|dwmblocks|tabbed|surf|mini-polkit) _has_comp=1 ;;
        esac
    done
    if [ "$_has_comp" = 1 ]; then
        _want_dwm=0
        case " ${INSTALL_ARGS:-} ${SUCKLESS_COMPONENTS:-} " in
            *" dwm "*) _want_dwm=1 ;;
        esac
    fi

    if [ "$_want_dwm" = 1 ]; then
        _dwm_sess="$SCRIPT_DIR/config/x11/dwm/install.sh"
        if [ -f "$_dwm_sess" ]; then
            info "安装 dwm-session"
            set --
            [ "${DWM_SESSION_COPY:-}" = "1" ] && set -- "$@" --copy
            sh "$_dwm_sess" "$@"
        else
            warn "缺少 config/x11/dwm/install.sh"
        fi
    fi
    info "suckless 完成"

    if [ "$_want_dwm" = 1 ]; then
        _X11_LIB_ONLY=1
        # shellcheck source=install/x11.sh
        . "$SCRIPT_DIR/install/x11.sh"
        x11_offer_multistart_for_desktop dwm
        unset _X11_LIB_ONLY
    fi
    unset _want_dwm _has_comp _t
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

install_kiosk() {
    dest="$SCRIPT_DIR/config/x11/kiosk"
    inst="$dest/install.sh"
    if [ ! -f "$inst" ]; then
        error "缺少 config/x11/kiosk/install.sh"
        exit 1
    fi
    info "调用 config/x11/kiosk/install.sh${INSTALL_ARGS:+ ← $INSTALL_ARGS}"
    set --
    [ "${KIOSK_COPY:-}" = "1" ] && set -- "$@" --copy
    # 兼容旧环境变量（默认已是 symlink）
    [ "${KIOSK_DEV:-}" = "1" ] && set -- "$@" --dev
    # shellcheck disable=SC2086
    [ -n "${INSTALL_ARGS:-}" ] && set -- "$@" $INSTALL_ARGS
    sh "$inst" "$@"
    info "kiosk 脚本完成。真机: startx kiosk -- <cmd>；本机测: kiosk-xephyr.sh"

    _X11_LIB_ONLY=1
    # shellcheck source=install/x11.sh
    . "$SCRIPT_DIR/install/x11.sh"
    x11_offer_multistart_for_desktop kiosk
    unset _X11_LIB_ONLY
}

install_fvwm() {
    ensure_submodule vendor/fvwm
    dest="$SCRIPT_DIR/vendor/fvwm"
    inst="$dest/install.sh"
    if [ ! -f "$inst" ]; then
        error "vendor/fvwm 缺少 install.sh"
        exit 1
    fi
    info "调用 vendor/fvwm/install.sh${INSTALL_ARGS:+ ← $INSTALL_ARGS}"
    set --
    [ "${FVWM_COPY:-}" = "1" ] && set -- "$@" --copy
    [ "${FVWM_FORCE:-}" = "1" ] && set -- "$@" --force
    # shellcheck disable=SC2086
    [ -n "${INSTALL_ARGS:-}" ] && set -- "$@" $INSTALL_ARGS
    sh "$inst" "$@"
    info "fvwm 完成。startx fvwm；依赖: fvwm3 rofi"

    _X11_LIB_ONLY=1
    # shellcheck source=install/x11.sh
    . "$SCRIPT_DIR/install/x11.sh"
    x11_offer_multistart_for_desktop fvwm
    unset _X11_LIB_ONLY
}

case "$INSTALL_SUB" in
    suckless)
        install_suckless
        ;;
    hyprland)
        install_hyprland
        ;;
    picom)
        warn "desktop:picom 已迁到 x11:picom，转发中"
        # shellcheck source=install/x11.sh
        . "$SCRIPT_DIR/install/x11.sh"
        ;;
    kiosk)
        install_kiosk
        ;;
    fvwm)
        install_fvwm
        ;;
    *)
        error "未知桌面子模块: ${INSTALL_SUB:-（空）}（用 desktop:suckless|hyprland|kiosk|fvwm；picom → x11:picom）"
        exit 1
        ;;
esac
