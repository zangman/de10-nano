# Absolute beginner's guide to DE10-Nano

## Summary

This repository contains all the details for an absolute beginner to get started with the DE10-Nano.

To get started, please visit [the wiki](https://github.com/zangman/de10-nano/wiki).

## FAQ

### Isn't there documentation already? Why this guide?

* **Not beginner friendly** - There is a lot of documentation online, but they don't show always explain everything.
* **Comprehensive** - The ultimate goal of this site is to be comprehensive so anyone starting new doesn't have to visit several websites and forums to get information.
* **Focused** - There are several boards by Terasic and Altera which use Cyclone V and all of them vary slightly. This guide only focuses on the DE10-Nano. If you are using a DE1 or any other Cyclone V board, a lot of the content will still be applicable. But I haven't tested it, so I don't know if it will work or not.

### I spotted a mistake!

Please let me know! Either raise an issue or submit a pull request and I will greatly appreciate it!

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
