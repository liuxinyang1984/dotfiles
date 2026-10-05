#!/bin/sh
# nvim.sh — neovim_lua（由 install.sh source）

ensure_submodule vendor/neovim

NVIM_SRC="$SCRIPT_DIR/vendor/neovim"
NVIM_DEST="${XDG_CONFIG_HOME}/nvim"

if ! command -v nvim >/dev/null 2>&1; then
    warn "未检测到 nvim，仍链接配置目录"
fi

safe_link "$NVIM_SRC" "$NVIM_DEST" "neovim"

info "nvim 配置完成（首次可在 nvim 内 :Lazy sync）"
