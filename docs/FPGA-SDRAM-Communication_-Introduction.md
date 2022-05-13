<p align="right"><sup><a href="../README.md#fpga---sdram-communication">Back</a> | <a href="FPGA-SDRAM-Communication_-SDRAM-Controller.md">Next</a> | </sup><a href="../README.md#fpga---sdram-communication"><sup>Contents</sup></a>
<br/>
<sup>FPGA - SDRAM Communication</sup></p>

# Introduction

## Summary

If you haven't done it already, I would recommend working on the [Simple Hardware Adder](https://github.com/zangman/de10-nano/wiki/Simple-Hardware-Adder:-Introduction) project first before attempting this one. That project covers a lot of introductory concepts such Platform Designer, Avalon Slaves, memory addressing etc. which we'll build upon in this project.

In this project, we'll up the game quite a bit and introduce several new concepts and techniques. These include:

- Avalon MM Burst transactions
- Custom Avalon Memory Mapped (MM) Master Component
- HPS hardware register modifications

And perhaps more. I'll try to be as detailed as possible, but as always, if I've missed anything please raise an [issue](https://github.com/zangman/de10-nano/issues) and I'll try to address it.

## Goal

In the previous project, we used the HPS to FPGA bridge to share data from the HPS to the FPGA. While this works fine for many data transfers, it's not fast enough when dealing with video data. For that reading and writing to SDRAM will be much faster. The Cyclone V FPGA supports this and we'll be taking advantage of it.

By the end of the project we will read a value from SDRAM and show it on the LEDs of the de10-nano. Note that it is very unlikely that you would use the SDRAM in this way, but this allows us to keep the project simple so that the concepts make sense. This is a lot more complicated than appears at first glance.

##

<p align="right">Next | <b><a href="FPGA-SDRAM-Communication_-SDRAM-Controller.md">SDRAM Controller</a></b>
<br/>
Back | <b><a href="../README.md#fpga---sdram-communication">Overview</a></p>
</b><p align="center"><sup>FPGA - SDRAM Communication | </sup><a href="../README.md#fpga---sdram-communication"><sup>Table of Contents</sup></a></p>
