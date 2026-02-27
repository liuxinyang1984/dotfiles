#!/bin/sh
# install.sh - dotfiles 安装主脚本

set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 颜色输出函数（使用 printf 保证可移植性）
info() {
    printf '\033[32m[INFO]\033[0m %s\n' "$1"
}
warn() {
    printf '\033[33m[WARN]\033[0m %s\n' "$1"
}
error() {
    printf '\033[31m[ERROR]\033[0m %s\n' "$1"
}

# 模块选择：若提供参数则安装指定模块，否则安装全部
if [ $# -gt 0 ]; then
    modules="$*"        # 将参数列表合并为空格分隔的字符串
else
    modules="shell vim desktop"   # 默认模块
fi

# 遍历模块
for module in $modules; do
    module_script="$SCRIPT_DIR/install/${module}.sh"
    if [ -f "$module_script" ]; then
        info "执行模块: $module"
        . "$module_script"        # 使用 . 代替 source
    else
        error "模块脚本不存在: $module_script"
        exit 1
    fi
done

info "所有指定模块安装完成！"
