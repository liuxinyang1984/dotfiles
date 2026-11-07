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

# 16 色：索引 3=暗黄/棕，11=亮黄 —— 都改成棕金（默认 11 是刺眼 #FFFF55）
if [ "${TERM:-}" = "linux" ] || [ -n "$_tty" ]; then
	# 黑 / 红 / 绿 / 棕金 / 蓝 / 品红 / 青 / 浅灰
	# 深灰 / 亮红 / 亮绿 / 亮棕金 / 亮蓝 / 亮品红 / 亮青 / 白
	# 绿槽也改成棕金：matrix 雨滴在 16 色 TTY 上常走绿，否则仍是荧光绿
	BLACK="000000"
	DARK_RED="AA0000"
	DARK_GREEN="8B6914"
	DARK_YELLOW="AE8010"
	DARK_BLUE="0000AA"
	DARK_MAGENTA="AA00AA"
	DARK_CYAN="00AAAA"
	LIGHT_GRAY="AAAAAA"
	DARK_GRAY="555555"
	RED="FF5555"
	GREEN="C09020"
	YELLOW="C09020"
	BLUE="5555FF"
	MAGENTA="FF55FF"
	CYAN="55FFFF"
	WHITE="FFFFFF"

	COLORS="$BLACK $DARK_RED $DARK_GREEN $DARK_YELLOW $DARK_BLUE $DARK_MAGENTA $DARK_CYAN $LIGHT_GRAY $DARK_GRAY $RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN $WHITE"
	i=0
	while [ "$i" -lt 16 ]; do
		# shellcheck disable=SC2086
		printf '\033]P%x%s' "$i" "$(echo $COLORS | cut -d ' ' -f$((i + 1)))"
		i=$((i + 1))
	done
	# 光标：Linux 文本 VT 只有下划线/半块/全块，没有 I-beam 竖线；6=全块（最接近）
	printf '\033[?6c'
	clear
fi
