#!/bin/sh
# 把会话 .desktop 装到 /usr/share/xsessions（Ly / 其它 DM 可读）
# 模板里用 @HOME@，安装时替换为真实 $HOME。
#   ./install-xsession.sh path/to/foo.desktop
# 环境：
#   LY_SKIP_XSESSION=1  跳过
#   XSESSIONS_DIR       默认 /usr/share/xsessions
set -e

if [ "${LY_SKIP_XSESSION:-0}" = 1 ]; then
	echo "LY_SKIP_XSESSION=1，跳过 xsessions" >&2
	exit 0
fi

src=$1
[ -n "$src" ] && [ -f "$src" ] || {
	echo "用法: $0 <file.desktop>" >&2
	exit 1
}

DEST_DIR="${XSESSIONS_DIR:-/usr/share/xsessions}"
base=$(basename "$src")
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

sed "s|@HOME@|${HOME}|g" "$src" >"$tmp"

run_root() {
	if [ "$(id -u)" -eq 0 ]; then
		"$@"
	elif command -v doas >/dev/null 2>&1; then
		doas "$@"
	elif command -v sudo >/dev/null 2>&1; then
		sudo "$@"
	else
		echo "写入 $DEST_DIR 需要 root（doas/sudo）" >&2
		exit 1
	fi
}

run_root mkdir -p "$DEST_DIR"
run_root cp -f "$tmp" "$DEST_DIR/$base"
run_root chmod 644 "$DEST_DIR/$base"
echo "xsessions ← $DEST_DIR/$base"
