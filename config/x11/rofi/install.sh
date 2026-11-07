#!/bin/sh
# 安装 CDE 风格 rofi 主题 + rofi-drun → ~/.config/rofi、~/.local/bin
#   ./install.sh           # 默认 symlink
#   ./install.sh --copy
# 父仓: ./install.sh x11:rofi
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${ROFI_BIN:-$HOME/.local/bin}"
ROFI_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/rofi"
MODE=link

usage() {
	cat <<'EOF'
用法: ./install.sh [--copy]

  安装 cde.rasi / cde-dwm.rasi / cde-dwm-drun.rasi / cde-clip.rasi → ~/.config/rofi/
  安装 rofi-drun → ~/.local/bin（.desktop 启动；dwm Super+Space）
  安装 rofi-run  → ~/.local/bin（PATH 命令；dwm Super+r）
EOF
}

for arg in "$@"; do
	case "$arg" in
	--copy) MODE=copy ;;
	-h|--help) usage; exit 0 ;;
	*) echo "未知参数: $arg" >&2; usage >&2; exit 1 ;;
	esac
done

[ -f "$ROOT/cde.rasi" ] || { echo "缺少 $ROOT/cde.rasi" >&2; exit 1; }
[ -f "$ROOT/cde-dwm.rasi" ] || { echo "缺少 $ROOT/cde-dwm.rasi" >&2; exit 1; }
[ -f "$ROOT/cde-dwm-drun.rasi" ] || { echo "缺少 $ROOT/cde-dwm-drun.rasi" >&2; exit 1; }
[ -f "$ROOT/cde-clip.rasi" ] || { echo "缺少 $ROOT/cde-clip.rasi" >&2; exit 1; }
[ -f "$ROOT/rofi-drun" ] || { echo "缺少 $ROOT/rofi-drun" >&2; exit 1; }
[ -f "$ROOT/rofi-run" ] || { echo "缺少 $ROOT/rofi-run" >&2; exit 1; }
chmod +x "$ROOT/rofi-drun" "$ROOT/rofi-run"

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
		case "$dest" in
		*.rasi) ;;
		*) chmod +x "$dest" ;;
		esac
		echo "copy $dest"
	fi
}

mkdir -p "$ROFI_CONF" "$BIN_DIR"
link_or_copy "$ROOT/cde.rasi" "$ROFI_CONF/cde.rasi"
link_or_copy "$ROOT/cde-dwm.rasi" "$ROFI_CONF/cde-dwm.rasi"
link_or_copy "$ROOT/cde-dwm-drun.rasi" "$ROFI_CONF/cde-dwm-drun.rasi"
link_or_copy "$ROOT/cde-clip.rasi" "$ROFI_CONF/cde-clip.rasi"
link_or_copy "$ROOT/rofi-drun" "$BIN_DIR/rofi-drun"
link_or_copy "$ROOT/rofi-run" "$BIN_DIR/rofi-run"

if ! command -v rofi >/dev/null 2>&1; then
	echo "警告: PATH 中无 rofi（Arch: pacman -S rofi）" >&2
fi

echo "rofi CDE → $ROFI_CONF（mode=$MODE）; rofi-drun / rofi-run → $BIN_DIR"
