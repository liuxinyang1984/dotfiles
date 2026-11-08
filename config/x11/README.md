# X11

本目录放 **X 会话相关**（不是某一种 desktop）：

| 路径 | 作用 |
|------|------|
| [`multistart/`](multistart/) | 路由：`startx <名>` → 执行 `<名>-session`（无白名单） |
| [`session-common.sh`](session-common.sh) | 各 session 共用的 PATH / IM / runtime |
| [`kiosk/`](kiosk/) | `kiosk-session` |
| [`dwm/`](dwm/) | `dwm-session` |
| [`picom/`](picom/) | `./install.sh x11:picom` → `vendor/picom` |
| [`rofi/`](rofi/) | `./install.sh x11:rofi` → CDE 主题 + `rofi-drun` |
| Ly | `./install.sh x11:ly` → [`vendor/ly`](../../vendor/ly/)（自包含源码+主题）；xsessions 由各 desktop 写入 |
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
./install.sh x11:rofi
./install.sh x11:ly              # Ly + ter-132b；tmux → custom-sessions
./install.sh desktop:kiosk       # 含 kiosk.desktop → xsessions
./install.sh desktop:fvwm        # 含 fvwm-session.desktop → xsessions
./install.sh desktop:suckless    # 含 dwm-session + dwm.desktop → xsessions
```

默认会话：`~/.config/x11/default-session`（一行会话名，对应 `<名>-session`）。

`x11:multistart` / `desktop:*` 装多启动时会往 `~/.profile` 与 `~/.zprofile` 写入
`# dotfiles-x11-local-bin:1`，保证登录 PATH 里 `~/.local/bin` 优先于 `/usr/bin`
（否则系统 `startx` 会盖住包装，`startx kiosk` 无效）。
