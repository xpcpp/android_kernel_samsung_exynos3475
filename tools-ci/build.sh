#!/usr/bin/env bash
# Usage: tools-ci/build.sh [defconfig] [fragment ...]
# env: CROSS_COMPILE (required), OUT (default out)
set -euo pipefail
DEFCONFIG=${1:-lineage-o5lteswa_defconfig}; shift || true
FRAGS=("$@"); [ ${#FRAGS[@]} -eq 0 ] && FRAGS=(arch/arm/configs/fragments/on5-debug.config)
OUT=${OUT:-out}; export ARCH=arm SUBARCH=arm
# old 3.10 host tools (dtc yylloc) need -fcommon with modern host gcc
HCF="-Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -fcommon"
mkdir -p "$OUT"
make O="$OUT" HOSTCFLAGS="$HCF" "$DEFCONFIG"
# merge fragments (3.10 merge_config.sh; -m = only merge, don't run make)
KCONFIG_CONFIG="$OUT/.config" scripts/kconfig/merge_config.sh -m -O "$OUT" "$OUT/.config" "${FRAGS[@]}"
make O="$OUT" HOSTCFLAGS="$HCF" olddefconfig 2>/dev/null || yes "" | make O="$OUT" HOSTCFLAGS="$HCF" oldconfig
make O="$OUT" HOSTCFLAGS="$HCF" -j"$(nproc)" zImage 2>&1 | tee "$OUT/build.log"
# CONFIG_BUILD_ARM_APPENDED_DTB_IMAGE => zImage-dtb appended image
ls -l "$OUT"/arch/arm/boot/
