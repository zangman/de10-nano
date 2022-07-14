<p align="right"><sup><a href="../README.md#appendix">Back</a> | <a href="SSH-Without-Password.md">Next</a> | </sup><a href="../README.md#appendix"><sup>Contents</sup></a>
<br/>
<sup>Appendix</sup></p>

# Yocto Linux

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Summary](#summary)
- [Steps](#steps)
  - [Preparing the sources](#preparing-the-sources)
  - [Configuration](#configuration)
  - [Build It!](#build-it)
- [Appendix](#appendix)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

This page lists all the steps to build a Yocto based distro for de10-nano-soc. Yocto is a complete build system i.e. it generates everything needed for a fully functioning Linux system for your DE10-Nano and this includes the bootloader (U-Boot), kernel and the rootFS.

**Please Note** - The steps listed on this page are from my experiments with Yocto. I've abandoned it in favour of Debian and keeping it here just for reference. The main problem when using Yocto is that the build process takes a very long time (4-5 hours on my virtualbox) and a lot of space (~50-100GB). The rest of the guide assumes that you are using Debian and not Yocto.

## Steps

### Preparing the sources

1.  Create a working directory:

    ```bash
    mkdir yocto
    ```

2.  Get the Yocto sources:

    ```bash
    git clone git://git.yoctoproject.org/poky.git
    ```

3.  Get the `meta-altera` recipes for Yocto:

    ```bash
    git clone git://github.com/kraj/meta-altera.git
    ```

4.  Visit the [Yocto releases](https://wiki.yoctoproject.org/wiki/Releases) page and choose which release you wish to use. For this guide, we will choose `dunfell` as its the latest with long term support. Switch the branch in the `poky` repository to `dunfell`

    ```bash
    cd poky
    git checkout dunfell
    cd ..
    ```

5.  Prepare for the configuration and the build:

    ```bash
    source poky/oe-init-build-env ./build
    ```

    This creates the `build` folder and `cd`s into it. It also sets various environment variables, config files etc.

### Configuration

Now we update the config files for our requirements. The steps followed here are not exhaustive, but they are meant to give a minimum console based Linux distro which can be used for most FPGA-HPS projects. For more information, look into the links in the appendix.

1. Add the `meta-altera` recipe to the Yocto build:

   ```bash
   vim conf/bblayers.conf
   ```

   Add the following line which points to the `meta-altera` recipe to the `BBLAYERS` variable, one line above the closing quotation mark.

   ` ${TOPDIR}/../meta-altera \`

   So your file should now look like this:

   ```
   # POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
   # changes incompatibly
   POKY_BBLAYERS_CONF_VERSION = "2"

   BBPATH = "${TOPDIR}"
   BBFILES ?= ""

   BBLAYERS ?= " \
     /home/myuser/yocto/poky/meta \
     /home/myuser/yocto/poky/meta-poky \
     /home/myuser/yocto/poky/meta-yocto-bsp \
     ${TOPDIR}/../meta-altera \
     "
   ```

2. Yocto uses `conf/local.conf` for the vast majority of it's configuration options. We will use the following options for this particular build. Copy paste all these options and paste them at the end of the file:

   ```
   MACHINE = "cyclone5"
   PACKAGE_CLASSES = "package_deb"
   EXTRA_IMAGE_FEATURES = "debug-tweaks tools-sdk tools-debug package-management"
   PREFERRED_PROVIDER_virtual/kernel = "linux-altera"
   PREFERRED_VERSION_linux-altera = "5.7%"
   UBOOT_CONFIG = "de10-nano-soc"
   UBOOT_EXTLINUX_FDT_default = "../soc_system.dtb"
   IMAGE_INSTALL_append += " apt dpkg "
   PACKAGE_FEED_URIS = "http://mirror.0x.sg/debian/"
   PACKAGE_FEED_BASE_PATHS = "rpm"
   PACKAGE_FEED_ARCHS = "all armhf"
   ```

   Let's go through these in detail:

   1. The de10-Nano uses a cyclone5 chip. So we have to specify that as the machine:

      ```
      MACHINE = "cyclone5"
      ```

   2. We want this to be a debian based distro. So we want to use the deb package classes:

      ```
      PACKAGE_CLASSES = "package_deb"
      ```

   3. `tools-sdk` and `tools-debug` are necessary to have `gcc` and `make` and other build essential utilities available. We're also including `package-management` because we want it to have a package manager.

      ```
      EXTRA_IMAGE_FEATURES = "debug-tweaks tools-sdk tools-debug package-management"
      ```

   4. Use the `linux-altera` configuration for the kernel.

      ```
      PREFERRED_PROVIDER_virtual/kernel = "linux-altera"
      ```

   5. Which version of the kernel to use? Assuming you are in the `build` directory, the following command lists all the available kernel options to use:

      ```
      ls ../meta-altera/recipes-kernel/linux/
      ```

      In our case, we want to use 5.7, so we use the following:

      ```
      PREFERRED_VERSION_linux-altera = "5.7%"
      ```

   6. TODO: Explain the remaining parameters in the config.

### Build It!

Now we build the linux image. Run the following commands to start the build process:

1. Build the bootloader and rootfs:

   ```bash
   bitbake virtual/bootloader
   ```

2. Build the kernel:

   ```bash
   bitbake virtual/kernel
   ```

3. Build the SD card image:

   ```bash
   bitbake core-image-minimal
   ```

## Appendix

All the resources that were used in putting together this guide:

[Rocketboards Yocto build guide](https://rocketboards.org/foswiki/Documentation/YoctoDoraBuildWithMetaAltera)

[meta-altera repo on github](https://github.com/kraj/meta-altera)

[Yocto official build guide](https://www.yoctoproject.org/docs/3.1.2/brief-yoctoprojectqs/brief-yoctoprojectqs.html)

[Yocto official tips and tricks](https://wiki.yoctoproject.org/wiki/TipsAndTricks/EnablingAPackageFeed)

<p align="right">Next | <b><a href="SSH-Without-Password.md">SSH Without Password</a></b>
<br/>
Back | <b><a href="../README.md#appendix">Overview</a></p>
</b><p align="center"><sup>Appendix | </sup><a href="../README.md#appendix"><sup>Table of Contents</sup></a></p>
