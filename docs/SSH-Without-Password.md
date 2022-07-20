<p align="right"><sup><a href="Yocto-Linux.md">Back</a> | <a href="Creating-a-Bootscript.md">Next</a> | </sup><a href="../README.md#appendix"><sup>Contents</sup></a>
<br/>
<sup>Appendix</sup></p>

# SSH without password (using keys)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Summary](#summary)
- [Steps](#steps)
  - [Create the public key on development machine](#create-the-public-key-on-development-machine)
  - [Copy the public key to de10-nano](#copy-the-public-key-to-de10-nano)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

It's tedious to keep typing the password everytime I need to copy something or ssh into my de10-nano. So listing the steps here to ssh/scp without a password using ssh keys.

## Steps

### Create the public key on development machine

> Note: If you've generated keys for github for your development machine, you can re-use the same ones. No need to create them again. In that case, skip this step.

Create a new key pair with the following command:

```bash
ssh-keygen -t rsa -b 4096 -C "email@domain.com"
```

Press `Enter` to accept default file location and name.

I prefer no passphrase, but you can enter the passphrase if you like.

The private and public keys created can be seen with:

```bash
ls ~/.ssh/id_*
```

### Copy the public key to de10-nano

```bash
ssh-copy-id root@<de10-ip-address>
```

Enter the password and that completes it!

## References

[linuxize.com - how to setup passwordless ssh login](https://linuxize.com/post/how-to-setup-passwordless-ssh-login/) - Most steps taken from here.

<p align="right">Next | <b><a href="Creating-a-Bootscript.md">Creating a bootscript</a></b>
<br/>
Back | <b><a href="Yocto-Linux.md">Yocto Linux</a></p>
</b><p align="center"><sup>Appendix | </sup><a href="../README.md#appendix"><sup>Table of Contents</sup></a></p>
