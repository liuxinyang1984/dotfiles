#!/bin/sh
# 在 Xephyr 嵌套 X11 里跑 kiosk（本机已有 Hyprland 等时用，勿 startx）
# 参数原样传给 kiosk-session.sh（任意命令）
#
# 用法:
#   kiosk-xephyr.sh                         # 默认 session（st+tmux）
#   kiosk-xephyr.sh alacritty
#   kiosk-xephyr.sh st -e nvim
#   kiosk-xephyr.sh qutebrowser
#   KIOSK_XEPHYR_DISPLAY=:3 KIOSK_XEPHYR_SCREEN=1600x900 kiosk-xephyr.sh foot
#
# 环境变量:
#   KIOSK_XEPHYR_DISPLAY   默认 :2
#   KIOSK_XEPHYR_SCREEN    默认 1280x800
#   KIOSK_XEPHYR_EXTRA     额外 Xephyr 参数
#   其余 KIOSK_* 传给 kiosk-session.sh

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
NESTED="${KIOSK_XEPHYR_DISPLAY:-:2}"
SCREEN="${KIOSK_XEPHYR_SCREEN:-1280x800}"
GEOM="${KIOSK_GEOM:-${SCREEN}+0+0}"
HOST_DISPLAY="${DISPLAY:-:0}"

if ! command -v Xephyr >/dev/null 2>&1; then
	echo "FATAL: Xephyr not found (Arch: xorg-server-xephyr)" >&2
	exit 1
fi

SESSION_SH=""
for c in "$ROOT/kiosk-session.sh" "$HOME/.local/bin/kiosk-session.sh"; do
	if [ -x "$c" ]; then
		SESSION_SH=$c
		break
	fi
done
if [ -z "$SESSION_SH" ]; then
	echo "FATAL: kiosk-session.sh not found" >&2
	exit 1
fi

sock="/tmp/.X11-unix/X${NESTED#:}"
need_xephyr=1
if [ -S "$sock" ]; then
	need_xephyr=0
	echo "reuse existing display $NESTED"
fi

XEPHYR_PID=""
if [ "$need_xephyr" -eq 1 ]; then
	# shellcheck disable=SC2086
	DISPLAY="$HOST_DISPLAY" Xephyr "$NESTED" -screen "$SCREEN" -ac ${KIOSK_XEPHYR_EXTRA:-} &
	XEPHYR_PID=$!
	echo "Xephyr pid=$XEPHYR_PID nested=$NESTED screen=$SCREEN host=$HOST_DISPLAY"
	n=0
	while [ "$n" -lt 50 ]; do
		[ -S "$sock" ] && break
		n=$((n + 1))
		sleep 0.1
	done
	if [ ! -S "$sock" ]; then
		echo "FATAL: Xephyr failed to create $NESTED (host DISPLAY=$HOST_DISPLAY?)" >&2
		[ -n "$XEPHYR_PID" ] && kill "$XEPHYR_PID" 2>/dev/null || true
		exit 1
	fi
fi

export DISPLAY="$NESTED"
unset WAYLAND_DISPLAY
export XDG_SESSION_TYPE=x11
export PATH="/usr/local/bin:${HOME}/.local/bin:${PATH:-}"
export KIOSK_GEOM="$GEOM"

unset WAYLAND_DISPLAY
unset WAYLAND_SOCKET
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export WINIT_UNIX_BACKEND=x11

echo "设置Display完毕"
echo "→ $SESSION_SH $*  (DISPLAY=$NESTED KIOSK_GEOM=$KIOSK_GEOM)"
echo "先点 Xephyr 窗口再按键。"

trap '
	if [ -n "$XEPHYR_PID" ] && kill -0 "$XEPHYR_PID" 2>/dev/null; then
		kill "$XEPHYR_PID" 2>/dev/null || true
	fi
' EXIT INT TERM

"$SESSION_SH" "$@"
