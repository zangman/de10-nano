# Building U-Boot for the DE10-Nano

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Summary](#summary)
- [Steps](#steps)
  - [Getting the sources](#getting-the-sources)
  - [Configuring](#configuring)
  - [Building](#building)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

U-Boot is a universal bootloader. Truly. It is used in almost every known embedded device out there and the DE10-Nano is no exception. Here we will build a U-Boot image to be used for the DE10-Nano.

This step will also generate the Secondary Program Loader (SPL) along with the bootloader. To understand how all the pieces fit together, refer to this table originally shared on [Stack Overflow](https://stackoverflow.com/questions/31244862/what-is-the-use-of-spl-secondary-program-loader/31252989). We will generate both steps 2 and 3.

```
+--------+----------------+----------------+----------+
| Boot   | Terminology #1 | Terminology #2 | Actual   |
| stage  |                |                | program  |
| number |                |                | name     |
+--------+----------------+----------------+----------+
| 1      |  Primary       |  -             | ROM code |
|        |  Program       |                |          |
|        |  Loader        |                |          |
|        |                |                |          |
| 2      |  Secondary     |  1st stage     | u-boot   |
|        |  Program       |  bootloader    | SPL      |
|        |  Loader (SPL)  |                |          |
|        |                |                |          |
| 3      |  -             |  2nd stage     | u-boot   |
|        |                |  bootloader    |          |
|        |                |                |          |
| 4      |  -             |  -             | kernel   |
|        |                |                |          |
+--------+----------------+----------------+----------+
```

## Steps

### Getting the sources

There are two source repositories for U-Boot - the official [U-Boot repo](https://github.com/u-boot/u-boot) and the [altera fork](https://github.com/altera-opensource/u-boot-socfpga) of the U-Boot repo. You can use either of them and honestly, I don't know if any difference exists. For this guide, we will be using the official U-Boot repo because a [patch](https://lists.denx.de/pipermail/u-boot/2019-April/367258.html) had been submitted for it and it worked fine when I tested it.

Clone the repository:

```bash
cd $DEWD
git clone https://github.com/u-boot/u-boot.git
```

List all the tags and select a release that you want to use. For this guide, I used the latest stable release `v2020.07`:

```bash
cd $DEWD/u-boot

# List all available tags.
git tag

# Checkout the desired release.
git checkout v2020.07
```

### Configuring

U-Boot has a number of pre-built configurations in the `configs` folder. To view all the available ones for altera, run the following command:

```bash
ls -l configs/socfpga*
```

We will be using `socfpga_de10_nano_defconfig`.

Prepare the default config:

```bash
make ARCH=arm socfpga_de10_nano_defconfig
```

The defaults should be fine. But should you choose to fine tune the config, you can run the following and update them:

```bash
make ARCH=arm menuconfig
```

### Building

Now we can build U-Boot. Run the following command:

```bash
make ARCH=arm -j 24
```

Once the compilation completes, it should have generated the file `u-boot-with-spl.sfp`. This is the bootloader combined with the secondary program loader (spl).

## References

[Official U-Boot repository](https://github.com/u-boot/u-boot) - The README has most of the instructions.

[Building embedded linux for the Terasic DE10-Nano](https://bitlog.it/20170820_building_embedded_linux_for_the_terasic_de10-nano.html) - This page is again a very useful reference.



