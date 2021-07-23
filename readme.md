# Oprek Advan Vandroid X7 

**Android 5.1 Ram 1 GB Intel Atom X3-C3230RK**

Rooting & custom ramdisk

- Layar: IPS LCD 7 inch, 600 x 1024 pixels (170 ppi)
- Memori internal: 8 GB, 1 GB RAM
- Memori eksternal: MicroSD, hingga 32 GB
- Chipset: Intel Atom X3-C3230RK "64-bit"
- CPU: Quad Core 1 GHz
- GPU: Mali-450 MP4
- Sistem Operasi: Android OS v5.1 (Lollipop)
- Kamera utama: 2 MP, 1600 x 1200 pixels
- Fitur kamera: LED flash, Geo-tagging, face detection, digital zoom
- Kamera depan: VGA
- Baterai: Li-ion 2500 mAh

``` bash
cat /proc/cmdline                                           
androidboot.bootloader=1546.300_M1S1 androidboot.serialno=0123456789012345678901234567890 pmu_rst_src=0x00010004 pmu_shutdwn_src=0x00000000 scu_rsts=0x10018003 scu_bcfg=0x0C1F8981 param=1 androidboot.mode=normal console=ttyFIQ0,115200n8 idle=halt earlyprintk=xgold notsc apic=sofia androidboot.hardware=sofiaboard nolapic_pm firmware_class.path=/system/vendor/firmware androidboot.selinux=permissive x86_intel_xgold_timer=soctimer_only vmalloc=512m slub_max_order=2
```

**Some `getprop` Info**
```
ro.board.platform: sofia3gr
ro.boot.bootloader: 1546.300_M1S1
ro.boot.hardware: sofiaboard
ro.build.characteristics: tablet
ro.build.date.utc: 1448357667
ro.build.date: Tue Nov 24 17:34:27 CST 2015
ro.build.description: sofia3gr-user 5.1.1 LMY48G eng.xiongsf.20151124.173039 release-keys
ro.build.display.id: X7/S9710/V23/20151124
ro.build.fingerprint: Advan/sofia3gr/sofia3gr:5.1.1/LMY48G/xiongsf11241733:user/release-keys
ro.build.flavor: sofia3gr-user
ro.build.host: build119
ro.build.id: LMY48G
ro.build.product: sofia3gr
ro.build.tags: release-keys
ro.build.type: user
ro.build.user: xiongsf
ro.build.version.all_codenames: REL
ro.build.version.codename: REL
ro.build.version.incremental: eng.xiongsf.20151124.173039
ro.build.version.release: 5.1.1
ro.build.version.sdk: 22
ro.product.board: rk30sdk
ro.product.brand: Advan
ro.product.cpu.abi: x86
ro.product.cpu.abilist32: x86,armeabi-v7a,armeabi
ro.product.cpu.abilist64: 
ro.product.cpu.abilist: x86,armeabi-v7a,armeabi
ro.product.device: sofia3gr
ro.product.locale.language: in
ro.product.locale.region: ID
ro.product.manufacturer: Advan
ro.product.model: X7
ro.product.name: sofia3gr
ro.product.ota.host: 223.255.241.214:2300
ro.product.usbfactory: rockchip_usb
ro.product.version: 23.0.0

```

- Host system is Linux Debian x86_64
- Install platformflashtoollite in tools
- Get mkbootimg & unpackbootimg

Flash fls file (Recover boot)

## Modify Ramdisk
Enable insecure, ADB Over wifi

``` bash
# Load PATH & LIB of intel's DownloadTool / flsTool
. setup-env.sh

# Unpack Boot Flash / boot.fls
flsTool -x stock-rom/boot.fls -o tmp/boot
mkdir -p kernel
cp tmp/boot/boot.fls_ID0_CUST_LoadMap0.bin kernel/boot.img


# Unpack Kernel / boot.img
mkdir kernel/boot
unpackbootimg -i kernel/boot.img -o kernel/boot

# Unpack initram
mkdir -p kernel/ramdisk && cd kernel/ramdisk
gzip -dc ../boot/boot.img-ramdisk.gz | cpio -imdv

# Repack Initram && Create custom boot
cd kernel
./makebootimg.sh
adb reboot fastboot
fastboot flash boot custom-boot.img
fastboot reboot

# Restore boot when bricked/bootloop
downloadTool stock-rom/boot.fls
downloadTool stock-rom/system.fls
```

## Modify System / Android

```
# Unpack System Flash / system.fls
flsTool -x stock-rom/system.fls -o tmp/system
mkdir -p android
# Convert sparse to RAW
simg2img tmp/system/system.fls_ID0_CUST_LoadMap0.bin android/system.img

```

## Source ?

- https://github.com/search?l=Makefile&q=rk30sdk&type=repositories
- https://github.com/flingone/device-rockchip-rk30sdk