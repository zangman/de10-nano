<p align="right"><sup><a href="Flash-FPGA-from-HPS-running-Linux.md">Back</a> | </sup><a href="../README.md#flashing-the-fpga-from-sd-card"><sup>Contents</sup></a>
<br/>
<sup>Flashing the FPGA from SD Card</sup></p>

# Flashing the FPGA On Boot Up

## Summary

Flashing the FPGA on boot up is a convenient way to have your design on the FPGA every time the board powers up. Here we will go through the steps to do it. Make sure you've followed the step to [modify the U-Boot to flash the FPGA](<https://github.com/zangman/de10-nano/wiki/Building-the-Universal-Bootloader-(U-Boot)#part-1---customizing-the-bootloader-for-the-de10-nano>), without this, it will not work.

## Steps

### Getting the RBF File

Complete the following steps to generate the `.rbf` file:

- [Set the MSEL pins](<https://github.com/zangman/de10-nano/wiki/Flash-FPGA-from-HPS-(running-Linux)#set-the-msel-pins>)
- [Create a blink design](<https://github.com/zangman/de10-nano/wiki/Flash-FPGA-from-HPS-(running-Linux)#create-a-blink-design>)

### Copy the RBF file into the FAT partition

If you followed the previous links, you should have `blink.rbf` copied onto your DE10-Nano in the root user's home directory.

```bash
ssh root@<ipaddress>

mkdir -p fat
mount /dev/mmcblk0p1 fat

# Our bootloader expects the file to be named soc_system.rbf.
# Rename blink.rbf with whatever your file is called.
cp blink.rbf fat/soc_system.rbf

# Unmount the fat partition.
umount fat

reboot
```

And that's all there is to it. Easy-peasy :).

When it reboots, you should see the following messages which show that the FPGA has been flashed:

```bash
U-Boot 2020.07-00002-g191c20e507-dirty (Sep 20 2020 - 11:21:00 +0800)

CPU:   Altera SoCFPGA Platform
FPGA:  Altera Cyclone V, SE/A6 or SX/C6 or ST/D6, version 0x0
BOOT:  SD/MMC Internal Transceiver (3.0V)
DRAM:  1 GiB
MMC:   dwmmc0@ff704000: 0
Loading Environment from MMC... *** Warning - bad CRC, using default environment

In:    serial
Out:   serial
Err:   serial
Model: Terasic DE10-Nano
Net:   eth0: ethernet@ff702000
Hit any key to stop autoboot:  0
Programming FPGA
7007204 bytes read in 433 ms (15.4 MiB/s)
switch to partitions #0, OK
mmc0 is current device
Scanning mmc 0:1...
Found /extlinux/extlinux.conf
Retrieving file: /extlinux/extlinux.conf
164 bytes read in 9 ms (17.6 KiB/s)
1:      Linux Default
Retrieving file: /extlinux/../zImage
5325792 bytes read in 330 ms (15.4 MiB/s)
append: root=/dev/mmcblk0p2 rw rootwait earlyprintk console=ttyS0,115200n8
Retrieving file: /extlinux/../socfpga_cyclone5_de0_nano_soc.dtb
26037 bytes read in 12 ms (2.1 MiB/s)
## Flattened Device Tree blob at 02000000
   Booting using the fdt blob at 0x2000000
   Loading Device Tree to 09ff6000, end 09fff5b4 ... OK

Starting kernel ...
```

##

<p align="right">Back | <b><a href="Flash-FPGA-from-HPS-running-Linux.md">Flashing the FPGA from Linux</a></p>
</b><p align="center"><sup>Flashing the FPGA from SD Card | </sup><a href="../README.md#flashing-the-fpga-from-sd-card"><sup>Table of Contents</sup></a></p>
