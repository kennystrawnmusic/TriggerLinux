#!/bin/bash

remotefilename=$(wget -O - http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/ | grep -Eo "stage3-amd64-systemd-[0-9]{1,}.tar.bz2" | head -n1)
url=http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/$remotefilename

if [ $ -ne 0 ]; then
  echo "Please run this script as root or (if installed and configured) with sudo prepended"
fi

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

echo "Binding DNS resolver configuration files to the chroot"
mount --bind /etc/resolv.conf /tmp/triggerlinux-chroot/etc/resolv.conf

echo "Emerging necessary packages inside the chroot"
chroot /tmp/triggerlinux-chroot mount -t proc none /proc
chroot /tmp/triggerlinux-chroot mount -t sysfs none /sys
chroot /tmp/triggerlinux-chroot mount -t devtmpfs none /dev
chroot /tmp/triggerlinux-chroot mount -t devpts none /dev/pts
chroot /tmp/triggerlinux-chroot mount -t tmpfs none /dev/shm
chroot /tmp/triggerlinux-chroot emerge --sync
chroot /tmp/triggerlinux-chroot emerge app-admin/sudo dev-vcs/git net-misc/wget dev-util/catalyst

echo "Cloning git repo inside the chroot"
chroot /tmp/triggerlinux-chroot bash -c "git clone https://github.com/realKennyStrawn93/TriggerLinux.git /tmp/triggerlinux"

echo "Running autocatalyst.sh inside the chroot"
chroot /tmp/triggerlinux-chroot bash -c "cd /tmp/triggerlinux && ./autocatalyst.sh && cd /"

echo "Copying ISO image out of the chroot"
cp -r /tmp/triggerlinux-chroot/var/tmp/catalyst/builds/default/*.iso /home/triggerlinux-livecd-$(date +%Y%m%d)-x86_64.iso

echo "Removing the chroot"
umount -lf /tmp/triggerlinux-chroot/{etc/resolv.conf,dev/shm,dev/pts,dev,sys,proc}
rm -rf /tmp/triggerlinux-chroot
