#!/usr/bin/env bash
set -e  # 遇到错误立即退出

# 获取脚本所在目录（保证符号链接路径正确）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色输出函数
info()  { echo -e "\033[32m[INFO]\033[0m $1"; }
warn()  { echo -e "\033[33m[WARN]\033[0m $1"; }
error() { echo -e "\033[31m[ERROR]\033[0m $1"; }

# 默认安装所有模块，也可通过参数指定
modules=("shell" "vim" "desktop")
if [ $# -gt 0 ]; then
    modules=("$@")  # 使用命令行参数指定要安装的模块（例如 ./install.sh shell vim）
fi

for module in "${modules[@]}"; do
    module_script="$SCRIPT_DIR/install/${module}.sh"
    if [ -f "$module_script" ]; then
        info "执行模块: $module"
        # 使用 source 让子模块能使用当前脚本的函数和变量
        source "$module_script"
    else
        error "模块脚本不存在: $module_script"
        exit 1
    fi
done

info "所有指定模块安装完成！"
