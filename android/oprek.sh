#!/bin/sh
set -e
MYDIR="$PWD"
if ! mount | grep -q "$MYDIR/workdir"; then
    mkdir -p workdir
    sudo mount -t tmpfs tmpfs workdir
fi

cleanmount() {
    cd "$MYDIR"
    echo "Cleaning Mount"
    sudo sync
    sudo umount "$MYDIR/workdir/system" || true
    sudo losetup -d $LOOP_DEV || true
}

if [ ! -f workdir/custom-system.img ]; then
    echo "Copying system.img to workdir/custom-system.img.."
    cp system.img workdir/custom-system.img
fi

mkdir -p workdir/system
LOOP_DEV=`sudo losetup --show -f workdir/custom-system.img`
echo "LOOP DEV $LOOP_DEV"
sudo mount -o noatime,rw $LOOP_DEV workdir/system
trap cleanmount 0

cd workdir/system
## Begin modify filesytem

echo "Install SuperSU"
. "$MYDIR/supersu.sh"

echo "Copying Apks"
for f in "$MYDIR"/apks/*.apk; do
    APKNAME="${f##*/}"
    DIRNAME="${APKNAME%.*}"
    DIRNAME="${DIRNAME%-*}"

    echo -n "\t$APKNAME ... "
    if [ -f "app/$DIRNAME/$APKNAME" ]; then
        echo "EXISTS"
        continue
    fi
    sudo mkdir -p "app/$DIRNAME"
    sudo cp -f -T "$f" "app/$DIRNAME/$APKNAME"
    sudo chmod 0755 "app/$DIRNAME/$APKNAME"
    echo "OK"
done



echo "Modify build.prop"
if ! grep 'net.hostname=vandroid-x7' build.prop; then
cat <<EOF | sudo tee -a build.prop
net.hostname=vandroid-x7
EOF
fi

echo "Removing unwanted apps"
sudo rm -rf vendor/bundled_persist-app

cd app
sudo rm -rf adobe_reader
sudo rm -rf AdvanStore
# sudo rm -rf BasicDreams
sudo rm -rf BBM
# sudo rm -rf Bluetooth
# sudo rm -rf Browser
# sudo rm -rf Calculator
# sudo rm -rf Calendar
# sudo rm -rf Camera2
# sudo rm -rf CaptivePortalLogin
# sudo rm -rf CertInstaller
sudo rm -rf CleanMaster
sudo rm -rf CMBrowser
# sudo rm -rf ConfigUpdater
# sudo rm -rf DeskClock
# sudo rm -rf DeviceTest
# sudo rm -rf DocumentsUI
# sudo rm -rf DownloadProviderUi
sudo rm -rf DuSpeedBooster
# sudo rm -rf Email
# sudo rm -rf Exchange2
# sudo rm -rf FMRadio
# sudo rm -rf Galaxy4
# sudo rm -rf Gallery2
# sudo rm -rf Gmail2
# sudo rm -rf GoogleCalendarSyncAdapter
# sudo rm -rf GoogleContactsSyncAdapter
# sudo rm -rf GooglePinyinIME
# sudo rm -rf HoloSpiralWallpaper
# sudo rm -rf HTMLViewer
# sudo rm -rf KeyChain
# sudo rm -rf LatinIME
# sudo rm -rf LiveWallpapers
# sudo rm -rf LiveWallpapersPicker
# sudo rm -rf Manual
# sudo rm -rf Maps
# sudo rm -rf Music
# sudo rm -rf NoiseField
# sudo rm -rf OpenWnn
# sudo rm -rf PackageInstaller
# sudo rm -rf PacProcessor
# sudo rm -rf PhaseBeam
# sudo rm -rf PhotoTable
# sudo rm -rf PicoTts
# sudo rm -rf PrintSpooler
# sudo rm -rf Provision
# sudo rm -rf RFTest
# sudo rm -rf RkApkinstaller
# sudo rm -rf RkExplorer
# sudo rm -rf RKUpdateService
# sudo rm -rf SoundRecorder
# sudo rm -rf Stk
sudo rm -rf TouchPalKeyboard
sudo rm -rf TouchPalKeyboard_IndonesianPack
# sudo rm -rf UserDictionaryProvider
# sudo rm -rf VideoPlayer
# sudo rm -rf VisualizationWallpapers
# sudo rm -rf WAPPushManager
# sudo rm -rf webview

cd ..

## End modify filesystem

echo "Done, result image is $MYDIR/workdir/custom-system.img"
