<p align="right"><sup><a href="Flash-FPGA-On-Boot-Up.md">Back</a> | <a href="Building-SoC-Design.md">Next</a> | </sup><a href="../README.md#hps-and-fpga-communication"><sup>Contents</sup></a>
<br/>
<sup>HPS and FPGA communication</sup></p>

# Configuring the Device Tree

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Summary](#summary)
- [Steps](#steps)
  - [Enable the FPGA bridges](#enable-the-fpga-bridges)
  - [Generate the Device Tree Binary](#generate-the-device-tree-binary)
  - [Copy the Device Tree Binary to the DE10-Nano](#copy-the-device-tree-binary-to-the-de10-nano)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

Here we will make some minor changes to the device tree so that we can have the HPS and the FPGA communicate with each other. The main change we need to do is enable the FPGA bridges which are key in allowing this communication to happen. Once we enable them in the device tree, the Altera driver will kick in and allow us bi-directional communication.

## Steps

### Enable the FPGA bridges

By default the device tree has all the FPGA bridges which allow FPGA and HPS intercommunication disabled. We'll need to enable them.

```bash
# Change into the linux directory.
cd $DEWD/linux-socfpga

# Create a new branch for our changes.
git checkout -b my_custom
```

Open the following file in an editor of your choice:

```bash
nano arch/arm/boot/dts/socfpga.dtsi
```

If you scroll through the file and see the nodes for the FPGA bridges, you will see that they are all disabled.

```bash
                fpga_bridge0: fpga_bridge@ff400000 {
                        compatible = "altr,socfpga-lwhps2fpga-bridge";
                        reg = <0xff400000 0x100000>;
                        resets = <&rst LWHPS2FPGA_RESET>;
                        clocks = <&l4_main_clk>;
                        status = "disabled";
                };

                fpga_bridge1: fpga_bridge@ff500000 {
                        compatible = "altr,socfpga-hps2fpga-bridge";
                        reg = <0xff500000 0x10000>;
                        resets = <&rst HPS2FPGA_RESET>;
                        clocks = <&l4_main_clk>;
                        status = "disabled";
                };

                fpga_bridge2: fpga-bridge@ff600000 {
                        compatible = "altr,socfpga-fpga2hps-bridge";
                        reg = <0xff600000 0x100000>;
                        resets = <&rst FPGA2HPS_RESET>;
                        clocks = <&l4_main_clk>;
                        status = "disabled";
                };

                fpga_bridge3: fpga-bridge@ffc25080 {
                        compatible = "altr,socfpga-fpga2sdram-bridge";
                        reg = <0xffc25080 0x4>;
                        status = "disabled";
                };
```

We will enable these bridges, but in a child device tree. Let's create a copy of the device tree we're using right now:

```bash
cd $DEWD/linux-socfpga/arch/arm/boot/dts
cp socfpga_cyclone5_de0_nano_soc.dts my_custom.dts
```

Let's enable the bridges in the device tree:

```bash
nano my_custom.dts
```

Copy and paste the following lines right at the end of the file:

```bash
&fpga_bridge0 {
  status = "okay";
  bridge-enable = <1>;
};

&fpga_bridge1 {
  status = "okay";
  bridge-enable = <1>;
};

&fpga_bridge2 {
  status = "okay";
  bridge-enable = <1>;
};

&fpga_bridge3 {
  status = "okay";
  bridge-enable = <1>;
};
```

Because this file includes `socfpga.dtsi`, these values will overwrite the values in the included file.

### Generate the Device Tree Binary

Let's generate the device tree binary:

```bash
cd $DEWD/linux-socfpga

# Linux kernel magically allows this.
make ARCH=arm my_custom.dtb
```

If there are no errors, we can now commit our changes to our branch:

```bash
git add .
git commit -m "Enabled bridges in custom device tree."
```

### Copy the Device Tree Binary to the DE10-Nano

Let's copy the device tree binary to the DE10-Nano:

```bash
cd $DEWD/linux-socfpga
scp arch/arm/boot/dts/my_custom.dtb root@<ipaddress>:~
```

Now let's replace the existing device tree on the DE10-Nano:

```bash
ssh root@<ipaddress>

mkdir -p fat
mount /dev/mmcblk0p1 fat

# Backup the current device tree.
cp fat/socfpga_cyclone5_de0_nano_soc.dtb fat/socfpga_cyclone5_de0_nano_soc_orig.dtb

# Copy the new device tree, it should match the name defined in extlinux.
cp my_custom.dtb fat/socfpga_cyclone5_de0_nano_soc.dtb

# Unmount
umount fat

reboot
```

Upon reboot, if you login and run the following command:

```bash
cat /sys/class/fpga_bridge/*/state
```

You should see that they're all enabled:

```bash
enabled
enabled
enabled
enabled
```

That means we are now ready to flash our design and run a program in user space.

<p align="right">Next | <b><a href="Building-SoC-Design.md">Designing and Flashing the design</a></b>
<br/>
Back | <b><a href="Flash-FPGA-On-Boot-Up.md">Flashing the FPGA On Boot Up</a></p>
</b><p align="center"><sup>HPS and FPGA communication | </sup><a href="../README.md#hps-and-fpga-communication"><sup>Table of Contents</sup></a></p>
