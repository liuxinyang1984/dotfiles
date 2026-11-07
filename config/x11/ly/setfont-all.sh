#!/bin/sh
# 把 console 字体打到所有文本 VT（默认 tty1–tty6，LY_TTY_MAX 可改）
# 用法: setfont-all.sh [字体名]   默认 ter-132b
FONT_NAME="${1:-${LY_FONT:-ter-132b}}"
MAX="${LY_TTY_MAX:-6}"
n=1
while [ "$n" -le "$MAX" ]; do
	if [ -c "/dev/tty$n" ]; then
		setfont -C "/dev/tty$n" "$FONT_NAME" 2>/dev/null || true
	fi
	n=$((n + 1))
done
echo "setfont $FONT_NAME → tty1–tty${MAX}"
