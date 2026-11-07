# kiosk

无 WM：起命令并用 xdotool 铺满当前屏。

| 命令 | 作用 |
|------|------|
| `kiosk-session` | 已有 `DISPLAY` |
| `kiosk-xephyr.sh` | 嵌套 Xephyr 再调 session |

## 安装

```bash
./install.sh desktop:kiosk
# → ~/.local/bin/kiosk-session ；并把 kiosk.desktop 写入 /usr/share/xsessions/
#   （供 Ly 等 DM；LY_SKIP_XSESSION=1 可跳过）
# startx kiosk 亦可
```

Ly / xsessions 的 `kiosk` 固定无参 → `st -e tmux`（session 名 `kiosk`）。换程序用 CLI：`kiosk-session …` / `startx kiosk -- …`。

## 用法

```bash
kiosk-session
kiosk-session alacritty
startx kiosk -- foot
kiosk-xephyr.sh qutebrowser
```
