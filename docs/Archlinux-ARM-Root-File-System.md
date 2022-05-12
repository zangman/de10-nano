<p align="right"><sup><a href="Building-the-Kernel.md">Back</a> | <a href="Building-the-SD-Card-image.md">Next</a> | </sup><a href="../README.md#getting-started"><sup>Contents</sup></a>
<br/>
<sup>Building Embedded Linux - Full Custom</sup></p>

# Archlinux ARM Root File System

## Summary

Here we'll walk through the steps to creating an Archlinux ARM root filesystem. I built this in Manjaro linux which is an Archlinux variant. If you use Debian or some other distro to build this, the steps might be a bit different.

## Initial setup

One of the main differences with creating the Archlinux ARM rootfs is we need to create the SD Card image first, mount it and then create our rootfs. I'm not entirely sure why this is required, but I suspect the reason is to take care of the various mount points correctly i.e. `/proc`, `/dev` etc.

In any case, to get started, we'll need to go through all the steps listed [here](https://github.com/zangman/de10-nano/wiki/Building-the-SD-Card-image) all the way up to copying the [kernel and device tree](https://github.com/zangman/de10-nano/wiki/Building-the-SD-Card-image#kernel-and-device-tree-partition-1) and jump back here for the rootfs.

## Archlinux ARM RootFS Steps

### Install dependencies

We'll need the `qemu-arm-static` binary which allows us to run arm binaries on the host machine which is most likely an x86_64.

In Archlinux, this is available in the [aur](https://aur.archlinux.org/packages/qemu-arm-static/) and the steps to install it are as follows:

```bash
cd $DEWD

# Clone the repository.
git clone https://aur.archlinux.org/qemu-arm-static.git

cd qemu-arm-static

# Build and install it.
makepkg -si
```

### Mount the partition

Let's mount the partition first so that we can start working on it:

```bash
cd $DEWD
cd sdcard
mkdir ext4

# Mount the ext4 partition.
sudo mount /dev/loop0p2 ext4
```

### Download prebuilt tarball

Now let's download a pre-built rootfs from the [Archlinux ARM mirror](http://os.archlinuxarm.org/os/) and extract it to the mounted folder:

```bash
cd $DEWD

# Download the tarball.
wget http://sg.mirror.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz

cd sdcard/ext4

# Extract the tarball as root.
# NOTE: important to do this as root!
sudo tar xf $DEWD/ArchLinuxARM-armv7-latest.tar.gz .

# Move up one folder.
cd ..
```

### Chroot into the folder

```bash
cd $DEWD/sdcard

# Copy the qemu-user-static to rootfs
sudo mkdir -p ext4/usr/bin
sudo cp /usr/bin/qemu-arm-static ext4/usr/bin

# Chroot!
sudo arch-chroot ext4 /bin/bash
```

If all goes well you should have a chrooted environment. You can check that it is for the arm environment with `uname -a`:

```bash
uname -a
Linux tree 5.10.70-1-MANJARO #1 SMP PREEMPT Thu Sep 30 15:29:01 UTC 2021 armv7l GNU/Linux
```

### Customising the rootfs

The tarball comes with all the necessary packages to have a barebones working system. But we'd like to do better, let's install a bunch of packages that will make our lives easier.

#### Initializing the keys

Before we do anything, we need to initialize the keys. Without doing this, pacman won't even work and we can't install anything. Run the following commands and wait for them to complete:

```bash
# Initialize the keys.
# This may take a while, wait for it to finish.
pacman-key --init

# Populate the archlinuxarm keys.
pacman-key --populate archlinuxarm

# Update.
pacman -Syu
```

Wait for the update to complete.

#### Update the locale

Follow the steps listed on [this page](https://wiki.archlinux.org/title/locale#Setting_the_locale) to set your locale. I'm just setting mine to US English.

Uncomment the required locale in /etc/locale.gen:

```bash
vim /etc/locale.gen
```

Save the file and generate the locale:

```bash
locale-gen
```

Set the locale:

```bash
# Set the locale.
localectl set-locale LANG=en_US.UTF-8

# Make changes immediate.
unset LANG
source /etc/profile.d/locale.sh
```

#### Install vim/neovim

```bash
pacman -S vim

# Or if you prefer neovim
pacman -S neovim
```

#### Set hostname

```bash
# I call mine de10-arch.
vim /etc/hostname
```

#### Root password

```bash
# I just set mine to 'root'
passwd
```

#### fstab

Copy the following lines as is into `/etc/fstab`:

```bash
none		/tmp	tmpfs	defaults,noatime,mode=1777	0	0
/dev/mmcblk0p2	/	ext4	defaults	0	1
```

#### Enable serial console

This allows you to see all the messages at boot time without having to ssh into the device using a simple serial console (Putty, minicom etc):

```bash
systemctl enable serial-getty@ttyS0.service
```

#### Enable root login over ssh

If you want to ssh as root, add/uncomment the following line in `/etc/ssh/sshd_config`:

```bash
PermitRootLogin yes
```

#### uboot-tools

Includes useful tools such as `mkimage`:

```bash
pacman -S uboot-tools
```

#### NTP - sync correct time

```bash
pacman -S ntp

# Start on boot.
systemctl enable ntpd.service

# Set timezone.
timedatectl set-timezone America/Los_Angeles
```

#### Speed up SSH connections

For some reason it takes about 20 seconds to login everytime I ssh. After a lot of searching, tracked it down to [this issue](https://serverfault.com/a/792494). What worked for me was to set `UsePAM no` in `/etc/ssh/sshd_config`. I don't know the repercussions of doing this, but for now this works great.

#### (Optional) Install wireless tools for wifi dongle

Detailed steps are available for [wireless](https://wiki.archlinux.org/title/Network_configuration/Wireless) and [netctl](https://wiki.archlinux.org/title/Netctl) but the following is what worked for my dongle (I assume everyone uses WPA2 encryption nowadays. If you use something different, refer to the wireless page).

```bash
# Netctl is needed for WPA.
pacman -S wireless_tools netctl wpa_supplicant

# Copy the relevant example.
cp /etc/netctl/examples/wireless-wpa /etc/netctl

# Add the wifi id and password.
vim /etc/netctl/wireless-wpa

# ESSID='MyNetwork'
# Key='WirelessKey'

# Enable it to start at boot
netctl enable wireless-wpa
```

### Finishing up

Install anything else you need and once done, we can exit from the chroot environment and clean up:

```bash
exit

# Remove qemu-arm-static as we don't need it anymore.
# Remember to copy it over whenever you need to chroot.
sudo rm ext4/usr/bin/qemu-arm-static

# Unmount the folder.
sudo umount ext4
```

Now head back over to [this section](https://github.com/zangman/de10-nano/wiki/Building-the-SD-Card-image#cleanup) to continue the clean up and writing to SD Card.

##

<p align="right">Next | <b><a href="Building-the-SD-Card-image.md">Creating the SD Card Image</a></b>
<br/>
Back | <b><a href="Building-the-Kernel.md">Building the Kernel</a></p>
</b><p align="center"><sup>Building Embedded Linux - Full Custom | </sup><a href="../README.md#building-embedded-linux---full-custom"><sup>Table of Contents</sup></a></p>
