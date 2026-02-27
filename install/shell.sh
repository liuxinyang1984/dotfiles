#!/bin/sh
# shell.sh - 配置 bash 和 zsh (POSIX 兼容版本)

info "开始配置 shell..."

# 定义目标目录
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SHELL_CONFIG_DIR="$XDG_CONFIG_HOME/shell"
BASH_CONFIG_DIR="$XDG_CONFIG_HOME/bash"
ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"

mkdir -p "$SHELL_CONFIG_DIR"

# 链接所有 .alias 文件
for f in "$SCRIPT_DIR/shell/"*.alias; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "alias 文件 $(basename "$f")"
    fi
done

# 链接ssh环境配置
safe_link "$SCRIPT_DIR/shell/ssh.env" "$SHELL_CONFIG_DIR/ssh.env" "SSH 环境变量"


# 考虑将来用脚本代替
# 链接所有 .env 文件
for f in "$SCRIPT_DIR/shell/"*.env; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "env 文件 $(basename "$f")"
    fi
done

# 链接所有 .fun 文件
for f in "$SCRIPT_DIR/shell/"*.fun; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "fun 文件 $(basename "$f")"
    fi
done

# bash 配置
if command -v bash >/dev/null 2>&1; then
    info "检测到 bash，配置 bash 相关文件..."
    safe_link "$SCRIPT_DIR/shell/bashrc" "$HOME/.bashrc" "bashrc"
    if [ -d "$SCRIPT_DIR/shell/bash" ]; then
        safe_link "$SCRIPT_DIR/shell/bash" "$BASH_CONFIG_DIR" "bash 专用配置目录"
    else
        info "未找到 bash 专用配置目录 $SCRIPT_DIR/shell/bash，跳过"
    fi
else
    info "bash 未安装，跳过 bash 配置"
fi

# zsh 配置
if command -v zsh >/dev/null 2>&1; then
    info "检测到 zsh，配置 zsh 相关文件..."
    safe_link "$SCRIPT_DIR/shell/zshrc" "$HOME/.zshrc" "zshrc"
    if [ -d "$SCRIPT_DIR/shell/zsh" ]; then
        safe_link "$SCRIPT_DIR/shell/zsh" "$ZSH_CONFIG_DIR" "zsh 专用配置目录"
    else
        info "未找到 zsh 专用配置目录 $SCRIPT_DIR/shell/zsh，跳过"
    fi
else
    info "zsh 未安装，跳过 zsh 配置"
fi

# 默认 shell 检查
if command -v zsh >/dev/null 2>&1; then
    if [ "$SHELL" = "$(command -v zsh)" ]; then
        info "当前默认 shell 已是 zsh"
    else
        warn "默认 shell 不是 zsh，如需更改请手动执行: chsh -s $(command -v zsh)"
    fi
fi

info "shell 配置完成"
