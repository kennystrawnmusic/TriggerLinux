#!/bin/bash

echo "Welcome to the TriggerLinux Gentoo Edition interactive installer!"

emerge-webrsync > /dev/null
if [ $? -ne 0 ]; then
  unlink /etc/resolv.conf && systemctl restart NetworkManager
fi

echo "Setting up partition space..."
fdisk -l
read -p "Which of the above devices do you want to repartition (example: /dev/sda)? " device
gparted $device

read -p "Which partitiob do you want to install the system on (example: /dev/sda1)? " part
mount $part /mnt/gentoo

echo "Installing base system..."
unsquashfs -f -d /mnt/gentoo /mnt/cdrom/image.squashfs

echo "Setting up critical mountpoints..."
mount -t proc none /mnt/gentoo/proc
mount -t sysfs none /mnt/gentoo/sys
mount -t devtmpfs none /mnt/gentoo/dev
mount -t devpts none /mnt/gentoo/dev/pts
mount -t tmpfs none /mnt/gentoo/dev/shm

echo "Making sure target system has an Internet connection..."
cat /etc/resolv.conf > /mnt/gentoo/etc/resolv.conf

echo "Installing bootloader..."
chroot /mnt/gentoo grub-install $device
chroot /mnt/gentoo grub-mkconfig -o /boot/grub/grub.cfg

echo "Configuring locales..."
ls /usr/share/zoneinfo/*
read -p "Which of the above timezones do you reside in (example: \"America/Los_Angeles\")? " timezone
chroot /mnt/gentoo bash -c "echo $timezone > /etc/timezone"
chroot /mnt/gentoo emerge --config sys-libs/timezone-data

read -p "What is your full name? " name
read -p "What system-level nickname do you want to use? " username
chroot /mnt/gentoo useradd -md /home/$username -c "name" -G "adm,wheel" $username
chroot /mnt/gentoo passwd $username
chroot /mnt/gentoo bash -c "sed -i \"s/root/$username/\" /etc/gdm/custom.conf"

read -p "Log in automatically without typing a password (y/n)? " autologin
if [ $autologin == 'n' ]; then
  chroot /mnt/gentoo bash -c "sed -i \"s/AutomaticLoginEnable.*/AutomaticLoginEnable=false/\" /etc/gdm/custom.conf"
fi

read -p "Do you want to use sudo without needing to type a password each time (y/n)? " sudoers
if [ $sudoers == "y" ]; then
  chroot /mnt/gentoo bash -c "echo \"$username ALL=(ALL:ALL) NOPASSWD: ALL\" >> /etc/sudoers"
fi

echo "Unmounting critical mountpoints..."
umount -lf /mnt/gentoo/dev/shm
umount -lf /mnt/gentoo/dev/pts
umount -lf /mnt/gentoo/dev
umount -lf /mnt/gentoo/sys
umount -lf /mnt/gentoo/proc

read -p "Installation finished. Restart (y/n)? " reboot
if [ reboot == "y" ]; then
  systemctl reboot
fi
