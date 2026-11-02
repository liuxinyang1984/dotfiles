# kiosk（`config/x11/kiosk`）

无窗口管理器：起一个（或一串）命令，用 xdotool 把窗口铺满当前屏。

| 脚本 | 作用 |
|------|------|
| `kiosk-session.sh` | 已有 `DISPLAY` 时跑 |
| `kiosk-xephyr.sh` | 嵌套 Xephyr 再调 session（本机已有桌面时） |

## 安装

默认 **symlink** 到 `~/.local/bin`（与全局配置类约定一致）：

```bash
./install.sh
./install.sh --copy                 # 拷贝
# 父仓
./install.sh desktop:kiosk
KIOSK_COPY=1 ./install.sh desktop:kiosk
```

## 用法：参数 = 启动命令

```bash
kiosk-session.sh                      # 默认 st + tmux
kiosk-session.sh alacritty
kiosk-session.sh foot
kiosk-session.sh st -e nvim
kiosk-session.sh qutebrowser

kiosk-xephyr.sh alacritty
kiosk-xephyr.sh st -e tmux new -A -s kiosk

# 经多启动（config/x11/multistart）
startx kiosk -- foot
```

无参数时也可用 `KIOSK_CMD='alacritty -e fish'`。

环境变量：`KIOSK_GEOM`、`KIOSK_OUTPUT`、`KIOSK_SESSION`（仅默认 tmux）、`KIOSK_LOG`、`KIOSK_XEPHYR_*`。

## 依赖

`xdotool`、`xrandr`|`xdpyinfo`；默认命令需要 `st`+`tmux`。你启动什么就装什么。Xephyr：`xorg-server-xephyr`。
