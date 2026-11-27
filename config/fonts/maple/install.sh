#!/bin/sh
# Maple Mono NL NF（Hinted TTF，无连字）
#   ./install.sh              # 默认：打印用法
#   ./install.sh --all / -a   # 下载字体 + 族级 render + 设为默认
#   ./install.sh --font       # 仅下载/安装字体文件
#   ./install.sh --render     # 仅链接 10-maple-render.conf
#   ./install.sh --default    # 仅启用 99-default-maple（并去掉其它 99-default-*）
# 父仓: ./install.sh fonts:maple [--all|…]
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$ROOT/../../.." && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

MAPLE_FAMILY="Maple Mono NL NF"
MAPLE_TAG="${MAPLE_TAG:-v8.0-beta.3}"
MAPLE_ZIP="MapleMonoNL-NF.zip"
MAPLE_URL="https://github.com/subframe7536/maple-font/releases/download/${MAPLE_TAG}/${MAPLE_ZIP}"
MAPLE_FONT_DIR="${MAPLE_FONT_DIR:-$XDG_DATA_HOME/fonts/MapleMonoNL-NF}"

FC_DIR="$XDG_CONFIG_HOME/fontconfig"
FC_CONFD="$FC_DIR/conf.d"
RENDER_SRC="$ROOT/conf/10-maple-render.conf"
DEFAULT_SRC="$ROOT/conf/99-default-maple.conf"
RENDER_DEST="$FC_CONFD/10-maple-render.conf"
DEFAULT_DEST="$FC_CONFD/99-default-maple.conf"
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
  --font          仅下载并安装 Maple Mono NL NF（Hinted TTF）
  --render        仅链接 10-maple-render.conf（本族 AA/hint）
  --default       仅启用 99-default-maple.conf（互斥其它 99-default-*）

环境变量:
  MAPLE_TAG       release 标签（默认 $MAPLE_TAG）
  MAPLE_FONT_DIR  字体安装目录（默认 \$XDG_DATA_HOME/fonts/MapleMonoNL-NF）

父仓:
  ./install.sh fonts:maple --all
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

maple_family_installed() {
	command -v fc-list >/dev/null 2>&1 || return 1
	fc-list : family | grep -Fxq "$MAPLE_FAMILY"
}

install_font() {
	if maple_family_installed; then
		info "已安装字体族: $MAPLE_FAMILY"
		return 0
	fi

	info "下载 Hinted TTF: $MAPLE_ZIP ($MAPLE_TAG)"
	command -v curl >/dev/null 2>&1 || { error "需要 curl"; exit 1; }
	command -v unzip >/dev/null 2>&1 || { error "需要 unzip"; exit 1; }

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
		warn "没有 fc-cache，跳过刷新"
	fi

	if maple_family_installed; then
		info "已安装 $MAPLE_FAMILY → $MAPLE_FONT_DIR"
	else
		warn "已解压到 $MAPLE_FONT_DIR，fc-list 仍看不到 $MAPLE_FAMILY（可再跑 fc-cache -f）"
	fi
}

install_render() {
	ensure_framework
	link_conf "$RENDER_SRC" "$RENDER_DEST" "10-maple-render"
}

clear_other_defaults() {
	[ -d "$FC_CONFD" ] || return 0
	for f in "$FC_CONFD"/99-default-*.conf; do
		[ -e "$f" ] || continue
		case "$f" in
		*/99-default-maple.conf) continue ;;
		esac
		# 只卸我们管理的（symlink 指向本仓 config/fonts/）
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

# sunsong 的 10-*-render 会改写 monospace → ttyp0/Song；Maple 作默认时须卸掉
disable_sunsong_render() {
	_ss="$FC_CONFD/10-sunsong-render.conf"
	[ -e "$_ss" ] || [ -L "$_ss" ] || return 0
	if [ -L "$_ss" ]; then
		_t="$(readlink "$_ss")"
		case "$_t" in
		*/config/fonts/sunsong/conf/10-sunsong-render.conf|"$DOTFILES_ROOT"/config/fonts/sunsong/conf/10-sunsong-render.conf)
			rm -f "$_ss"
			info "已停用 Sol7 render（否则会盖住 Maple monospace）: $_ss"
			;;
		esac
	fi
}

install_default() {
	ensure_framework
	clear_other_defaults
	disable_sunsong_render
	link_conf "$DEFAULT_SRC" "$DEFAULT_DEST" "99-default-maple"
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

info "maple 完成"
