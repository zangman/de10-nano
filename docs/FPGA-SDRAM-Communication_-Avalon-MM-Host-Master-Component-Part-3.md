<p align="right"><sup><a href="FPGA-SDRAM-Communication_-Avalon-MM-Host-Master-Component-Part-2.md">Back</a> | <a href="Yocto-Linux.md">Next</a> | </sup><a href="../README.md#fpga---sdram-communication"><sup>Contents</sup></a>
<br/>
<sup>FPGA - SDRAM Communication</sup></p>

# Avalon MM Host/Master - 3

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Summary](#summary)
- [Allocate SDRAM Memory](#allocate-sdram-memory)
- [Set the HPS registers to enable SDRAM access](#set-the-hps-registers-to-enable-sdram-access)
- [Trying out our design](#trying-out-our-design)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

There are some configuration changes that are required before we can flash our design. We'll go through those in this section.

## Allocate SDRAM Memory

We want to have some dedicated memory available for our FPGA. For this we have to inform the Linux kernel not to touch it for any kernel or user programs.

We'll have to add a kernel boot parameter to `extlinux.conf` which is present in the fat partition of the SD Card. You can take out the sd card and plug it into your development machine and make the changes, but I prefer to just do it on the de10-nano.

```bash
# SSH into the de10-nano.
ssh root@<ip address>

# Mount the fat partition.
mkdir fat
mount /dev/mmcblk0p1 fat

# Open the file for editing.
vim fat/extlinux/extlinux.conf
```

Add the boot parameter `mem=512M` to the line that begins with `APPEND`:

```bash
LABEL Linux Default
    KERNEL ../zImage
    FDT ../socfpga_cyclone5_de0_nano_soc.dtb
    APPEND root=/dev/mmcblk0p2 rw rootwait earlyprintk console=ttyS0,115200n8 net.ifnames=0 mem=512M
```

In our reader component (`avalon_sdr`), we had hardcoded the address as `32'h2000_0000` which translates to 512 MB. We don't really need to reserve so much memory, but it's what I used :).

Save the file and unmount the partition:

```bash
umount fat
```

## Set the HPS registers to enable SDRAM access

I struggled with this for a couple of weeks. There isn't much information available to explain how to do this. Luckily, I finally found [this article](https://support.criticallink.com/redmine/projects/mityarm-5cs/wiki/Important_Note_about_FPGAHPS_SDRAM_Bridge) from 2013 that explains what HPS registers need to be enabled.

Using this along with the [Register Address Map](https://www.intel.com/content/www/us/en/programmable/hps/cyclone-v/hps.html#sfo1411577376106.html), I was finally able to get this working.

We will need serial access to the device as we need to access the u-boot console. So make sure that you connect the de10-nano with a usb cable on the serial connector and plug it into your development machine. You will need something like PuTTy or picocom to connect to it.

What we need to do is:

1. Copy the design to the fat partition:

   ```bash
   # Copy the rbf from dev machine to de10-nano.
   scp soc_system.rbf root@<ip address>:~

   # SSH to the de10-nano
   ssh root@<ip address>

   # Mount fat partition.
   mkdir fat
   mount /dev/mmcblk0p1 fat

   # Copy it and rename it to sdr.rbf.
   cp soc_system.rbf fat/sdr.rbf

   # Unmount fat.
   umount fat

   # Reboot the device.
   reboot
   ```

2. Reboot the de10-nano. When you see the message "Hit any key to stop autoboot", press any key. This will drop you into the u-boot console.

3. In the u-boot console, first set `fpga2sdram` peripheral to reset by writing zero to [`fpgaportrst`](https://www.intel.com/content/www/us/en/programmable/hps/cyclone-v/hps.html#sfo1411577376106.html) register. This is at address `0xFFC25080`.

   ```bash
   mw 0xFFC25080 0x0
   ```

4. Now we load the `rbf` file into memory and then flash the FPGA with it. The reason we do this is because the FPGA design has some configuration bits on the bridge that get enabled when we flash it. However, this needs to be done when the sdram bridge is in reset mode and when it is not being used by the HPS. Hence it needs to be done in u-boot.

   ```bash
   fatload mmc 0:1 0x2000000 sdr.rbf
   fpga load 0 0x2000000 0x700000
   ```

5. Next we write a 1 to the `applycfg` bit of the [`staticcfg`](https://www.intel.com/content/www/us/en/programmable/hps/cyclone-v/hps.html#sfo1411577374877.html) register. In my case, when I checked the address location with `md 0xFFc2505C`, the value was `0x2`. So to ensure that I only change the `applycfg` bit, I wrote `0xA` to the memory location:

   ```bash
   mw 0xFFC2505C 0xA
   ```

6. Finally, we re-enable the ['fpgaportrst'](https://www.intel.com/content/www/us/en/programmable/hps/cyclone-v/hps.html#sfo1411577376106.html) register:

   ```bash
   mw 0xFFC25080 0xFFFF
   ```

7. And continue the boot process:

   ```bash
   boot
   ```

**NOTE**: If these steps aren't done exactly as explained here, the HPS will hang when the FPGA tries to access SDRAM.

This needs to be done only once when powering it up for the first time. You can then proceed to flash any new designs [without rebooting](./Flash-FPGA-from-HPS-running-Linux.md) even for designs that access the SDRAM. But if you power down the device (not reboot), you will need to go through the steps again.

To avoid doing this repeatedly, you can [create a bootscript](./Creating-a-Bootscript.md) which will make it less tedious.

## Trying out our design

Normally we would write a C program as shown here and use `mmap` to write to device memory. However, I recently discovered a [busybox devmem](https://github.com/brgl/busybox/blob/master/miscutils/devmem.c) which will help us test without writing a program, directly from the linux commandline.

Let's install it first. SSH into the de10-nano and run the following commands:

```bash
sudo apt update
sudo apt install busybox
```

Now we can access any memory location with the command `busybox devmem <address>`. I prefer creating an alias for this to make it easier. Here's how we can test our design to see if it's working:

```bash
# Create alias.
alias mem='busybox devmem'

# Write the desired value to location 0x20000000 (512M).
# 0xAA is 0b10101010, so we should see alternating leds lighting up.
mem 0x20000000 w 0xAA

# Now let's trigger the sdram reader by writing to the starting address
# of the HPS-FPGA bridge which is at 0xC0000000.
# It doesn't matter what we write.
mem 0xC0000000 w 0x1
```

If all goes well, you should see the LEDs lighting up in an alternating pattern.

## References

[Cyclone V HPS Register Address Map and Definitions](https://www.intel.com/content/www/us/en/programmable/hps/cyclone-v/hps.html#sfo1411577376106.html) - Lists all the registers for the HPS.

<p align="right">Next | <b><a href="Yocto-Linux.md">Appendix - Yocto Linux</a></b>
<br/>
<p align="right">Back | <b><a href="FPGA-SDRAM-Communication_-Avalon-MM-Host-Master-Component-Part-2.md">Avalon MM Host/Master - 2</a></p>
</b><p align="center"><sup>FPGA - SDRAM Communication | </sup><a href="../README.md#fpga---sdram-communication"><sup>Table of Contents</sup></a></p>
