#!/bin/sh
# X11 截图（dwm）：scrot → 存盘 + 剪贴板 + swappy 预览
# 对齐 Hyprland scripts/screenshot.sh 的 --now / --win / --area
# 安装: desktop:suckless → ~/.local/bin/screenshot-x11
set -e

if command -v xdg-user-dir >/dev/null 2>&1; then
	base="$(xdg-user-dir PICTURES)"
else
	base="${HOME}/Pictures"
fi
dir="${base}/Screenshots"
mkdir -p "$dir"
file="${dir}/Screenshot_$(date +%Y-%m-%d-%H-%M-%S).png"

notify() {
	command -v notify-send >/dev/null 2>&1 || return 0
	notify-send -u low -h string:x-canonical-private-synchronous:shot-notify Screenshot "$1"
}

shot() {
	# $1 = scrot extra args (may be empty); rest unused
	scrot "$@" "$file"
	if command -v xclip >/dev/null 2>&1; then
		xclip -selection clipboard -t image/png -i "$file"
		notify "Copied to clipboard."
	fi
	if command -v swappy >/dev/null 2>&1; then
		swappy -f "$file"
		if [ -e "$file" ]; then
			notify "Screenshot Saved."
		else
			notify "Screenshot Deleted."
		fi
	else
		notify "$file"
	fi
}

case "${1:---now}" in
--now|"")
	shot
	;;
--win)
	shot -u
	;;
--area)
	shot -s
	;;
-h|--help)
	echo "usage: screenshot-x11 [--now|--win|--area]" >&2
	exit 0
	;;
*)
	echo "unknown: $1 (use --now|--win|--area)" >&2
	exit 1
	;;
esac
