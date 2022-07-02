# Absolute beginner's guide to DE10-Nano

To get started with the guide, please begin [here](#getting-started).

To just download the Debian or Arch Linux ARM (**NEW**) image for the DE10-Nano, please visit the [releases page](https://github.com/zangman/de10-nano/releases).

### Table of Contents

- [Getting Started](#getting-started)
- [Building Embedded Linux - Full Custom](#building-embedded-linux---full-custom)
- [Flashing the FPGA from SD Card](#flashing-the-fpga-from-sd-card)
- [HPS and FPGA communication](#hps-and-fpga-communication)
- [My First SoC - Simple Hardware Adder](#my-first-soc---simple-hardware-adder)
- [FPGA - SDRAM Communication](#fpga---sdram-communication)
- [Appendix](#appendix)
- [FAQ](#faq)
  - [Isn't there documentation already? Why this guide?](#isnt-there-documentation-already-why-this-guide)
  - [Can I just get the image? I don't want to go through the guide to get Debian on my DE10-Nano.](#can-i-just-get-the-image-i-dont-want-to-go-through-the-guide-to-get-debian-on-my-de10-nano)
  - [How much Linux do I need to know?](#how-much-linux-do-i-need-to-know)
  - [Will you cover VHDL/Verilog or FPGAs in general?](#will-you-cover-vhdlverilog-or-fpgas-in-general)
  - [I spotted a mistake!](#i-spotted-a-mistake)
- [Getting further help](#getting-further-help)
- [Prerequisites](#prerequisites)

# Getting Started

- [Introduction to SoCs](docs/Introduction-to-SoCs.md)
- [Introduction to DE10-Nano](docs/Introduction-to-DE10-Nano.md)
- [Setting up the development environment](docs/Setting-up-the-Development-Environment.md)

# Building Embedded Linux - Full Custom

- [The Basics](docs/Building-Embedded-Linux.md)
- [Building the Universal Bootloader (U-Boot)](docs/Building-the-Universal-Bootloader-U-Boot.md)
- [Building the Kernel](docs/Building-the-Kernel.md)
- [RootFS - Choose one:](docs/Building-the-Kernal-RootFS-Choose-One.md)
  - [Debian](docs/Debian-Root-File-System.md)
  - [Archlinux ARM](docs/Archlinux-ARM-Root-File-System.md)
- [Creating the SD Card Image](docs/Building-the-SD-Card-image.md)
- [(Optional) Setting up WIFI](docs/%5BOptional%5D-Setting-up-Wifi.md)

# Flashing the FPGA from SD Card

- [From Linux](docs/Flash-FPGA-from-HPS-running-Linux.md)
- [On Boot Up](docs/Flash-FPGA-On-Boot-Up.md)

# HPS and FPGA communication

- [Configuring the Device Tree](docs/Configuring-the-Device-Tree.md)
- [Designing and Flashing the design](docs/Building-SoC-Design.md)

# My First SoC - Simple Hardware Adder

- [Introduction](docs/Simple-Hardware-Adder_-Introduction.md)
- [Initial project setup](docs/Simple-Hardware-Adder_-Initial-Project-Setup.md)
- [Simple Adder](docs/Simple-Hardware-Adder_-The-Adder.md)
- [Primer on Avalon MM](docs/Simple-Hardware-Adder_-Primer-on-Avalon-Memory-Map-Interface.md)
- [Custom Avalon MM Components](docs/Simple-Hardware-Adder_-Custom-Avalon-MM-Components.md)
- [Wiring the Components](docs/Simple-Hardware-Adder_-Wiring-the-components.md)
- [Add the Simple Adder](docs/Simple-Hardware-Adder_-Setting-up-the-Adder.md)
- [Writing the Software](docs/Simple-Hardware-Adder_-Writing-the-Software.md)

# FPGA - SDRAM Communication

- [Introduction](docs/FPGA-SDRAM-Communication_-Introduction.md)
- [SDRAM Controller](docs/FPGA-SDRAM-Communication_-SDRAM-Controller.md)
- [More on Avalon MM](docs/FPGA-SDRAM-Communication_-More-about-the-Avalon-Memory-Mapped-Interface.md)
- [Avalon MM Agent/Slave - Trigger Component](docs/FPGA-SDRAM-Communication_-Avalon-MM-Agent-Slave-Trigger-Component.md)
- [Avalon MM Host/Master - 1](docs/FPGA-SDRAM-Communication_-Avalon-MM-Host-Master-Component-Part-1.md)
- [Avalon MM Host/Master - 2](docs/FPGA-SDRAM-Communication_-Avalon-MM-Host-Master-Component-Part-2.md)
- [Avalon MM Host/Master - 3](docs/FPGA-SDRAM-Communication_-Avalon-MM-Host-Master-Component-Part-3.md)

# Appendix

- [Yocto Linux](docs/Yocto-Linux.md)
- [SSH Without Password](docs/SSH-Without-Password.md)
- [Creating a bootscript](docs/Creating-a-Bootscript.md)

# FAQ

## Isn't there documentation already? Why this guide?

- **Not beginner friendly** - There is a lot of documentation online, but they don't show always explain everything.
- **Comprehensive** - The ultimate goal of this site is to be comprehensive so all the information needed is available and accessible easily.
- **Focused** - There are several boards by Terasic and Altera which use Cyclone V and all of them vary slightly. This guide only focuses on the DE10-Nano. If you are using a DE1 or any other Cyclone V board, a lot of the content will still be applicable. But I haven't tested it, so I don't know if it will work or not.

## Can I just get the image? I don't want to go through the guide to get Debian on my DE10-Nano.

Sure, You can download the SD Card image from the [releases page](https://github.com/zangman/de10-nano/releases).

## How much Linux do I need to know?

You are expected to be comfortable using the command line in Linux. All the shell commands you will need will be provided in the guide. But the commands themselves won't be explained, you will need to learn more about them yourself.

## Will you cover VHDL/Verilog or FPGAs in general?

No, this guide does not cover general FPGAs. There is enough information online to learn HDL as well. Basic understanding of FPGAs and HDL is expected.

## I spotted a mistake!

Please let me know! Either raise an [issue](https://github.com/zangman/de10-nano/issues) or submit a [pull request](https://github.com/zangman/de10-nano/pulls) and I will greatly appreciate it!

# Getting further help

If you have a question about something, feel free to raise it as an issue and I'll try and address it. But this is a hobby for me and I can't really guarantee being able to answer it, nor do I guarantee that I will have time to answer your question.

You can also reach out to the following communities for more help:

- [FPGA Subreddit](reddit.com/r/FPGA) - Some of the nicest people online here. I have lost track of the number of times people have asked "Which board should I get?" and yet never has the post been taken down or rudely put down.
- ##FPGA on IRC Freenode - Excellent resource for general FPGA related questions. Ask a question and do lurk around, people are busy and may not reply immediately.
- [Intel community forums](community.intel.com) - Not very active, but from time to time people do reply. Sometimes support engineers from Intel will come across your post and reply, but that usually takes time.
- [Rocketboards forum](forum.rocketboards.org/) - Similar to the intel forums, these are not very active. But there's a lot of helpful information on the forums, so searching there is also an option when you get stuck.

## Prerequisites

This document assumes no knowledge of SoCs. However, it requires a few things for you to be able to follow along:

- **DE10-Nano**: Obviously you need the DE10-Nano board. Most prominent electronics retailers stock it (digikey, mouser, element14) or you can purchase it directly from the Terasic website. Please don't purchase knock-offs or cheap alternatives. FPGA programming is hard enough and there are a million things that can go wrong.
- **Beginner's knowledge of FPGAs** - While there is some FPGA programming involved, this guide does not teach you the basics of FPGAs, HDLs etc. There are several resources available online.
- **Intermediate knowledge of Linux**: Linux will be the preferred OS for this guide. You should be able to navigate the terminal and know at least the basic commands of the shell.
- **Serial UART**: To see the bootloader commands, we will need to have a serial console like `PuTTy` or `minicom` available and also connect our DE10-Nano using the USB port.
- **Connected to LAN**: We will need the device connected to LAN so that we can ssh to it from our host computer.
