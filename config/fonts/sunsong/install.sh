#!/bin/sh
# SunSong — Solaris 7 点阵宋 + Lucida 配对（仓内 PCF，无下载）
#   ./install.sh              # 默认：打印用法
#   ./install.sh --all / -a   # 安装字体 + 族级 render + 设为默认
#   ./install.sh --font       # 仅安装 PCF → ~/.local/share/fonts/SunSong
#   ./install.sh --render     # 仅链接 10-sunsong-render.conf
#   ./install.sh --default    # 仅启用 99-default-sunsong（并去掉其它 99-default-*）
# 父仓: ./install.sh fonts:sunsong [--all|…]
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$ROOT/../../.." && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

SUNSONG_FONT_DIR="${SUNSONG_FONT_DIR:-$XDG_DATA_HOME/fonts/SunSong}"
FILES_DIR="$ROOT/files"

FC_DIR="$XDG_CONFIG_HOME/fontconfig"
FC_CONFD="$FC_DIR/conf.d"
RENDER_SRC="$ROOT/conf/10-sunsong-render.conf"
DEFAULT_SRC="$ROOT/conf/99-default-sunsong.conf"
RENDER_DEST="$FC_CONFD/10-sunsong-render.conf"
DEFAULT_DEST="$FC_CONFD/99-default-sunsong.conf"
FRAMEWORK_SRC="$DOTFILES_ROOT/config/fonts/fonts.conf"
FRAMEWORK_DEST="$FC_DIR/fonts.conf"

DO_FONT=0
DO_RENDER=0
DO_DEFAULT=0

info() { printf '\033[32m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[31m[ERROR]\033[0m %s\n' "$1"; }

usage() {
	cat <<EOF
用法: ./install.sh [选项]

  （无参 / -h / --help）  打印本说明

  -a, --all       全部安装：字体 + 族级 render + 设为默认（99-default）
  --font          仅安装仓内 OTB（SFNT 点阵）到 \$SUNSONG_FONT_DIR
  --render        仅链接 10-sunsong-render.conf（点阵关 AA、禁缩放）
  --default       仅启用 99-default-sunsong.conf（互斥其它 99-default-*）

环境变量:
  SUNSONG_FONT_DIR  字体目录（默认 \$XDG_DATA_HOME/fonts/SunSong）

说明:
  蓝本为 Solaris 7 zh：界面 Lucida Sans + Song；终端 LucidaTypewriter + Song。
  文件为 OTB（由 PCF 转换）：传统 PCF 会被 GTK/Pango 忽略并回退 Noto。
  终端 monospace 按 Sol7 FIXEDWIDTH 分档（LT@14+Song@16 / song-roman 同档）。
  详见 SOURCE.txt 与 10-sunsong-render.conf。

父仓:
  ./install.sh fonts:sunsong --all
EOF
}

link_conf() {
	_src="$1"
	_dest="$2"
	_name="$3"
	[ -f "$_src" ] || { error "缺少 $_src"; exit 1; }
	mkdir -p "$(dirname "$_dest")"
	if [ -L "$_dest" ] || [ ! -e "$_dest" ]; then
		ln -sfn "$_src" "$_dest"
		info "$_name → $_dest"
	elif [ -e "$_dest" ]; then
		warn "$_dest 已存在且非符号链接，备份后替换"
		mv "$_dest" "${_dest}.backup.$(date +%Y%m%d%H%M%S)"
		ln -sfn "$_src" "$_dest"
		info "$_name → $_dest"
	fi
}

ensure_framework() {
	mkdir -p "$FC_CONFD"
	[ -f "$FRAMEWORK_SRC" ] || {
		warn "无框架 $FRAMEWORK_SRC，跳过 fonts.conf"
		return 0
	}
	if [ -L "$FRAMEWORK_DEST" ]; then
		_cur="$(readlink "$FRAMEWORK_DEST")"
		if [ "$_cur" = "$FRAMEWORK_SRC" ]; then
			info "fontconfig 框架已链接"
			return 0
		fi
	fi
	if [ -f "$FRAMEWORK_DEST" ] && [ ! -L "$FRAMEWORK_DEST" ]; then
		if grep -q 'managed-by: dotfiles' "$FRAMEWORK_DEST" 2>/dev/null; then
			:
		else
			warn "已有陌生 fonts.conf（无 managed-by: dotfiles），不覆盖；仅写入 conf.d"
			return 0
		fi
	fi
	if [ -e "$FRAMEWORK_DEST" ] && [ ! -L "$FRAMEWORK_DEST" ]; then
		mv "$FRAMEWORK_DEST" "${FRAMEWORK_DEST}.backup.$(date +%Y%m%d%H%M%S)"
	fi
	ln -sfn "$FRAMEWORK_SRC" "$FRAMEWORK_DEST"
	info "fontconfig 框架 → $FRAMEWORK_DEST"
}

install_font() {
	[ -d "$FILES_DIR" ] || { error "缺少 $FILES_DIR"; exit 1; }
	_n="$(find "$FILES_DIR" -maxdepth 1 -name '*.otb' | wc -l)"
	[ "$_n" -gt 0 ] || { error "$FILES_DIR 下没有 .otb"; exit 1; }

	mkdir -p "$SUNSONG_FONT_DIR"
	# 清掉旧 PCF，同步仓内 OTB（SFNT 点阵，GTK/Pango 可用）
	find "$SUNSONG_FONT_DIR" -maxdepth 1 \( -name '*.pcf' -o -name '*.otb' \) -delete 2>/dev/null || true
	find "$FILES_DIR" -maxdepth 1 -name '*.otb' -exec cp -f {} "$SUNSONG_FONT_DIR/" \;
	info "已安装 $_n 个 OTB → $SUNSONG_FONT_DIR"
	# 仓内 OTB 已含唯一 PS name；若有人用手改过，仍以 files/ 为准

	if command -v fc-cache >/dev/null 2>&1; then
		fc-cache -f "$SUNSONG_FONT_DIR"
	else
		warn "没有 fc-cache，跳过刷新"
	fi

	if command -v fc-list >/dev/null 2>&1; then
		if fc-list : family | grep -Fxq 'SunSong'; then
			info "fc-list 可见: SunSong"
		else
			warn "fc-list 未见 SunSong（可再跑 fc-cache -f）"
		fi
		if fc-list : family | grep -Fxq 'LucidaTypewriter'; then
			info "fc-list 可见: LucidaTypewriter"
		else
			warn "fc-list 未见 LucidaTypewriter"
		fi
	fi
}

install_render() {
	ensure_framework
	link_conf "$RENDER_SRC" "$RENDER_DEST" "10-sunsong-render"
}

clear_other_defaults() {
	[ -d "$FC_CONFD" ] || return 0
	for f in "$FC_CONFD"/99-default-*.conf; do
		[ -e "$f" ] || continue
		case "$f" in
		*/99-default-sunsong.conf) continue ;;
		esac
		if [ -L "$f" ]; then
			_t="$(readlink "$f")"
			case "$_t" in
			*/config/fonts/*/conf/99-default-*.conf|"$DOTFILES_ROOT"/config/fonts/*/conf/99-default-*.conf)
				rm -f "$f"
				info "已移除其它默认: $f"
				;;
			esac
		fi
	done
}

install_default() {
	ensure_framework
	clear_other_defaults
	link_conf "$DEFAULT_SRC" "$DEFAULT_DEST" "99-default-sunsong"
}

# --- 参数 ---
if [ $# -eq 0 ]; then
	usage
	exit 0
fi

for arg in "$@"; do
	case "$arg" in
	-h|--help)
		usage
		exit 0
		;;
	-a|--all)
		DO_FONT=1
		DO_RENDER=1
		DO_DEFAULT=1
		;;
	--font) DO_FONT=1 ;;
	--render) DO_RENDER=1 ;;
	--default) DO_DEFAULT=1 ;;
	*)
		error "未知参数: $arg"
		usage >&2
		exit 1
		;;
	esac
done

[ -f "$RENDER_SRC" ] || { error "缺少 $RENDER_SRC"; exit 1; }
[ -f "$DEFAULT_SRC" ] || { error "缺少 $DEFAULT_SRC"; exit 1; }

[ "$DO_FONT" = 1 ] && install_font
[ "$DO_RENDER" = 1 ] && install_render
[ "$DO_DEFAULT" = 1 ] && install_default

if [ "$DO_RENDER" = 1 ] || [ "$DO_DEFAULT" = 1 ]; then
	if command -v fc-cache >/dev/null 2>&1; then
		fc-cache -f >/dev/null 2>&1 || true
	fi
fi

info "sunsong 完成"
