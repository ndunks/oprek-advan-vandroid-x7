#!/bin/bash
# $PWD is kernel

UNPACKED="boot/boot.img"
pushd ramdisk
find . ! -name . | LC_ALL=C sort | cpio -o -H newc -R root:root | gzip > ../custom-ramdisk.gz
popd

cmdline=`cat $UNPACKED-cmdline`
board=`cat $UNPACKED-board`
base=`cat $UNPACKED-base`
pagesize=`cat $UNPACKED-pagesize`
kernel_offset=`cat $UNPACKED-kerneloff`
ramdisk_offset=`cat $UNPACKED-ramdiskoff`
second_offset=`cat $UNPACKED-secondoff`
tags_offset=`cat $UNPACKED-tagsoff`
header_version=`cat $UNPACKED-headerversion`
hash=`cat $UNPACKED-hash`

mkbootimg \
       --kernel "$UNPACKED-zImage" \
       --ramdisk "custom-ramdisk.gz" \
       --second "$UNPACKED-second" \
       --cmdline "$cmdline" \
       --board "$board" \
       --base "$base" \
       --pagesize "$pagesize" \
       --kernel_offset "$kernel_offset" \
       --ramdisk_offset "$ramdisk_offset" \
       --second_offset "$second_offset" \
       --tags_offset "$tags_offset" \
       --header_version "$header_version" \
       --hash "$hash" \
       -o custom-boot.img

if [ "$1X" != "X" ]; then
       echo "Begin flasing"
       adb reboot fastboot
       sleep 3
       fastboot flash boot custom-boot.img
       fastboot reboot
fi
