#!/bin/bash
# $1 == root fs dir 
# $2 == output dir

# -m minimum io size
# -e leb-size logical erase block size 
# -c max logical erase blocks

mkfs.ubifs -r "$1" -m 0x800 -e 0x1f000 -c 8192 -o "temp.img"
ubinize -vv -o "$2" -m 0x800 -p 0x20000 -O 2048 ubinize.conf
mv rootfs.ubifs rootfs-128k.ubifs

mkfs.ubifs -r "$1" -m 0x800 -e 0x3f000 -c 8192 -o "temp.img"
ubinize -vv -o "$2" -m 0x800 -p 0x40000 -O 2048 ubinize.conf
mv rootfs.ubifs rootfs-256k.ubifs

#-m minimum io size
#-p, --peb-size=<bytes>       size of the physical eraseblock of the flash
#                             this UBI image is created for in bytes,
#                             kilobytes (KiB), or me
#-O, --vid-hdr-offset=<num>   offset if the VID header from start of the
#                             physical eraseblock (default is the next
#                             minimum I/O unit or sub-page after the EC
#                             header)
#


