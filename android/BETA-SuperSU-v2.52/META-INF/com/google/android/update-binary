#!/sbin/sh
#
# SuperSU installer ZIP
# Copyright (c) 2012-2015 - Chainfire
#
# To install SuperSU properly, aside from cleaning old versions and
# other superuser-type apps from the system, the following files need to
# be installed:
#
# API   source                        target                              chmod   chcon                       required
#
# 7-19  common/Superuser.apk          /system/app/Superuser.apk           0644    u:object_r:system_file:s0   gui
# 20+   common/Superuser.apk          /system/app/SuperSU/SuperSU.apk     0644    u:object_r:system_file:s0   gui
#
# 17+   common/install-recovery.sh    /system/etc/install-recovery.sh     0755    *1                          required
# 17+                                 /system/bin/install-recovery.sh     (symlink to /system/etc/...)        required
# *1: same as /system/bin/toolbox: u:object_r:system_file:s0 if API < 20, u:object_r:toolbox_exec:s0 if API >= 20
#
# 7+    ARCH/su *2                    /system/xbin/su                     *3      u:object_r:system_file:s0   required
# 7+                                  /system/bin/.ext/.su                *3      u:object_r:system_file:s0   gui
# 17+                                 /system/xbin/daemonsu               0755    u:object_r:system_file:s0   required
# 17+                                 /system/xbin/sugote                 0755    u:object_r:zygote_exec:s0   required
# *2: su.pie for 17+ x86(_32) only
# *3: 06755 if API < 18, 0755 if API >= 18
#
# 19+   ARCH/supolicy                 /system/xbin/supolicy               0755    u:object_r:system_file:s0   required
# 19+   ARCH/libsupol.so              /system/lib(64)/libsupol.so         0644    u:object_r:system_file:s0   required
#
# 17+   /system/bin/sh or mksh *4     /system/xbin/sugote-mksh            0755    u:object_r:system_file:s0   required
# *4: which one (or both) are available depends on API
#
# 21+   /system/bin/app_process32 *5  /system/bin/app_process32_original  0755    u:object_r:zygote_exec:s0   required
# 21+   /system/bin/app_process64 *5  /system/bin/app_process64_original  0755    u:object_r:zygote_exec:s0   required
# 21+   /system/bin/app_processXX *5  /system/bin/app_process_init        0755    u:object_r:system_file:s0   required
# 21+                                 /system/bin/app_process             (symlink to /system/xbin/daemonsu)  required
# 21+                             *5  /system/bin/app_process32           (symlink to /system/xbin/daemonsu)  required
# 21+                             *5  /system/bin/app_process64           (symlink to /system/xbin/daemonsu)  required
# *5: Only do this for the relevant bits. On a 64 bits system, leave the 32 bits files alone, or dynamic linker errors
#     will prevent the system from fully working in subtle ways. The bits of the su binary must also match!
#
# 17+   common/99SuperSUDaemon *6     /system/etc/init.d/99SuperSUDaemon  0755    u:object_r:system_file:s0   optional
# *6: only place this file if /system/etc/init.d is present
#
# 17+   'echo 1 >' or 'touch' *7      /system/etc/.installed_su_daemon    0644    u:object_r:system_file:s0   optional
# *7: the file just needs to exist or some recoveries will nag you. Even with it there, it may still happen.
#
# It may seem some files are installed multiple times needlessly, but
# it only seems that way. Installing files differently or symlinking
# instead of copying (unless specified) will lead to issues eventually.
#
# The following su binary versions are included in the full package. Each
# should be installed only if the system has the same or newer API level
# as listed. The script may fall back to a different binary on older API
# levels. supolicy are all ndk/pie/19+ for 32 bit, ndk/pie/20+ for 64 bit.
#
# binary        ARCH/path   build type      API
#
# arm-v5te      arm         ndk non-pie     7+
# x86           x86         ndk non-pie     7+
#
# x86           x86         ndk pie         17+   (su.pie, naming exception)
# arm-v7a       armv7       ndk pie         17+
# mips          mips        ndk pie         17+
#
# arm64-v8a     arm64       ndk pie         20+
# mips64        mips64      ndk pie         20+
# x86_64        x64         ndk pie         20+
#
# Note that if SELinux is set to enforcing, the daemonsu binary expects
# to be run at startup (usually from install-recovery.sh, 99SuperSUDaemon,
# or app_process) from u:r:init:s0 or u:r:kernel:s0 contexts. Depending
# on the current policies, it can also deal with u:r:init_shell:s0 and
# u:r:toolbox:s0 contexts. Any other context will lead to issues eventually.
#
# After installation, run '/system/xbin/su --install', which may need to
# perform some additional installation steps. Ideally, at one point,
# a lot of this script will be moved there.
#
# The included chattr(.pie) binaries are used to remove ext2's immutable
# flag on some files. This flag is no longer set by SuperSU's OTA
# survival since API level 18, so there is no need for the 64 bit versions.
# Note that chattr does not need to be installed to the system, it's just
# used by this script, and not supported by the busybox used in older
# recoveries.
#
# Non-static binaries are supported to be PIE (Position Independent
# Executable) from API level 16, and required from API level 20 (which will
# refuse to execute non-static non-PIE).
#
# The script performs several actions in various ways, sometimes
# multiple times, due to different recoveries and firmwares behaving
# differently, and it thus being required for the correct result.

OUTFD=$2
ZIP=$3

SYSTEMLIB=/system/lib

ui_print() {
  echo -n -e "ui_print $1\n" > /proc/self/fd/$OUTFD
  echo -n -e "ui_print\n" > /proc/self/fd/$OUTFD
}

ch_con() {
  LD_LIBRARY_PATH=$SYSTEMLIB /system/toybox chcon -h u:object_r:system_file:s0 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/bin/toybox chcon -h u:object_r:system_file:s0 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/toolbox chcon -h u:object_r:system_file:s0 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/bin/toolbox chcon -h u:object_r:system_file:s0 $1
  chcon -h u:object_r:system_file:s0 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/toybox chcon u:object_r:system_file:s0 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/bin/toybox chcon u:object_r:system_file:s0 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/toolbox chcon u:object_r:system_file:s0 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/bin/toolbox chcon u:object_r:system_file:s0 $1
  chcon u:object_r:system_file:s0 $1
}

ch_con_ext() {
  LD_LIBRARY_PATH=$SYSTEMLIB /system/toybox chcon $2 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/bin/toybox chcon $2 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/toolbox chcon $2 $1
  LD_LIBRARY_PATH=$SYSTEMLIB /system/bin/toolbox chcon $2 $1
  chcon $2 $1
}

ln_con() {
  LD_LIBRARY_PATH=$SYSTEMLIB /system/toybox ln -s $1 $2
  LD_LIBRARY_PATH=$SYSTEMLIB /system/bin/toybox ln -s $1 $2
  LD_LIBRARY_PATH=$SYSTEMLIB /system/toolbox ln -s $1 $2
  LD_LIBRARY_PATH=$SYSTEMLIB /system/bin/toolbox ln -s $1 $2
  ln -s $1 $2
  ch_con $2
}

set_perm() {
  chown $1.$2 $4
  chown $1:$2 $4
  chmod $3 $4
  ch_con $4
  ch_con_ext $4 $5
}

cp_perm() {
  rm $5
  if [ -f "$4" ]; then
    cat $4 > $5
    set_perm $1 $2 $3 $5 $6
  fi
}

toolbox_mount() {
  DEV=
  POINT=
  FS=
  for i in `cat /etc/fstab | grep "$1"`; do
    if [ -z "$DEV" ]; then
      DEV=$i
    elif [ -z "$POINT" ]; then
      POINT=$i
    elif [ -z "$FS" ]; then
      FS=$i
      break
    fi
  done
  mount -t $FS -o rw $DEV $POINT
  mount -t $FS -o rw,remount $DEV $POINT

  DEV=
  POINT=
  FS=
  for i in `cat /etc/recovery.fstab | grep "$1"`; do
    if [ -z "$POINT" ]; then
      POINT=$i
    elif [ -z "$FS" ]; then
      FS=$i
    elif [ -z "$DEV" ]; then
      DEV=$i
      break
    fi
  done
  if [ "$FS" = "emmc" ]; then
    mount -t ext4 -o rw $DEV $POINT
    mount -t ext4 -o rw,remount $DEV $POINT
    mount -t f2fs -o rw $DEV $POINT
    mount -t f2fs -o rw,remount $DEV $POINT
  else
    mount -t $FS -o rw $DEV $POINT
    mount -t $FS -o rw,remount $DEV $POINT
  fi
}

ui_print "*****************"
ui_print "SuperSU installer"
ui_print "*****************"

ui_print "- Mounting /system, /data and rootfs"

mount /system
mount /data
mount -o rw,remount /system
mount -o rw,remount /system /system
mount -o rw,remount /
mount -o rw,remount / /

toolbox_mount /system
toolbox_mount /data

if [ -z "$BIN" ]; then
  # TWRP went full retard
  if [ ! -f "/sbin/unzip" ]; then
    ui_print "- BAD RECOVERY DETECTED, NO UNZIP, ABORTING"
    exit 1
  fi
fi

cat /system/bin/toybox > /system/toybox
chmod 0755 /system/toybox
ch_con /system/toybox

cat /system/bin/toolbox > /system/toolbox
chmod 0755 /system/toolbox
ch_con /system/toolbox

API=$(cat /system/build.prop | grep "ro.build.version.sdk=" | dd bs=1 skip=21 count=2)
ABI=$(cat /system/build.prop /default.prop | grep -m 1 "ro.product.cpu.abi=" | dd bs=1 skip=19 count=3)
ABILONG=$(cat /system/build.prop /default.prop | grep -m 1 "ro.product.cpu.abi=" | dd bs=1 skip=19)
ABI2=$(cat /system/build.prop /default.prop | grep -m 1 "ro.product.cpu.abi2=" | dd bs=1 skip=20 count=3)
SUMOD=06755
SUGOTE=false
SUPOLICY=false
INSTALL_RECOVERY_CONTEXT=u:object_r:system_file:s0
MKSH=/system/bin/mksh
PIE=
SU=su
ARCH=arm
APKFOLDER=false
APKNAME=/system/app/Superuser.apk
APPPROCESS=false
APPPROCESS64=false
if [ "$ABI" = "x86" ]; then ARCH=x86; fi;
if [ "$ABI2" = "x86" ]; then ARCH=x86; fi;
if [ "$API" -eq "$API" ]; then
  if [ "$API" -ge "17" ]; then
    SUGOTE=true
    PIE=.pie
    if [ "$ARCH" = "x86" ]; then SU=su.pie; fi;
    if [ "$ABILONG" = "armeabi-v7a" ]; then ARCH=armv7; fi;
    if [ "$ABI" = "mip" ]; then ARCH=mips; fi;
    if [ "$ABILONG" = "mips" ]; then ARCH=mips; fi;
  fi
  if [ "$API" -ge "18" ]; then
    SUMOD=0755
  fi
  if [ "$API" -ge "20" ]; then
    if [ "$ABILONG" = "arm64-v8a" ]; then ARCH=arm64; SYSTEMLIB=/system/lib64; APPPROCESS64=true; fi;
    if [ "$ABILONG" = "mips64" ]; then ARCH=mips64; SYSTEMLIB=/system/lib64; APPPROCESS64=true; fi;
    if [ "$ABILONG" = "x86_64" ]; then ARCH=x64; SYSTEMLIB=/system/lib64; APPPROCESS64=true; fi;
    APKFOLDER=true
    APKNAME=/system/app/SuperSU/SuperSU.apk
  fi
  if [ "$API" -ge "19" ]; then
    SUPOLICY=true
    if [ "$(LD_LIBRARY_PATH=$SYSTEMLIB /system/toolbox ls -lZ /system/bin/toolbox | grep toolbox_exec > /dev/null; echo $?)" -eq "0" ]; then
      INSTALL_RECOVERY_CONTEXT=u:object_r:toolbox_exec:s0
    fi
  fi
  if [ "$API" -ge "21" ]; then
    APPPROCESS=true
  fi
fi
if [ ! -f $MKSH ]; then
  MKSH=/system/bin/sh
fi

#ui_print "DBG [$API] [$ABI] [$ABI2] [$ABILONG] [$ARCH] [$MKSH]"

if [ -z "$BIN" ]; then
  ui_print "- Extracting files"

  cd /tmp
  mkdir supersu
  cd supersu

  unzip -o "$ZIP"
  
  BIN=/tmp/supersu/$ARCH
  COM=/tmp/supersu/common
fi

ui_print "- Disabling OTA survival"
chmod 0755 $BIN/chattr$PIE
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/bin/su
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/xbin/su
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/bin/.ext/.su
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/sbin/su
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /vendor/sbin/su
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /vendor/bin/su
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /vendor/xbin/su
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/xbin/daemonsu
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/xbin/sugote
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/xbin/sugote_mksh
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/xbin/supolicy
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/xbin/ku.sud
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/xbin/.ku
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/xbin/.su
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/lib/libsupol.so
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/lib64/libsupol.so
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/etc/install-recovery.sh
LD_LIBRARY_PATH=$SYSTEMLIB $BIN/chattr$PIE -ia /system/bin/install-recovery.sh

ui_print "- Removing old files"

if [ -f "/system/bin/install-recovery.sh" ]; then
  if [ ! -f "/system/bin/install-recovery_original.sh" ]; then
    mv /system/bin/install-recovery.sh /system/bin/install-recovery_original.sh
    ch_con /system/bin/install-recovery_original.sh
  fi
fi
if [ -f "/system/etc/install-recovery.sh" ]; then
  if [ ! -f "/system/etc/install-recovery_original.sh" ]; then
    mv /system/etc/install-recovery.sh /system/etc/install-recovery_original.sh
    ch_con /system/etc/install-recovery_original.sh
  fi
fi

rm -f /system/bin/su
rm -f /system/xbin/su
rm -f /system/sbin/su
rm -f /vendor/sbin/su
rm -f /vendor/bin/su
rm -f /vendor/xbin/su
rm -f /system/xbin/daemonsu
rm -f /system/xbin/sugote
rm -f /system/xbin/sugote-mksh
rm -f /system/xbin/supolicy
rm -f /system/xbin/ku.sud
rm -f /system/xbin/.ku
rm -f /system/xbin/.su
rm -f /system/lib/libsupol.so
rm -f /system/lib64/libsupol.so
rm -f /system/bin/.ext/.su
rm -f /system/bin/install-recovery.sh
rm -f /system/etc/install-recovery.sh
rm -f /system/etc/init.d/99SuperSUDaemon
rm -f /system/etc/.installed_su_daemon
rm -f /system/app/Superuser.apk
rm -f /system/app/Superuser.odex
rm -rf /system/app/Superuser
rm -f /system/app/SuperUser.apk
rm -f /system/app/SuperUser.odex
rm -rf /system/app/SuperUser
rm -f /system/app/superuser.apk
rm -f /system/app/superuser.odex
rm -rf /system/app/superuser
rm -f /system/app/Supersu.apk
rm -f /system/app/Supersu.odex
rm -rf /system/app/Supersu
rm -f /system/app/SuperSU.apk
rm -f /system/app/SuperSU.odex
rm -rf /system/app/SuperSU
rm -f /system/app/supersu.apk
rm -f /system/app/supersu.odex
rm -rf /system/app/supersu
rm -f /system/app/VenomSuperUser.apk
rm -f /system/app/VenomSuperUser.odex
rm -rf /system/app/VenomSuperUser
rm -f /data/dalvik-cache/*com.noshufou.android.su*
rm -f /data/dalvik-cache/*/*com.noshufou.android.su*
rm -f /data/dalvik-cache/*com.koushikdutta.superuser*
rm -f /data/dalvik-cache/*/*com.koushikdutta.superuser*
rm -f /data/dalvik-cache/*com.mgyun.shua.su*
rm -f /data/dalvik-cache/*/*com.mgyun.shua.su*
rm -f /data/dalvik-cache/*com.m0narx.su*
rm -f /data/dalvik-cache/*/*com.m0narx.su*
rm -f /data/dalvik-cache/*com.kingroot.kinguser*
rm -f /data/dalvik-cache/*/*com.kingroot.kinguser*
rm -f /data/dalvik-cache/*com.kingroot.master*
rm -f /data/dalvik-cache/*/*com.kingroot.master*
rm -f /data/dalvik-cache/*Superuser.apk*
rm -f /data/dalvik-cache/*/*Superuser.apk*
rm -f /data/dalvik-cache/*SuperUser.apk*
rm -f /data/dalvik-cache/*/*SuperUser.apk*
rm -f /data/dalvik-cache/*superuser.apk*
rm -f /data/dalvik-cache/*/*superuser.apk*
rm -f /data/dalvik-cache/*VenomSuperUser.apk*
rm -f /data/dalvik-cache/*/*VenomSuperUser.apk*
rm -f /data/dalvik-cache/*eu.chainfire.supersu*
rm -f /data/dalvik-cache/*/*eu.chainfire.supersu*
rm -f /data/dalvik-cache/*Supersu.apk*
rm -f /data/dalvik-cache/*/*Supersu.apk*
rm -f /data/dalvik-cache/*SuperSU.apk*
rm -f /data/dalvik-cache/*/*SuperSU.apk*
rm -f /data/dalvik-cache/*supersu.apk*
rm -f /data/dalvik-cache/*/*supersu.apk*
rm -f /data/dalvik-cache/*.oat
rm -rf /data/app/com.noshufou.android.su*
rm -rf /data/app/com.koushikdutta.superuser*
rm -rf /data/app/com.mgyun.shua.su*
rm -rf /data/app/com.m0narx.su*
rm -rf /data/app/com.kingroot.kinguser*
rm -rf /data/app/com.kingroot.master*
rm -rf /data/app/eu.chainfire.supersu-*
rm -rf /data/app/eu.chainfire.supersu.apk

ui_print "- Creating space"
if ($APKFOLDER); then
  if [ -f "/system/app/Maps/Maps.apk" ]; then
    cp /system/app/Maps/Maps.apk /Maps.apk
    rm /system/app/Maps/Maps.apk
  fi
  if [ -f "/system/app/GMS_Maps/GMS_Maps.apk" ]; then
    cp /system/app/GMS_Maps/GMS_Maps.apk /GMS_Maps.apk
    rm /system/app/GMS_Maps/GMS_Maps.apk
  fi
  if [ -f "/system/app/YouTube/YouTube.apk" ]; then
    cp /system/app/YouTube/YouTube.apk /YouTube.apk
    rm /system/app/YouTube/YouTube.apk
  fi
else
  if [ -f "/system/app/Maps.apk" ]; then
    cp /system/app/Maps.apk /Maps.apk
    rm /system/app/Maps.apk
  fi
  if [ -f "/system/app/GMS_Maps.apk" ]; then
    cp /system/app/GMS_Maps.apk /GMS_Maps.apk
    rm /system/app/GMS_Maps.apk
  fi
  if [ -f "/system/app/YouTube.apk" ]; then
    cp /system/app/YouTube.apk /YouTube.apk
    rm /system/app/YouTube.apk
  fi
fi

ui_print "- Placing files"

mkdir /system/bin/.ext
set_perm 0 0 0777 /system/bin/.ext
cp_perm 0 0 $SUMOD $BIN/$SU /system/bin/.ext/.su
cp_perm 0 0 $SUMOD $BIN/$SU /system/xbin/su
cp_perm 0 0 0755 $BIN/$SU /system/xbin/daemonsu
if ($SUGOTE); then
  cp_perm 0 0 0755 $BIN/$SU /system/xbin/sugote u:object_r:zygote_exec:s0
  cp_perm 0 0 0755 $MKSH /system/xbin/sugote-mksh
fi
if ($SUPOLICY); then
  cp_perm 0 0 0755 $BIN/supolicy /system/xbin/supolicy
  cp_perm 0 0 0644 $BIN/libsupol.so $SYSTEMLIB/libsupol.so
fi
if ($APKFOLDER); then
  mkdir /system/app/SuperSU
  set_perm 0 0 0755 /system/app/SuperSU
fi
cp_perm 0 0 0644 $COM/Superuser.apk $APKNAME
cp_perm 0 0 0755 $COM/install-recovery.sh /system/etc/install-recovery.sh
ln_con /system/etc/install-recovery.sh /system/bin/install-recovery.sh
if ($APPPROCESS); then
  rm /system/bin/app_process
  ln_con /system/xbin/daemonsu /system/bin/app_process
  if ($APPPROCESS64); then
    if [ ! -f "/system/bin/app_process64_original" ]; then
      mv /system/bin/app_process64 /system/bin/app_process64_original
    else
      rm /system/bin/app_process64
    fi
    ln_con /system/xbin/daemonsu /system/bin/app_process64
    if [ ! -f "/system/bin/app_process_init" ]; then
      cp_perm 0 2000 0755 /system/bin/app_process64_original /system/bin/app_process_init
    fi
  else
    if [ ! -f "/system/bin/app_process32_original" ]; then
      mv /system/bin/app_process32 /system/bin/app_process32_original
    else
      rm /system/bin/app_process32
    fi
    ln_con /system/xbin/daemonsu /system/bin/app_process32
    if [ ! -f "/system/bin/app_process_init" ]; then
      cp_perm 0 2000 0755 /system/bin/app_process32_original /system/bin/app_process_init
    fi
  fi
fi
cp_perm 0 0 0744 $COM/99SuperSUDaemon /system/etc/init.d/99SuperSUDaemon
echo 1 > /system/etc/.installed_su_daemon
set_perm 0 0 0644 /system/etc/.installed_su_daemon

ui_print "- Restoring files"
if ($APKFOLDER); then
  if [ -f "/Maps.apk" ]; then
    cp_perm 0 0 0644 /Maps.apk /system/app/Maps/Maps.apk
    rm /Maps.apk
  fi
  if [ -f "/GMS_Maps.apk" ]; then
    cp_perm 0 0 0644 /GMS_Maps.apk /system/app/GMS_Maps/GMS_Maps.apk
    rm /GMS_Maps.apk
  fi
  if [ -f "/YouTube.apk" ]; then
    cp_perm 0 0 0644 /YouTube.apk /system/app/YouTube/YouTube.apk
    rm /YouTube.apk
  fi
else
  if [ -f "/Maps.apk" ]; then
    cp_perm 0 0 0644 /Maps.apk /system/app/Maps.apk
    rm /Maps.apk
  fi
  if [ -f "/GMS_Maps.apk" ]; then
    cp_perm 0 0 0644 /GMS_Maps.apk /system/app/GMS_Maps.apk
    rm /GMS_Maps.apk
  fi
  if [ -f "/YouTube.apk" ]; then
    cp_perm 0 0 0644 /YouTube.apk /system/app/YouTube.apk
    rm /YouTube.apk
  fi
fi

ui_print "- Post-installation script"
rm /system/toybox
rm /system/toolbox
LD_LIBRARY_PATH=$SYSTEMLIB /system/xbin/su --install

ui_print "- Unmounting /system and /data"
umount /system
umount /data

ui_print "- Done !"
exit 0
