<p align="right"><sup><a href="Setting-up-the-Development-Environment.md">Back</a> | <a href="Building-the-Universal-Bootloader-U-Boot.md">Next</a> | </sup><a href="../README.md#getting-started"><sup>Contents</sup></a>
<br/>
<sup>Building Embedded Linux - Full Custom</sup></p>

# The Basics

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Summary](#summary)
- [Yocto or Full Custom?](#yocto-or-full-custom)
- [What do we need for Embedded Linux?](#what-do-we-need-for-embedded-linux)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

We will look into building a fully functional embedded linux OS for the DE10-Nano. There are several images available online, but what's the fun in that eh? :smile: It's more fun to build our own linux OS from scratch.

## Yocto or Full Custom?

There are a few ways to build Embedded Linux and you may have heard of Yocto and OpenEmbedded thrown about a lot. Yocto uses a lot of the configuration from OpenEmbedded (called recipes) and basically gives you a nice polished version of Linux that you can use. Yocto makes it really convenient to build a working Linux OS, that is, once you get over the steep learning curve of Yocto (think days, not weeks). Only after you understand the basics of Yocto and have worked with it for a while will you really appreciate it and what it does for you. However, one key thing to remember about Yocto is that it's meant for manufacturers to build a limited version of the OS that does exactly what it needs to and nothing more. _**It is not a general purpose Linux OS like Debian**_. For example, if you build routers or microwaves that run Linux which the end user will most likely never interact with, then Yocto is great. But for a hobbyist like me, that's a no go. I want to play with my DE10-Nano and so I chose to go with a full-fledged Debian Linux.

But this means that we have to take care of everything ourselves. Yocto can be configured to auto-build the Bootloader with the SPL, the Kernel, the rootFS and generate a nice `sdcard.img` file for you to just burn onto your SD Card. We get none of those benefits with our Debian build, we'll just have to do everything ourselves.

## What do we need for Embedded Linux?

There are a few steps we need to go through to build a working embedded linux OS:

- **Device ROM** - Every embedded device, including the DE10-Nano, has some instructions that get executed as soon as the device gets powered on. These instructions point the device to read the preloader binary from a specific storage location such as SD Card, eMMC etc. There's nothing for us to do here, it's a ROM.
- **Preloader** - The preloader is a binary that is provided by the manufacturer which in our case is Intel/Altera. This does some basic setup before it hands over to the Bootloader. In our case, we'll have the Preloader combined with the bootloader.
- **Bootloader** - The bootloader does some hardware initialization before it hands over to the Kernel to initialize the OS.
- **Kernel** - The kernel is the heart of the OS and contains all the information about the hardware on the board.
- **RootFS** - The root filesystem is the location where we work and write programs etc.

<p align="right">Next | <b><a href="Building-the-Universal-Bootloader-U-Boot.md">Building the Universal Bootloader (U-Boot)</a></b>
<br/>
Back | <b><a href="../README.md#building-embedded-linux---full-custom">Overview</a></p>
</b><p align="center"><sup>Building Embedded Linux - Full Custom | </sup><a href="../README.md#building-embedded-linux---full-custom"><sup>Table of Contents</sup></a></p>
