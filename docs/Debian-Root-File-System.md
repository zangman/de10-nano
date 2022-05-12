<p align="right"><sup><a href="Building-the-Kernel.md">Back</a> | <a href="Building-the-SD-Card-image.md">Next</a> | </sup><a href="../README.md#getting-started"><sup>Contents</sup></a>
<br/>
<sup>Building Embedded Linux - Full Custom</sup></p>

# Debian Root File System

## Summary

There are several flavours of rootfs to choose from. This one focuses on the Debian rootfs. This will give you an environment similar to the Rasbperry Pi OS for your DE10-Nano. There is a small note in the Appendix about BuildRoot and Yocto if you're interested in the differences.

## Debootstrap and QEMU

Debootstrap is a utility that makes it easy to create a rootfs on an existing Debian based machine. However, since our host machine is most likely `x86_64` and we are targeting an `armhf` architecture for the DE10-Nano, we will need to install an emulator from the [QEMU project](https://wiki.qemu.org/Main_Page). To install both on your host OS:

```bash
sudo apt install debootstrap qemu-user-static
```

## First Stage

In the first stage, we will create a directory to hold the rootfs. Note that almost all the commands in this part will be done as root using `sudo` so take care not to make any mistakes.

```bash
cd $DEWD
mkdir rootfs

# buster is the latest debian version at the time of writing.
# Replace it with whatever is the latest.
sudo debootstrap --arch=armhf --foreign buster rootfs
```

## Second Stage

First, we have to copy over `qemu` to the target file system and `chroot` to target. Without copying over `qemu` we cannot `chroot`.

```bash
cd $DEWD
sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin/
```

Now we should be able to `chroot`:

```bash
sudo chroot rootfs /usr/bin/qemu-arm-static /bin/bash -i
```

Once in the `chroot`-ed environment, we can kick off the second stage of `debootstrap`:

```bash
/debootstrap/debootstrap --second-stage
```

This will take about 5 minutes to complete.

## NOTE - Manjaro/Arch

If your development machine is running Manjaro/Arch linux then the following commands are needed:

```bash
# Install debootstrap.
sudo pacman -S debootstrap

# Install qemu-arm-static. Note that qemu-arm won't work and we need
# qemu-arm-static.
cd /tmp
git clone https://aur.archlinux.org/qemu-arm-static.git
cd qemu-arm-static
makepkg -si
```

Also, when creating the rootfs directory, it needs to be done from a folder which is owned by root:

```bash
sudo mkdir -p /var/tmp/rootfs
cd /var/tmp
```

And proceed with the same steps as above to create the rootfs.

## Configuration

While still in the `chroot` environment, let's do some setup so that our rootfs is more convenient to use.

- **Ugh, where's vim?** - Vim is my preferred editor, so I'll install it first before I do anything else. If you're comfortable using nano as the editor, then you can skip this.

  ```bash
  apt install vim -y
  ```

- **Hostname** - Change the name to be different from the current host distro in `/etc/hostname`. I call mine `de10-nano`.

- **Root password** - Set the root password so it is not blank. I just set it to 'root'.

  ```bash
  passwd
  ```

- **fstab** - Let's update fstab so that the system auto mounts the drives. Copy the following lines as is into `/etc/fstab`:

  ```bash
  none		/tmp	tmpfs	defaults,noatime,mode=1777	0	0
  /dev/mmcblk0p2	/	ext4	defaults	0	1
  ```

- **Enable the serial console** - This allows you to see all the messages at boot time without having to ssh into the device using a simple serial console (Putty, minicom etc)

  ```bash
  systemctl enable serial-getty@ttyS0.service
  ```

- **Locales** - Configure and install the locales you will need. For me, this is just `en_US.UTF-8`:

  ```bash
  apt install locales -y
  dpkg-reconfigure locales
  ```

- **Ethernet** - To get the ethernet on the DE10-Nano working, we need to add the following to the file`/etc/network/interfaces` under the line that says `source-directory /etc/network/interfaces.d`. This will enable DHCP:

  ```bash
  auto lo eth0
  iface lo inet loopback

  allow-hotplug eth0
  iface eth0 inet dhcp
  ```

- **Sources.list** - Use a more complete apt `sources.list`. Edit the file `/etc/apt/sources.list` and add the following. Replace `buster` with whatever version of debian you are using:

  ```bash
  deb http://deb.debian.org/debian/ buster main contrib non-free
  deb-src http://deb.debian.org/debian/ buster main contrib non-free
  deb http://deb.debian.org/debian/ buster-updates main contrib non-free
  deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free
  deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free
  deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free
  ```

- **Openssh-Server** - Install `openssh-server` so that you can `ssh` into the device:

  ```bash
  apt install openssh-server -y
  ```

- **(Optional) Root login over ssh** - If you want to ssh as root, add/uncomment the following line in `/etc/ssh/sshd_config`:

  ```bash
  PermitRootLogin yes
  ```

- **(Optional) Add a user** - TODO - add a user and enable sudo.

- **PRNG entropy seeding speedups** - This speeds up the ssh server startup time on debian buster. See [here](http://linux-sunxi.org/Debootstrap) for more details.

  ```bash
  apt install haveged -y
  ```

- **Install any other packages** - You can install any other packages you need as well:

  ```bash
  apt install net-tools build-essential device-tree-compiler -y
  ```

  > **Explanation**:
  >
  > - net-tools makes the `ifconfig` command available.
  > - build-essential install `gcc` and allows you to compile programs on the DE10-Nano.
  > - device-tree-compiler is needed to compile the device tree when flashing the FPGA directly from the HPS.

## (Optional) Setup WIFI

You can also do the necessary steps for setting up WIFI as detailed [here](https://github.com/zangman/de10-nano/wiki/%5BOptional%5D-Setting-up-Wifi#install-the-necessary-firmware). This is optional and can be done later on also if you can connect your de10-nano to the LAN.

## Clean up

Run the following for some basic clean up:

```bash
# Remove cached packages.
apt clean

# Remove QEMU.
rm /usr/bin/qemu-arm-static

# Exit from the chroot.
exit
```

## Create a tarball

The last step is to create a tarball that we will extract into our SD Card partition:

```bash
cd $DEWD
cd rootfs

# Don't forget the dot at the end.
# Also has to be run as root.
sudo tar -cjpf $DEWD/rootfs.tar.bz2 .

# One level up to see the file.
cd ..
```

And that completes the Debian rootfs. Be careful when extracting this as it will extract everything within the same directory (without creating another directory).

## References

[Quck and easy bootstrap of Debian for armhf](https://blog.lazy-evaluation.net/posts/linux/debian-armhf-bootstrap.html)

[Debootstrap - Linux-Sunxi](http://linux-sunxi.org/Debootstrap)

## Appendix

### BuildRoot and Yocto

[BuildRoot](https://buildroot.org/) and [Yocto](https://www.yoctoproject.org/) are two of the most popular embedded linux generating platforms out there. No doubt you would have heard of them. They are mature and well supported and used by many device manufacturers globally. However, in this guide, I chose to go with Debian instead of either of these. And the reason for that is the target audience. Both BuildRoot and Yocto are designed to build a highly customised and restricted linux OS that the manufacturer wants to have on their device (smartwatch, router, microwave etc). And some of the benefits are:

- Optimized for tiny footprint
- Packages installed are restricted
- Well supported steps for firmware updates

I wanted a general purpose OS for my DE10-Nano which is why I chose to go with Debian. But if you're doing this for work, chances are you're pretty much looking for BuildRoot or Yocto.

##

<p align="right">Next | <b><a href="Building-the-SD-Card-image.md">Creating the SD Card Image</a></b>
<br/>
Back | <b><a href="Building-the-Kernel.md">Building the Kernel</a></p>
</b><p align="center"><sup>Building Embedded Linux - Full Custom | </sup><a href="../README.md#building-embedded-linux---full-custom"><sup>Table of Contents</sup></a></p>
