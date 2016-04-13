#!/bin/bash
# $1 == root fs dir 
# $2 == output dir

mkfs.ubifs -r "$1" -m 0x800 -e 0x1f000 -c 8192 -o "temp.img"
ubinize -vv -o "$2" -m 0x800 \
  -p 0x20000 -O 2048 ubinize.conf


