#!/bin/sh
# install.sh — 按参数安装模块；无参只打印用法
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=install/lib.sh
. "$SCRIPT_DIR/install/lib.sh"

usage() {
    cat <<EOF
用法: $0 <模块> [模块...]

  shell                 本仓 shell/：bashrc、alias、ssh.env、~/.gitconfig（不含 zsh）
  zsh                   调用 vendor/zshrc/install.sh（配置 → ~/.config/zsh）
  tmux                  调用 vendor/tmux/install.sh（配置 → ~/.config/tmux）
  nvim                  调用 vendor/neovim/install.sh
  vim                   调用 vendor/vim_server/install.sh
  fontconfig            链接 fonts.conf；缺 Maple Mono NL NF（Hinted）则下载安装
  fcitx5-chinese        Alpine x86 装本仓预编译 apk；否则有包则跳过，再否则编译拼音插件
  desktop:suckless      调用 suckless/install.sh（默认系统 PREFIX；SUCKLESS_USER=1 → ~/.local）+ fontconfig
  desktop:hyprland      vendor/hyprland（仓登记后可用）+ fontconfig

示例:
  $0 shell zsh tmux nvim
  $0 vim
  $0 fontconfig
  $0 fcitx5-chinese
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
        shell|zsh|tmux|nvim|vim|fontconfig|fcitx5-chinese)
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
