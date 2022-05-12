<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Summary](#summary)
- [SoCs are different from standard FPGAs](#socs-are-different-from-standard-fpgas)
- [You can ignore the HPS and it becomes a standard FPGA](#you-can-ignore-the-hps-and-it-becomes-a-standard-fpga)
- [I'm comfortable with basic FPGAs, I want to use the HPS, so how?!](#im-comfortable-with-basic-fpgas-i-want-to-use-the-hps-so-how)
- [Stop ranting, tell me something useful!](#stop-ranting-tell-me-something-useful)
- [How does the HPS interact with the SoC? Can I just access some pins internally?](#how-does-the-hps-interact-with-the-soc-can-i-just-access-some-pins-internally)
- [Now we can start!](#now-we-can-start)
- [Additional Resources](#additional-resources)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

If you have never worked with SoCs, this page will help you understand why an SoC like the DE10-Nano is quite different from a regular FPGA.

## SoCs are different from standard FPGAs

On a standard FPGA board ([iCEstick](https://www.latticesemi.com/icestick), [nandland go](https://www.nandland.com/goboard/introduction.html)), all the peripherals are connected to various pins on the FPGA. However, on the DE10-Nano, some of the peripherals are connected to the FPGA fabric and some are connected to the HPS. For example, HDMI is connected to the FPGA fabric. So you can't get video out just by using Linux on an sd card. It needs to be accompanied with some files that will allow the HPS to communicate with the FPGA to show the HDMI output. This is shown in the [block diagram](https://software.intel.com/content/www/us/en/develop/articles/de10-nano-board-schematic.html). Similarly, UART is only available with the HPS.

The HPS is a completely different silicon from the FPGA. It is pretty much like somebody carved some space out of the FPGA chip, and dropped in an ARM Cortex-9 die as is and wired it up to the FPGA.

## You can ignore the HPS and it becomes a standard FPGA

You can pretend the HPS doesn't exist and program it and use it like a normal FPGA board. You only get access to the peripherals that are connected to the FPGA, but that's pretty solid to get started with. If you've never used an FPGA before and are just learning Verilog/VHDL, this is where I would suggest you spend your initial days. Use this to get comfortable with FPGAs. Start with [My First FPGA](https://software.intel.com/content/www/us/en/develop/articles/terasic-de10-nano-get-started-guide.html) tutorial on the intel site. The [nandland](https://www.nandland.com/articles/fpga-101-fpgas-for-beginners.html) tutorials are very good for beginners and he has videos as well.


## I'm comfortable with basic FPGAs, I want to use the HPS, so how?!

When you start trying to learn this, you realize you're now a bit out of the hobbyist domain and are in the professional domain. What this means is:

 * Not easy to find documentation.
 * Forum responses take days/weeks because the folks are busy with day jobs (Intel community, Rocketboards, reddit)
 * Compilation times go through the roof. Not uncommon to have a design build for 10-15 minutes after which you copy it to the SD Card only to find that it doesn't work and you have no idea why. If you are doing this as a hobby, expect that a simple hello world tutorial may take the whole weekend or 2 weekends.
 * Version mismatch. The quartus version or the kernel version you have at hand is different from the one in the documentation. Kernel version is easier to fix since you can just get an image that works. But quartus version is harder because of software obsolosence. Maybe you can download Quartus 17.0 and it works, but maybe you can't for the linux distro you are running.
 * Software is unbelievably bad. I don't mean this as judgement. It's just a fact. Coming from a software background, you may be used to the polish of intellij, eclipse or cloud platforms. But quartus is nothing like that. It uses cygwin with shell scripts but has windows batch files and bash scripts and oh god! For someone starting out, this was just painful.

## Stop ranting, tell me something useful!

 * To start using the HPS, I have found it easier to use Linux as the main OS for development. I do this via Manjaro installed on virtualbox on Windows. If you have a linux desktop, it is much better. This ensures you are consistent with the tooling i.e. not having to switch between cygwin, windows terminal etc.
 * You will need the following tools to work with the DE10-Nano:
   * Quartus Prime Lite (latest at the time of writing is 20.1)
   * ModelSim-Intel FPGA EDition (for testing your designs. I use verilator)
   * Cyclone V Device Support
   * Intel SoC Embedded Development Suite Standard Edition (Available in standard under additional tools) - This is very important if you want to develop using the HPS as the tools and utilities it provides are needed to work compile and write applications.
   
## How does the HPS interact with the SoC? Can I just access some pins internally?

Imagine you have an FPGA-only board (like the nandland go) and a processor-only board (like an Arduino or raspberry pi). How would you interface them together if you wanted them to talk to each other? You would use one of the communication standards that both platforms understand so that they can talk to each other such as SPI, I2C, Ethernet, etc. This is usually available in hardware in Raspberry PI and/or Arduino and you don't need to implement them from scratch. However, you need to implement a design on the FPGA which supports one of these protocols and then they can communicate with each other.

On SoCs, they use a similar protocol which is called an Avalon Bus (on Altera) and AXI Bus (on Altera and Xilinx). This bus protocol allows for fast communication between the two. These bus architectures are very complicated that it takes a fair bit of study to learn these. Thankfully, Quartus comes with a tool called `Platform Designer` (previously called `QSYS`) which makes it easier to work with this without having to know too much about how the bus works.

## Now we can start!

This basic understanding is the key to make sense of any of the resources below. I spent a lot of time trying to reach out to people, scouring the internet just to understand this. Hope it helps you get a start. I am not an expert, I am a hobbyist trying to piece this together bit by bit so some of the info may need some correction. Use the menu on the right to go through the steps you like.

## Additional Resources
I have found the following resources immensely helpful when I was getting started:

 * [The DE10-Nano CD-Rom](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=205&No=1046&PartNo=4) - This is the most important resource as it includes the Golden Hardware Reference Design (GHRD) which is used as the starting point most times. It also includes tools which can be used to generate the starter code. Make sure you download the right revision, there is a doc for this on the [Terasic resources page](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1046&PartNo=4).
 * [RSYocto](https://github.com/robseb/rsyocto) - This is an excellent embedded linux distro that has some magical utilities that make programming the FPGA a cakewalk. I've used this and it is partly the inspiration for me to learn more on how to build my own distribution.
 * [Hello world on DE1-SOC using Platform Designer](https://www.youtube.com/watch?v=XXMeiVhjaZU&t=2268s). This was the eye opener for me and took an entire weekend the first time. Study this slowly and carefully and follow the exact same steps to get an LED working by communicating from the HPS to the FPGA. While it is for the DE1-SOC, the steps are identical to the DE10-Nano. Just copy the values from the GHRD on the CD-ROM instead of the values he uses in the video.
 * [Building embedded linux for the DE10-Nano](https://bitlog.it/20170820_building_embedded_linux_for_the_terasic_de10-nano.html) - This is another incredible resource that talks about everything end to end including the device tree and building a linux distro. There are many steps which have been used and referenced directly from here.
 * [Classroom videos on DE1-SoC](https://www.youtube.com/watch?v=sKhvMhTiuM4) - These are a series of 25 videos on the DE1-SOC which I found very helpful. I have only gone through the first 3-4 but they are quite interesting. Good if you want an introduction on how you would go about building a design on an SoC.
