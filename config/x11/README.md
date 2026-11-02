# X11

本目录放 **X 会话相关**（不是某一种 desktop）：

| 子目录 | 作用 |
|--------|------|
| [`multistart/`](multistart/) | 多启动：`./install.sh x11:multistart` |
| [`kiosk/`](kiosk/) | 无 WM 全屏：参数即启动命令；含 `kiosk-xephyr.sh` |
| [`picom/`](picom/) | 合成器：`./install.sh x11:picom` → `vendor/picom` |

## 安装

```bash
./install.sh x11:multistart          # 多启动 → ~/.xinitrc + ~/.local/bin/startx
./install.sh x11:picom
./install.sh desktop:kiosk           # 结束可询多启动 / 写默认
./install.sh desktop:fvwm            # vendor/fvwm → ~/.fvwm
./install.sh desktop:suckless        # dwm；同上
```

非交互：

```bash
X11_MULTISTART=1 X11_DEFAULT_SESSION=fvwm FVWM_FORCE=1 ./install.sh desktop:fvwm
X11_MULTISTART=0 ./install.sh desktop:kiosk
X11_DEFAULT_SESSION=kiosk ./install.sh x11:multistart
```

默认会话：`~/.config/x11/default-session`（`kiosk`|`dwm`|`fvwm`）。

`~/.local/bin` 须排在 `/usr/bin` 前，包装 `startx` 才会生效。

## 用法

```bash
startx
startx dwm
startx fvwm
startx kiosk
startx kiosk -- alacritty
kiosk-xephyr.sh foot
```

识别本仓 multistart：`# dotfiles-x11-session:1`。
