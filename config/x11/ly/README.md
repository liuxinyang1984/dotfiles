# x11:ly

[Ly](https://codeberg.org/fairyglade/ly)（TUI 显示管理器）+ Terminus console 字体。

## 职责

| 本模块 | 不做 |
|--------|------|
| 装 `ly` / `terminus-font` | 不维护 dwm/kiosk/fvwm 的 `.desktop` |
| 全 VT `FONT=ter-132b`（口语 ter-v32b） | 不替代 `startx` / `*-session` |
| `/etc/ly/startup.sh`：16 色黄槽→棕金 | |
| `systemctl enable ly@tty1`（默认） | |
| 可选 `tmux` → `/etc/ly/custom-sessions/` | |

**会话声明归各 desktop**：`desktop:suckless` / `kiosk` / `fvwm` 安装时把对应 `.desktop` 写入 `/usr/share/xsessions/`（Ly 与其它 DM 都能读）。Hyprland 用发行版自带的 `wayland-sessions`。

## 安装

```bash
./install.sh x11:ly
# 或
./config/x11/ly/install.sh
```

选项：`--no-packages`、`--no-enable`、`--no-colors`。跳过某桌面的 xsessions：`LY_SKIP_XSESSION=1`。

## 配色（为何改 hex 往往「没变」）

Linux **文本控制台只有 16 色**。Ly 的 `0xSSRRGGBB` 真彩会并到最近的调色板槽；多种「棕/黄」都会落成同一个刺眼的 **黄**（尤其亮黄 `#FFFF55`），所以只改 `config.ini` 的 fg 常常看不出差别。

本模块用 [`startup.sh`](startup.sh) 在 Ly 起来前重写 VT 调色板：把暗黄/亮黄/绿槽改成棕金（matrix 雨滴在 TTY 上常走绿色）。这才是 TTY 上真正能看见的颜色。

默认样式（`crt-amber.colors`）：`animation = none`，`bigclock = en`，居中；`blank_box = false`（实心登录框）。

```bash
./config/x11/ly/install.sh --no-packages --no-enable
sudo systemctl restart ly@tty1
```

## 字体

Arch Terminus console 名：`ter-132b` = 编码 1 + **32**px + **b**old（即常说的 **ter-v32b**）。

安装时：

1. `/etc/vconsole.conf` → `FONT=ter-132b`（开机后所有 VT 默认）
2. 立刻 `setfont` 到 **tty1–tty6**（`LY_TTY_MAX` 可改）
3. `systemd-vconsole-setup` restart
4. Ly 的 `startup.sh` 再对当前 TTY 设一次

只改字体：`sudo ./config/x11/ly/setfont-all.sh ter-132b`

## TTY

默认 **`tty = 1`** → `ly@tty1.service`（安装时写入 ini，并 disable 旧的 `ly@tty2`）。换号：`LY_TTY=2 ./install.sh …`。Ctrl+Alt+F1 进 Ly。
