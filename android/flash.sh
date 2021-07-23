#!/bin/bash
set -e
if [ ! -f workdir/custom-system.img ]; then
       echo "No workdir/custom-system.img to flash"
       exit 1
fi
echo "Make sparse"
img2simg workdir/custom-system.img workdir/custom-system-sparse.img
echo "Begin flasing"
adb shell reboot fastboot
sleep 4
fastboot flash system workdir/custom-system-sparse.img
fastboot reboot

