#!/bin/sh
# install.sh - dotfiles 安装主脚本
set -e

# safe_link 函数：安全创建符号链接
safe_link() {
    src="$1"
    dest="$2"
    name="$3"

    # 源文件/目录必须存在
    if [ ! -e "$src" ]; then
        warn "源文件不存在: $src，跳过 $name 的链接"
        return
    fi

    if [ -L "$dest" ]; then
        # 目标已是符号链接，检查指向
        current_target="$(readlink "$dest")"
        if [ "$current_target" = "$src" ]; then
            info "$name 已正确链接到 $src，跳过"
        else
            warn "$name 符号链接指向错误：$current_target"
            ln -sf "$src" "$dest"
            info "已更新符号链接 $dest -> $src"
        fi
    elif [ -e "$dest" ]; then
        # 目标存在但不是符号链接
        warn "$name 已存在且不是符号链接: $dest"
        printf "是否覆盖？（备份原文件/目录并创建符号链接）[y/N] "
        read reply
        case "$reply" in
            [yY]|[yY][eE][sS])
                backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
                mv "$dest" "$backup"
                info "已备份原内容到 $backup"
                ln -s "$src" "$dest"
                info "已创建符号链接 $dest -> $src"
                ;;
            *)
                info "跳过 $name 的配置"
                ;;
        esac
    else
        # 目标不存在
        ln -s "$src" "$dest"
        info "已创建符号链接 $dest -> $src"
    fi
}


# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 颜色输出函数
info() { printf '\033[32m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[31m[ERROR]\033[0m %s\n' "$1"; }

# 模块选择：若提供参数则安装指定模块，否则安装全部
if [ $# -gt 0 ]; then
    modules="$*"
else
    modules="shell vim desktop"
fi

# 遍历每个参数
for arg in $modules; do
    # 检查参数中是否包含冒号
    case "$arg" in
        *:*)
            module="${arg%%:*}"   # 冒号前为模块名
            sub="${arg#*:}"       # 冒号后为子模块
            ;;
        *)
            module="$arg"
            sub=""                # 无子模块，表示安装全部
            ;;
    esac

    module_script="$SCRIPT_DIR/install/${module}.sh"
    if [ -f "$module_script" ]; then
        info "执行模块: $module${sub:+ (子模块: $sub)}"
        export INSTALL_SUB="$sub"
        . "$module_script"
        unset INSTALL_SUB
    else
        error "模块脚本不存在: $module_script"
        exit 1
    fi
done

info "所有指定模块安装完成！"
