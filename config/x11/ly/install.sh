#!/bin/sh
# Ly：TUI 显示管理器 + Terminus console 字体
#   ./install.sh              # Arch：装 ly/terminus-font，FONT=ter-132b，CRT 黄，enable ly@ttyN
#   ./install.sh --no-packages  # 不跑 pacman，只改配置/单元
#   ./install.sh --no-enable    # 不 enable systemd
#   ./install.sh --no-colors    # 不改 /etc/ly/config.ini 颜色
# 父仓: ./install.sh x11:ly
# 颜色文件: crt-amber.colors（LY_COLORS=path 可换）；LY_SKIP_COLORS=1 等同 --no-colors
#
# 会话 .desktop 由各 desktop 模块自己装到 /usr/share/xsessions。
# 本模块额外提供 TTY 会话 tmux → /etc/ly/custom-sessions（可选）。
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
DO_PKGS=1
DO_ENABLE=1
DO_COLORS=1
FONT_NAME="${LY_FONT:-ter-132b}"
LY_INI="${LY_INI:-/etc/ly/config.ini}"
LY_CUSTOM="${LY_CUSTOM:-/etc/ly/custom-sessions}"
LY_COLORS_FILE="${LY_COLORS:-$ROOT/crt-amber.colors}"

usage() {
	cat <<'EOF'
用法: ./install.sh [--no-packages] [--no-enable] [--no-colors]

  Arch: pacman -S ly terminus-font
  /etc/vconsole.conf → FONT=ter-132b（口语 ter-v32b），并 setfont 到 tty1–6
  /etc/ly/startup.sh → 16 色调色板（黄槽改棕金；TTY 无真彩）
  /etc/ly/config.ini → tty=1、配色、start_cmd
  systemctl enable ly@tty1（并 disable 旧 ly@tty2）
  可选: tmux.desktop → /etc/ly/custom-sessions/

  dwm/kiosk/fvwm 的 xsessions 由对应 desktop:* 安装时写入。
EOF
}

for arg in "$@"; do
	case "$arg" in
	--no-packages) DO_PKGS=0 ;;
	--no-enable) DO_ENABLE=0 ;;
	--no-colors) DO_COLORS=0 ;;
	-h|--help) usage; exit 0 ;;
	*) echo "未知参数: $arg" >&2; usage >&2; exit 1 ;;
	esac
done
[ "${LY_SKIP_COLORS:-0}" = 1 ] && DO_COLORS=0

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

if [ "$DO_PKGS" = 1 ]; then
	if is_arch; then
		echo "pacman: ly terminus-font"
		run_root pacman -S --needed --noconfirm ly terminus-font
		# tmux 会话可选
		if ! command -v tmux >/dev/null 2>&1; then
			echo "pacman: tmux（Ly custom 会话）"
			run_root pacman -S --needed --noconfirm tmux || true
		fi
	else
		echo "非 Arch：请自行安装 ly / terminus-font（或等价 console 字体）" >&2
	fi
fi

LY_BIN=/usr/bin/ly-dm
if [ ! -x "$LY_BIN" ]; then
	echo "未找到 $LY_BIN；跳过 Ly 配置（可先装 ly）" >&2
	exit 0
fi

if [ ! -f "/usr/share/kbd/consolefonts/${FONT_NAME}.psf.gz" ] && \
	[ ! -f "/usr/share/kbd/consolefonts/${FONT_NAME}.psfu.gz" ]; then
	echo "警告: 无 console 字体 ${FONT_NAME}（terminus-font 是否已装？）" >&2
else
	echo "vconsole FONT=${FONT_NAME}"
	if [ -f /etc/vconsole.conf ] && grep -qE '^[[:space:]]*FONT=' /etc/vconsole.conf; then
		run_root sed -i "s/^[[:space:]]*FONT=.*/FONT=${FONT_NAME}/" /etc/vconsole.conf
	else
		printf '\nFONT=%s\n' "$FONT_NAME" | run_root tee -a /etc/vconsole.conf >/dev/null
	fi
	# 立刻打到所有文本 VT（不只 Ly 那一路）
	if [ -f "$ROOT/setfont-all.sh" ]; then
		chmod +x "$ROOT/setfont-all.sh"
		run_root env LY_FONT="$FONT_NAME" LY_TTY_MAX="${LY_TTY_MAX:-6}" \
			sh "$ROOT/setfont-all.sh" "$FONT_NAME" || true
	fi
	run_root systemctl restart systemd-vconsole-setup.service 2>/dev/null || true
fi

# Ly 启动钩子：字体 + 16 色黄槽→棕金（TTY 真彩会并到 16 色，只改 ini 往往看不出差别）
if [ -f "$ROOT/startup.sh" ]; then
	chmod +x "$ROOT/startup.sh"
	run_root install -m755 "$ROOT/startup.sh" /etc/ly/startup.sh
	echo "startup.sh → /etc/ly/startup.sh（console 调色板）"
fi

# 默认 tty1（LY_TTY=N 覆盖）；写入 ini，不再跟发行版默认的 tty=2
TTY_NUM="${LY_TTY:-1}"
LY_UNIT="ly@tty${TTY_NUM}.service"

# 按 key upsert 到 config.ini（不整文件覆盖）
ly_upsert_ini() {
	_ini=$1
	_key=$2
	_val=$3
	_tmp=$(mktemp)
	if [ -f "$_ini" ] && grep -qE "^[[:space:]]*${_key}[[:space:]]*=" "$_ini"; then
		sed -E "s|^[[:space:]]*${_key}[[:space:]]*=.*|${_key} = ${_val}|" "$_ini" >"$_tmp"
	elif [ -f "$_ini" ]; then
		cp "$_ini" "$_tmp"
		printf '%s = %s\n' "$_key" "$_val" >>"$_tmp"
	else
		printf '%s = %s\n' "$_key" "$_val" >"$_tmp"
	fi
	run_root install -m644 "$_tmp" "$_ini"
	rm -f "$_tmp"
}

if [ ! -f "$LY_INI" ] && [ -f /etc/ly/config.ini.example ]; then
	run_root install -m644 /etc/ly/config.ini.example "$LY_INI"
fi
if [ -f "$LY_INI" ]; then
	echo "Ly tty = ${TTY_NUM}"
	ly_upsert_ini "$LY_INI" tty "$TTY_NUM"
	ly_upsert_ini "$LY_INI" start_cmd "/etc/ly/startup.sh"
fi

if [ "$DO_COLORS" = 1 ]; then
	if [ ! -f "$LY_COLORS_FILE" ]; then
		echo "警告: 无颜色文件 $LY_COLORS_FILE，跳过配色" >&2
	elif [ ! -f "$LY_INI" ]; then
		echo "警告: 无 $LY_INI，跳过配色（先装 ly）" >&2
	else
		echo "Ly 配色/样式 ← $(basename "$LY_COLORS_FILE")（棕金 + matrix + 镂空框）"
		# 去掉注释空行，按 key=val 写入
		while IFS= read -r _line || [ -n "$_line" ]; do
			_line=$(printf '%s' "$_line" | sed 's/#.*//;s/^[[:space:]]*//;s/[[:space:]]*$//')
			[ -z "$_line" ] && continue
			_key=$(printf '%s' "$_line" | cut -d= -f1 | sed 's/[[:space:]]*$//')
			_val=$(printf '%s' "$_line" | cut -d= -f2- | sed 's/^[[:space:]]*//')
			[ -n "$_key" ] && [ -n "$_val" ] || continue
			ly_upsert_ini "$LY_INI" "$_key" "$_val"
		done <"$LY_COLORS_FILE"
	fi
fi

if [ "$DO_ENABLE" = 1 ]; then
	# 从旧默认 tty2 迁走，避免双实例
	if [ "$TTY_NUM" != 2 ]; then
		run_root systemctl disable --now "ly@tty2.service" 2>/dev/null || true
	fi
	if [ "$TTY_NUM" != 1 ]; then
		run_root systemctl disable --now "ly@tty1.service" 2>/dev/null || true
	fi
	echo "enable $LY_UNIT"
	run_root systemctl enable "$LY_UNIT"
fi

# tmux → Ly custom-sessions（Terminal=true，不宜放 xsessions）
if [ -f "$ROOT/sessions/tmux.desktop" ] && command -v tmux >/dev/null 2>&1; then
	run_root mkdir -p "$LY_CUSTOM"
	run_root cp -f "$ROOT/sessions/tmux.desktop" "$LY_CUSTOM/tmux.desktop"
	run_root chmod 644 "$LY_CUSTOM/tmux.desktop"
	echo "custom-sessions ← tmux.desktop"
fi

echo "x11:ly 完成。字体 ${FONT_NAME}；单元 $LY_UNIT"
echo "  会话 xsessions：装 desktop:suckless / kiosk / fvwm 时自动写入"
echo "  立刻改字并亮 Ly: setfont -C /dev/tty${TTY_NUM} ${FONT_NAME}; systemctl restart ${LY_UNIT}"
