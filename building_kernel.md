# Building the Kernel

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

  - [Summary](#summary)
  - [Steps](#steps)
    - [Library dependencies](#library-dependencies)
    - [Download the Kernel](#download-the-kernel)
    - [Configure the Kernel](#configure-the-kernel)
    - [Build the Kernel image](#build-the-kernel-image)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

Here we build a kernel for the DE10-Nano from scratch.

## Steps

### Library dependencies

The following packages are needed for compiling the kernel:

```bash
sudo apt-get install libncurses-dev flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf bc
```

### Download the Kernel

Altera has their own fork of the kernel. You can clone the [altera linux repository](https://github.com/altera-opensource/linux-socfpga.git):

```bash
cd $DEWD
git clone https://github.com/altera-opensource/linux-socfpga.git
```

List the branches with `git branch -a` and checkout the one you want to use. We chose to use the latest available at the time of writing. What's the point of using an ancient kernel if you're going to all this trouble? 

```bash
cd linux-socfpga

# View the list of available branches.
git branch -a

# Use the branch you prefer.
git checkout socfpga-5.8
```

### Configure the Kernel

Create the default configuration:

```bash
make ARCH=arm socfpga_defconfig
```

Now open the kernel configuration window:

```bash
make ARCH=arm menuconfig
```

Under `General setup` and uncheck `Automatically append version information to the version string`. This makes it easier to test different versions of the drivers. Better to keep it enabled in production though.

Feel free to look through the other options and when done, press the right-arrow key until `Exit` is highlighted and press enter. Keep exiting until you get a window that asks if you want to save config. Choose yes and that will exit you out of the utility.

### Build the Kernel image

Now we can finally build the kernel image. Use the following command to create a kernel image called `zImage`:

```bash
make ARCH=arm LOCALVERSION=zImage -j 24
```

If it makes any complaints about `bc` not found or `flex` not found, install that utility using `sudo apt install <library>`.

The kernel gets compiled in about 5-10 mins on my Virtualbox Debian, but YMMV.

Once the compilation is complete, you now have a compressed Linux kernel image. Now we can proceed to the other two parts:

[Building rootfs](#)

[Building preloader](#)

[Building bootloader with bootscript](#)

[Putting it all together in an SD Card image](#)

# References

[Building embedded linux for the Terasic DE10-Nano](https://bitlog.it/20170820_building_embedded_linux_for_the_terasic_de10-nano.html) - Almost everything on this page has been taken from this incredible article. Do take the time to go through it.



