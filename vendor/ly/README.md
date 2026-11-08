# ly（CRT）

基于 [fairyglade/ly](https://github.com/fairyglade/ly) 的自包含 fork：**改过的源码 + 主题 + `install.sh`**。父仓只 `./install.sh x11:ly` 调用本目录。

## 相对上游的改动

- 空 / null `initial_info_text` → **不显示 hostname**
- 单项 CyclableLabel 不画 `<>`
- `box_title` 绘制时右偏并加左右空格（ini 会 trim，不能靠配置空格）
- 主题色 **软方块光标**（藏硬件白光标；颜色跟 `fg`）
- **注销后退出进程**，systemd `Restart=always` + `TTYReset` 再拉起（避免 i915/fbcon 上 soft reclaim 滚屏花屏）
- 默认 `waylandsessions = null`（纯 X11 机无 `/usr/share/wayland-sessions` 时不报 `err_crawl`）

## 安装

```bash
# 在本仓
./install.sh

# 或父仓
./install.sh x11:ly
```

选项见 `./install.sh --help`（`--no-packages` / `--no-enable` / `--no-colors` / `--no-build`；`LY_TTY` / `LY_FONT` 等）。

- **Arch**：`pacman` 装 `zig`、`terminus-font`；（可选）官方 `ly` 只借 systemd unit
- **Alpine**：同源 `zig build`；需自备 zig≥0.17 与字体 / service
- 二进制：`/usr/local/bin/ly-dm` + `ly@.service.d/override.conf`

## 主题

| 名 | 文件 |
|----|------|
| `amber` | `crt-amber.colors` 棕金 |
| `green` | `crt-green.colors` Matrix 雨绿 |

```bash
./theme.sh amber
./theme.sh green
```

`crt-current.colors` 软链 + `/etc/ly/theme`（`startup.sh` 16 色调色板）。

## 布局

```
vendor/ly/
  install.sh theme.sh startup.sh
  crt-*.colors
  src/ ly-ui/ ly-core/   # 已打补丁的 Ly 源码
  lang/ sessions/
```

上游许可见 `license.md`。
