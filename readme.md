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

cat /proc/cmdline                                           
androidboot.bootloader=1546.300_M1S1 androidboot.serialno=0123456789012345678901234567890 pmu_rst_src=0x00010004 pmu_shutdwn_src=0x00000000 scu_rsts=0x10018003 scu_bcfg=0x0C1F8981 param=1 androidboot.mode=normal console=ttyFIQ0,115200n8 idle=halt earlyprintk=xgold notsc apic=sofia androidboot.hardware=sofiaboard nolapic_pm firmware_class.path=/system/vendor/firmware androidboot.selinux=permissive x86_intel_xgold_timer=soctimer_only vmalloc=512m slub_max_order=2

- Host system is Linux Debian x86_64
- Install platformflashtoollite in tools
- Get mkbootimg & unpackbootimg

Flash fls file (Recover boot)

``` bash
# Load PATH & LIB of intel's DownloadTool / flsTool
. setup-env.sh

# Unpack boot.img
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
downloadTool kernel/boot.fls


```
