# install/lib.sh — 由 install.sh source，勿单独执行

info() { printf '\033[32m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[31m[ERROR]\033[0m %s\n' "$1"; }

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

safe_link() {
    src="$1"
    dest="$2"
    name="$3"

    if [ ! -e "$src" ]; then
        warn "源文件不存在: $src，跳过 $name 的链接"
        return
    fi

    if [ -L "$dest" ]; then
        current_target="$(readlink "$dest")"
        if [ "$current_target" = "$src" ]; then
            info "$name 已正确链接到 $src，跳过"
        else
            warn "$name 符号链接指向错误：$current_target"
            ln -sf "$src" "$dest"
            info "已更新符号链接 $dest -> $src"
        fi
    elif [ -e "$dest" ]; then
        warn "$name 已存在且不是符号链接: $dest"
        printf "是否覆盖？（备份原文件/目录并创建符号链接）[y/N] "
        read reply
        case "$reply" in
            [yY]|[yY][eE][sS])
                backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
                mv "$dest" "$backup"
                info "已备份原内容到 $backup"
                ln -s "$src" "$dest"
                info "已创建符号链接 $dest -> $src"
                ;;
            *)
                info "跳过 $name 的配置"
                ;;
        esac
    else
        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
        info "已创建符号链接 $dest -> $src"
    fi
}

# 子模块是否已在 .gitmodules 中登记
submodule_registered() {
    relpath="$1"
    git -C "$SCRIPT_DIR" config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null \
        | awk '{print $2}' \
        | grep -Fxq "$relpath"
}

# 工作区是否干净（无未提交变更）
git_workdir_clean() {
    repo="$1"
    [ -z "$(git -C "$repo" status --porcelain 2>/dev/null)" ]
}

# 快进到 origin 当前分支；脏则跳过。嵌套 submodule 一并 init 并尝试 ff-only。
submodule_pull_ff() {
    repo="$1"
    name="$2"

    if ! git_workdir_clean "$repo"; then
        warn "$name 工作区有未提交改动，跳过 pull"
        return 0
    fi

    if git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        info "更新 $name: git pull --ff-only"
        git -C "$repo" pull --ff-only
    else
        warn "$name 没有上游分支，跳过 pull"
    fi

    if [ -f "$repo/.gitmodules" ]; then
        git -C "$repo" submodule update --init --recursive
        # 嵌套仓各自 ff-only；某个脏则只警告
        git -C "$repo" submodule foreach --recursive '
            if [ -n "$(git status --porcelain)" ]; then
                echo "skip dirty: $displaypath" >&2
            elif git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
                git pull --ff-only
            fi
        '
    fi
}

# 按参数用到的 path 初始化并跟远程最新（不 pin 父仓 SHA）
ensure_submodule() {
    relpath="$1"
    dest="$SCRIPT_DIR/$relpath"

    if [ ! -d "$SCRIPT_DIR/.git" ] && [ ! -f "$SCRIPT_DIR/.git" ]; then
        error "当前目录不是 git 仓库，无法维护 submodule: $relpath"
        exit 1
    fi

    if [ ! -f "$SCRIPT_DIR/.gitmodules" ]; then
        error "缺少 .gitmodules，请先 git submodule add 对应仓库"
        exit 1
    fi

    if ! submodule_registered "$relpath"; then
        error "未在 .gitmodules 中登记: $relpath"
        exit 1
    fi

    info "确保 submodule: $relpath"
    git -C "$SCRIPT_DIR" submodule update --init --recursive -- "$relpath"

    if [ ! -e "$dest/.git" ] && [ ! -d "$dest/.git" ]; then
        error "submodule 初始化失败: $dest"
        exit 1
    fi

    submodule_pull_ff "$dest" "$relpath"
}

link_fontconfig() {
    src="$SCRIPT_DIR/config/fontconfig/fonts.conf"
    dest="$XDG_CONFIG_HOME/fontconfig/fonts.conf"
    mkdir -p "$XDG_CONFIG_HOME/fontconfig"
    safe_link "$src" "$dest" "fontconfig"
}
