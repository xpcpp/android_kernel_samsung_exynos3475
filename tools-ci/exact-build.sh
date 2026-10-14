#!/usr/bin/env bash
# Exact replica of av1acp/sm-g550fy-kernel build.sh (commit 908ba124), then repack with the stock-trailer packer.
set -euo pipefail
export ARCH=arm
export CROSS_COMPILE="$TOOLCHAIN_DIR/bin/arm-eabi-"
export LOCALVERSION="-13870322"            # stock utsrelease: 3.10.9-13870322
export KBUILD_BUILD_USER=github-actions KBUILD_BUILD_HOST=runner
git checkout cm-14.1 -- arch/arm/include/asm/rodata.h 2>/dev/null || git show origin/cm-14.1:arch/arm/include/asm/rodata.h > arch/arm/include/asm/rodata.h || true  # pristine source (undo our ftrace stub)
# same host-tool fix as theirs (dtc yylloc)
for f in scripts/dtc/dtc-parser.tab.c_shipped scripts/dtc/dtc-parser.y; do
  [ -f $f ] && sed -i 's/^YYLTYPE yylloc;$/extern YYLTYPE yylloc;/' $f
done
make o5lteswa_00_defconfig
sed -i 's/^CONFIG_LOCALVERSION_AUTO=y/# CONFIG_LOCALVERSION_AUTO is not set/' .config
make -j"$(nproc)" zImage-dtb 2>&1 | tee build.log
IMG=arch/arm/boot/zImage-dtb
REL=$(cat include/config/kernel.release)
[ "$REL" = "3.10.9-13870322" ] || { echo "release mismatch: $REL"; exit 1; }
python3 - <<'PY'
import struct
k=open('arch/arm/boot/zImage-dtb','rb').read()
f=k.find(b"\xd0\x0d\xfe\xed",4096)
if f>0 and f+struct.unpack(">I",k[f+4:f+8])[0]==len(k): k=k[:f]; print('stripped appended DTB at',f)
assert k[0x24:0x28]==bytes.fromhex("18286f01")
open('zImage-plain','wb').write(k)
PY
python3 tools-ci/mkbootimg.py --kernel zImage-plain --stock-trailer --out boot-exact-stocktail.img
cp .config kernel-exact.config; cp System.map System-exact.map
echo "::notice title=EXACT::compiler=$("${CROSS_COMPILE}gcc" --version | head -1) | release=$REL | zImage-dtb=$(stat -c%s $IMG) plain=$(stat -c%s zImage-plain) | boot=$(stat -c%s boot-exact-stocktail.img) | sha256(plain)=$(sha256sum zImage-plain | cut -c1-16)"
