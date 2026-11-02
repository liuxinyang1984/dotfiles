#!/bin/sh
# 安装 dwm-session → ~/.local/bin
#   ./install.sh           # 默认 symlink
#   ./install.sh --copy
# 父仓: desktop:suckless 会调用
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${DWM_SESSION_BIN:-$HOME/.local/bin}"
MODE=link
X11_COMMON_SRC="$(cd "$ROOT/.." && pwd)/session-common.sh"
X11_COMMON_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/x11/session-common.sh"

usage() {
	cat <<'EOF'
用法: ./install.sh [--copy]

  安装 dwm-session → ~/.local/bin，并链 session-common.sh
  startx dwm  →  查找并执行 dwm-session
EOF
}

for arg in "$@"; do
	case "$arg" in
	--copy) MODE=copy ;;
	-h|--help) usage; exit 0 ;;
	*) echo "未知参数: $arg" >&2; usage >&2; exit 1 ;;
	esac
done

[ -f "$ROOT/dwm-session" ] || { echo "缺少 $ROOT/dwm-session" >&2; exit 1; }
chmod +x "$ROOT/dwm-session"

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

mkdir -p "$(dirname "$X11_COMMON_DEST")"
if [ -f "$X11_COMMON_SRC" ]; then
	ln -sfn "$X11_COMMON_SRC" "$X11_COMMON_DEST"
	echo "symlink $X11_COMMON_DEST → $X11_COMMON_SRC"
fi

link_or_copy "$ROOT/dwm-session" "$BIN_DIR/dwm-session"
echo "dwm-session → $BIN_DIR（mode=$MODE）; startx dwm"
