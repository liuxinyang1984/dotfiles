#!/bin/sh
# shell.sh — bash + 共用 alias/env + gitconfig（zsh 请用 ./install.sh zsh）

info "开始配置 shell（bash / gitconfig；不含 zsh）..."

SHELL_CONFIG_DIR="$XDG_CONFIG_HOME/shell"
BASH_CONFIG_DIR="$XDG_CONFIG_HOME/bash"

mkdir -p "$SHELL_CONFIG_DIR"

for f in "$SCRIPT_DIR/shell/"*.alias; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "alias 文件 $(basename "$f")"
    fi
done

safe_link "$SCRIPT_DIR/shell/ssh.env" "$SHELL_CONFIG_DIR/ssh.env" "SSH 环境变量"
safe_link "$SCRIPT_DIR/shell/gitconfig" "$HOME/.gitconfig" "gitconfig"

for f in "$SCRIPT_DIR/shell/"*.env; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "env 文件 $(basename "$f")"
    fi
done

for f in "$SCRIPT_DIR/shell/"*.fun; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "fun 文件 $(basename "$f")"
    fi
done

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

info "shell 配置完成（zsh: ./install.sh zsh）"
