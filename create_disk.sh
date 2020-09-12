#!/bin/bash
if [[ ${EUID} -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

sdcard_file=${1}
working_dir=${2}

if [ -z ${sdcard_file} ]; then
  echo "Needs name of sdcard file."
  exit 2
fi

if [ -z ${working_dir} ]; then
  echo "Working directory path not specified."
  exit 3
fi

dd if=/dev/zero of=${sdcard_file} bs=1G count=1

lodev=$(losetup --show -f ${sdcard_file})
echo "Loopback device: ${lodev}"

sfdisk ${lodev} < sdcard_template
partprobe ${lodev}

# SPL with U-Boot.
echo "==== Writing spl with u-boot. ===="
dd if=${working_dir}/u-boot/u-boot-with-spl.sfp of=${lodev}p3 bs=64k seek=0
echo "==== Done writing spl ===="

echo "Making fat system."
mkfs -t vfat ${lodev}p1

echo "Making ext4 system."
mkfs.ext4 ${lodev}p2

echo "Mounting file systems."
mkdir -p fat ext4

mount ${lodev}p1 fat
mount ${lodev}p2 ext4

echo "Copying rootfs."
cd ext4
tar -xf ${working_dir}/rootfs.tar.bz2
cd ..

echo "Copying kernel."
cp ${working_dir}/linux/arch/arm/boot/zImage fat/

echo "Copying device tree."
cp ${working_dir}/u-boot/arch/arm/dts/socfpga_cyclone5_de10_nano.dtb fat/

echo "Creating extlinux."
mkdir -p fat/extlinux

echo "LABEL Linux Default" > fat/extlinux/extlinux.conf
echo "    KERNEL ../zImage" >> fat/extlinux/extlinux.conf
echo "    FDT ../socfpga_cyclone5_de10_nano.dtb" >> fat/extlinux/extlinux.conf
echo "    APPEND root=/dev/mmcblk0p2 rw rootwait earlyprintk console=ttyS0,115200n8" >> fat/extlinux/extlinux.conf

echo "Unmounting filesystems."
umount fat
umount ext4

rmdir fat
rmdir ext4

echo "Deleting loopback device ${lodev}"
losetup -d ${lodev}
