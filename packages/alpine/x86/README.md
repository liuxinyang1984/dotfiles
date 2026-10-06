# Alpine x86（i686）预编译包

官方 aports 因 qtwebengine 排除 `x86`。这里是无 Qt GUI、`-march=bonnell`（Atom Z530 等）的 `fcitx5-chinese-addons`。

| 文件 | 说明 |
|------|------|
| `fcitx5-chinese-addons-5.1.15-r0.apk` | 拼音/码表等，`arch=x86` |
| `fcitx5-chinese-addons-lang-5.1.15-r0.apk` | 翻译 |
| `APKBUILD` | 用 `i386/alpine:edge` + abuild 重打包 |

目标机需已有 edge 的 `fcitx5`、`libime`、`opencc`（so 名与编包时一致）。

```bash
# 推荐：本仓安装脚本（Alpine x86 会优先装这两包）
./install.sh fcitx5-chinese

# 或手工（未签名，允许 untrusted）
doas apk add --allow-untrusted \
  packages/alpine/x86/fcitx5-chinese-addons-5.1.15-r0.apk \
  packages/alpine/x86/fcitx5-chinese-addons-lang-5.1.15-r0.apk
```

Arch / Alpine x86_64 请用发行版仓库，不要装这个 apk。
