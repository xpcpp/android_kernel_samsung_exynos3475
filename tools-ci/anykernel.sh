### AnyKernel3 config - Galaxy On5 Pro SM-G550FY (o5prolte / Exynos3475)
# Replaces ONLY the kernel; keeps the device's own ramdisk + dt.img (stock Samsung DTBH layout).
properties() { '
kernel.string=On5 Pro (G550FY) debug+trace kernel
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=o5prolte
device.name2=o5proltedd
device.name3=o5lte
device.name4=o5lteswa
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

# boot shell variables (partition path taken from stock fstab: 13540000.dwmmc0, names are UPPERCASE)
BLOCK=/dev/block/platform/13540000.dwmmc0/by-name/BOOT;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# keep stock ramdisk/dt, swap kernel only
split_boot;
flash_boot;
