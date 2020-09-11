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

## Steps

### Getting the sources

There are two source repositories for U-Boot - the official [U-Boot repo](https://github.com/u-boot/u-boot) and the [altera fork](https://github.com/altera-opensource/u-boot-socfpga) of the U-Boot repo. You can use either of them and honestly, I don't know if any difference exists. For this guide, we will be using the official U-Boot repo because a [patch](https://lists.denx.de/pipermail/u-boot/2019-April/367258.html) had been submitted for it and it worked fine when I tested it.

Clone the repository:

```bash
git clone https://github.com/u-boot/u-boot.git
```

List all the tags and select a release that you want to use. For this guide, I used the latest stable release `v2020.07`:

```bash
cd u-boot

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
make socfpga_de10_nano_defconfig
```

### Building

TODO

## References

TODO