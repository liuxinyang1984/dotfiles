#!/bin/sh
# fontconfig.sh — 兼容入口：装框架 + fonts:maple --all（desktop:* 仍调用本脚本）
# 字体包请用：./install.sh fonts:maple | fonts:sunsong

_fw="$SCRIPT_DIR/config/fonts/fonts.conf"
_dest="$XDG_CONFIG_HOME/fontconfig/fonts.conf"
mkdir -p "$XDG_CONFIG_HOME/fontconfig/conf.d"

if [ -f "$_dest" ] && [ ! -L "$_dest" ]; then
    if ! grep -q 'managed-by: dotfiles' "$_dest" 2>/dev/null; then
        warn "已有陌生 fonts.conf（无 managed-by: dotfiles），不覆盖: $_dest"
    else
        safe_link "$_fw" "$_dest" "fontconfig"
    fi
else
    safe_link "$_fw" "$_dest" "fontconfig"
fi

_maple="$SCRIPT_DIR/config/fonts/maple/install.sh"
if [ -x "$_maple" ]; then
    info "调用 fonts/maple/install.sh --all"
    "$_maple" --all
else
    warn "缺少 $_maple，跳过 Maple"
fi

info "fontconfig 完成（框架在 config/fonts/；旧 config/fontconfig/ 已废弃）"
