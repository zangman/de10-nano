<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Summary](#summary)
- [Simple Adder module](#simple-adder-module)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

Here we create a simple adder module. While the adder is quite simple, there is one important thing to take note of. We are creating a **regular** adder in verilog which would be just how you would have designed it if you were going to use it in a simple FPGA and not an SoC. This demonstrates how you can take an existing design that works in an FPGA and re-use it in an SoC. Pretty cool stuff!

## Simple Adder module

This is as easy as can be. We're going to design a 64 bit adder. It will take 2 64 bit inputs and return a 64 bit output:

```systemverilog
module simple_adder(
  input logic [63:0] a,
  input logic [63:0] b,
  output logic [63:0] sum 
);
assign sum = a + b;

endmodule
```

Save this in a folder in your working directory:

```bash
cd $DEWD
mkdir -p ip/simple_adder
cd ip/simple_adder
vim simple_adder.sv
# Paste the code here and save
```

This completes the adder. Use the menu on the right to go to the next section.