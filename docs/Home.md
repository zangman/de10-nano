<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Absolute beginner's guide to DE10-Nano](#absolute-beginners-guide-to-de10-nano)
  - [FAQ](#faq)
    - [Isn't there documentation already? Why this guide?](#isnt-there-documentation-already-why-this-guide)
    - [Can I just get the image? I don't want to go through the guide to get Debian on my DE10-Nano.](#can-i-just-get-the-image-i-dont-want-to-go-through-the-guide-to-get-debian-on-my-de10-nano)
    - [How much Linux do I need to know?](#how-much-linux-do-i-need-to-know)
    - [Will you cover VHDL/Verilog or FPGAs in general?](#will-you-cover-vhdlverilog-or-fpgas-in-general)
    - [I spotted a mistake!](#i-spotted-a-mistake)
  - [Getting further help](#getting-further-help)
  - [Prerequisites](#prerequisites)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Absolute beginner's guide to DE10-Nano

## FAQ

### Isn't there documentation already? Why this guide?

* **Not beginner friendly** - There is a lot of documentation online, but they don't show always explain everything.
* **Comprehensive** - The ultimate goal of this site is to be comprehensive so all the information needed is available and accessible easily.
* **Focused** - There are several boards by Terasic and Altera which use Cyclone V and all of them vary slightly. This guide only focuses on the DE10-Nano. If you are using a DE1 or any other Cyclone V board, a lot of the content will still be applicable. But I haven't tested it, so I don't know if it will work or not.

### Can I just get the image? I don't want to go through the guide to get Debian on my DE10-Nano.
Sure, You can download the SD Card image from the [releases page](https://github.com/zangman/de10-nano/releases).

### How much Linux do I need to know?
You are expected to be comfortable using the command line in Linux. All the shell commands you will need will be provided in the guide. But the commands themselves won't be explained, you will need to learn more about them yourself.

### Will you cover VHDL/Verilog or FPGAs in general?
No, this guide does not cover general FPGAs. There is enough information online to learn HDL as well. Basic understanding of FPGAs and HDL is expected.

### I spotted a mistake!
Please let me know! Either raise an [issue](https://github.com/zangman/de10-nano/issues) or submit a [pull request](https://github.com/zangman/de10-nano/pulls) and I will greatly appreciate it!

## Getting further help

If you have a question about something, feel free to raise it as an issue and I'll try and address it. But this is a hobby for me and I can't really guarantee being able to answer it, nor do I guarantee that I will have time to answer your question.

You can also reach out to the following communities for more help:

* [FPGA Subreddit](reddit.com/r/FPGA) - Some of the nicest people online here. I have lost track of the number of times people have asked "Which board should I get?" and yet never has the post been taken down or rudely put down.
* ##FPGA on IRC Freenode - Excellent resource for general FPGA related questions. Ask a question and do lurk around, people are busy and may not reply immediately.
* [Intel community forums](community.intel.com) - Not very active, but from time to time people do reply. Sometimes support engineers from Intel will come across your post and reply, but that usually takes time.
* [Rocketboards forum](forum.rocketboards.org/) - Similar to the intel forums, these are not very active. But there's a lot of helpful information on the forums, so searching there is also an option when you get stuck.

## Prerequisites

This document assumes no knowledge of SoCs. However, it requires a few things for you to be able to follow along:

 * **DE10-Nano**: Obviously you need the DE10-Nano board. Most prominent electronics retailers stock it (digikey, mouser, element14) or you can purchase it directly from the Terasic website. Please don't purchase knock-offs or cheap alternatives. FPGA programming is hard enough and there are a million things that can go wrong.
 * **Beginner's knowledge of FPGAs** - While there is some FPGA programming involved, this guide does not teach you the basics of FPGAs, HDLs etc. There are several resources available online.
 * **Intermediate knowledge of Linux**: Linux will be the preferred OS for this guide. You should be able to navigate the terminal and know at least the basic commands of the shell.
 * **Serial UART**: To see the bootloader commands, we will need to have a serial console like `PuTTy` or `minicom` available and also connect our DE10-Nano using the USB port.
 * **Connected to LAN**: We will need the device connected to LAN so that we can ssh to it from our host computer.

