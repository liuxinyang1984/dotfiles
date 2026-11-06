#!/bin/sh
# x11.sh — 由 install.sh source；X 会话入口与 X 上配件（非某一种 desktop）
#
#   ./install.sh x11:multistart
#   ./install.sh x11:picom
#   ./install.sh x11:rofi
#
# 环境变量:
#   X11_DEFAULT_SESSION=<名>   写入 default-session；运行时执行 <名>-session
#   X11_MULTISTART=1|0         desktop 安装时强制装/跳过多启动（非交互）
#
# desktop 侧若只想复用函数：_X11_LIB_ONLY=1 . install/x11.sh

X11_MARKER='# dotfiles-x11-session:1'
X11_DEFAULT_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/x11/default-session"
X11_MULTISTART_DIR="$SCRIPT_DIR/config/x11/multistart"
X11_COMMON_SRC="$SCRIPT_DIR/config/x11/session-common.sh"
X11_COMMON_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/x11/session-common.sh"

x11_is_our_multistart() {
	[ -e "$HOME/.xinitrc" ] || return 1
	grep -q "^${X11_MARKER}$" "$HOME/.xinitrc" 2>/dev/null
}

x11_install_session_common() {
	[ -f "$X11_COMMON_SRC" ] || return 0
	mkdir -p "$(dirname "$X11_COMMON_DEST")"
	ln -sfn "$X11_COMMON_SRC" "$X11_COMMON_DEST"
	info "session-common → $X11_COMMON_DEST"
}

x11_set_default_session() {
	_sess="$1"
	# 任意简单名；不维护白名单（运行时查 <名>-session）
	if [ -z "$_sess" ] || printf '%s' "$_sess" | grep -q '[^a-zA-Z0-9_-]'; then
		error "默认会话名无效: ${_sess}（仅字母数字 _ -）"
		return 1
	fi
	mkdir -p "$(dirname "$X11_DEFAULT_FILE")"
	printf '%s\n' "$_sess" >"$X11_DEFAULT_FILE"
	info "默认会话 → $X11_DEFAULT_FILE ($_sess → ${_sess}-session)"
	if ! command -v "${_sess}-session" >/dev/null 2>&1 && \
		[ ! -x "$HOME/.local/bin/${_sess}-session" ]; then
		warn "尚未在 PATH 找到 ${_sess}-session（装完对应 desktop 即可）"
	fi
}

X11_LOCAL_BIN_MARKER='# dotfiles-x11-local-bin:1'

# 把 marker 块写入单个登录文件（幂等）
x11_append_local_bin_path_file() {
	_f=$1
	if [ -f "$_f" ] && grep -q "^${X11_LOCAL_BIN_MARKER}$" "$_f" 2>/dev/null; then
		return 0
	fi
	if [ -f "$_f" ]; then
		printf '\n' >>"$_f"
	fi
	{
		echo "$X11_LOCAL_BIN_MARKER"
		echo '# multistart：~/.local/bin/startx 与 *-session 须优先于 /usr/bin'
		echo 'case ":${PATH}:" in'
		echo '*:"$HOME/.local/bin":*) ;;'
		echo '*) export PATH="$HOME/.local/bin:$PATH" ;;'
		echo 'esac'
	} >>"$_f"
	info "PATH 优先 ~/.local/bin → $_f"
}

# 写进登录壳 PATH（否则 /usr/bin/startx 盖住包装，startx kiosk 失效）
x11_ensure_local_bin_path() {
	# POSIX 登录（Alpine ash / bash --login / 多数 getty）
	x11_append_local_bin_path_file "$HOME/.profile"
	# zsh 登录读 .zprofile，不读 .profile
	x11_append_local_bin_path_file "$HOME/.zprofile"
	case ":${PATH}:" in
	*:"$HOME/.local/bin":*) ;;
	*) export PATH="$HOME/.local/bin:$PATH" ;;
	esac
}

x11_warn_startx_path() {
	_ours="$HOME/.local/bin/startx"
	[ -x "$_ours" ] || return 0
	_resolved="$(command -v startx 2>/dev/null || true)"
	if [ "$_resolved" != "$_ours" ]; then
		warn "PATH 里 startx 不是 ~/.local/bin/startx（当前: ${_resolved:-无}）"
		warn "新开登录壳后再试 which startx；或显式: ~/.local/bin/startx"
	fi
}

install_x11_multistart() {
	_xinitrc="$X11_MULTISTART_DIR/xinitrc"
	_startx="$X11_MULTISTART_DIR/startx"
	if [ ! -f "$_xinitrc" ] || [ ! -f "$_startx" ]; then
		error "缺少 multistart 文件: $X11_MULTISTART_DIR"
		exit 1
	fi

	safe_link "$_xinitrc" "$HOME/.xinitrc" "multistart xinitrc"
	mkdir -p "$HOME/.local/bin"
	ln -sfn "$_startx" "$HOME/.local/bin/startx"
	info "startx 包装 → $HOME/.local/bin/startx"
	x11_install_session_common
	x11_ensure_local_bin_path

	if [ -n "${X11_DEFAULT_SESSION:-}" ]; then
		x11_set_default_session "$X11_DEFAULT_SESSION" || exit 1
	fi

	x11_warn_startx_path
	info "multistart 完成。startx <名> → 执行 <名>-session（须已安装）"
}

install_x11_picom() {
	ensure_submodule vendor/picom
	dest="$SCRIPT_DIR/vendor/picom"
	inst="$dest/install.sh"
	if [ ! -f "$inst" ]; then
		error "vendor/picom 缺少 install.sh"
		exit 1
	fi
	info "调用 vendor/picom/install.sh${INSTALL_ARGS:+ ← $INSTALL_ARGS}"
	set --
	[ "${PICOM_USER:-}" = "1" ] && set -- "$@" --user
	[ "${PICOM_NO_CONFIG:-}" = "1" ] || set -- "$@" --config
	# shellcheck disable=SC2086
	[ -n "${INSTALL_ARGS:-}" ] && set -- "$@" $INSTALL_ARGS
	sh "$inst" "$@"
	info "picom 完成。dwm（multistart）会话会自动起；也可手动: picom --experimental-backends -b"
}

# desktop:* 装完后调用；$1 = 会话名（将对应 <名>-session）
x11_offer_multistart_for_desktop() {
	_want="$1"
	if [ -z "$_want" ] || printf '%s' "$_want" | grep -q '[^a-zA-Z0-9_-]'; then
		error "x11_offer_multistart_for_desktop: 无效会话名 $_want"
		return 1
	fi
	x11_install_session_common

	# 非交互覆盖
	case "${X11_MULTISTART:-}" in
	0)
		info "X11_MULTISTART=0，跳过多启动"
		return 0
		;;
	1)
		install_x11_multistart
		x11_set_default_session "${X11_DEFAULT_SESSION:-$_want}" || return 1
		return 0
		;;
	esac

	if x11_is_our_multistart; then
		info "已是本仓多启动 xinitrc，不动入口"
		x11_ensure_local_bin_path
		x11_warn_startx_path
		if [ -t 0 ]; then
			printf "是否将默认会话写成 %s？[y/N] " "$_want"
			read -r _reply || _reply=
			case "$_reply" in
			[yY]|[yY][eE][sS])
				x11_set_default_session "$_want" || return 1
				;;
			*)
				info "保留现有默认会话"
				;;
			esac
		fi
		return 0
	fi

	if [ ! -t 0 ]; then
		info "非交互且未设 X11_MULTISTART，只装会话、不改 ~/.xinitrc"
		info "需要多启动时: ./install.sh x11:multistart  或 X11_MULTISTART=1"
		return 0
	fi

	printf "是否安装本仓多启动（~/.xinitrc + ~/.local/bin/startx）？[y/N] "
	read -r _reply || _reply=
	case "$_reply" in
	[yY]|[yY][eE][sS])
		install_x11_multistart
		printf "是否把默认会话写成 %s？[y/N] " "$_want"
		read -r _reply2 || _reply2=
		case "$_reply2" in
		[yY]|[yY][eE][sS])
			x11_set_default_session "$_want" || return 1
			;;
		*)
			info "未改默认会话（无参 startx → xinitrc 内 DEFAULT_SESSION 或 default-session 文件）"
			;;
		esac
		;;
	*)
		info "只装会话，不改 ~/.xinitrc。需要时: ./install.sh x11:multistart"
		;;
	esac
}

install_x11_rofi() {
	_sh="$SCRIPT_DIR/config/x11/rofi/install.sh"
	[ -x "$_sh" ] || [ -f "$_sh" ] || {
		error "缺少 $_sh"
		return 1
	}
	chmod +x "$_sh"
	info "安装 x11:rofi…"
	"$_sh"
}

x11_dispatch() {
	case "${INSTALL_SUB:-}" in
	multistart)
		install_x11_multistart
		;;
	picom)
		install_x11_picom
		;;
	rofi)
		install_x11_rofi
		;;
	"")
		error "请指定 x11:multistart、x11:picom 或 x11:rofi"
		exit 1
		;;
	*)
		error "未知 x11 子模块: ${INSTALL_SUB}（用 x11:multistart / x11:picom / x11:rofi）"
		exit 1
		;;
	esac
}

if [ "${_X11_LIB_ONLY:-0}" != 1 ]; then
	x11_dispatch
fi
