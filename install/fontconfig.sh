#!/bin/sh
# fontconfig.sh — 由 install.sh source；desktop 模块也会调用
# Maple Mono NL NF（Hinted TTF，无连字，族名与普通 Maple Mono 不同）

MAPLE_FAMILY="Maple Mono NL NF"
MAPLE_TAG="${MAPLE_TAG:-v8.0-beta.3}"
MAPLE_ZIP="MapleMonoNL-NF.zip"
MAPLE_URL="https://github.com/subframe7536/maple-font/releases/download/${MAPLE_TAG}/${MAPLE_ZIP}"
MAPLE_FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/MapleMonoNL-NF"

maple_family_installed() {
    command -v fc-list >/dev/null 2>&1 || return 1
    fc-list : family | grep -Fxq "$MAPLE_FAMILY"
}

ensure_maple_mono() {
    if maple_family_installed; then
        info "已安装字体族: $MAPLE_FAMILY"
        return 0
    fi

    info "未检测到 $MAPLE_FAMILY，下载 Hinted TTF: $MAPLE_ZIP ($MAPLE_TAG)"
    command -v curl >/dev/null 2>&1 || { error "需要 curl 下载字体"; exit 1; }
    command -v unzip >/dev/null 2>&1 || { error "需要 unzip 解压字体"; exit 1; }

    mkdir -p "$MAPLE_FONT_DIR"
    tmpzip="${TMPDIR:-/tmp}/$MAPLE_ZIP"
    if ! curl -fL --retry 5 --retry-all-errors -o "$tmpzip" "$MAPLE_URL"; then
        error "下载失败: $MAPLE_URL"
        exit 1
    fi
    unzip -o -d "$MAPLE_FONT_DIR" "$tmpzip"
    rm -f "$tmpzip"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$MAPLE_FONT_DIR"
    else
        warn "没有 fc-cache，跳过刷新；新开终端后再查 fc-list"
    fi

    if maple_family_installed; then
        info "已安装 $MAPLE_FAMILY → $MAPLE_FONT_DIR"
    else
        warn "已解压到 $MAPLE_FONT_DIR，但 fc-list 仍看不到 $MAPLE_FAMILY（可再跑 fc-cache -f）"
    fi
}

link_fontconfig() {
    src="$SCRIPT_DIR/config/fontconfig/fonts.conf"
    dest="$XDG_CONFIG_HOME/fontconfig/fonts.conf"
    mkdir -p "$XDG_CONFIG_HOME/fontconfig"
    safe_link "$src" "$dest" "fontconfig"
}

ensure_maple_mono
link_fontconfig
info "fontconfig 完成"
