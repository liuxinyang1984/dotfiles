# shellcheck shell=sh
# 各 *-session 可 source（由 x11:multistart / desktop:* 链到 ~/.config/x11/）
# 用法: . "${XDG_CONFIG_HOME:-$HOME/.config}/x11/session-common.sh"

export PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
	export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
	mkdir -p "$XDG_RUNTIME_DIR"
	chmod 700 "$XDG_RUNTIME_DIR"
fi

export GTK_IM_MODULE="${GTK_IM_MODULE:-fcitx}"
export QT_IM_MODULE="${QT_IM_MODULE:-fcitx}"
export XMODIFIERS="${XMODIFIERS:-@im=fcitx}"
export SDL_IM_MODULE="${SDL_IM_MODULE:-fcitx}"
