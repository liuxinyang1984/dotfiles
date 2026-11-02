# picom（`x11:picom`）

X11 合成器。源码在 [`vendor/picom`](../../../vendor/picom)（fork：[liuxinyang1984/picom](https://github.com/liuxinyang1984/picom)）；本目录只说明归属，不重复放一份树。

```bash
./install.sh x11:picom
PICOM_USER=1 ./install.sh x11:picom   # → ~/.local
PICOM_NO_CONFIG=1 ./install.sh x11:picom
```

默认把仓内 `picom.conf`（或 sample）链到 `~/.config/picom/picom.conf`（已有则跳过）。

多启动：`./install.sh x11:multistart`。dwm 会话（[`../multistart/xinitrc`](../multistart/xinitrc)）会带 `--experimental-backends -b` 起 picom。兼容旧名：`desktop:picom` → 转发。
