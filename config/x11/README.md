# X11

本目录放 **X 会话相关**（不是某一种 desktop）：

| 路径 | 作用 |
|------|------|
| [`multistart/`](multistart/) | 路由：`startx <名>` → 执行 `<名>-session`（无白名单） |
| [`session-common.sh`](session-common.sh) | 各 session 共用的 PATH / IM / runtime |
| [`kiosk/`](kiosk/) | `kiosk-session` |
| [`dwm/`](dwm/) | `dwm-session` |
| [`picom/`](picom/) | `./install.sh x11:picom` → `vendor/picom` |
| fvwm | `vendor/fvwm` → `fvwm-session` |

## 模型

```
startx dwm     →  ~/.local/bin/dwm-session
startx fvwm    →  ~/.local/bin/fvwm-session
startx kiosk -- alacritty  →  kiosk-session alacritty
```

multistart **不**内嵌会话逻辑；只判断 `${1}-session` 是否在 PATH。

## 安装

```bash
./install.sh x11:multistart
./install.sh x11:picom
./install.sh desktop:kiosk
./install.sh desktop:fvwm
./install.sh desktop:suckless    # 含 dwm-session
```

默认会话：`~/.config/x11/default-session`（一行会话名，对应 `<名>-session`）。

`~/.local/bin` 须排在 `/usr/bin` 前，包装 `startx` 才生效。
