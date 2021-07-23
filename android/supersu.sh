#!/bin/bash

set -e
# SYSTEM="$PWD"
set_perm() {
  sudo chown $1.$2 $4
  sudo chown $1:$2 $4
  sudo chmod $3 $4
  #ch_con $4
  #ch_con_ext $4 $5
}

cp_perm() {
   sudo rm $5 || true
  if [ -f "$4" ]; then
    sudo cp -f $4 $5
    set_perm $1 $2 $3 $5 $6
  fi
}
SUPERSU_DIR="../../BETA-SuperSU-v2.52/"
ARCH=x86
BIN="$SUPERSU_DIR/$ARCH"
COM="$SUPERSU_DIR/common"
SYSTEMLIB=lib
MKSH=bin/sh
SU=su.pie
SUMOD=0755
SUGOTE=true
SUPOLICY=true

sudo mkdir -p bin/.ext
set_perm 0 0 0777 bin/.ext
cp_perm 0 0 $SUMOD $BIN/$SU bin/.ext/.su
cp_perm 0 0 $SUMOD $BIN/$SU xbin/su
cp_perm 0 0 0755 $BIN/$SU xbin/daemonsu
if ($SUGOTE); then
  cp_perm 0 0 0755 $BIN/$SU xbin/sugote u:object_r:zygote_exec:s0
  cp_perm 0 0 0755 $MKSH xbin/sugote-mksh
fi
if ($SUPOLICY); then
  cp_perm 0 0 0755 $BIN/supolicy xbin/supolicy
  cp_perm 0 0 0644 $BIN/libsupol.so $SYSTEMLIB/libsupol.so
fi
