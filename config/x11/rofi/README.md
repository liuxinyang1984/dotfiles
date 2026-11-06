# X11 rofi（CDE 主题）

供 **dwm / fvwm** 共用的 rofi 主题与启动包装。`drun` 模式读 `.desktop`。

| 文件 | 作用 |
|------|------|
| `cde.rasi` | CDE 灰绿主题（原 `vendor/fvwm/rofi/`） |
| `rofi-drun` | `rofi -show drun`（.desktop 启动器） |
| `rofi-run` | `rofi -show run`（类 dmenu，跑 PATH 命令） |

## 安装

```bash
./install.sh x11:rofi
# 或
./config/x11/rofi/install.sh
```

落地：

- `~/.config/rofi/cde.rasi`
- `~/.local/bin/rofi-drun` / `rofi-run`

依赖：`rofi`；图标主题可选 `Flat-Remix-Green-Light`（可用 `ROFI_ICON_THEME` 覆盖）。

## dwm

模板：`vendor/suckless/dwm/config.def.rofi.h`（`make` 缺 `config.h` 时从此复制）。

- **Super+Space** → `rofi-drun`（应用）
- **Super+r** → `rofi-run`（命令）
- float rule：`class = "Rofi"`（`-normal-window` 以便 CDE 边框）
