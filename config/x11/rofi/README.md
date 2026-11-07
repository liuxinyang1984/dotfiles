# X11 rofi（CDE 主题）

供 **dwm / fvwm** 共用的 rofi 主题与启动包装。`drun` 模式读 `.desktop`。

| 文件 | 作用 |
|------|------|
| `cde.rasi` | CDE 灰绿主题（fvwm；保留细线 + Motif 外框；有图标列） |
| `cde-dwm.rasi` | dwm：无图标列（run / clip 基座）+ `-normal-window` |
| `cde-dwm-drun.rasi` | dwm + drun：有图标 |
| `cde-clip.rasi` | 剪切板列表（无图标；导入 cde-dwm） |
| `rofi-drun` | `rofi -show drun`（.desktop 启动器） |
| `rofi-run` | `rofi -show run`（类 dmenu，跑 PATH 命令） |

## 安装

```bash
./install.sh x11:rofi
# 或
./config/x11/rofi/install.sh
```

落地：

- `~/.config/rofi/cde.rasi`、`cde-dwm.rasi`、`cde-dwm-drun.rasi`、`cde-clip.rasi`
- `~/.local/bin/rofi-drun` / `rofi-run`

依赖：`rofi`；图标主题可选 `Flat-Remix-Green-Light`（可用 `ROFI_ICON_THEME` 覆盖）。

## dwm

模板：`vendor/suckless/dwm/config.def.rofi.h`（`make` 缺 `config.h` 时从此复制）。

- **Super+Space** → `rofi-drun`（`cde-dwm-drun.rasi` + 图标）
- **Super+r** → `rofi-run`（`cde-dwm.rasi`，无图标）
- float rule：`class = "Rofi"`（吃 CDE 装饰）
- fvwm：`ROFI_THEME=…/cde.rasi` 用带细线的主题 + Motif 框
