#!/bin/sh
# Ly：TUI 显示管理器 + Terminus console 字体
#   ./install.sh              # Arch：装 ly/terminus-font，FONT=ter-132b，enable ly@ttyN
#   ./install.sh --no-packages  # 不跑 pacman，只改配置/单元
#   ./install.sh --no-enable    # 不 enable systemd
# 父仓: ./install.sh x11:ly
#
# 会话 .desktop 由各 desktop 模块自己装到 /usr/share/xsessions。
# 本模块额外提供 TTY 会话 tmux → /etc/ly/custom-sessions（可选）。
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
DO_PKGS=1
DO_ENABLE=1
FONT_NAME="${LY_FONT:-ter-132b}"
LY_INI="${LY_INI:-/etc/ly/config.ini}"
LY_CUSTOM="${LY_CUSTOM:-/etc/ly/custom-sessions}"

usage() {
	cat <<'EOF'
用法: ./install.sh [--no-packages] [--no-enable]

  Arch: pacman -S ly terminus-font
  /etc/vconsole.conf → FONT=ter-132b（即口语 ter-v32b）
  systemctl enable ly@ttyN（N 读自 /etc/ly/config.ini，默认 2）
  可选: tmux.desktop → /etc/ly/custom-sessions/

  dwm/kiosk/fvwm 的 xsessions 由对应 desktop:* 安装时写入。
EOF
}

for arg in "$@"; do
	case "$arg" in
	--no-packages) DO_PKGS=0 ;;
	--no-enable) DO_ENABLE=0 ;;
	-h|--help) usage; exit 0 ;;
	*) echo "未知参数: $arg" >&2; usage >&2; exit 1 ;;
	esac
done

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
fi

TTY_NUM=2
if [ -f "$LY_INI" ]; then
	n=$(grep -E '^[[:space:]]*tty[[:space:]]*=' "$LY_INI" | head -1 | sed 's/.*=[[:space:]]*//' || true)
	[ -n "${n:-}" ] && TTY_NUM=$n
fi
LY_UNIT="ly@tty${TTY_NUM}.service"

if [ "$DO_ENABLE" = 1 ]; then
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
