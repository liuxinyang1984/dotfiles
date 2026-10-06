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
    for key in $(git -C "$SCRIPT_DIR" config -f .gitmodules --name-only --get-regexp '^submodule\..*\.path$' 2>/dev/null); do
        p="$(git -C "$SCRIPT_DIR" config -f .gitmodules --get "$key")"
        if [ "$p" = "$relpath" ]; then
            return 0
        fi
    done
    return 1
}

# 从 parent/.gitmodules 读取 path 对应的 branch（可为空）
gitmodules_branch() {
    parent="$1"
    path="$2"
    for key in $(git -C "$parent" config -f .gitmodules --name-only --get-regexp '^submodule\..*\.path$' 2>/dev/null); do
        p="$(git -C "$parent" config -f .gitmodules --get "$key")"
        if [ "$p" = "$path" ]; then
            name="${key#submodule.}"
            name="${name%.path}"
            git -C "$parent" config -f .gitmodules --get "submodule.${name}.branch" 2>/dev/null || true
            return 0
        fi
    done
}

# 工作区是否干净（无未提交变更）
git_workdir_clean() {
    repo="$1"
    [ -z "$(git -C "$repo" status --porcelain 2>/dev/null)" ]
}

# 解析要跟随的远程分支：显式 branch > origin/HEAD > master
remote_tracking_branch() {
    repo="$1"
    preferred="$2"

    if [ -n "$preferred" ]; then
        printf '%s\n' "$preferred"
        return
    fi

    head="$(git -C "$repo" symbolic-ref -q refs/remotes/origin/HEAD 2>/dev/null || true)"
    if [ -n "$head" ]; then
        printf '%s\n' "${head#refs/remotes/origin/}"
        return
    fi

    git -C "$repo" remote set-head origin -a >/dev/null 2>&1 || true
    head="$(git -C "$repo" symbolic-ref -q refs/remotes/origin/HEAD 2>/dev/null || true)"
    if [ -n "$head" ]; then
        printf '%s\n' "${head#refs/remotes/origin/}"
        return
    fi

    printf 'master\n'
}

# 将仓库对齐到 origin/<branch> tip（脏则跳过）
sync_repo_to_tip() {
    repo="$1"
    preferred_branch="$2"
    name="$3"

    if ! git_workdir_clean "$repo"; then
        warn "$name 工作区有未提交改动，跳过更新到线上 tip"
        return 0
    fi

    info "fetch $name"
    git -C "$repo" fetch origin

    branch="$(remote_tracking_branch "$repo" "$preferred_branch")"
    if ! git -C "$repo" rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
        error "$name 没有 origin/$branch"
        exit 1
    fi

    tip="$(git -C "$repo" rev-parse --short "origin/$branch")"
    info "更新 $name → origin/$branch ($tip)"
    git -C "$repo" checkout -B "$branch" "origin/$branch"
}

# init 嵌套 submodule（仅克隆，不钉最终 SHA），再各自跟线上 tip
sync_nested_submodules_to_tip() {
    parent="$1"

    [ -f "$parent/.gitmodules" ] || return 0

    git -C "$parent" submodule update --init

    for key in $(git -C "$parent" config -f .gitmodules --name-only --get-regexp '^submodule\..*\.path$' 2>/dev/null); do
        nested="$(git -C "$parent" config -f .gitmodules --get "$key")"
        [ -n "$nested" ] || continue
        nested_path="$parent/$nested"
        if [ ! -e "$nested_path/.git" ] && [ ! -f "$nested_path/.git" ]; then
            warn "嵌套 submodule 未检出: $nested_path"
            continue
        fi
        nested_branch="$(gitmodules_branch "$parent" "$nested")"
        sync_repo_to_tip "$nested_path" "$nested_branch" "$nested"
        sync_nested_submodules_to_tip "$nested_path"
    done
}

# 按参数用到的 path：init 后跟远程分支 tip（不 pin 父仓 SHA）
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
    # 只 init 本层，不用 --recursive（避免嵌套先 pin 到父仓记录的 SHA）
    git -C "$SCRIPT_DIR" submodule update --init -- "$relpath"

    if [ ! -e "$dest/.git" ] && [ ! -f "$dest/.git" ] && [ ! -d "$dest/.git" ]; then
        error "submodule 初始化失败: $dest"
        exit 1
    fi

    branch="$(gitmodules_branch "$SCRIPT_DIR" "$relpath")"
    sync_repo_to_tip "$dest" "$branch" "$relpath"
    sync_nested_submodules_to_tip "$dest"
}

link_fontconfig() {
    src="$SCRIPT_DIR/config/fontconfig/fonts.conf"
    dest="$XDG_CONFIG_HOME/fontconfig/fonts.conf"
    mkdir -p "$XDG_CONFIG_HOME/fontconfig"
    safe_link "$src" "$dest" "fontconfig"
}
