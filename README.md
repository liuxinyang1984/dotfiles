# dotfiles

按参数安装本机配置与工具。无参只打印用法。`vendor/` 是 git submodule，安装时跟对应远程分支 tip（工作区脏则沿用当前树）。

```bash
./install.sh <模块> [模块...]
```

| 模块 | 作用 |
|------|------|
| `shell` | bashrc、共用 alias/`ssh.env`、`~/.gitconfig`（**不含 zsh**） |
| `zsh` | 调用 `vendor/zshrc/install.sh` → `~/.config/zsh` + 插件 |
| `tmux` | 调用 `vendor/tmux/install.sh` → `~/.config/tmux` + TPM 插件 |
| `nvim` | 调用 `vendor/neovim/install.sh` → symlink `~/.config/nvim` |
| `vim` | 调用 `vendor/vim_server/install.sh`（默认用户；`--system` → `/opt/vim-config`） |
| `fontconfig` | 链接 `fonts.conf`；缺 Maple Mono NL NF（Hinted）则下载 |
| `fcitx5-chinese` | Alpine x86 优先装本仓预编译 apk；否则有仓库包则跳过，再否则源码编译 |
| `keyd` | 安装 `config/keyd/default.conf` → `/etc/keyd/`，`systemctl enable --now keyd` |
| `dunst` | 链接 `config/dunst/dunstrc` + `config/mako/config`（dwm / Hyprland 通知） |
| `desktop:suckless` | 调用 suckless `install.sh`（含 **dwmblocks** 状态栏；默认系统 PREFIX；`SUCKLESS_USER=1` → `~/.local`）+ fontconfig |
| `desktop:hyprland` | 仓登记后再用 |
| `desktop:kiosk` | [`config/x11/kiosk/`](config/x11/kiosk/) → `~/.local/bin`（默认 symlink；`KIOSK_COPY=1` 拷贝）；可询多启动 |
| `desktop:fvwm` | [`vendor/fvwm`](vendor/fvwm) → `~/.fvwm`（默认 symlink；`FVWM_COPY=1` / `FVWM_FORCE=1`）；可询多启动 |
| `x11:multistart` | 多启动 → [`config/x11/multistart/`](config/x11/multistart/) |
| `x11:picom` | X 合成器 → `vendor/picom`（[`config/x11/picom/`](config/x11/picom/)）；旧名 `desktop:picom` 仍转发 |

## 安装约定（各组件 `install.sh`）

组件仓根目录自带 `install.sh`，可单独跑；本仓模块先 `ensure_submodule` 再转发。

**配置类统一：默认 symlink（改仓即生效）；要落地拷贝用 `--copy`。** `--dev` 仍接受，等同默认。本仓 `safe_link` 同此约定。

| 组件 | 默认 | 其它 |
|------|------|------|
| **zshrc / tmux / neovim / fvwm / kiosk** | symlink | `--copy` |
| **shell / dunst / fontconfig / x11:multistart** | `safe_link` | — |
| **vim_server** | `~/.vimrc` **source 本仓**（勿链 vimrc 文件；效果同跟仓） | `--system [--prefix DIR]` 拷贝到目录（默认 `/opt/vim-config`，可改任意路径） |
| **suckless / picom** | 编译安装 | `--user` / 环境变量 → `~/.local` |

私货（API key、mysql、内网 ssh）放本机，例如 `~/.config/shell/local/*.alias`，不要进 git。

## desktop:suckless

编译安装：**dwm、st、dmenu、dwmblocks、tabbed、surf**。默认系统 PREFIX。个人：`SUCKLESS_USER=1`。部分组件：`SUCKLESS_COMPONENTS="dwm st"`。mini-polkit：`INSTALL_POLKIT=1`。

源码说明：[liuxinyang1984/suckless](https://github.com/liuxinyang1984/suckless)。状态栏用 **`dwmblocks &`**（fork：[dwmblocks-async](https://github.com/liuxinyang1984/dwmblocks-async)；脚本：[shell_script](https://github.com/liuxinyang1984/shell_script)/`status/`）。不要叠 `slstatus` / `xsetroot` 循环。

### 依赖

Arch：

```bash
sudo pacman -S base-devel libx11 libxft libxext libxinerama fontconfig freetype2 \
  libx11-xcb xcb-util libxcb \
  gtk3 gcr webkit2gtk-4.1
```

Alpine：

```bash
doas apk add build-base libx11-dev libxft-dev libxext-dev libxinerama-dev \
  fontconfig-dev freetype-dev libxcb-dev xcb-util-dev \
  gtk+3.0-dev gcr-dev webkit2gtk-4.1-dev pkgconf
```

```bash
./install.sh desktop:suckless
```

## X11 / desktop

| 前缀 | 含义 |
|------|------|
| `x11:*` | [`multistart/`](config/x11/multistart/)、[`picom/`](config/x11/picom/) |
| `desktop:*` | [`kiosk/`](config/x11/kiosk/)、fvwm、suckless、hyprland |

详见 [`config/x11/README.md`](config/x11/README.md)。

## x11:picom

X 合成器（[liuxinyang1984/picom](https://github.com/liuxinyang1984/picom)）。默认 `/usr/local`；个人：`PICOM_USER=1`。默认链仓内 conf → `~/.config/picom/picom.conf`（已有则跳过）；`PICOM_NO_CONFIG=1` 跳过。

```bash
./install.sh x11:picom
PICOM_USER=1 ./install.sh x11:picom
```

Arch 依赖示例：

```bash
sudo pacman -S base-devel meson ninja git asciidoc \
  libx11 libxext libxcb xcb-util xcb-util-image xcb-util-renderutil \
  xorgproto pixman libconfig libev uthash libglvnd mesa \
  pcre2 dbus
```

dwm 多启动会话会带 `--experimental-backends -b` 起 picom。

## X11 会话

```bash
./install.sh x11:multistart
./install.sh x11:picom
./install.sh desktop:kiosk
./install.sh desktop:fvwm           # FVWM_FORCE=1 若已有 ~/.fvwm
# X11_MULTISTART=1 X11_DEFAULT_SESSION=fvwm ./install.sh desktop:fvwm

startx fvwm
startx kiosk -- alacritty
kiosk-xephyr.sh st -e nvim
```

默认会话：`~/.config/x11/default-session`（`kiosk`|`dwm`|`fvwm`）。壁纸：`~/Pictures/wallpapers/`。

## keyd

键盘映射：`config/keyd/default.conf` → `/etc/keyd/default.conf`，并 `enable --now keyd`。

- Caps：点按 Esc，按住 Ctrl
- Esc → `` ` ``；Shift+Esc → `~`
- Shift+Caps → Caps Lock

```bash
# Arch
sudo pacman -S keyd
./install.sh keyd
```

## dunst / mako（通知）

独立于 suckless：本机 Hyprland 用 [mako](https://github.com/emersion/mako)（`config/mako/config`）；dwm/X11 用 [dunst](https://dunst-project.org/)（由 mako 几何/超时移植，`config/dunst/dunstrc`，边框 `#0099ff`）。`xinitrc` 的 dwm 会话在 `dbus-run-session` 里启动 `dunst`。

```bash
# Arch
sudo pacman -S dunst libnotify   # dwm
# sudo pacman -S mako            # Hyprland（若尚未安装）
./install.sh dunst
notify-send "test" "hello"
```

## fcitx5-chinese

有发行版包就装包；没有（例如 Alpine `x86`）再跑本模块。

Arch：

```bash
sudo pacman -S fcitx5 fcitx5-chinese-addons extra-cmake-modules boost fmt opencc nlohmann-json
```

Alpine x86_64：

```bash
doas apk add fcitx5 fcitx5-chinese-addons libime opencc
```

Alpine i686 / `x86`：见 `packages/alpine/x86/`。

```bash
doas apk add fcitx5 libime opencc
./install.sh fcitx5-chinese
```
