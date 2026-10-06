#!/bin/sh
# install.sh — 按参数安装模块；无参只打印用法
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=install/lib.sh
. "$SCRIPT_DIR/install/lib.sh"

usage() {
    cat <<EOF
用法: $0 <模块> [模块...]

  shell                 本仓 shell/（bashrc、zshrc、alias）
  nvim                  vendor/neovim → ~/.config/nvim
  vim                   vendor/vim_server，~/.vimrc source 入口
  fontconfig            链接 fonts.conf；缺 Maple Mono NL NF（Hinted）则下载安装
  desktop:suckless      vendor/suckless（dwm/st/dmenu 编进 ~/.local）+ fontconfig
  desktop:hyprland      vendor/hyprland（仓登记后可用）+ fontconfig

示例:
  $0 shell nvim
  $0 vim
  $0 fontconfig
  $0 desktop:suckless
EOF
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
        *:*)
            module="${arg%%:*}"
            sub="${arg#*:}"
            ;;
        *)
            module="$arg"
            sub=""
            ;;
    esac

    case "$module" in
        desktop)
            if [ -z "$sub" ]; then
                error "请指定 desktop:suckless 或 desktop:hyprland"
                exit 1
            fi
            ;;
        shell|nvim|vim|fontconfig)
            if [ -n "$sub" ]; then
                error "模块 $module 不接受子模块: $arg"
                exit 1
            fi
            ;;
        *)
            error "未知模块: $arg"
            usage
            exit 1
            ;;
    esac

    module_script="$SCRIPT_DIR/install/${module}.sh"
    if [ ! -f "$module_script" ]; then
        error "模块脚本不存在: $module_script"
        exit 1
    fi

    info "执行模块: $module${sub:+ ($sub)}"
    INSTALL_SUB="$sub"
    export INSTALL_SUB
    # shellcheck source=/dev/null
    . "$module_script"
    unset INSTALL_SUB
done

info "指定模块已处理完毕"
