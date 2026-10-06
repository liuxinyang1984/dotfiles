#!/bin/sh
# fcitx5-chinese.sh — 编译安装 fcitx5-chinese-addons（拼音等）
# Alpine 无对应 apk 或版本不对时用。须装到与 fcitx5 相同的 prefix。

FCITX5_CHINESE_REPO="${FCITX5_CHINESE_REPO:-https://github.com/fcitx/fcitx5-chinese-addons.git}"
FCITX5_CHINESE_SRC="${FCITX5_CHINESE_SRC:-${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/fcitx5-chinese-addons}"

run_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v doas >/dev/null 2>&1; then
        doas "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        error "安装到系统目录需要 root（doas 或 sudo）"
        exit 1
    fi
}

apk_has() {
    command -v apk >/dev/null 2>&1 || return 1
    apk info -e "$1" >/dev/null 2>&1
}

pinyin_addon_present() {
    [ -e /usr/lib/fcitx5/pinyin.so ] || [ -e /usr/local/lib/fcitx5/pinyin.so ]
}

ensure_fcitx5_chinese_deps() {
    command -v cmake >/dev/null 2>&1 || {
        error "需要 cmake。Alpine: doas apk add build-base cmake extra-cmake-modules samurai fcitx5-dev libime-dev boost-dev fmt-dev gettext-dev opencc-dev curl-dev nlohmann-json pkgconf git"
        exit 1
    }
    command -v git >/dev/null 2>&1 || { error "需要 git"; exit 1; }
    command -v fcitx5 >/dev/null 2>&1 || { error "请先安装 fcitx5（apk add fcitx5 fcitx5-dev libime-dev）"; exit 1; }
}

fcitx5_prefix() {
    pkg-config --variable=prefix Fcitx5Core 2>/dev/null || printf '%s\n' /usr
}

fcitx5_version() {
    fcitx5 --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1
}

sync_chinese_addons_src() {
    src="$1"
    if [ ! -d "$src/.git" ]; then
        mkdir -p "$(dirname "$src")"
        info "克隆 fcitx5-chinese-addons → $src"
        git clone "$FCITX5_CHINESE_REPO" "$src"
    else
        info "更新 fcitx5-chinese-addons"
        git -C "$src" fetch --tags origin || warn "fetch 失败，使用已有源码"
    fi

    if [ -n "${FCITX5_CHINESE_TAG:-}" ]; then
        info "checkout $FCITX5_CHINESE_TAG"
        git -C "$src" checkout "$FCITX5_CHINESE_TAG"
        return
    fi

    ver="$(fcitx5_version)"
    if [ -n "$ver" ] && git -C "$src" tag -l "$ver" | grep -Fxq "$ver"; then
        info "对齐 fcitx5 版本 tag $ver"
        git -C "$src" checkout "$ver"
        return
    fi

    info "无匹配 tag${ver:+ ($ver)}，使用默认分支"
    git -C "$src" checkout master 2>/dev/null || git -C "$src" checkout main
    git -C "$src" pull --ff-only || true
}

if apk_has fcitx5-chinese-addons; then
    info "已有 apk 包 fcitx5-chinese-addons，跳过编译"
else
    if pinyin_addon_present; then
        info "已检测到 pinyin addon，跳过编译"
    else
        ensure_fcitx5_chinese_deps
        PREFIX="$(fcitx5_prefix)"
        info "fcitx5 prefix=$PREFIX"

        if command -v apk >/dev/null 2>&1; then
            info "安装编译依赖（若已安装 apk 会跳过）"
            run_root apk add \
                build-base cmake extra-cmake-modules samurai git \
                fcitx5-dev libime-dev boost-dev fmt-dev gettext-dev \
                opencc-dev curl-dev nlohmann-json pkgconf
        fi

        sync_chinese_addons_src "$FCITX5_CHINESE_SRC"
        rm -rf "$FCITX5_CHINESE_SRC/build"
        mkdir -p "$FCITX5_CHINESE_SRC/build"

        gen=""
        if command -v ninja >/dev/null 2>&1; then
            gen="-G Ninja"
        fi

        info "cmake（无 Qt WebEngine / 配置 GUI，适合 Alpine）"
        # shellcheck disable=SC2086
        cmake -S "$FCITX5_CHINESE_SRC" -B "$FCITX5_CHINESE_SRC/build" $gen \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX="$PREFIX" \
            -DENABLE_TEST=OFF \
            -DENABLE_BROWSER=OFF \
            -DENABLE_GUI=OFF

        cmake --build "$FCITX5_CHINESE_SRC/build"
        info "安装到 $PREFIX（需要提权）"
        run_root cmake --install "$FCITX5_CHINESE_SRC/build"
        info "编译安装完成。可 fcitx5-remote -r，在配置里启用拼音"
    fi
fi
