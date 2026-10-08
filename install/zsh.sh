#!/bin/sh
# zsh.sh — 同步 vendor/zshrc 后调用其 install.sh

run_vendor_install vendor/zshrc

if command -v zsh >/dev/null 2>&1; then
    if [ "$SHELL" = "$(command -v zsh)" ]; then
        info "当前默认 shell 已是 zsh"
    else
        warn "默认 shell 不是 zsh，如需更改: chsh -s $(command -v zsh)"
    fi
fi
