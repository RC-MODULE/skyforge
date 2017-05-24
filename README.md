# What is it?

SkyForge is a high-level tool to create ready to boot debian root filesystems
using a simple Dockerfile-inspired syntax.

It uses multistrap to create a basic system and it's own configuration file called Skyfile to create a rootfs tarball

SkyForge assigns a hash to each of the steps it executes. If you are developing
your Skyfile and rerun the build only the actual commands that have changed will be re-run, thus saving you time and bandwidth. What's more skyforge captures the state of the rootfs at each step and makes sure that each command will be run exactly with the same rootfs as if the build had been started from scratch.

SkyForge uses OverlayFS for fast snapshots. If you don't have OverlayFS, you can instruct SkyForge to tarball each and every state of the rootfs being made. Result will be roughly the same, but snapshots will consume a lot of time and disk space. See

```
skyforge tarball
```

# Installation

Just copy skyforge somewhere in your $PATH (e.g. /usr/local/bin ) and execute it as root.

Since multistrap tool requires root privileges so does this tool. You
are strongly adviced to use a disposable environment to run this tool, e.g. docker or a VM.

Since we are going to cook debian rootfs you should normally be running debian.
Ubuntu and derivatives might/likely will work, but I haven't  tested them myself.

# Commandline options

##  build

Build rootfs from Skyfile in current directory.

```
skyforge build
```

If you don't have OverlayFS building will not store snapshots on each step. If you don't have OverlayFS in your kernel but still want the snapshot feature run


```
skyforge tarball
skyforge build
```

## tarball
Enables tarballing of each of the steps run. This will persist until you run 'skyforge purge'. See 'build' section for more

## clean

Remove old snapshots from working directory (.forge) and leave only those
actually present in the Skyfile

```
skyforge clean
```

Skyforge does cleaning every time it is executed, so you normally don't need to
run it manually

## purge

Remove all intermediate junk created by Skyforge.
Equivalent of running rm -Rf .forge

## mount

When running with OverlayFS available this command mounts the rootfs/ at the last snapshot and prints out history like 'status' does

## status

Prints out current action log including Skyfile lines and their hashes.
Each line of Skyfile is identified by a hash.
Inserting a line before it changes the hashes of all lines following it.

Example
```
0 ✓ necromant @ sylwer ~/work/images-kitchen/skforge-ng $ sudo skyforge status
[S] 137e53ce7d4cdfdc450ebd8e4c26e0f5 | MULTISTRAP armel debian-devel.conf
[S] 1f9c1485f902a9d2666aac149964bd4f | INSTALL /usr/bin/qemu-arm-static
[S] 5d9b38f8739e1651cff272c8eb52967b | RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C /var/lib/dpkg/info/dash.preinst install
[S] f65e324ccf1e930b92aa36d03d5d6bca | RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C dpkg --configure -a
[S] 8fc57faaae70663788b66be85a350da9 | INSTALL /etc/resolv.conf
[S] 7b71e6cc8c2e49f631f9359caf0b2ae5 | APT_KEY http://www.module.ru/mb7707/repo/repository.gpg
[S] c69c646d9f312a12921e351af0c46286 | PASSWD 12345678
[S] b99f635eac300deb0ac0cbd4f23b6b1b | HOSTNAME shade
[S] 20b00807b38463389ece47f5d44f268e | LOCALE en_US.UTF8 UTF8
[S] c89fd713906fad5f2a88dacce5071897 | IFACE_STATIC eth0 192.168.20.9 255.255.255.0 192.168.20.1 8.8.8.8
[S] 1cfbab080e8c49db1df2347eebc37edf | RUN sed "'s/PermitRootLogin without-password/PermitRootLogin yes/'" -i etc/ssh/sshd_config
[R] b1fabddf2afd249fc0a6cb6197ce3e6b | REMOVE /etc/ssh/ssh_host_*
[R] d1c3a6448f04d6656cfdf187a096ed06 | REMOVE /etc/resolv.conf
[R] e0b5c4cea6ae1dad709b751e13b10efd | STORE rootfs.tgz
```

Legend:

### [S]  

Skyforge will skip this step, it has already been run/we have a snapshot

### [R]

Skyforge will execute this step when you run build

## Replay hash

Replay all actions starting with the one identified by hash during the next build

Example

```
skyforge replay b1fabddf2afd249fc0a6cb6197ce3e6b
```

# A summary of available Skyfile commands

## MULTISTRAP debarch config-file

Runs multistrap with the supplied debarch (e.g. armel) using the config file supplied. Should be the first command to run. This step also makes sure an adequate qemu-static binary is copied to target chroot. (e.g. qemu-arm-static for arm).

NOTE: Since debian architecture names are not always mapped one-to-one to qemu architecture names this script takes care to guess the right one. This logic currently covers arm, mips and x86/x86_64 variants. If you have something else - patches are welcome.

```
MULTISTRAP armel debian-armel.conf
```

## DPKG_CONFIGURE

Runs the steps required to configure the unpacked packages in chroot.
This command does the following:

1. Prohibits the start of any services via policy-rc.d
2. Runs the dash.preinst script (As described in debian wiki)
3. Runs dpkg-configure -a
4. Allows service startup

The default behavior is interactive (e.g. allow dpkg-configure to ask different
questions). If this is not desired, supply the silent argument.
If you want to other variables you can do it here as well.

Configure packages, ask no questions
```
DPKG_CONFIGURE silent
```
or
```
DPKG_CONFIGURE DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
```

Configure packages, ask questions about system setup
```
DPKG_CONFIGURE
```
or
```
DPKG_CONFIGURE interactive
```

## DENY_SERVICE_START

Prohibits any services to be started in the target root filesystem via policy-rc.d

## ALLOW_SERVICE_START

Undos what DENY_SERVICE_START has done

## INCLUDE Skyfile

Include a Skyfile script.

```
INCLUDE Skyfile.inc
```

## INSTALL filename

Copies a file from host operating system to target

```
INSTALL /etc/resolv.conf
```

##RUN command

Runs a command in chrooted environment. If you have a cross-chroot and that doesn't work check if you have qemu-user-static installed and that MULTISTRAP command actually copied the right one to your chroot.

```
RUN uname -a
```

##REMOVE filename

Delete a file from target root filesystem

```
REMOVE /etc/resolv.conf
```

## ADD_DEB package

Install a debian package to target rootfs the package can be either a local file or an URL

```
    ADD_DEB https://example.com/myfile.deb
    ADD_DEB myotherfile.deb
```

##ADD_PACKAGES pkg1 pkg2

Call apt-get to install additional packages. Use of this command is not recommended. Edit multistrap.conf instead.

```
ADD_PACKAGES usb-utils
```

##STORE filename

Tarball the root filesystem into the archive filename.
The archive generated will be deleted if you run 'skyforge purge'

```
STORE rootfs.tar.gz
```

##PASSWD

Setup root password on the target system.

```
PASSWD 12345678
```

##HOSTNAME

Setup hostname on the target root filesystem

```
HOSTNAME iltharia
```

##LOCALE

Add locale to /etc/locale.gen and generate locales on the target

```
LOCALE en_US.UTF8 UTF8
```

##IFACE_STATIC iface ip netmask gateway

Configure ethernet interface parameters (static IP)

```
IFACE_STATIC eth0 192.168.20.9 255.255.255.0 192.168.20.1 8.8.8.8
```

##IFACE_DHCP iface

Configure ethernet interface with DHCP

```
IFACE_DHCP eth0
```

##APT_KEY url

Add an apt gpg key into the target rootfs

```
APT_KEY http://www.module.ru/mb7707/repo/repository.gpg
```
## SH command

Just run a shell command in this directory.
You can omit SH and it will still work the same. Magic!

```
SH ls rootfs/
```
and

```
ls rootfs/
```

are essentially the same

##SYMLINK2COPY

Replace all symlinks in the root filesystem with file copies. This bloats the filesystem but is sometimes the only choice if you want to use the rootfs as a
sysroot for development in a windows-environment that (sic!) doesn't play with symlinks well.

```
SYMLINK2COPY
```
##SYMLINK2RELATIVE

Replace all symlinks containing absolute paths in the root filesystem with
symlinks containing relative paths. This is required if you plan to use the resulting rootfs as a development sysroot (Because unpacking this filesystem anywhere save for / will corrupt relative symlinks)
```
SYMLINK2RELATIVE
```

## LDSOFIXUP

Concatenate contents of rootfs/etc/ld.so.conf.d into one ld.so.conf
This is usually required if you plan to use the rootfs as a sysroot with linaro abe-based crooss toolchains that don't read properly the contents of /etc/ld.so.conf.d/
If you plan to actually boot the system - you don't need this one.

##ADD filename.tgz dir

Unpack the filename.tgz into the rootfs/[dir] directory.

```
ADD stuff.tgz /
ADD cross-compiler.tgz /opt
```

##ARTIFACT filename

Mark filename as a build artifact. The only effect this has - this file will be
removed when you run skyforge purge

# A complete Skyfile Example

```
#The basic multistrap stuff
MULTISTRAP armel debian-devel.conf
INSTALL /usr/bin/qemu-arm-static
RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C /var/lib/dpkg/info/dash.preinst install
RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C dpkg --configure -a

#Install a proper resolv.conf
INSTALL /etc/resolv.conf

#Install RCM Repository GPG Key
APT_KEY http://www.module.ru/mb7707/repo/repository.gpg

#Basic system setup
PASSWD 12345678
HOSTNAME shade
LOCALE en_US.UTF8 UTF8
IFACE_STATIC eth0 192.168.20.9 255.255.255.0 192.168.20.1 8.8.8.8
#IFACE_DHCP eth0

#Enable root access over ssh
RUN sed "'s/PermitRootLogin without-password/PermitRootLogin yes/'" -i /etc/ssh/sshd_config

#Force SSH to generate host keys at boot
REMOVE /etc/ssh/ssh_host_*
REMOVE /etc/resolv.conf

STORE rootfs.tgz
```

See more examples in example/ directory


#License

See LICENSE.TXT
