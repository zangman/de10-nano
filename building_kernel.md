<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Building the Kernel](#building-the-kernel)
    - [Library dependencies](#library-dependencies)
    - [Get a suitable ARM compiler](#get-a-suitable-arm-compiler)
    - [Download the Kernel](#download-the-kernel)
    - [Configure the Kernel](#configure-the-kernel)
    - [Build the Kernel image](#build-the-kernel-image)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Building the Kernel

### Library dependencies

```bash
sudo apt-get install libncurses-dev flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf bc
```

### Get a suitable ARM compiler

Head over to the [downloads page at Linaro](https://www.linaro.org/downloads/) and download the latest binary release for `arm-linux-gnueabihf`. This is the version of `gcc` that we will use to compile our kernel with. The latest version at the time of writing is `7.5.0-2019.12`. We will fetch the `x86_64` release because we're using Debian on a 64-bit machine.

```bash
wget https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz

tar -xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz

# Delete the archive since we don't need it anymore.
rm gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
```

Set the `CROSS_COMPILE` environment variable to point to the binary location. This is to tell the kernel `Makefile` where the compiler binary is located.

```bash
export CROSS_COMPILE=$PWD/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
```

### Download the Kernel

Altera has their own fork of the kernel. You can clone the [altera linux repository](https://github.com/altera-opensource/linux-socfpga.git):

```bash
git clone https://github.com/altera-opensource/linux-socfpga.git
```

List the branches with `git branch -a` and checkout the one you want to use. We chose to use the latest available at the time of writing. What's the point of using an ancient kernel if you're going to all this trouble? 

```bash
cd linux-socfpga
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

### Build the Kernel image

Now we can finally build the kernel image. Use the following command to create a kernel image called `zImage`:

```bash
make ARCH=arm LOCALVERSION=zImage
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



