# Building the SD Card Image

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Building the SD Card Image](#building-the-sd-card-image)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

Before reading this, you should have completed the sections on building the bootloader, the kernel, rootfs and the device tree. Your hard work has paid off and we're almost at the finish line! We now have all the parts needed to create our own Embedded Linux distro for the DE10-Nano.

There are several ways to build a bootable image. Rocketboards has a [python script](https://rocketboards.org/foswiki/Documentation/BuildingBootloader#Cyclone_V_SoC_45_Boot_from_SD_Card) that automatically creates one for you.

## Steps

### Create the SD Card image file and partitions

Let's create a folder in which we'll create our SD card image:

```bash
cd $DEWD
mkdir sdcard
cd sdcard
```

Let's create an image file of 1GB in size. Adjust the `bs` parameter if you want a bigger or smaller one.

```bash
# Create an image file of 1GB in size.
sudo dd if=/dev/zero of=sdcard.img bs=1G count=1
```

Let's make it visible as a device. This will enable us to treat this file as a disk drive so we can work with it.

```bash
sudo losetup --show -f sdcard.img
```

This should output the loopback device. You should see something like `/dev/loop0`.

Now let's partition this disk drive.