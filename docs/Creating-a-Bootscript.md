<p align="right"><sup><a href="SSH-Without-Password.md">Back</a> | </sup><a href="../README.md#appendix"><sup>Contents</sup></a>
<br/>
<sup>Appendix</sup></p>

# Creating a Bootscript

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Summary](#summary)
- [Pre-requisites](#pre-requisites)
- [Steps](#steps)
  - [Create the bootscript source file](#create-the-bootscript-source-file)
  - [Compile the boot script source](#compile-the-boot-script-source)
  - [Copy the compiled script to de10-nano](#copy-the-compiled-script-to-de10-nano)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

If you need to run some additional commands at boot time, instead of updating `bootcmd` in u-boot sources and writing to sd card, it's easier to just create a script file and copy that to the fat partition. Here we will create a simple bootscript that enables the required registers for access to SDRAM.

## Pre-requisites

You will require U-Boot sources available as described in the [Building U-Boot](./Building-the-Universal-Bootloader-U-Boot.md#configure-u-boot-to-flash-fpga-automatically-at-boot-time) section. [This section](./Building-the-Universal-Bootloader-U-Boot.md#configure-u-boot-to-flash-fpga-automatically-at-boot-time) shows how to modify `bootcmd` to check for a bootscript and you will need to have followed the same/similar steps when setting up U-Boot for your device.

## Steps

### Create the bootscript source file

We'll first write all the commands we need in a text file called `bootscript.txt`. This file will be compiled into a bootscript image file.

For my specific example, I need to perform the following steps:

1. Check if an image titled `sdr.rbf` is present in the fat partition.
2. If yes, then modify registers before flashing the design and then modify a few registers after than and then continue.

The code I'm using here is specific to accessing SDRAM from the FPGA, you can replace it with whatever you need:

```bash
if test -e mmc 0:1 sdr.rbf; then
  echo "Found sdr.rbf"
  mw 0xFFC25080 0x0
  fatload mmc 0:1 0x3000000 sdr.rbf
  fpga load 0 0x3000000 0x700000
  mw 0xFFC2505C 0xA
  mw 0xFFC25080 0xFFFF
else
  echo sdr.rbf not found, doing nothing
fi;
```

Save this as `bootscript.txt`.

### Compile the boot script source

We need to compile the bootscript source so that U-Boot can read it. U-Boot ships with a compiler called `mkimage` which we'll use to compile for the de10-nano as follows:

```bash
$DEWD/u-boot/tools/mkimage -C none -A arm -T script -d bootscript.txt u-boot.scr
```

The params used here are explained as follows:

- `-C none` - No compression
- `-A arm` - ARM architecture
- `-T script` - this is a script type
- `-d booscript.txt` - path to the source file
- `u-boot.scr` - Output file name

### Copy the compiled script to de10-nano

Copy the u-boot.scr to the fat partition of the de10-nano. This can be done with the following commands:

```bash
scp u-boot.scr root@<de10-ip-address>:~

# Login to de10-nano and copy the file to fat.
ssh root@<de10-ip-address>
mkdir -p fat
mount /dev/mmcblk0p1 fat
cp u-boot.scr fat/
umount fat
```

And that's it!

## References

[Sunxi U-Boot](https://linux-sunxi.org/U-Boot) - The command, syntax and params for `mkimage` are from this page.

<p align="right">Back | <b><a href="SSH-Without-Password.md">SSH Without Password</a></p>
</b><p align="center"><sup>Appendix | </sup><a href="../README.md#appendix"><sup>Table of Contents</sup></a></p>
