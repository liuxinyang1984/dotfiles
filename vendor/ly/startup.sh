#!/bin/sh
# Ly 启动前（仍占 TTY）：console 字体 + 16 色调色板
# Linux VT 无真彩，0xRRGGBB 会并到 16 色；要把「黄」槽改成棕金才看得见差别。
# 由 x11:ly install 安装到 /etc/ly/startup.sh

FONT_NAME="${LY_FONT:-ter-132b}"

# 当前 Ly 所在 TTY（ly@.service 的 %i，如 tty1）
_tty=""
if [ -n "${TTY:-}" ]; then
	_tty=$TTY
elif [ -r /proc/self/fd/0 ]; then
	_tty=$(readlink /proc/self/fd/0 2>/dev/null | sed 's|^/dev/||') || true
fi

if [ -n "$_tty" ] && [ -c "/dev/$_tty" ]; then
	setfont -C "/dev/$_tty" "$FONT_NAME" 2>/dev/null || setfont "$FONT_NAME" 2>/dev/null || true
fi

# 16 色调色板：主题见 /etc/ly/theme 或 LY_THEME（amber|green）
if [ "${TERM:-}" = "linux" ] || [ -n "$_tty" ]; then
	_theme="${LY_THEME:-}"
	[ -z "$_theme" ] && [ -r /etc/ly/theme ] && _theme=$(cat /etc/ly/theme)
	_theme=$(printf '%s' "${_theme:-amber}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

	BLACK="000000"
	DARK_RED="AA0000"
	DARK_BLUE="0000AA"
	DARK_MAGENTA="AA00AA"
	DARK_CYAN="00AAAA"
	LIGHT_GRAY="AAAAAA"
	DARK_GRAY="555555"
	RED="FF5555"
	BLUE="5555FF"
	MAGENTA="FF55FF"
	CYAN="55FFFF"
	WHITE="FFFFFF"

	case "$_theme" in
	green)
		# Matrix 雨绿（测完改回 amber）
		DARK_GREEN="008F11"
		DARK_YELLOW="00FF41"
		GREEN="39FF14"
		YELLOW="00FF41"
		;;
	*)
		# 棕金（默认，见 crt-amber.colors）
		DARK_GREEN="8B6914"
		DARK_YELLOW="AE8010"
		GREEN="C09020"
		YELLOW="C09020"
		;;
	esac
	unset _theme

	COLORS="$BLACK $DARK_RED $DARK_GREEN $DARK_YELLOW $DARK_BLUE $DARK_MAGENTA $DARK_CYAN $LIGHT_GRAY $DARK_GRAY $RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN $WHITE"
	i=0
	while [ "$i" -lt 16 ]; do
		# shellcheck disable=SC2086
		printf '\033]P%x%s' "$i" "$(echo $COLORS | cut -d ' ' -f$((i + 1)))"
		i=$((i + 1))
	done
	# 硬件光标藏起（?1c）；Ly 用主题色画软方块光标
	printf '\033[?1c'
	clear
fi
