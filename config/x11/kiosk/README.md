# kiosk

无 WM：起命令并用 xdotool 铺满当前屏。

| 命令 | 作用 |
|------|------|
| `kiosk-session` | 已有 `DISPLAY` |
| `kiosk-xephyr.sh` | 嵌套 Xephyr 再调 session |

## 安装

```bash
./install.sh desktop:kiosk
# → ~/.local/bin/kiosk-session ；startx kiosk 即可
```

## 用法

```bash
kiosk-session
kiosk-session alacritty
startx kiosk -- foot
kiosk-xephyr.sh qutebrowser
```
