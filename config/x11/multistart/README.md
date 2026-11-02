# multistart（多启动）

X11 会话入口：一份 `xinitrc` + 包装 `startx`，按参数选 `kiosk` / `dwm` 等。

## 安装

```bash
./install.sh x11:multistart
X11_DEFAULT_SESSION=fvwm ./install.sh x11:multistart
```

落地：

- `~/.xinitrc` → 本目录 `xinitrc`
- `~/.local/bin/startx` → 本目录 `startx`（须在 PATH 里优先于 `/usr/bin/startx`）
- 可选 `~/.config/x11/default-session`（一行：`kiosk` / `dwm` / `fvwm`）

识别标记：xinitrc 头 `# dotfiles-x11-session:1`。

`desktop:kiosk` / `desktop:suckless` / `desktop:fvwm` 结束时也会询问；非交互用 `X11_MULTISTART=0|1`。

## 用法

```bash
startx                    # 默认 = default-session 或文件内 DEFAULT_SESSION
startx dwm
startx fvwm
startx kiosk              # → kiosk-session.sh（默认命令）
startx kiosk -- alacritty # → kiosk-session.sh alacritty
```

旁路：[`../kiosk/`](../kiosk/)、[`../picom/`](../picom/)、[`../../vendor/fvwm`](../../vendor/fvwm)。
