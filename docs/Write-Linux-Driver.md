<p align="right"><sup><a href="Building-SoC-Design.md">Back</a> | <a href="Simple-Hardware-Adder_-Introduction.md">Next</a> | </sup><a href="../README.md#hps-and-fpga-communication"><sup>Contents</sup></a>
<br/>
<sup>HPS and FPGA communication</sup></p>

# Writing a simple Linux Driver

## Summary

This article explains how to write a driver for our FPGA custom IP. The driver will be a very basic Loadable Kernal Module (LMK) and serve as an example for how you can write a software interface for your custom hardware in the FPGA. A device driver's purpose is to provide kernal code to access the hardware, but without forcing particular policies or rules on the users. Different users have different needs and the driver should only expose capabilities of the hardware.

Content on this page has been obtained from the excellent [bitlog article](https://bitlog.it/20170820_building_embedded_linux_for_the_terasic_de10-nano.html), which has obtained it's content from this [rocketboards article](https://rocketboards.org/foswiki/Documentation/EmbeddedLinuxBeginnerSGuide#11). The steps below have been updated to work with our setup and configuration.

Before we begin, make sure you have studied, completed, and understood the content from [Designing and Flashing the design](./Building-SoC-Design.md). Head over to the [discussions board](https://github.com/zangman/de10-nano/discussions) if you have questions.

## Steps

### Modify *custom_leds_hw.tcl* file

In the Platform Designer step of the [Designing and Flashing the design](./Building-SoC-Design.md) a file called *custom_leds_hw.tcl* is generated. Open the file and add the following lines to it:

```
# Device tree generation
set_module_assignment embeddedsw.dts.vendor "dsa"
set_module_assignment embeddedsw.dts.compatible "dev,custom-leds"
set_module_assignment embeddedsw.dts.group "leds"
```

This will add information to our device when we generate the device tree that will allow our driver to automatically be matched with it. After adding this change, we need to regenerate the HDL so that the **.sopcinfo** will be updated with this change.

Open Quartus and click on `Open Project` and select the `.qpf` file in the GHRD. Open up Platform Designer (previously called QSys) by going to `Tools -> Platform Designer`. Select `soc_system.qsys` in the file open dialog. 

After it loads, simply click on the button `Generate HDL...` at the bottom right to generate to open the `Generation` window. The default options are fine, just click on `Generate`. This will generate all the verilog code needed for our Avalon Bus and wires everything together. Wait for it to finish and click `Close` and then click on `Finish` on Platform Designer. We're done with this step, you can also close out of Quartus.

### Generating the device tree

The **Device Tree** tells the Linux kernal what kind of hardware is present in the system. The SoC EDS contains a script tool called **sopc2dts**, which can create a **.dts** file from the **.sopcinfo** in our GHDR. The **.dts** it generates is not immediately compatible with the Linux system we built from scratch, however it does produce an outline of what the *custom_leds_0* device should look like in our device tree. Let's generate the **.dts** file and add it to our device tree. Keep in mind that we will have to make some modifications to it before it will work.

```bash
cd $DEWD/DE10_NANO_SoC_GHRD

# Set up the paths.
embedded_command_shell.sh

# Generate the device tree.
sopc2dts --input soc_system.sopcinfo --output soc_system.dts --type dts --board soc_system_board_info.xml --board hps_common_board_info.xml --bridge-removal all --clocks

# Let's get out of the embedded_command_shell.
exit
```

Inside the generated **soc_system.dts**, there is an entry for our *custom_leds_0*:

```
custom_leds_0: leds@0x100000000 {
				compatible = "dsa,custom_leds-1.0", "dev,custom-leds";
				reg = <0x00000001 0x00000000 0x00000008>;
				clocks = <&clk_0>;
			}; //end leds@0x100000000 (custom_leds_0)
```

This is a good starting point to work with, but there are some problems we need to fix.
- base address wrong
- clk_0 not defined to our dtsi
- reg cannot hold 3 values in our dtsi

### Determine base address and span of FPGA peripherals

We need to determine the base address of our custom IP component and update the device tree with it. One way of doing this is by using the utility called *sopc-create-header-files* which decodes the SOPCINFO file. We have used this program before to create the **hps_0.h** header file in [Designing and Flashing the design](./Building-SoC-Design.md).

Start by creating a directory to store the generated files.

```bash
cd $DEWD/DE10_NANO_SoC_GHRD

# Make directory for header files
mkdir qsys_headers 
```

Run the following commands to use the **soc_system.sopcinfo** to generate the header files.

```bash
cd $DEWD/DE10_NANO_SoC_GHRD

sopc-create-header-files $DEWD/DE10_NANO_SoC_GHRD/soc_system.sopcinfo --output-dir qsys_headers 

# Make directory for header files.0
cd qsys_headers 

#List the files
ls
```
There should be a number of header files for the GHRD hardware system from the perspective of each master in the system, as well as some system wide perspectives:

```bash
f2sdram_only_master.h  hps_0_arm_a9_1.h  hps_only_master.h 
fpga_only_master.h     hps_0_bridges.h   mm_bridge_0.h 
hps_0_arm_a9_0.h       hps_0.h           soc_system.h 
```
The following grep patterns will extract the base address of the FPGA peripherals in our design.

```bash
cd $DEWD/DE10_NANO_SoC_GHRD/qsys_headers

# list out the base addresses of the FPGA components
cat soc_system.h | grep -E -e "#define HPS_0_ARM_A9_0_" | grep -v -E -e "HPS_0_ARM_A9_0_HPS_0_" | grep -E -e "_BASE\s"
```
You should see something like the following output:

```bash
#define HPS_0_ARM_A9_0_CUSTOM_LEDS_0_BASE 0xff200000
#define HPS_0_ARM_A9_0_SYSID_QSYS_BASE 0xff201000
#define HPS_0_ARM_A9_0_JTAG_UART_BASE 0xff202000
#define HPS_0_ARM_A9_0_DIPSW_PIO_BASE 0xff204000
#define HPS_0_ARM_A9_0_BUTTON_PIO_BASE 0xff205000
#define HPS_0_ARM_A9_0_ILC_BASE 0xff230000
```
The following grep patterns will extract the span of the FPGA peripherals in our design.

```bash
cd $DEWD/DE10_NANO_SoC_GHRD/qsys_headers

# list out the span of the FPGA components
cat soc_system.h | grep -E -e "#define HPS_0_ARM_A9_0_" | grep -v -E -e "HPS_0_ARM_A9_0_HPS_0_" | grep -E -e "_SPAN\s"
```
You should see something like the following output:

```bash
#define HPS_0_ARM_A9_0_CUSTOM_LEDS_0_SPAN 8
#define HPS_0_ARM_A9_0_SYSID_QSYS_SPAN 8
#define HPS_0_ARM_A9_0_JTAG_UART_SPAN 8
#define HPS_0_ARM_A9_0_DIPSW_PIO_SPAN 16
#define HPS_0_ARM_A9_0_BUTTON_PIO_SPAN 16
#define HPS_0_ARM_A9_0_ILC_SPAN 256
```
The output shows us what the base addresses are for the peripherals in the FPGA. In this case the address is *0xff200000* for our custom LEDs component. We also see that the span is 8, this is because our component only specifies 8 LEDs. We will use these values in the next step.


### Modify socfpga.dtsi

We need to add the base address from the previous step to the *socfpga.dtsi* that we saw at the start of the [Configuring the Device Tree](./Configuring-the-Device-Tree.md) guide. 

```bash
# Change into the linux directory.
cd $DEWD/linux-socfpga

# Use an editor of your choice.
nano arch/arm/boot/dts/socfpga.dtsi
```
Copy the following device tree entry and add it to the device tree inside of the **soc{...}** section (I placed mine right below **gmac1: ethernet@ff702000 {...};** for no particular reason). Observe that the base address has been updated and the reg property has  been changed to contain the base address and span. The compatible property is used to match this device with a compatible driver (we will write this driver later).

```
		custom_leds_0: leds@0xff200000 {
				compatible = "dsa,custom_leds-1.0", "dev,custom-leds";
				reg = <0xff200000 0x000008>;
				clocks = <&l4_main_clk>;
		}; //end leds@0xff200000 (custom_leds_0)
```
Please not that the clocks property has been updated to match the clock name (*<&l4_main_clk>*) that exists in our setup. Make sure to save your modifications.

### Generate the Device Tree Binary

Let's generate the device tree binary:

```bash
cd $DEWD/linux-socfpga

# Linux kernel magically allows this.
make ARCH=arm my_custom.dtb
```
We are going to continue to use **my_custom.dtb** from [Configuring the Device Tree](./Configuring-the-Device-Tree.md) which contains our changes to enable the FPGA bridges. It is required for the FPGA bridges to be enabled in order to access components on the FPGA.

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
cat /sys/devices/platform/soc/ff200000.leds/*
```

You should see something like the following output:

```bash
(null)
of:NledsT(null)Cdsa,custom_leds-1.0Cdev,custom-leds
cat: /sys/devices/platform/soc/ff200000.leds/of_node: Is a directory
cat: /sys/devices/platform/soc/ff200000.leds/power: Is a directory
cat: /sys/devices/platform/soc/ff200000.leds/subsystem: Is a directory
OF_NAME=leds
OF_FULLNAME=/soc/leds@0xff200000
OF_COMPATIBLE_0=dsa,custom_leds-1.0
OF_COMPATIBLE_1=dev,custom-leds
OF_COMPATIBLE_N=2
MODALIAS=of:NledsT(null)Cdsa,custom_leds-1.0Cdev,custom-leds
```

That means we can see that our custom IP device is listed and we are now ready to write our driver.

### Write the simple Linux driver

We should have the FPGA flashed with the design from [Designing and Flashing the design](./Building-SoC-Design.md) and now the custom LED component listed in the device tree. We are ready to write a Loadable Kernal Module that will control the LEDs. We'll use the cross-compiling method to build the binary on our host Debian system and then copy it over to the DE10-Nano. Run the following commands to create a file:

```bash
cd $DEWD
mkdir -p driver_led
cd driver_led
nano driver_leds.c
```

In the file, copy paste the following code. This is copy pasted directly from [rocketboards.org](https://rocketboards.org/foswiki/Documentation/EmbeddedLinuxBeginnerSGuide#11) and is modified to work with our system:

```C
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/io.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/of.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/init.h>             // Macros used to mark up functions e.g., __init __exit
#include <linux/kernel.h>           // Contains types, macros, functions for the kernel

MODULE_LICENSE("GPL");              ///< The license type -- this affects runtime behavior
MODULE_AUTHOR("Cameron Kirk");      ///< The author -- visible when you use modinfo
MODULE_DESCRIPTION("A simple Linux driver for the BBB.");  ///< The description -- see modinfo
MODULE_VERSION("0.1");              ///< The version of the module

// Prototypes
static int leds_probe(struct platform_device *pdev);
static int leds_remove(struct platform_device *pdev);
static ssize_t leds_read(struct file *file, char *buffer, size_t len, loff_t *offset);
static ssize_t leds_write(struct file *file, const char *buffer, size_t len, loff_t *offset);

// An instance of this structure will be created for every custom_led IP in the system
struct custom_leds_dev {
    struct miscdevice miscdev;
    void __iomem *regs;
    u8 leds_value;
};

// Specify which device tree devices this driver supports
static const struct of_device_id custom_leds_dt_ids[] = {
    {
        .compatible = "dev,custom-leds",
    },
    { /* end of table */ }
};

// Inform the kernel about the devices this driver supports
MODULE_DEVICE_TABLE(of, custom_leds_dt_ids);

// Data structure that links the probe and remove functions with our driver
static struct platform_driver leds_platform = {
    .probe = leds_probe,
    .remove = leds_remove,
    .driver = {
        .name = "Custom LEDs Driver",
        .owner = THIS_MODULE,
        .of_match_table = custom_leds_dt_ids,
    }
};

// The file operations that can be performed on the custom_leds character file
static const struct file_operations custom_leds_fops = {
    .owner = THIS_MODULE,
    .read = leds_read,
    .write = leds_write
};

/** @brief The LKM initialization function
 *  The static keyword restricts the visibility of the function to within this C file. The __init
 *  macro means that for a built-in driver (not a LKM) the function is only used at initialization
 *  time and that it can be discarded and its memory freed up after that point.
 *  @return returns 0 if successful
 *  Called when the driver is installed
 */
static int __init leds_init(void)
{
    int ret_val = 0;
    pr_info("Initializing the Custom LEDs module\n");

    // Register our driver with the "Platform Driver" bus
    ret_val = platform_driver_register(&leds_platform);
    if(ret_val != 0) {
        pr_err("platform_driver_register returned %d\n", ret_val);
        return ret_val;
    }

    pr_info("Custom LEDs module successfully initialized!\n");

    return 0;
}

// Called whenever the kernel finds a new device that our driver can handle
// (In our case, this should only get called for the one instantiation of the Custom LEDs module)
static int leds_probe(struct platform_device *pdev)
{
    int ret_val = -EBUSY;
    struct custom_leds_dev *dev;
    struct resource *r = 0;

    pr_info("leds_probe enter\n");

    // Get the memory resources for this LED device
    r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if(r == NULL) {
        pr_err("IORESOURCE_MEM (register space) does not exist\n");
        goto bad_exit_return;
    }

    // Create structure to hold device-specific information (like the registers)
    dev = devm_kzalloc(&pdev->dev, sizeof(struct custom_leds_dev), GFP_KERNEL);

    // Both request and ioremap a memory region
    // This makes sure nobody else can grab this memory region
    // as well as moving it into our address space so we can actually use it
    dev->regs = devm_ioremap_resource(&pdev->dev, r);
    if(IS_ERR(dev->regs))
        goto bad_ioremap;

    // Turn the LEDs on (access the 0th register in the custom LEDs module)
    
    dev->leds_value = 0xFF;
    iowrite32(dev->leds_value, dev->regs);

    // Initialize the misc device (this is used to create a character file in userspace)
    dev->miscdev.minor = MISC_DYNAMIC_MINOR;    // Dynamically choose a minor number
    dev->miscdev.name = "custom_leds";
    dev->miscdev.fops = &custom_leds_fops;

    ret_val = misc_register(&dev->miscdev);
    if(ret_val != 0) {
        pr_info("Couldn't register misc device :(");
        goto bad_exit_return;
    }

    // Give a pointer to the instance-specific data to the generic platform_device structure
    // so we can access this data later on (for instance, in the read and write functions)
    platform_set_drvdata(pdev, (void*)dev);

    pr_info("leds_probe exit\n");

    return 0;

bad_ioremap:
   ret_val = PTR_ERR(dev->regs); 
bad_exit_return:
    pr_info("leds_probe bad exit :(\n");
    return ret_val;
}// This function gets called whenever a read operation occurs on one of the character files
static ssize_t leds_read(struct file *file, char *buffer, size_t len, loff_t *offset)
{
    int success = 0;

    /* 
    * Get the custom_leds_dev structure out of the miscdevice structure.
    *
    * Remember, the Misc subsystem has a default "open" function that will set
    * "file"s private data to the appropriate miscdevice structure. We then use the
    * container_of macro to get the structure that miscdevice is stored inside of (which
    * is our custom_leds_dev structure that has the current led value).
    * 
    * For more info on how container_of works, check out:
    * http://linuxwell.com/2012/11/10/magical-container_of-macro/
    */
    struct custom_leds_dev *dev = container_of(file->private_data, struct custom_leds_dev, miscdev);

    // Give the user the current led value
    success = copy_to_user(buffer, &dev->leds_value, sizeof(dev->leds_value));

    // If we failed to copy the value to userspace, display an error message
    if(success != 0) {
        pr_info("Failed to return current led value to userspace\n");
        return -EFAULT; // Bad address error value. It's likely that "buffer" doesn't point to a good address
    }

    return 0; // "0" indicates End of File, aka, it tells the user process to stop reading
}

// This function gets called whenever a write operation occurs on one of the character files
static ssize_t leds_write(struct file *file, const char *buffer, size_t len, loff_t *offset)
{
    int success = 0;

    /* 
    * Get the custom_leds_dev structure out of the miscdevice structure.
    *
    * Remember, the Misc subsystem has a default "open" function that will set
    * "file"s private data to the appropriate miscdevice structure. We then use the
    * container_of macro to get the structure that miscdevice is stored inside of (which
    * is our custom_leds_dev structure that has the current led value).
    * 
    * For more info on how container_of works, check out:
    * http://linuxwell.com/2012/11/10/magical-container_of-macro/
    */
    struct custom_leds_dev *dev = container_of(file->private_data, struct custom_leds_dev, miscdev);

    // Get the new led value (this is just the first byte of the given data)
    success = copy_from_user(&dev->leds_value, buffer, sizeof(dev->leds_value));

    // If we failed to copy the value from userspace, display an error message
    if(success != 0) {
        pr_info("Failed to read led value from userspace\n");
        return -EFAULT; // Bad address error value. It's likely that "buffer" doesn't point to a good address
    } else {
        // We read the data correctly, so update the LEDs
        iowrite32(dev->leds_value, dev->regs);
    }

    // Tell the user process that we wrote every byte they sent 
    // (even if we only wrote the first value, this will ensure they don't try to re-write their data)
    return len;
}

// Gets called whenever a device this driver handles is removed.
// This will also get called for each device being handled when 
// our driver gets removed from the system (using the rmmod command).
static int leds_remove(struct platform_device *pdev)
{
    // Grab the instance-specific information out of the platform device
    struct custom_leds_dev *dev = (struct custom_leds_dev*)platform_get_drvdata(pdev);

    pr_info("leds_remove enter\n");

    // Turn the LEDs off
    iowrite32(0x00, dev->regs);

    // Unregister the character file (remove it from /dev)
    misc_deregister(&dev->miscdev);

    pr_info("leds_remove exit\n");

    return 0;
}

/** @brief The leds cleanup function
 *  Similar to the initialization function, it is static. The __exit macro notifies that if this
 *  code is used for a built-in driver (not a LKM) that this function is not required.
 *  Called when the driver is removed
 */
static void leds_exit(void)
{
    pr_info("Custom LEDs module exit\n");

    // Unregister our driver from the "Platform Driver" bus
    // This will cause "leds_remove" to be called for each connected device
    platform_driver_unregister(&leds_platform);

    pr_info("Custom LEDs module successfully unregistered\n");
}

// Tell the kernel which functions are the initialization and exit functions
module_init(leds_init);
module_exit(leds_exit);
```

### Use the Kernel Build System

Now we're ready to build our driver. 

In order to compile this code, it needs to link against the build system for our Linux kernal. This is done by using a Makefile, which will allow us to create our driver binary by simply typing the **make** command in the same directory as our Makefile.

First let's create the Makefile.

```bash
cd $DEWD/driver_led
nano Makefile
```
In the file, copy paste the following code. This is copy pasted directly from [rocketboards.org](https://rocketboards.org/foswiki/Documentation/EmbeddedLinuxBeginnerSGuide#11):

```bash
KDIR ?= ../linux-socfpga

default:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR)

clean:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR) clean

help:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(CURDIR) help

```
Feel free to update the KDIR to point to the full path of your linux kernal build system if it is not currently correct.

Now, let's create the kBuild file.

```bash
cd $DEWD/driver_led
nano Kbuild
```
In the file, copy paste the following code. This is copy pasted directly from [rocketboards.org](https://rocketboards.org/foswiki/Documentation/EmbeddedLinuxBeginnerSGuide#11):

```bash
obj-m := driver_leds.o

```
Now we just need to run the **make** command.
```bash
cd $DEWD/driver_led
make
```

Assuming there were no errors in the build, we can now send the driver to the board.

This will have created a kernal object called `driver_leds.ko`. Let's copy this onto the DE10-Nano and see if it works:

```bash
scp driver_leds.ko root@<ipaddress>:~

```

### Testing the Driver

Now we are ready to install the driver and test if it works. Login to the board and run the following command to install the driver:

```
root@de10-nano:~# insmod driver_leds.ko
[ 2025.906135] Initializing the Custom LEDs module
[ 2025.910765] leds_probe enter
[ 2025.913887] leds_probe exit
[ 2025.917103] Custom LEDs module successfully initialized!
```
If everything is working, you should now see all the LEDs on (except for the blinking LED that is included in the GHRD). This is because of the code we have in the "leds_probe" function. A character file was also created at /dev/custom_leds. You can write values to that file to change which LEDs are turned on. Now run the following command.

```
root@de10-nano:~# echo "9" > /dev/custom_leds
```
After you run the above command, the LEDs should change to reflect this ASCII character's binary value. Feel free to write other values to this file to see how the LEDs change. When you’re done, remove the driver using the rmmod command (all of the LEDs should turn off, as described in the “leds_remove” function).
```
root@de10-nano:~# rmmod driver_leds.ko
rmmod: ERROR: ../libkmod/libkmod.c:514 lookup_builtin_file() could not open builtin file '/lib/modules/5.12.0zImage/modules.buil[ 2091.695249] Custom LEDs module exit
tin.bin'
[ 2091.709624] leds_remove enter
[ 2091.713582] leds_remove exit
[ 2091.718406] Custom LEDs module successfully unregistered
```
## References

[Building embedded linux for the Terasic DE10-Nano](https://bitlog.it/20170820_building_embedded_linux_for_the_terasic_de10-nano.html) - Most of this article has been adapted from here.

[How to Create a Device Tree](https://rocketboards.org/foswiki/Documentation/HOWTOCreateADeviceTree) - Excellent article on how to create a device tree for Cyclone V.

[Embedded Linux Beginners Guide](https://rocketboards.org/foswiki/Documentation/EmbeddedLinuxBeginnerSGuide#11) - Most of the [Building embedded linux for the Terasic DE10-Nano](https://bitlog.it/20170820_building_embedded_linux_for_the_terasic_de10-nano.html) seems to be adapted from here.

<p align="right">Next | <b><a href="Simple-Hardware-Adder_-Introduction.md">My first SoC - Simple Hardware Adder</a></b>
<br/>
<p align="right">Back | <b><a href="Building-SoC-Design.md">Designing and Flashing the design</a></p>
</b><p align="center"><sup>HPS and FPGA communication | </sup><a href="../README.md#hps-and-fpga-communication"><sup>Table of Contents</sup></a></p>
