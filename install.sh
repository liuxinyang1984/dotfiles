#!/bin/sh
# install.sh — 按参数安装模块；无参只打印用法
# 模块词之后、下一个模块词之前的参数，转发给该模块内部 install.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=install/lib.sh
. "$SCRIPT_DIR/install/lib.sh"

# 合法模块词（完整 token）。不在此集合内的参数挂到「前一个」模块。
is_known_module() {
    case "$1" in
        shell|zsh|tmux|nvim|vim|fontconfig|fcitx5-chinese|keyd|dunst) return 0 ;;
        desktop:suckless|desktop:hyprland|desktop:kiosk|desktop:fvwm|desktop:picom) return 0 ;;
        x11:multistart|x11:picom|x11:rofi) return 0 ;;
        *) return 1 ;;
    esac
}

usage() {
    cat <<EOF
用法: $0 <模块> [模块参数...] [模块 [模块参数...] ...]

  不在模块列表中的参数，视为前一个模块的参数，转发给其内部 install.sh。

  shell                 本仓 shell/：bashrc、alias、ssh.env、~/.gitconfig（不含 zsh）
  zsh                   调用 vendor/zshrc/install.sh（配置 → ~/.config/zsh）
  tmux                  调用 vendor/tmux/install.sh（配置 → ~/.config/tmux）
  nvim                  调用 vendor/neovim/install.sh
  vim                   调用 vendor/vim_server/install.sh
  fontconfig            链接 fonts.conf；缺 Maple Mono NL NF（Hinted）则下载安装
  fcitx5-chinese        Alpine x86 装本仓预编译 apk；否则有包则跳过，再否则编译拼音插件
  keyd                  安装 config/keyd/default.conf → /etc/keyd/，启用 keyd 服务
  dunst                 链接 dunst + mako 通知配置（dwm / Hyprland）
  desktop:suckless      调用 suckless/install.sh（可跟 dwm st …；SUCKLESS_USER=1 → ~/.local）
  desktop:hyprland      vendor/hyprland（仓登记后可用）+ fontconfig
  desktop:kiosk         config/x11/kiosk → ~/.local/bin（可跟 --copy；KIOSK_COPY=1 亦可）
  desktop:fvwm          vendor/fvwm → ~/.fvwm（可跟 --copy / --force）
  x11:multistart        多启动：~/.xinitrc + ~/.local/bin/startx
  x11:picom             调用 vendor/picom/install.sh（可跟 --user 等）
  x11:rofi              CDE 主题 + rofi-drun（.desktop 启动器）

示例:
  $0 shell zsh tmux nvim
  $0 desktop:suckless
  $0 desktop:suckless dwm
  $0 desktop:suckless dwm st
  $0 desktop:suckless --user dwm
  $0 shell desktop:suckless dwm
  $0 desktop:kiosk --copy
  $0 x11:multistart
  $0 x11:picom
  $0 x11:rofi
EOF
}

run_one_module() {
    _full="$1"
    # INSTALL_ARGS 已由调用方 export（可能为空）

    case "$_full" in
        *:*)
            module="${_full%%:*}"
            sub="${_full#*:}"
            ;;
        *)
            module="$_full"
            sub=""
            ;;
    esac

    case "$module" in
        desktop)
            if [ -z "$sub" ]; then
                error "请指定 desktop:suckless、desktop:hyprland、desktop:kiosk 或 desktop:fvwm（picom → x11:picom）"
                exit 1
            fi
            ;;
        x11)
            if [ -z "$sub" ]; then
                error "请指定 x11:multistart、x11:picom 或 x11:rofi"
                exit 1
            fi
            ;;
        shell|zsh|tmux|nvim|vim|fontconfig|fcitx5-chinese|keyd|dunst)
            if [ -n "$sub" ]; then
                error "模块 $module 不接受子模块: $_full"
                exit 1
            fi
            ;;
        *)
            error "未知模块: $_full"
            usage
            exit 1
            ;;
    esac

    module_script="$SCRIPT_DIR/install/${module}.sh"
    if [ ! -f "$module_script" ]; then
        error "模块脚本不存在: $module_script"
        exit 1
    fi

    if [ -n "${INSTALL_ARGS:-}" ]; then
        info "执行模块: $_full ← ${INSTALL_ARGS}"
    else
        info "执行模块: $_full"
    fi
    INSTALL_SUB="$sub"
    export INSTALL_SUB
    export INSTALL_ARGS
    # shellcheck source=/dev/null
    . "$module_script"
    unset INSTALL_SUB
    unset INSTALL_ARGS
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            usage
            exit 0
            ;;
    esac
done

current_mod=""
INSTALL_ARGS=""

for arg in "$@"; do
    if is_known_module "$arg"; then
        if [ -n "$current_mod" ]; then
            export INSTALL_ARGS
            run_one_module "$current_mod"
        fi
        current_mod="$arg"
        INSTALL_ARGS=""
    else
        if [ -z "$current_mod" ]; then
            error "参数「$arg」不是模块，且前面没有模块可挂载"
            usage
            exit 1
        fi
        if [ -z "$INSTALL_ARGS" ]; then
            INSTALL_ARGS="$arg"
        else
            INSTALL_ARGS="$INSTALL_ARGS $arg"
        fi
    fi
done

if [ -n "$current_mod" ]; then
    export INSTALL_ARGS
    run_one_module "$current_mod"
fi

info "指定模块已处理完毕"
