# Debian rootfs

There are several flavours of rootfs to choose from. This one focuses on the Debian rootfs. This will give you an environment similar to the Rasbperry Pi OS for your DE10-Nano.

### Debootstrap and QEMU

Debootstrap is a utility that makes it easy to create a rootfs on an existing Debian based machine. However, since our host machine is most likely `x86_64` and we are targeting an `armhf` architecture for the DE10-Nano, we will need to install an emulator from the [QEMU project](https://wiki.qemu.org/Main_Page). To install both on your host OS:

```bash
sudo apt install debootstrap qemu-user-static
```

### First Stage

In the first stage, we will create a directory to hold the rootfs. Note that almost all the commands in this part will be done as root using `sudo` so take care not to make any mistakes.

```bash
# I prefer to use a directory in my home folder.
rootfs=~/rootfs

mkdir $rootfs

# buster is the latest debian version at the time of writing.
# Replace it with whatever is the latest.
sudo debootstrap --arch=armhf --foreign buster $rootfs
```

### Second Stage

First, we have to copy over `qemu` to the target file system and `chroot` to target. Without copying over `qemu` we cannot `chroot`.

```bash
sudo cp /usr/bin/qemu-arm-static $rootfs/usr/bin/
```

Now we should be able to `chroot`:

```bash
sudo chroot $rootfs /usr/bin/qemu-arm-static /bin/sh -i
```

Once in the `chroot`-ed environment, we can kick off the second stage of `debootstrap`:

```bash
/debootstrap/debootstrap --second-stage
```

This will take about 5 minutes to complete.

### Configuration

While still in the `chroot` environment, let's do some setup so that our rootfs is more convenient to use.

* **Hostname** - Change the name to be different from the current host distro in `/etc/hostname`. I call mine `de10-nano`.

* **Root password** - Set the root password so it is not blank.

  ```bash
  passwd
  ```

* **fstab** - Let's update fstab so that the system auto mounts the drives. Copy the following lines as is into `/etc/fstab`:

  ```bash
  none		/tmp	tmpfs	defaults,noatime,mode=1777	0	0
  /dev/mmcblk0p2	/	ext4	defaults	0	1 
  ```

* **Enable the serial console** - This allows you to see all the messages at boot time without having to ssh into the device using a simple serial console (Putty, minicom etc)

  ```bash
  systemctl enable serial-getty@ttyS0.service
  ```

* **Locales** - Configure and install the locales you will need. For me, this is just `en_US.UTF-8`:

  ```bash
  apt install locales
  dpkg-reconfigure locales
  ```

* **Ethernet** - To get the ethernet on the DE10-Nano working, we need to add the following to the file`/etc/network/interfaces`. This will enable DHCP:

  ```bash
  auto lo eth0
  allow-hotplug eth0
  iface lo inet loopback
  iface eth0 inet dhcp
  ```

* **Sources.list** - Use a more complete apt `sources.list`. Edit the file `/etc/apt/sources.list` and add the following. Replace `buster` with whatever version of debian you are using:

  ```bash
  deb http://deb.debian.org/debian/ buster main contrib non-free
  deb-src http://deb.debian.org/debian/ buster main contrib non-free
  deb http://deb.debian.org/debian/ buster-updates main contrib non-free
  deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free
  deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free
  deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free
  ```

* **Openssh-Server** - Install `openssh-server` so that you can `ssh` into the device:

  ```bash
  apt install openssh-server
  ```

* **(Optional) Root login over ssh** - If you want to ssh as root, add/uncomment the following line in `/etc/ssh/sshd_config`:

  ```bash
  PermitRootLogin yes
  ```

* **(Optional) Add a user** - TODO - add a user and enable sudo.

* **PRNG entropy seeding speedups** - This speeds up the ssh server startup time on debian buster. See [here](http://linux-sunxi.org/Debootstrap) for more details.

  ```bash
  apt install haveged
  ```

* **Install any other packages** - I can't live without vim, so I'll install it. You can install any other package as well:

  ```bash
  apt install vim
  ```

### Clean up

Run the following for some basic clean up:

```bash
# Remove cached packages.
apt clean

# Remove QEMU.
rm /usr/bin/qemu-arm-static

# Exit from the chroot.
exit
```

### Create a tarball

The last step is to create a tarball that we will extract into our SD Card partition:

```bash
cd $rootfs

# Don't forget the dot at the end.
# Also has to be run as root.
sudo tar -cjpf ~/rootfs.tar.bz2 .
```

And that completes the Debian rootfs. Be careful when extracting this as it will extract everything within the same directory (without creating another directory).



## References

[Quck and easy bootstrap of Debian for armhf](https://blog.lazy-evaluation.net/posts/linux/debian-armhf-bootstrap.html)

[Debootstrap - Linux-Sunxi](http://linux-sunxi.org/Debootstrap)

