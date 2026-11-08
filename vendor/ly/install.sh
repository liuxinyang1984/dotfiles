#!/bin/sh
# Ly CRT：本仓自包含（已改源码 + 主题/启动钩子）
#   ./install.sh                 # 依赖 + zig 编译 ly-dm + 配色 + enable ly@ttyN
#   ./install.sh --no-packages
#   ./install.sh --no-enable
#   ./install.sh --no-colors
#   ./install.sh --no-build      # 不编译（只要已有 /usr/local/bin/ly-dm）
# 父仓: ./install.sh x11:ly
# 主题: ./theme.sh amber|green
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
DO_PKGS=1
DO_ENABLE=1
DO_COLORS=1
DO_BUILD=1
FONT_NAME="${LY_FONT:-ter-132b}"
LY_INI="${LY_INI:-/etc/ly/config.ini}"
LY_CUSTOM="${LY_CUSTOM:-/etc/ly/custom-sessions}"
LY_COLORS_FILE="${LY_COLORS:-$ROOT/crt-current.colors}"
DST="${LY_DM_DST:-/usr/local/bin/ly-dm}"
[ -e "$LY_COLORS_FILE" ] || LY_COLORS_FILE="$ROOT/crt-amber.colors"

usage() {
	cat <<'EOF'
用法: ./install.sh [--no-packages] [--no-enable] [--no-colors] [--no-build]

  从本仓源码 zig build → /usr/local/bin/ly-dm（不依赖发行版 ly 行为）
  Arch 可选: pacman 装 zig / terminus-font /（可选）ly 仅借 unit 模板
  Alpine 等: 需已有 zig≥0.17 与 console 字体；自行提供等价 unit
  配色: crt-current.colors；调色板: /etc/ly/theme（见 theme.sh）
  默认 enable ly@tty1（LY_TTY=N）；其它 ly@ttyN 只 disable 不 stop
EOF
}

for arg in "$@"; do
	case "$arg" in
	--no-packages) DO_PKGS=0 ;;
	--no-enable) DO_ENABLE=0 ;;
	--no-colors) DO_COLORS=0 ;;
	--no-build) DO_BUILD=0 ;;
	-h|--help) usage; exit 0 ;;
	*) echo "未知参数: $arg" >&2; usage >&2; exit 1 ;;
	esac
done
[ "${LY_SKIP_COLORS:-0}" = 1 ] && DO_COLORS=0
[ "${LY_SKIP_BUILD:-0}" = 1 ] && DO_BUILD=0

run_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	elif command -v doas >/dev/null 2>&1; then
		doas "$@"
	elif command -v sudo >/dev/null 2>&1; then
		sudo "$@"
	else
		echo "需要 root（doas/sudo）" >&2
		exit 1
	fi
}

is_arch() {
	[ -f /etc/arch-release ] || grep -qi arch /etc/os-release 2>/dev/null
}

is_alpine() {
	[ -f /etc/alpine-release ]
}

# --- 依赖 ---
if [ "$DO_PKGS" = 1 ]; then
	if is_arch; then
		echo "pacman: zig terminus-font"
		run_root pacman -S --needed --noconfirm --overwrite '*' zig terminus-font
		# 可选：官方 ly 提供 systemd unit / 示例 ini（二进制仍用我们编的）
		run_root pacman -S --needed --noconfirm ly || true
		if ! command -v tmux >/dev/null 2>&1; then
			run_root pacman -S --needed --noconfirm tmux || true
		fi
	elif is_alpine; then
		echo "apk: zig terminus-font（若仓库有）"
		run_root apk add --no-cache zig terminus-font tmux 2>/dev/null \
			|| echo "警告: apk 依赖未齐，请确保 zig≥0.17 与 console 字体可用" >&2
	else
		echo "请自行安装: zig≥0.17、terminus（或等价 console 字体）" >&2
	fi
fi

# --- 编译本仓源码 ---
build_ly() {
	if ! command -v zig >/dev/null 2>&1; then
		echo "未找到 zig" >&2
		return 1
	fi
	echo "zig $(zig version)；build -Doptimize=ReleaseSafe（$ROOT）"
	(
		cd "$ROOT"
		zig build -Doptimize=ReleaseSafe
	)
	BIN="$ROOT/zig-out/bin/ly"
	[ -x "$BIN" ] || { echo "缺少 $BIN" >&2; return 1; }
	run_root install -m755 "$BIN" "$DST"
	if command -v systemctl >/dev/null 2>&1; then
		run_root mkdir -p /etc/systemd/system/ly@.service.d
		run_root tee /etc/systemd/system/ly@.service.d/override.conf >/dev/null <<'UNIT'
[Service]
ExecStart=
ExecStart=/usr/local/bin/ly-dm
UNIT
		run_root systemctl daemon-reload
	fi
	echo "ok: $DST"
}

if [ "$DO_BUILD" = 1 ]; then
	build_ly || echo "警告: 编译失败" >&2
fi

if [ ! -x "$DST" ] && [ ! -x /usr/bin/ly-dm ]; then
	echo "未找到 ly-dm（$DST）；中止配置" >&2
	exit 1
fi

# --- 字体 ---
if [ ! -f "/usr/share/kbd/consolefonts/${FONT_NAME}.psf.gz" ] && \
	[ ! -f "/usr/share/kbd/consolefonts/${FONT_NAME}.psfu.gz" ]; then
	echo "警告: 无 console 字体 ${FONT_NAME}" >&2
else
	echo "vconsole FONT=${FONT_NAME}"
	if [ -f /etc/vconsole.conf ] && grep -qE '^[[:space:]]*FONT=' /etc/vconsole.conf; then
		run_root sed -i "s/^[[:space:]]*FONT=.*/FONT=${FONT_NAME}/" /etc/vconsole.conf
	else
		printf '\nFONT=%s\n' "$FONT_NAME" | run_root tee -a /etc/vconsole.conf >/dev/null
	fi
	if [ -f "$ROOT/setfont-all.sh" ]; then
		chmod +x "$ROOT/setfont-all.sh"
		run_root env LY_FONT="$FONT_NAME" LY_TTY_MAX="${LY_TTY_MAX:-6}" \
			sh "$ROOT/setfont-all.sh" "$FONT_NAME" || true
	fi
	run_root systemctl restart systemd-vconsole-setup.service 2>/dev/null || true
fi

run_root mkdir -p /etc/ly
if [ -f "$ROOT/startup.sh" ]; then
	chmod +x "$ROOT/startup.sh"
	run_root install -m755 "$ROOT/startup.sh" /etc/ly/startup.sh
	echo "startup.sh → /etc/ly/startup.sh"
fi
# 默认 theme 文件（与 crt-current 一致）
if [ ! -f /etc/ly/theme ]; then
	_th=amber
	if [ -L "$ROOT/crt-current.colors" ]; then
		_th=$(basename "$(readlink "$ROOT/crt-current.colors")" .colors)
		_th=${_th#crt-}
	fi
	printf '%s\n' "$_th" | run_root tee /etc/ly/theme >/dev/null
fi

TTY_NUM="${LY_TTY:-1}"
LY_UNIT="ly@tty${TTY_NUM}.service"

ly_upsert_ini() {
	_ini=$1
	_key=$2
	_val=$3
	_tmp=$(mktemp)
	if command -v python3 >/dev/null 2>&1; then
		python3 - "$_ini" "$_key" "$_val" "$_tmp" <<'PY'
import re, sys
path, key, val, out = sys.argv[1:5]
try:
	text = open(path, encoding="utf-8").read()
except FileNotFoundError:
	text = ""
line = f"{key} = {val}"
pat = re.compile(rf"^[ \t]*{re.escape(key)}[ \t]*=.*$", re.M)
if pat.search(text):
	text = pat.sub(line, text, count=1)
else:
	if text and not text.endswith("\n"):
		text += "\n"
	text += line + "\n"
open(out, "w", encoding="utf-8").write(text)
PY
	else
		_esc=$(printf '%s' "$_val" | sed 's/[&\\]/\\&/g')
		if [ -f "$_ini" ] && grep -qE "^[[:space:]]*${_key}[[:space:]]*=" "$_ini"; then
			sed -E "s|^[[:space:]]*${_key}[[:space:]]*=.*|${_key} = ${_esc}|" "$_ini" >"$_tmp"
		elif [ -f "$_ini" ]; then
			cp "$_ini" "$_tmp"
			printf '%s = %s\n' "$_key" "$_val" >>"$_tmp"
		else
			printf '%s = %s\n' "$_key" "$_val" >"$_tmp"
		fi
	fi
	run_root install -m644 "$_tmp" "$_ini"
	rm -f "$_tmp"
}

if [ ! -f "$LY_INI" ] && [ -f /etc/ly/config.ini.example ]; then
	run_root install -m644 /etc/ly/config.ini.example "$LY_INI"
fi
# 无官方示例时写一份最小 ini
if [ ! -f "$LY_INI" ]; then
	printf '# ly CRT\ntty = %s\nstart_cmd = /etc/ly/startup.sh\n' "$TTY_NUM" \
		| run_root tee "$LY_INI" >/dev/null
fi

echo "Ly tty = ${TTY_NUM}"
ly_upsert_ini "$LY_INI" tty "$TTY_NUM"
ly_upsert_ini "$LY_INI" start_cmd "/etc/ly/startup.sh"

if [ "$DO_COLORS" = 1 ]; then
	if [ ! -f "$LY_COLORS_FILE" ]; then
		echo "警告: 无 $LY_COLORS_FILE" >&2
	else
		echo "Ly 配色 ← $(basename "$(readlink -f "$LY_COLORS_FILE" 2>/dev/null || echo "$LY_COLORS_FILE")")"
		while IFS= read -r _line || [ -n "$_line" ]; do
			case "$_line" in
			\#*|"") continue ;;
			esac
			_line=$(printf '%s' "$_line" | sed 's/[[:space:]]*#.*$//')
			[ -z "$_line" ] && continue
			_key=$(printf '%s' "$_line" | cut -d= -f1 | sed 's/[[:space:]]*$//')
			_val=$(printf '%s' "$_line" | cut -d= -f2- | sed 's/^ //')
			[ -n "$_key" ] || continue
			ly_upsert_ini "$LY_INI" "$_key" "$_val"
		done <"$LY_COLORS_FILE"
	fi
fi

if [ "$DO_ENABLE" = 1 ] && command -v systemctl >/dev/null 2>&1; then
	for _n in 1 2 3 4 5 6; do
		[ "$_n" = "$TTY_NUM" ] && continue
		run_root systemctl disable "ly@tty${_n}.service" 2>/dev/null || true
	done
	echo "enable $LY_UNIT"
	run_root systemctl enable "$LY_UNIT"
	run_root systemctl restart "$LY_UNIT" 2>/dev/null || run_root systemctl start "$LY_UNIT" || true
fi

if [ -f "$ROOT/lang/unix.ini" ]; then
	run_root mkdir -p /etc/ly/lang
	run_root install -m644 "$ROOT/lang/unix.ini" /etc/ly/lang/unix.ini
	echo "lang ← unix.ini"
fi

if [ -f "$ROOT/sessions/tmux.desktop" ] && command -v tmux >/dev/null 2>&1; then
	run_root mkdir -p "$LY_CUSTOM"
	run_root cp -f "$ROOT/sessions/tmux.desktop" "$LY_CUSTOM/tmux.desktop"
	run_root chmod 644 "$LY_CUSTOM/tmux.desktop"
	echo "custom-sessions ← tmux.desktop"
fi

echo "vendor/ly 完成。字体 ${FONT_NAME}；二进制 $DST；单元 ${LY_UNIT:-（无 systemd）}"
echo "  主题: ./theme.sh amber|green"
echo "  测 Ly: setfont -C /dev/tty${TTY_NUM} ${FONT_NAME}; systemctl restart ${LY_UNIT:-ly@tty1}"
