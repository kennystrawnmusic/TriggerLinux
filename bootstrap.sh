#!/usr/bin/sudo /bin/bash

remotefilename=$(wget -O - http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/ | grep -Eo "stage3-amd64-systemd-[0-9]{1,}.tar.bz2" | head -n1)
url=http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/$remotefilename

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

echo "Cloning git repo inside the chroot"
chroot /tmp/triggerlinux-chroot emerge dev-util/triggerlinux-autobuilder

echo "Running autocatalyst.sh inside the chroot"
chroot /tmp/triggerlinux-chroot bash -c "cd /opt/TriggerLinux && ./autocatalyst.sh && cd /"

echo "Copying ISO image out of the chroot"
cp -r /tmp/triggerlinux-chroot/var/tmp/catalyst/builds/default/*.iso ./triggerlinux-livedvd-$(date +%Y%m%d)-x86_64.iso

echo "Removing the chroot"
umount -lf /tmp/triggerlinux-chroot/{etc/resolv.conf,dev/shm,dev/pts,dev,sys,proc}
rm -rf /tmp/triggerlinux-chroot
