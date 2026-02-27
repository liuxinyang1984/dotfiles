# 定义源目录
PLUGIN_CONFIG_SRC="$SCRIPT_DIR/plugin-config"

# 目标目录（Vim）
VIM_PLUGIN_CONFIG_DEST="$HOME/.vim/plugin-config"

# 创建 Vim 插件配置目录并链接所有子目录
if [ -d "$PLUGIN_CONFIG_SRC" ]; then
    mkdir -p "$VIM_PLUGIN_CONFIG_DEST"
    # 使用 rsync 或 cp 将整个目录结构复制过去？但我们要的是符号链接，所以需要分别处理子目录
    # 简单做法：将每个子目录分别链接
    for subdir in common vim nvim; do
        if [ -d "$PLUGIN_CONFIG_SRC/$subdir" ]; then
            mkdir -p "$VIM_PLUGIN_CONFIG_DEST/$subdir"
            for f in "$PLUGIN_CONFIG_SRC/$subdir"/*.vim; do
                [ -f "$f" ] && safe_link "$f" "$VIM_PLUGIN_CONFIG_DEST/$subdir/$(basename "$f")" "插件配置 $subdir/$(basename "$f")"
            done
        fi
    done
fi

# 如果 Neovim 已安装，将它的配置目录链接到 Vim 的插件配置目录（共享）
if command -v nvim >/dev/null 2>&1; then
    NVIM_PLUGIN_CONFIG_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugin-config"
    mkdir -p "$(dirname "$NVIM_PLUGIN_CONFIG_DEST")"
    safe_link "$VIM_PLUGIN_CONFIG_DEST" "$NVIM_PLUGIN_CONFIG_DEST" "Neovim 插件配置目录"
fi
