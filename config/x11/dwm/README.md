# dwm-session

`desktop:suckless` 会安装 `~/.local/bin/dwm-session`。

```bash
dwm-session
startx dwm
```

自启：dwmblocks、feh、fcitx5、dunst、clipmenud、picom（可 `SKIP_PICOM=1`）。

快捷键（`config.def.rofi.h` → `config.h`，需 `./install.sh x11:rofi`）：
**Super+Space** → `rofi-drun`（.desktop），**Super+r** → `rofi-run`（PATH 命令）。
