<p align="right"><sup><a href="Building-the-Kernal-RootFS-Choose-One.md">Back</a> | <a href="%5BOptional%5D-Setting-up-Wifi.md">Next</a> | </sup><a href="../README.md#getting-started"><sup>Contents</sup></a>
<br/>
<sup>Building Embedded Linux - Full Custom</sup></p>

# Building the SD Card Image

## Summary

Before reading this, you should have completed the sections on building the bootloader, the kernel, rootfs (for debian) and the device tree. Your hard work has paid off and we're almost at the finish line! We now have all the parts needed to create our own Embedded Linux distro for the DE10-Nano.

There are several ways to build a bootable image. Rocketboards has a [python script](https://rocketboards.org/foswiki/Documentation/BuildingBootloader#Cyclone_V_SoC_45_Boot_from_SD_Card) that automatically creates one for you.

## Steps

### Create the SD Card image file

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

> **Note**: For larger images, there are several more practical options available now instead of `dd` (such as `fallocate`). I refer you to [this stackoverflow question](https://stackoverflow.com/questions/257844/quickly-create-a-large-file-on-a-linux-system).
>
> For example, to create a 10GB image quickly `fallocate` is much faster:
>
> ```bash
> fallocate -l 10G sdcard.img
> ```

Let's make it visible as a device. This will enable us to treat this file as a disk drive so we can work with it.

```bash
sudo losetup --show -f sdcard.img
```

This should output the loopback device. You should see something like `/dev/loop0`.

### Partitioning the drive

To run Embedded Linux on the DE10-Nano, we need 3 partitions as shown in the table below. Partition numbers have to be exactly as shown below. File sizes also have to be exactly as shown, except for the Root Filesystem which can be increased to take up all the remaining space on the SD card. In our case, we're using a 1GB image file so, we'll have the Root Filesystem take up around 750MB.

Note that you should create them in the exact order listed when using fdisk.

> **Suggestion**: If you are creating an image and writing to an SD card several times because you are trying some experimental features, it's better to keep the file size low like 1GB for the entire SD card. This makes it faster to write the image to the SD Card.

| Order | Partition              | Partition Type | Partition Number | Last Sector | FS Type       | FS Hex Code |
| ----- | ---------------------- | -------------- | ---------------- | ----------- | ------------- | ----------- |
| 1     | U-Boot and SPL         | primary        | 3                | +1M         | Altera Custom | a2          |
| 2     | Kernel and Device Tree | primary        | 1                | +254M       | fat32         | b           |
| 3     | Root Filesystem        | primary        | 2                | _default_   | ext4          | 83          |

To partition the file, we're going to use `fdisk`:

```bash
sudo fdisk /dev/loop0
```

Press `p` and `enter` to see the list of partitions:

```bash
Welcome to fdisk (util-linux 2.33.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): p
Disk /dev/loop0: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xef52db22

Command (m for help):
```

#### Bootloader partition

As you can see, there are no partitions at the moment. Let's create them as per the table above. For the first partition, you will need to type in the following commands in the fdisk prompt. For example, the first step is `n` followed by `enter`.

1. `n`, `enter`
2. `p`, `enter`
3. `3`, `enter`
4. `enter`
5. `+1M`, `enter`

If you typed everything correctly, it should look as shown below:

```bash
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 3
First sector (2048-2097151, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-2097151, default 2097151): +1M

Created a new partition 3 of type 'Linux' and of size 1 MiB.

Command (m for help):
```

You can see that it assigned it the default filesystem of `Linux`. We need to change that to `Altera Custom`. This is not a standard filesystem, so we'll need to manually assign the hex code `a2`. For this, enter the following commands:

1. `t`, `enter`
2. `a2`, `enter`

```bash
Command (m for help): t
Selected partition 3
Hex code (type L to list all codes): a2
Changed type of partition 'Linux' to 'unknown'.
```

#### Kernel and Device Tree partition

For the next partition, type the following commands:

1. `n`, `enter`
2. `p`, `enter`
3. `1`, `enter`
4. `enter`
5. `+254M`, `enter`

The output should look like:

```bash
Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1,2,4, default 1): 1
First sector (4096-2097151, default 4096):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4096-2097151, default 2097151): +254M

Created a new partition 1 of type 'Linux' and of size 254 MiB.

Command (m for help):
```

Again, let's change the filesystem type. Type the following commands:

1. `t`, `enter`
2. `1`,`enter`
3. `b`, `enter`

```bash
Command (m for help): t
Partition number (1,3, default 3): 1
Hex code (type L to list all codes): b

Changed type of partition 'Linux' to 'W95 FAT32'.

Command (m for help):
```

#### Root Partition

For the last partition, we will assign whatever space remains in the image file. Here are the commands:

1. `n`, `enter`
2. `p`, `enter`
3. `2`, `enter`
4. `enter`
5. `enter`

```bash
Command (m for help): n
Partition type
   p   primary (2 primary, 0 extended, 2 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2,4, default 2): 2
First sector (524288-2097151, default 524288):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (524288-2097151, default 2097151):

Created a new partition 2 of type 'Linux' and of size 768 MiB.
```

We will keep the default `Linux` partition type for this.

#### Writing the partition table

Check that the partitions are created as expected. Here is what I see when I type in `p`, `enter`:

```bash
Command (m for help): p
Disk /dev/loop0: 1 GiB, 1073741824 bytes, 2097152 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xef52db22

Device       Boot  Start     End Sectors  Size Id Type
/dev/loop0p1        4096  524287  520192  254M  b W95 FAT32
/dev/loop0p2      524288 2097151 1572864  768M 83 Linux
/dev/loop0p3        2048    4095    2048    1M a2 unknown
```

The partitions created so far haven't been written to the image file yet. So let's put them in with the command `w`, `enter`:

```bash
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Re-reading the partition table failed.: Invalid argument

The kernel still uses the old table. The new table will be used at the next reboot or after you run partprobe(8) or kpartx(8).
```

The error in the message tells us that the partitions haven't been loaded by the kernel, which is indeed the case if you type:

```bash
ls /dev/loop0*
```

you will see we only have one device `/dev/loop0` and the partitions are not visible.

To access them for mounting and writing the contents, we have to run

```bash
sudo partprobe /dev/loop0
```

Now if you type:

```bash
ls /dev/loop0*
```

You should see the partitions:

```bash
/dev/loop0  /dev/loop0p1  /dev/loop0p2  /dev/loop0p3
```

### Creating the file systems

Lets create the fat and ext4 filesystems:

```bash
# Partition 1 is FAT
sudo mkfs -t vfat /dev/loop0p1

# Partition 2 is Linux
sudo mkfs.ext4 /dev/loop0p2
```

### Writing to the partitions

Now we'll populate the various partitions.

#### Bootloader partition

The bootloader partition is a binary partition which needs to be written in raw format. We don't have to mount it, so we'll just use the `dd` command to write it directly:

```bash
cd $DEWD
cd sdcard
sudo dd if=../u-boot/u-boot-with-spl.sfp of=/dev/loop0p3 bs=64k seek=0 oflag=sync
```

#### Kernel and Device Tree partition

This is a fat partition, so we'll need to mount it first and copy the files:

```bash
cd $DEWD
cd sdcard
mkdir -p fat

# Mount the fat partition.
sudo mount /dev/loop0p1 fat

# Copy the kernel image.
sudo cp ../linux-socfpga/arch/arm/boot/zImage fat

# Copy the de0 device tree.
sudo cp ../linux-socfpga/arch/arm/boot/dts/socfpga_cyclone5_de0_nano_soc.dtb fat

# Create the extlinux config file for the bootloader.
echo "LABEL Linux Default" > extlinux.conf
echo "    KERNEL ../zImage" >> extlinux.conf
echo "    FDT ../socfpga_cyclone5_de0_nano_soc.dtb" >> extlinux.conf
echo "    APPEND root=/dev/mmcblk0p2 rw rootwait earlyprintk console=ttyS0,115200n8" >> extlinux.conf

# Copy it into the extlinux folder.
sudo mkdir -p fat/extlinux
sudo cp extlinux.conf fat/extlinux

# Unmount the partition.
sudo umount fat
```

> **Note**: One thing to call out is that we are using the device tree for the DE0. The reasons for this are explained in the appendix.

#### Root Filesystem partition

> Note: If your rootfs is Archlinux ARM, then jump to [this section](https://github.com/zangman/de10-nano/wiki/Archlinux-ARM-Root-File-System) to continue with the rootfs setup instead of the steps below.

For the final partition, here are the steps:

```bash
cd $DEWD
cd sdcard
mkdir -p ext4

# Mount the ext4 partition.
sudo mount /dev/loop0p2 ext4

# Extract the rootfs archive.
cd ext4
sudo tar -xf $DEWD/rootfs.tar.bz2

# Unmount the partition.
cd ..
sudo umount ext4
```

Quite straightfoward.

### Cleanup

Run the following commands to clean up:

```bash
# Delete unnecessary files and folders.
cd $DEWD
cd sdcard
rmdir fat
rmdir ext4
rm extlinux.conf

# Delete the loopback device.
sudo losetup -d /dev/loop0
```

### Writing to SD Card

The hard work is done. Now all that's left is to write the `sdcard.img` file to an actual SD Card and we're ready to boot.

#### Writing in Linux

If you are not using Virtualbox for your Debian OS or if you have access to the SD Card device directly in the virtual machine, then you can use the following command to write the image file directly to the SD Card.

> **WARNING** - Be extremely careful with the command below. If you type the wrong device, there are no warnings, it will wipe your system clean.

```bash
cd $DEWD
cd sdcard

# Identify your SD Card device.
lsblk

# Write to the correct device (Ex: /dev/sdb).
sudo dd if=sdcard.img of=/dev/sdb bs=64K status=progress
```

##### Note: Writing to a used SD Card

This is taken from [this stack exchange link](https://raspberrypi.stackexchange.com/a/108628).

If we are writing to an SD card that was already written to with an image file before, we need to delete all the partitions on the sd card before writing to it again.

To do this, we can use fdisk as follows:

1.  `d`, `enter`
1.  `enter`
1.  `d`, `enter`
1.  `enter`
1.  `d`, `enter`
1.  `enter`
1.  `w`, `enter`

Example output below:

```bash
Command (m for help): d
Partition number (1-3, default 3):

Partition 3 has been deleted.

Command (m for help): d
Partition number (1,2, default 2):

Partition 2 has been deleted.

Command (m for help): d
Selected partition 1
Partition 1 has been deleted.

Command (m for help): d
No partition is defined yet!

Command (m for help): w

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

After this, we can run the `dd` command as shown above.

#### Writing in Windows

If, like me, your SD Card reader is attached to your laptop and not available as a USB device to access through virtualbox, you will need to transfer the file to windows and then use [Rufus](https://rufus.ie/) to write to the SD Card.

You can transfer the file either by creating a shared folder to transfer between virtualbox and the host windows system or by uploading it to Google Drive and then downloading in windows.

## References

[Building embedded linux for the Terasic DE10-Nano](https://bitlog.it/20170820_building_embedded_linux_for_the_terasic_de10-nano.html) - A large part of this page has been taken from here.

## Appendix

### Scripts to automate the SD Card creation

It is possible to automate all the steps above with a simple shell script. If you are interested in doing this, you can look at [this example](https://github.com/zangman/de10-nano/blob/master/scripts/create_disk.sh) which shows how to do it. One thing to note is that since `fdisk` is a dialogue based utility, it's a bit trickier to automate. So I chose to use `sfdisk` which is also installed along with `fdisk` to do it. It takes a [template file](https://github.com/zangman/de10-nano/blob/master/scripts/sdcard_template) to copy from.

This [stackoverflow link](https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script) has more details on how to automate both `fdisk` and `sfdisk`.

### Note on the DE0 Device Tree

You might be wondering why we're using the DE0's device tree and not the DE10's. Short answer - it's complicated.

Let's back up a bit about what the device tree does and why we need it. The device tree provides information to the kernel about various parameters for the hardware devices on the board (UART, I2C, etc) along with information on which device driver to use.

Device trees for specific boards, such as the DE10-Nano, are provided by the vendors and are submitted via a pull request in 2 locations:

- The official Linux kernel sources ([linux](https://github.com/torvalds/linux))
- The official U-Boot sources ([u-boot](https://github.com/u-boot/u-boot))

However, in the case of the DE10-Nano, there are some additional customisations, drivers etc made by Altera/Intel in their own forks of the sources. These are available here:

- Altera Linux kernel sources ([linux-socfpga](https://github.com/altera-opensource/linux-socfpga))
- Altera U-Boot sources ([u-boot-socfpga](https://github.com/altera-opensource/u-boot-socfpga))

The device tree source files (dts) are generally submitted to both Linux and U-Boot. However, as it turns out, for the Altera devices, both of them are not in sync.

But what is not in sync? The device trees for the DE10-Nano? Why does it matter?

_Sigh_, this needs more explanation.

Typically, the way the device trees are structured for each board, there are 3 prominent files:

1. The board's device tree source file (Ex: `socfpga_cyclone5_de0_nano_soc.dts`)
2. Cyclone5 device tree source include file (viz., `socfpga_cyclone5.dtsi`) which the above file depends on.
3. Socfpga device tree source include file (viz., `socfpga.dtsi`) which the file in #2 depends on.

The way it stands right now, the DE10-Nano has a device tree available in U-Boot sources (`socfpga_cyclone5_de10_nano.dts`), but not in the Linux sources. You could use the device tree for the DE10-Nano from `u-boot-socfpga` and it will work fine to boot linux. However, there are some additional changes that were added to `socfpga.dtsi` in the kernel sources which are more recent (Ex: the bridge from FPGA to HPS was added). But there is no DE10-Nano device tree in the linux sources.

I gave the DE0 device tree a try from the Linux kernel and it worked fine. So I decided to stick with it for now. Perhaps in the future someone will clean this mess up and then we can use the DE10-Nano device tree and all will be well.

The alternative is to copy the DE10 device tree from U-Boot into the linux sources, maintain my own branch and modify it to work with the board. Totally acceptable (and perhaps better) option. But for me, this was easier so I decided to stick with it.

I hope that helps explain this.

### Note on updating sdcard.img

I wasted a lot of time on this, so just putting it here in case you run into the same.

When experimenting with different builds of U-Boot, I was reusing the same `sdcard.img` file and simply running `dd` to overwrite the binary partition, which is `/dev/loop0p3` in our guide. However, when I did this and wrote to the SD Card it kept using the old version of the bootloader. After a lot of time debugging, it turns out the reason it wasn't updating was because `dd` doesn't wipe the entire partition. It just streams whatever you have to the destination. So the bits may get overwritten or maybe not.

The solution is to wipe the partition clean before updating it. This can be done with the following command which fills it with zeros till the partition runs out of space:

```bash
sudo dd if=/dev/zero of=/dev/loop0p3 bs=64k oflag=sync status=progress
```

##

<p align="right">Next | <b><a href="%5BOptional%5D-Setting-up-Wifi.md">(Optional) Setting up WIFI</a></b>
<br/>
Back | <b><a href="Building-the-Kernal-RootFS-Choose-One.md">RootFS - Choose one</a></p>
</b><p align="center"><sup>Building Embedded Linux - Full Custom | </sup><a href="../README.md#building-embedded-linux---full-custom"><sup>Table of Contents</sup></a></p>
