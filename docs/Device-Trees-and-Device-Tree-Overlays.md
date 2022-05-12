<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Summary](#summary)
- [Introduction to Device Trees](#introduction-to-device-trees)
  - [What is a device tree?](#what-is-a-device-tree)
  - [Who creates the device tree?](#who-creates-the-device-tree)
  - [Why would I need to modify the device tree?](#why-would-i-need-to-modify-the-device-tree)
  - [What is a dts, dtsi, dtb?](#what-is-a-dts-dtsi-dtb)
  - [Where can I find the vanilla device tree for the DE10-Nano?](#where-can-i-find-the-vanilla-device-tree-for-the-de10-nano)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

We won't be doing too much to generate the device tree. However, this page will form the basis of understanding what the device tree is used for. The device tree will be important for us once we start building our own hardware using the FPGA and interacting with it from the HPS.

## Introduction to Device Trees

### What is a device tree?

TODO

### Who creates the device tree?

TODO

### Why would I need to modify the device tree?

TODO

### What is a dts, dtsi, dtb?

TODO

### Where can I find the vanilla device tree for the DE10-Nano?

A plain vanilla device tree is already available in the kernel. After you've compiled the kernel, you can use the device tree binary:

````
$DEWD/socfpga-linux/arch/arm/boot/dts/socfpga_cyclone5_de0_nano_soc.dtb`
````

