#!/bin/sh
# vim.sh - 配置 vim 和 neovim

info "vim.sh 运行目录: $SCRIPT_DIR"

# 定义 Vim 相关源文件目录
VIM_SRC_DIR="$SCRIPT_DIR/vim"
PLUGIN_CONFIG_SRC="$VIM_SRC_DIR/plugin-config"
COMMON_VIM_SRC="$VIM_SRC_DIR/common.vim"
VIMRC_SRC="$VIM_SRC_DIR/vimrc"
INITVIM_SRC="$VIM_SRC_DIR/init.vim"

info "Vim 源文件目录: $VIM_SRC_DIR"

# 目标目录
VIM_CONFIG_DIR="$HOME/.vim"
VIM_PLUGIN_CONFIG_DEST="$VIM_CONFIG_DIR/plugin-config"
VIM_COMMON_DEST="$VIM_CONFIG_DIR/common.vim"

# 创建 Vim 配置目录（如果不存在）
mkdir -p "$VIM_CONFIG_DIR"

# 链接 common.vim（基础配置）
if [ -f "$COMMON_VIM_SRC" ]; then
    safe_link "$COMMON_VIM_SRC" "$VIM_COMMON_DEST" "common.vim"
else
    info "common.vim 不存在，跳过"
fi

# 链接插件配置子目录
if [ -d "$PLUGIN_CONFIG_SRC" ]; then
    info "插件配置源目录存在: $PLUGIN_CONFIG_SRC"
    mkdir -p "$VIM_PLUGIN_CONFIG_DEST"
    for subdir in common vim nvim; do
        if [ -d "$PLUGIN_CONFIG_SRC/$subdir" ]; then
            mkdir -p "$VIM_PLUGIN_CONFIG_DEST/$subdir"
            for f in "$PLUGIN_CONFIG_SRC/$subdir"/*.vim; do
                if [ -f "$f" ]; then
                    info "链接插件配置文件: $(basename "$f")"
                    safe_link "$f" "$VIM_PLUGIN_CONFIG_DEST/$subdir/$(basename "$f")" "插件配置 $subdir/$(basename "$f")"
                fi
            done
        fi
    done
else
    info "插件配置源目录不存在: $PLUGIN_CONFIG_SRC，跳过"
fi

# ---------- Vim 专用配置 ----------
if command -v vim >/dev/null 2>&1; then
    info "检测到 vim，链接 .vimrc..."
    if [ -f "$VIMRC_SRC" ]; then
        safe_link "$VIMRC_SRC" "$HOME/.vimrc" "vimrc"
    else
        warn "vimrc 源文件不存在: $VIMRC_SRC"
    fi
else
    info "vim 未安装，跳过 .vimrc 链接"
fi

# ---------- Neovim 专用配置 ----------
if command -v nvim >/dev/null 2>&1; then
    info "检测到 neovim，配置 neovim..."
    NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    mkdir -p "$NVIM_CONFIG_DIR"

    # 链接 init.vim
    if [ -f "$INITVIM_SRC" ]; then
        safe_link "$INITVIM_SRC" "$NVIM_CONFIG_DIR/init.vim" "init.vim"
    else
        warn "init.vim 源文件不存在: $INITVIM_SRC"
    fi

    # 将 Neovim 的插件配置目录链接到 Vim 的目录（已存在）
    NVIM_PLUGIN_CONFIG_DEST="$NVIM_CONFIG_DIR/plugin-config"
    info "为 neovim 创建插件配置目录链接: $NVIM_PLUGIN_CONFIG_DEST -> $VIM_PLUGIN_CONFIG_DEST"
    safe_link "$VIM_PLUGIN_CONFIG_DEST" "$NVIM_PLUGIN_CONFIG_DEST" "Neovim 插件配置目录"
else
    info "neovim 未安装，跳过 neovim 配置"
fi

info "vim/neovim 配置完成"
