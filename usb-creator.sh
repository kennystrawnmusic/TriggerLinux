#!/usr/bin/sudo /bin/bash

builddir=/var/tmp/catalyst/builds/default
scriptdir=$PWD

if [ -z $1 ]; then
  fdisk -l
  echo "Usage: usb-creator.sh /dev/USB_DEVICE, where USB_DEVICE is the device listed above as your flash drive"
else
  cd $builddir
  dd if=/dev/zero of=$1 oflag=direct bs=4M status=progress
  dd if=livecd-amd64-installer-latest.iso of=$1 oflag=direct bs=4M status=progress
  cd $scriptdir
fi
