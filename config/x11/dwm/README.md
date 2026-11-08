# dwm-session

`desktop:suckless` 会安装 `~/.local/bin/dwm-session`，并把 `dwm.desktop` 写入 `/usr/share/xsessions/`（供 Ly 等 DM；`LY_SKIP_XSESSION=1` 可跳过）。

```bash
dwm-session
startx dwm
```

自启：dwmblocks、feh、fcitx5、dunst、clipmenud、picom（可 `SKIP_PICOM=1`）、`xss-lock`→`slock`。

空闲（`xset`，可 `IDLE_LOCK_SEC` / `IDLE_DPMS_SEC` 覆盖）：**5 分钟锁屏**，**15 分钟灭屏**。锁屏器与 `xss-lock`：

```bash
./vendor/suckless/slock/install.sh          # 或 ./install.sh desktop:suckless slock
./vendor/suckless/slock/install.sh --help
```

快捷键（`config.def.rofi.h` → `config.h`，需 `./install.sh x11:rofi`）：
**Super+Space** → `rofi-drun`（.desktop），**Super+r** → `rofi-run`（PATH 命令）。

polkit：`dwm-session` 会起 `mini-polkit-agent`（若已装）。后端默认 dmenu，可：

```bash
./vendor/suckless/mini-polkit/install.sh --prompt=rofi
```
