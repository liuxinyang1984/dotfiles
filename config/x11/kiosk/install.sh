#!/bin/sh
# 安装 kiosk-session / kiosk-xephyr.sh → ~/.local/bin
#   ./install.sh           # 默认 symlink
#   ./install.sh --copy
# 父仓: ./install.sh desktop:kiosk（KIOSK_COPY=1 → --copy）
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${KIOSK_BIN:-$HOME/.local/bin}"
MODE=link
X11_COMMON_SRC="$(cd "$ROOT/.." && pwd)/session-common.sh"
X11_COMMON_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/x11/session-common.sh"

usage() {
	cat <<'EOF'
用法: ./install.sh [--copy|--dev]

  安装 kiosk-session、kiosk-xephyr.sh → ~/.local/bin
  （默认）  symlink
  --copy    拷贝
  --dev     同默认（兼容）

  kiosk-session [command...]
  startx kiosk -- alacritty
EOF
}

for arg in "$@"; do
	case "$arg" in
	--copy) MODE=copy ;;
	--dev) MODE=link ;;
	-h|--help) usage; exit 0 ;;
	*)
		echo "未知参数: $arg" >&2
		usage >&2
		exit 1
		;;
	esac
done

link_or_copy() {
	src="$1"
	dest="$2"
	mkdir -p "$(dirname "$dest")"
	if [ "$MODE" = link ]; then
		ln -sfn "$src" "$dest"
		echo "symlink $dest → $src"
	else
		[ -L "$dest" ] && rm -f "$dest"
		cp -f "$src" "$dest"
		chmod +x "$dest"
		echo "copy $dest"
	fi
}

[ -f "$ROOT/kiosk-session" ] || { echo "缺少 $ROOT/kiosk-session" >&2; exit 1; }
[ -f "$ROOT/kiosk-xephyr.sh" ] || { echo "缺少 $ROOT/kiosk-xephyr.sh" >&2; exit 1; }
chmod +x "$ROOT/kiosk-session" "$ROOT/kiosk-xephyr.sh"

mkdir -p "$(dirname "$X11_COMMON_DEST")"
if [ -f "$X11_COMMON_SRC" ]; then
	ln -sfn "$X11_COMMON_SRC" "$X11_COMMON_DEST"
	echo "symlink $X11_COMMON_DEST → $X11_COMMON_SRC"
fi

link_or_copy "$ROOT/kiosk-session" "$BIN_DIR/kiosk-session"
link_or_copy "$ROOT/kiosk-xephyr.sh" "$BIN_DIR/kiosk-xephyr.sh"
# 兼容旧名
ln -sfn "$BIN_DIR/kiosk-session" "$BIN_DIR/kiosk-session.sh" 2>/dev/null || \
	link_or_copy "$ROOT/kiosk-session" "$BIN_DIR/kiosk-session.sh"

missing=""
for c in xdotool; do
	command -v "$c" >/dev/null 2>&1 || missing="$missing $c"
done
if ! command -v xrandr >/dev/null 2>&1 && ! command -v xdpyinfo >/dev/null 2>&1; then
	missing="$missing xrandr|xdpyinfo"
fi
[ -n "$missing" ] && echo "警告: 未在 PATH 找到:$missing" >&2
command -v Xephyr >/dev/null 2>&1 || \
	echo "提示: 无 Xephyr 时无法用 kiosk-xephyr.sh" >&2

echo "kiosk → $BIN_DIR（mode=$MODE）"
echo "  kiosk-session [command...]"
echo "  startx kiosk -- <cmd>"

_repo="$(cd "$ROOT/../../.." && pwd)"
_ly_xsess="$_repo/vendor/ly/install-xsession.sh"
if [ -f "$ROOT/kiosk.desktop" ] && [ -f "$_ly_xsess" ]; then
	chmod +x "$_ly_xsess"
	sh "$_ly_xsess" "$ROOT/kiosk.desktop" || echo "警告: xsessions 未写入（无 root 或已跳过）" >&2
fi
unset _ly_xsess _repo
