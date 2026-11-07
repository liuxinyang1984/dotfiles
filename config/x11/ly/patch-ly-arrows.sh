#!/bin/sh
# 去掉 CyclableLabel 的 < >（单项 info 行不再显示 <.>；会话多项仍可切换，只是两侧变空格）
# 写入 /usr/local/bin/ly-dm + systemd drop-in
set -e
SRC="${1:-/usr/bin/ly-dm}"
DST="${2:-/usr/local/bin/ly-dm}"
[ -f "$SRC" ] || { echo "缺少 $SRC" >&2; exit 1; }
TMP=$(mktemp)
python3 - "$SRC" "$TMP" <<'PY'
from pathlib import Path
import sys
data = bytearray(Path(sys.argv[1]).read_bytes())
patched = 0
i = 0
while i < len(data) - 8:
    if data[i:i+4] == bytes([0x3C, 0, 0, 0]):
        window = data[i:i+64]
        j = window.find(bytes([0x3E, 0, 0, 0]))
        if j != -1:
            data[i:i+4] = bytes([0x20, 0, 0, 0])
            data[i+j:i+j+4] = bytes([0x20, 0, 0, 0])
            patched += 1
            i += j + 4
            continue
    i += 1
if patched < 1:
    raise SystemExit("未找到可打补丁的 < > 对，Ly 版本可能已变")
Path(sys.argv[2]).write_bytes(data)
print(f"patched {patched} arrow pair(s)")
PY
chmod 755 "$TMP"
run() { if [ "$(id -u)" -eq 0 ]; then "$@"; elif command -v doas >/dev/null; then doas "$@"; else sudo "$@"; fi; }
run install -m755 "$TMP" "$DST"
rm -f "$TMP"
run mkdir -p /etc/systemd/system/ly@.service.d
run tee /etc/systemd/system/ly@.service.d/override.conf >/dev/null <<'UNIT'
[Service]
ExecStart=
ExecStart=/usr/local/bin/ly-dm
UNIT
run systemctl daemon-reload
echo "ok: $DST + ly@.service.d/override.conf"
