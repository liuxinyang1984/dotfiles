#!/bin/sh
# fonts.sh — 由 install.sh source；必须带 INSTALL_SUB（如 maple / sunsong）

case "${INSTALL_SUB:-}" in
    maple|sunsong)
        _sh="$SCRIPT_DIR/config/fonts/${INSTALL_SUB}/install.sh"
        if [ ! -x "$_sh" ]; then
            error "缺少 $_sh"
            exit 1
        fi
        info "调用 config/fonts/${INSTALL_SUB}/install.sh${INSTALL_ARGS:+ ← $INSTALL_ARGS}"
        # shellcheck disable=SC2086
        if [ -n "${INSTALL_ARGS:-}" ]; then
            "$_sh" $INSTALL_ARGS
        else
            # 无参：模块自己打印 --help
            "$_sh"
        fi
        ;;
    "")
        error "请指定 fonts:maple 或 fonts:sunsong"
        exit 1
        ;;
    *)
        error "未知字体包: fonts:$INSTALL_SUB"
        exit 1
        ;;
esac
