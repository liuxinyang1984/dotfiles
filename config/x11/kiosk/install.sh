#!/bin/sh
# 安装 kiosk 脚本 → ~/.local/bin
#   ./install.sh           # 默认 symlink（改仓即生效）
#   ./install.sh --copy    # 拷贝
#   ./install.sh --dev     # 同默认（兼容旧用法）
# 父仓: ./install.sh desktop:kiosk（KIOSK_COPY=1 → --copy）
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${KIOSK_BIN:-$HOME/.local/bin}"
MODE=link

usage() {
	cat <<'EOF'
用法: ./install.sh [--copy|--dev]

  安装 kiosk-session.sh、kiosk-xephyr.sh → ~/.local/bin
  （默认）  symlink 到本目录
  --copy    拷贝
  --dev     同默认（兼容）
  -h        帮助

参数即启动命令（任意）:
  kiosk-session.sh
  kiosk-session.sh alacritty
  kiosk-xephyr.sh foot
  startx kiosk -- qutebrowser
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

for f in kiosk-session.sh kiosk-xephyr.sh; do
	[ -f "$ROOT/$f" ] || { echo "缺少 $ROOT/$f" >&2; exit 1; }
	link_or_copy "$ROOT/$f" "$BIN_DIR/$f"
done

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
echo "  kiosk-session.sh [command...]"
echo "  kiosk-xephyr.sh  [command...]"
echo "多启动: ./install.sh x11:multistart（desktop:kiosk 结束时也会询问）"
