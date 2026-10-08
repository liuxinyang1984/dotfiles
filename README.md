# dotfiles

按参数安装本机配置与工具。无参只打印用法。`vendor/` 是 git submodule，安装时跟对应远程分支 tip（工作区脏则沿用当前树）。

各组件仓根目录有自己的 `install.sh`，可单独执行（例如 `~/git/neovim/install.sh`）。本仓对应模块会先同步 submodule，再调用 `vendor/<名>/install.sh`。fontconfig / fcitx5-chinese / shell（bash、gitconfig）仍只在本仓。zsh 仓尚未登记 submodule 时，用 `~/git/zshrc/install.sh`。

```bash
./install.sh <模块> [模块...]
```

| 模块 | 作用 |
|------|------|
| `shell` | `shell/` → bashrc、zshrc、alias、`~/.gitconfig` |
| `nvim` | `vendor/neovim` → `~/.config/nvim` |
| `vim` | `vendor/vim_server`，`~/.vimrc` source 入口 |
| `fontconfig` | 链接 `fonts.conf`；缺 Maple Mono NL NF（Hinted）则下载 |
| `fcitx5-chinese` | Alpine x86 优先装本仓预编译 apk；否则有仓库包则跳过，再否则源码编译 |
| `desktop:suckless` | 调用 suckless `install.sh`（默认系统 PREFIX；`SUCKLESS_USER=1` 则 `~/.local`）+ fontconfig |
| `desktop:hyprland` | 链接 hyprland 配置（仓登记后可用），并走 fontconfig |

## desktop:suckless

编译安装：**dwm、st、dmenu、slstatus、tabbed、surf**。默认 `doas`/`sudo make install`（`config.mk` PREFIX，一般为 `/usr/local`）。个人：`SUCKLESS_USER=1 ./install.sh desktop:suckless`。mini-polkit：`INSTALL_POLKIT=1 ./install.sh desktop:suckless`。

源码与补丁说明在 [liuxinyang1984/suckless](https://github.com/liuxinyang1984/suckless)。dwm 会话里用 `slstatus &` 写状态栏，不要再叠一层 `xsetroot` 循环。

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

dwm swallow 需要 xcb。surf 需要 GTK3 / GCR / WebKitGTK 4.1。

### 安装

```bash
./install.sh desktop:suckless
```

## fcitx5-chinese

有发行版包就装包；没有（例如 Alpine `x86` 无 `fcitx5-chinese-addons`）再跑本模块编译。

Arch：

```bash
sudo pacman -S fcitx5 fcitx5-chinese-addons extra-cmake-modules boost fmt opencc nlohmann-json
```

Alpine x86_64（edge 通常有仓库包）：

```bash
doas apk add fcitx5 fcitx5-chinese-addons libime opencc
```

Alpine i686 / `x86`（仓库没有）：本仓带预编译包（无 Qt GUI，`-march=bonnell`），见 `packages/alpine/x86/`。

```bash
doas apk add fcitx5 libime opencc
./install.sh fcitx5-chinese
# 等价于：
doas apk add --allow-untrusted \
  packages/alpine/x86/fcitx5-chinese-addons-5.1.15-r0.apk \
  packages/alpine/x86/fcitx5-chinese-addons-lang-5.1.15-r0.apk
```

无本仓 apk、又要源码编译时：

```bash
doas apk add build-base cmake extra-cmake-modules samurai fcitx5-dev libime-dev \
  boost-dev fmt-dev gettext-dev opencc-dev curl-dev nlohmann-json pkgconf git
./install.sh fcitx5-chinese
```
