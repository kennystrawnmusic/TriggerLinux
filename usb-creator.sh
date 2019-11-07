#!/usr/bin/sudo /bin/bash

builddir=/var/tmp/catalyst/builds/default
scriptdir=$PWD

cd $builddir
dd if=/dev/zero of=$1 oflag=direct bs=4M status=progress
dd if=livecd-amd64-installer-latest.iso of=$1 oflag=direct bs=4M status=progress
cd $scriptdir
