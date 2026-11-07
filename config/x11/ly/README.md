# x11:ly

[Ly](https://codeberg.org/fairyglade/ly)（TUI 显示管理器）+ Terminus console 字体。

## 职责

| 本模块 | 不做 |
|--------|------|
| 装 `ly` / `terminus-font` | 不维护 dwm/kiosk/fvwm 的 `.desktop` |
| `FONT=ter-132b`（口语 ter-v32b） | 不替代 `startx` / `*-session` |
| `systemctl enable ly@ttyN` | |
| 可选 `tmux` → `/etc/ly/custom-sessions/` | |

**会话声明归各 desktop**：`desktop:suckless` / `kiosk` / `fvwm` 安装时把对应 `.desktop` 写入 `/usr/share/xsessions/`（Ly 与其它 DM 都能读）。Hyprland 用发行版自带的 `wayland-sessions`。

## 安装

```bash
./install.sh x11:ly
# 或
./config/x11/ly/install.sh
```

选项：`--no-packages`、`--no-enable`。跳过某桌面的 xsessions：`LY_SKIP_XSESSION=1`。

## 字体

Arch Terminus console 名：`ter-132b` = 编码 1 + **32**px + **b**old（即常说的 ter-v32b）。

## TTY

默认读 `/etc/ly/config.ini` 的 `tty=`（多为 2）→ `ly@tty2.service`。Ctrl+Alt+F2 进 Ly。
