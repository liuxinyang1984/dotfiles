#!/bin/sh
# vim.sh — vim_server（由 install.sh source）
# 不软链 vimrc（Vim 7.4 会把 runtime 目录解析错）

ensure_submodule vendor/vim_server

VIM_SRC="$SCRIPT_DIR/vendor/vim_server/vimrc"
VIMRC_DEST="$HOME/.vimrc"
SOURCE_LINE="source $VIM_SRC"

if [ ! -f "$VIM_SRC" ]; then
    error "找不到 vim_server 入口: $VIM_SRC"
    exit 1
fi

if ! command -v vim >/dev/null 2>&1; then
    warn "未检测到 vim，仍写入 ~/.vimrc"
fi

if [ -L "$VIMRC_DEST" ]; then
    warn "$VIMRC_DEST 是符号链接，vim_server 需要普通文件 source"
    printf "是否备份并改写成 source 行？[y/N] "
    read reply
    case "$reply" in
        [yY]|[yY][eE][sS])
            backup="${VIMRC_DEST}.backup.$(date +%Y%m%d%H%M%S)"
            mv "$VIMRC_DEST" "$backup"
            info "已备份到 $backup"
            printf '%s\n' "$SOURCE_LINE" > "$VIMRC_DEST"
            info "已写入 $VIMRC_DEST"
            ;;
        *)
            info "跳过 vimrc"
            ;;
    esac
elif [ -f "$VIMRC_DEST" ]; then
    if grep -Fq "$SOURCE_LINE" "$VIMRC_DEST"; then
        info "vimrc 已包含 source 行，跳过"
    else
        printf '\n%s\n' "$SOURCE_LINE" >> "$VIMRC_DEST"
        info "已在 vimrc 末尾追加 source 行"
    fi
else
    printf '%s\n' "$SOURCE_LINE" > "$VIMRC_DEST"
    info "已创建 $VIMRC_DEST"
fi

info "vim 配置完成（插件: vim -u $VIM_SRC -es +PlugInstall +qa）"
