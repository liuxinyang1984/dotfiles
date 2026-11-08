#!/bin/sh
# 切换 Ly CRT 主题：改 crt-current.colors 软链 + /etc/ly/theme + 写回 config.ini
#   ./theme.sh              # 显示当前
#   ./theme.sh amber        # 棕金
#   ./theme.sh green        # Matrix 雨绿
#   ./theme.sh list
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
LINK="$ROOT/crt-current.colors"
THEME_FILE="${LY_THEME_FILE:-/etc/ly/theme}"
LY_INI="${LY_INI:-/etc/ly/config.ini}"

run_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	elif command -v doas >/dev/null 2>&1; then
		doas "$@"
	elif command -v sudo >/dev/null 2>&1; then
		sudo "$@"
	else
		echo "需要 root（doas/sudo）写 $THEME_FILE / 重启 ly" >&2
		exit 1
	fi
}

current_theme() {
	if [ -L "$LINK" ]; then
		_t=$(basename "$(readlink "$LINK")" .colors)
		_t=${_t#crt-}
		printf '%s\n' "$_t"
	elif [ -r "$THEME_FILE" ]; then
		tr -d '[:space:]' <"$THEME_FILE"
	else
		echo amber
	fi
}

usage() {
	cat <<EOF
用法: $0 [amber|green|list|status]

  amber  棕金（crt-amber.colors）
  green  Matrix 雨绿（crt-green.colors）
  list   可用主题
  status 当前主题（默认）

当前: $(current_theme)
软链: $LINK → $(readlink "$LINK" 2>/dev/null || echo '无')
EOF
}

apply_theme() {
	_name=$1
	_src="$ROOT/crt-${_name}.colors"
	[ -f "$_src" ] || { echo "无主题文件: $_src" >&2; exit 1; }

	ln -sfn "crt-${_name}.colors" "$LINK"
	echo "$_name" | run_root tee "$THEME_FILE" >/dev/null

	LY_SKIP_BUILD=1 LY_COLORS="$LINK" LY_THEME="$_name" \
		sh "$ROOT/install.sh" --no-packages --no-enable

	_tty=1
	if [ -f "$LY_INI" ]; then
		_tty=$(awk -F= '/^[[:space:]]*tty[[:space:]]*=/{gsub(/ /,"",$2); print $2; exit}' "$LY_INI")
		[ -n "$_tty" ] || _tty=1
	fi
	run_root systemctl try-restart "ly@tty${_tty}.service" 2>/dev/null \
		|| run_root systemctl restart "ly@tty${_tty}.service" 2>/dev/null \
		|| true
	echo "主题 → $_name（ly@tty${_tty}）"
}

case "${1:-status}" in
-h|--help) usage ;;
list)
	for f in "$ROOT"/crt-*.colors; do
		[ -e "$f" ] || continue
		b=$(basename "$f" .colors)
		case "$b" in crt-current) continue ;; esac
		echo "${b#crt-}"
	done
	;;
status) usage ;;
amber|green) apply_theme "$1" ;;
*)
	echo "未知主题: $1" >&2
	usage >&2
	exit 1
	;;
esac
