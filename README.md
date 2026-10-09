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
| `desktop:suckless` | 调用 suckless `install.sh`（默认系统 PREFIX；`SUCKLESS_USER=1` → `~/.local`）+ fontconfig |
| `desktop:hyprland` | 仓登记后再用 |

## 安装约定（各组件 `install.sh`）

组件仓根目录自带 `install.sh`，可单独跑；本仓模块先 `ensure_submodule` 再转发。

| 组件 | 默认 | 个人 / 其它 |
|------|------|-------------|
| **zshrc** | 同步到 `~/.config/zsh`，插件 `~/.local/share/zsh/plugins` | `--dev` 直接 source 仓库；**无**系统安装 |
| **tmux** | 同步到 `~/.config/tmux`，插件 `~/.config/tmux/plugins` | `--dev` 配置文件 symlink 到仓库；**无**系统安装 |
| **neovim** | symlink 整仓 → `~/.config/nvim` | 仅个人 |
| **vim_server** | `~/.vimrc` source 仓内 `vimrc` | `--system` → `/opt/vim-config`（需 doas/sudo） |
| **suckless** | `doas`/`sudo make install`（config.mk PREFIX，通常 `/usr/local`） | `--user` → `~/.local`；可指定 `dwm`/`st`/…；`--polkit` |
| **fontconfig / fcitx5-chinese / shell** | 仅本仓脚本 | — |

私货（API key、mysql、内网 ssh）放本机，例如 `~/.config/shell/local/*.alias`，不要进 git。

## desktop:suckless

编译安装：**dwm、st、dmenu、slstatus、tabbed、surf**。默认系统 PREFIX。个人：`SUCKLESS_USER=1`。部分组件：`SUCKLESS_COMPONENTS="dwm st"`。mini-polkit：`INSTALL_POLKIT=1`。

源码说明：[liuxinyang1984/suckless](https://github.com/liuxinyang1984/suckless)。状态栏用 `slstatus &`，不要叠 `xsetroot` 循环。

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
