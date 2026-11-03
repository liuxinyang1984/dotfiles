# multistart（多启动）

只做两件事：落地 `~/.xinitrc` + 包装 `startx`；按会话名拼接命令。

## 规则

`startx <名> [--] [args…]` → 若存在 `<名>-session`，则：

```text
~/.xinitrc  <名>  [args…]
  →  exec <名>-session [args…]
```

无白名单：装了 `foo-session` 就能 `startx foo`。

## 安装

```bash
./install.sh x11:multistart
X11_DEFAULT_SESSION=dwm ./install.sh x11:multistart
```

落地：`~/.xinitrc`、`~/.local/bin/startx`、`~/.config/x11/session-common.sh`，
并在 `~/.profile` / `~/.zprofile` 写入 PATH（`# dotfiles-x11-local-bin:1`）。

识别标记：`# dotfiles-x11-session:1`。

## 用法

```bash
startx
startx dwm
startx fvwm
startx kiosk -- alacritty
```

会话脚本由各 desktop 安装：`kiosk-session` / `dwm-session` / `fvwm-session`。
