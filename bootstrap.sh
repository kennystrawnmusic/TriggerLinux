#!/usr/bin/sudo /bin/bash

url=https://github.com/realKennyStrawn93/TriggerLinux/releases/download/continuous/triggerlinux-livedvd-stage1-latest.tar.bz2
scriptdir=$PWD

echo "Welcome to the TriggerLinux Gentoo Edition bootstrap script!"

echo "Downloading stage tarball..."
wget -O /tmp/chroot.tar.bz2 $url

echo "Extracting stage tarball as chroot"
mkdir -p /tmp/triggerlinux-chroot
tar -C /tmp/triggerlinux-chroot -xjvf /tmp/chroot.tar.bz2

echo "Copying portage_confdir to the chroot"
rm -rf /tmp/triggerlinux-chroot/etc/portage
cp -r portage /tmp/triggerlinux-chroot/etc/portage
rm -rf /tmp/triggerlinux-chroot/var/db/repos/gentoo
mkdir -p /tmp/triggerlinux-chroot/var/db/repos/gentoo

echo "Binding DNS resolver configuration files to the chroot"
mount --bind /etc/resolv.conf /tmp/triggerlinux-chroot/etc/resolv.conf

echo "Emerging necessary packages inside the chroot"
chroot /tmp/triggerlinux-chroot mount -t proc none /proc
chroot /tmp/triggerlinux-chroot mount -t sysfs none /sys
chroot /tmp/triggerlinux-chroot mount -t devtmpfs none /dev
chroot /tmp/triggerlinux-chroot mount -t devpts none /dev/pts
chroot /tmp/triggerlinux-chroot mount -t tmpfs none /dev/shm
chroot /tmp/triggerlinux-chroot emerge --sync
chroot /tmp/triggerlinux-chroot emerge app-portage/layman
chroot /tmp/triggerlinux-chroot layman -L
chroot /tmp/triggerlinux-chroot bash -c "yes | layman -a brave-overlay"
chroot /tmp/triggerlinux-chroot bash -c "yes | layman -o https://raw.githubusercontent.com/realKennyStrawn93/triggerlinux-overlay/master/triggerlinux-overlay.xml -f -a triggerlinux-overlay"
# Needed to avoid "permission denied" errors when building
chroot /tmp/triggerlinux-chroot chmod -R 777 /var/cache

echo "Cloning git repo inside the chroot"
chroot /tmp/triggerlinux-chroot emerge dev-util/triggerlinux-autobuilder

echo "Running autocatalyst.sh inside the chroot"
chroot /tmp/triggerlinux-chroot bash -c "cd /opt/TriggerLinux && ./autocatalyst.sh && cd /"

echo "Copying ISO image out of the chroot"
cp /tmp/triggerlinux-chroot/var/tmp/catalyst/builds/default/*.tar.bz2 $scriptdir/triggerlinux-livedvd-stage1-latest.tar.bz2
cp /tmp/triggerlinux-chroot/var/tmp/catalyst/builds/default/*.iso $scriptdir/triggerlinux-livedvd-latest-x86_64.iso

echo "Removing the chroot"
umount -lf /tmp/triggerlinux-chroot/{etc/resolv.conf,dev/shm,dev/pts,dev,sys,proc}
rm -rf /tmp/triggerlinux-chroot
