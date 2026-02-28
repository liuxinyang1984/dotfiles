#!/bin/sh
# vim.sh - 配置 vim 和 neovim（支持子模块选择）

info "vim.sh 运行目录: $SCRIPT_DIR"

# 定义 Vim 相关源文件目录
VIM_ROOT_SRC_DIR="$SCRIPT_DIR/vim"
COMMON_VIM_SRC="$VIM_ROOT_SRC_DIR/common.vim"
PLUGIN_CONFIG_SRC="$VIM_ROOT_SRC_DIR/plugin-config"
VIMRC_SRC="$VIM_ROOT_SRC_DIR/vimrc"
INITVIM_SRC="$VIM_ROOT_SRC_DIR/init.vim"

info "Vim 源文件目录: $VIM_ROOT_SRC_DIR"

# ---------- Vim 专用配置 ----------
if [ -z "$INSTALL_SUB" ] || [ "$INSTALL_SUB" = "vim" ]; then
    if command -v vim >/dev/null 2>&1; then
        info "检测到 vim，链接 .vimrc..."
        # 定义Vim目标目录
        VIM_CONFIG_DIR="$HOME/.vim"

        # 创建 Vim 配置目录（如果不存在）
        mkdir -p "$VIM_CONFIG_DIR"

        # 链接配置文件
        safe_link "$VIMRC_SRC" "$HOME/.vimrc" "vimrc"
        # 链接通用配置
        safe_link "$COMMON_VIM_SRC" "$VIM_CONFIG_DIR/common.vim" "common.vim"

        # 链接插件配置
        VIM_PLUGIN_CONFIG_DEST="$VIM_CONFIG_DIR/plugin-config"
        if [ -d "$PLUGIN_CONFIG_SRC" ]; then
            info "插件配置源目录存在: $PLUGIN_CONFIG_SRC"
            mkdir -p "$VIM_PLUGIN_CONFIG_DEST"
            for subdir in common vim; do
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
    else
        info "vim 未安装，跳过 vim 配置"
    fi
fi

# ---------- Neovim 专用配置 ----------
if [ -z "$INSTALL_SUB" ] || [ "$INSTALL_SUB" = "nvim" ]; then
    if command -v nvim >/dev/null 2>&1; then
        info "检测到 neovim，配置 neovim..."
        NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
        mkdir -p "$NVIM_CONFIG_DIR"

        # 链接配置文件
        safe_link "$INITVIM_SRC" "$NVIM_CONFIG_DIR/init.vim" "init.vim"
        # 链接通用配置
        safe_link "$COMMON_VIM_SRC" "$NVIM_CONFIG_DIR/common.vim" "common.vim"

        # 链接插件配置
        NVIM_PLUGIN_CONFIG_DEST="$NVIM_CONFIG_DIR/plugin-config"
        if [ -d "$PLUGIN_CONFIG_SRC" ]; then
            info "插件配置源目录存在: $PLUGIN_CONFIG_SRC"
            mkdir -p "$NVIM_PLUGIN_CONFIG_DEST"
            for subdir in common nvim; do
                if [ -d "$PLUGIN_CONFIG_SRC/$subdir" ]; then
                    mkdir -p "$NVIM_PLUGIN_CONFIG_DEST/$subdir"
                    info "新建目录$NVIM_PLUGIN_CONFIG_DEST/$subdir"
                    for f in "$PLUGIN_CONFIG_SRC/$subdir"/*.vim; do
                        if [ -f "$f" ]; then
                            info "链接插件配置文件: $(basename "$f")"
                            safe_link "$f" "$NVIM_PLUGIN_CONFIG_DEST/$subdir/$(basename "$f")" "插件配置 $subdir/$(basename "$f")"
                        fi
                    done
                fi
            done
        else
            info "插件配置源目录不存在: $PLUGIN_CONFIG_SRC，跳过"
        fi
    else
        info "neovim 未安装，跳过 neovim 配置"
    fi
fi

info "vim/neovim 配置完成"
