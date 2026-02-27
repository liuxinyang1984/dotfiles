#!/usr/bin/env bash
# shell.sh - 配置 bash 和 zsh（模块化安装脚本）
# 该脚本由主脚本 install.sh 调用，依赖 $SCRIPT_DIR 及 info/warn 等函数

info "开始配置 shell..."

# ----------------------------- 定义目标目录 -----------------------------
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SHELL_CONFIG_DIR="$XDG_CONFIG_HOME/shell"      # 通用配置目录
BASH_CONFIG_DIR="$XDG_CONFIG_HOME/bash"        # bash 专用配置目录
ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"          # zsh 专用配置目录

mkdir -p "$SHELL_CONFIG_DIR"
# 注意：BASH_CONFIG_DIR 和 ZSH_CONFIG_DIR 将由 safe_link 创建（如果是目录链接，则无需提前创建）

# ----------------------------- safe_link 函数 -----------------------------
# 参数：源路径 目标路径 描述信息
safe_link() {
    local src="$1"
    local dest="$2"
    local name="$3"

    # 源文件/目录必须存在
    if [ ! -e "$src" ]; then
        warn "源文件不存在: $src，跳过 $name 的链接"
        return
    fi

    if [ -L "$dest" ]; then
        # 目标已是符号链接，检查指向是否正确
        local current_target="$(readlink "$dest")"
        if [ "$current_target" = "$src" ]; then
            info "$name 已正确链接到 $src，跳过"
        else
            warn "$name 符号链接指向错误：$current_target"
            ln -sfn "$src" "$dest"   # -n 将目标视为普通文件（不进入目录）
            info "已更新符号链接 $dest -> $src"
        fi
    elif [ -e "$dest" ]; then
        # 目标存在但不是符号链接（可能是文件或目录）
        warn "$name 已存在且不是符号链接: $dest"
        read -p "是否覆盖？（备份原文件/目录并创建符号链接）[y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
            mv "$dest" "$backup"
            info "已备份原内容到 $backup"
            ln -s "$src" "$dest"
            info "已创建符号链接 $dest -> $src"
        else
            info "跳过 $name 的配置"
        fi
    else
        # 目标不存在，直接创建符号链接
        ln -s "$src" "$dest"
        info "已创建符号链接 $dest -> $src"
    fi
}

# ----------------------------- 通用配置文件链接 -----------------------------
# 将所有 .alias 文件链接到 SHELL_CONFIG_DIR
for f in "$SCRIPT_DIR/shell/"*.alias; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "alias 文件 $(basename "$f")"
    fi
done

# 将所有 .env 文件链接到 SHELL_CONFIG_DIR
for f in "$SCRIPT_DIR/shell/"*.env; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "env 文件 $(basename "$f")"
    fi
done

# 将所有 .fun 文件链接到 SHELL_CONFIG_DIR
for f in "$SCRIPT_DIR/shell/"*.fun; do
    if [ -f "$f" ]; then
        safe_link "$f" "$SHELL_CONFIG_DIR/$(basename "$f")" "fun 文件 $(basename "$f")"
    fi
done

# ----------------------------- bash 配置 -----------------------------
if command -v bash >/dev/null 2>&1; then
    info "检测到 bash，配置 bash 相关文件..."

    # 链接 bashrc 到家目录
    safe_link "$SCRIPT_DIR/shell/bashrc" "$HOME/.bashrc" "bashrc"

    # 链接 bash 专用配置目录（如果存在）
    if [ -d "$SCRIPT_DIR/shell/bash" ]; then
        safe_link "$SCRIPT_DIR/shell/bash" "$BASH_CONFIG_DIR" "bash 专用配置目录"
    else
        info "未找到 bash 专用配置目录 $SCRIPT_DIR/shell/bash，跳过"
    fi
else
    info "bash 未安装，跳过 bash 配置"
fi

# ----------------------------- zsh 配置 -----------------------------
if command -v zsh >/dev/null 2>&1; then
    info "检测到 zsh，配置 zsh 相关文件..."

    # 链接 zshrc 到家目录
    safe_link "$SCRIPT_DIR/shell/zshrc" "$HOME/.zshrc" "zshrc"

    # 链接 zsh 专用配置目录（如果存在）
    if [ -d "$SCRIPT_DIR/shell/zsh" ]; then
        safe_link "$SCRIPT_DIR/shell/zsh" "$ZSH_CONFIG_DIR" "zsh 专用配置目录"
    else
        info "未找到 zsh 专用配置目录 $SCRIPT_DIR/shell/zsh，跳过"
    fi
else
    info "zsh 未安装，跳过 zsh 配置"
fi

# ----------------------------- 默认 shell 检查 -----------------------------
if command -v zsh >/dev/null 2>&1; then
    if [ "$SHELL" = "$(which zsh)" ]; then
        info "当前默认 shell 已是 zsh"
    else
        warn "默认 shell 不是 zsh，如需更改请手动执行: chsh -s $(which zsh)"
    fi
fi

info "shell 配置完成"
