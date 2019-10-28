#!/bin/bash

kernel="$(ls /boot | grep kernel-genkernel | sort -rn | head -n1)"
initramfs="$(ls /boot | grep initramfs-genkernel | sort -rn | head -n1)"

#Overlays
layman -L
yes | layman -a snapd
yes | layman -a brave-overlay

#Live media hostname
echo "livecd" > /etc/hostname

#Download config files that emerge won't install and inject them into the system
wget -O /etc/calamares/settings.conf https://raw.githubusercontent.com/calamares/calamares/master/settings.conf
for i in $(ls /usr/lib64/calamares/modules); do
  wget -O /etc/calamares/modules/$i.conf https://raw.githubusercontent.com/calamares/calamares/master/src/modules/$i/$i.conf
done

#Configure calamares branding
sed -i "s/branding\:.*/branding\: triggerlinux/" /etc/calamares/settings.conf

#Un-break partitioning
sed -i '84,$d' /etc/calamares/modules/partition.conf
sed -i '9,38d' /etc/calamares/modules/partition.conf
sed -i "s/#\ ensureSuspendToDisk/ensureSuspendToDisk/" /etc/calamares/modules/partition.conf
sed -i "s/#\ neverCreateSwap/neverCreateSwap/" /etc/calamares/modules/partition.conf

#Needed in order to successfully unpack system
sed -i '85,$d' /etc/calamares/modules/unpackfs.conf
sed -i "s/source\:.*/source\:\ \"\/mnt\/cdrom\/image.squashfs\"/" /etc/calamares/modules/unpackfs.conf
sed -i "s/sourcefs\:.*/sourcefs\:\ \"squashfs\"/" /etc/calamares/modules/unpackfs.conf
sed -i "s/destination\:.*/destination\:\ \"\/\"/" /etc/calamares/modules/unpackfs.conf
sed -i '12,80d' /etc/calamares/modules/unpackfs.conf
sed -i '1,10d' /etc/calamares/modules/unpackfs.conf

#Add the proper number of groups
sed -i '23a\ \ \ \ \-\ cdrom' /etc/calamares/modules/users.conf
sed -i '24a\ \ \ \ \-\ cdrw' /etc/calamares/modules/users.conf
sed -i '25a\ \ \ \ \-\ usb' /etc/calamares/modules/users.conf
sed -i '26a\ \ \ \ \-\ plugdev' /etc/calamares/modules/users.conf
sed -i '27a\ \ \ \ \-\ vboxusers' /etc/calamares/modules/users.conf
sed -i '28a\ \ \ \ \-\ vboxsf' /etc/calamares/modules/users.conf
sed -i '29a\ \ \ \ \-\ vboxguest' /etc/calamares/modules/users.conf
sed -i '30a\ \ \ \ \-\ portage' /etc/calamares/modules/users.conf
sed -i '31a\ \ \ \ \-\ messagebus' /etc/calamares/modules/users.conf
sed -i '32a\ \ \ \ \-\ polkituser' /etc/calamares/modules/users.conf
sed -i '33a\ \ \ \ \-\ games' /etc/calamares/modules/users.conf
sed -i '34a\ \ \ \ \-\ scanner' /etc/calamares/modules/users.conf
sed -i '35a\ \ \ \ \-\ bumblebee' /etc/calamares/modules/users.conf
sed -i '36a\ \ \ \ \-\ lpadmin' /etc/calamares/modules/users.conf

#Calamares bootloader config
sed -i "s/kernel\:.*/kernel\:\ \"\/boot\/$kernel\"/" /etc/calamares/modules/bootloader.conf
sed -i "s/img\:.*/img\:\ \"\/boot\/$initramfs\"/" /etc/calamares/modules/bootloader.conf
sed -i "s/fallback\:.*/fallback\: \"\/boot\/$initramfs\"/" /etc/calamares/modules/bootloader.conf
sed -i "s/timeout\:.*/timeout\:\ \"0\"/" /etc/calamares/modules/bootloader.conf

#Integrate calamares with Portage
sed -i "s/backend\:.*/backend\:\ portage/" /etc/calamares/modules/packages.conf
sed -i "s/update\_system\:.*/update_system\:\ true/" /etc/calamares/modules/packages.conf

#Don't need calamares on the system post-installation
sed -i "162,166d" /etc/calamares/modules/packages.conf
sed -i '$d' /etc/calamares/modules/packages.conf
sed -i '$d' /etc/calamares/modules/packages.conf
sed -i '$d' /etc/calamares/modules/packages.conf
sed -i "$ a\ \ \ \ \-\ app-admin\/calamares" /etc/calamares/modules/packages.conf

#Calamares Plymouth theme
sed -i "s/plymouth_theme\:.*/plymouth_theme\: bgrt/" /etc/calamares/modules/plymouthcfg.conf

#Default calamares locale
sed -i "s/zone\:.*/zone\:\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \"Los_Angeles\"/" /etc/calamares/modules/locale.conf
sed -i "s/selector\:.*\ /selector\:\ \"time_zone\"/" /etc/calamares/modules/locale.conf

#Reboot immediately when finished
sed -i "s/restartNowCommand\:.*/restartNowCommand\: \"echo b > \/proc\/sysrq-trigger\"/" /etc/calamares/modules/finished.conf

#Enable "packages" module
sed -i "124a\ \ \-\ packages" /etc/calamares/settings.conf

#Disable Arch/Manjaro-specific modules
sed -i "s/\ \ \-\ initcpio/#\ \ \-\ initcpio/" /etc/calamares/settings.conf
sed -i "s/\ \ \-\ initcpiocfg/#\ \ \-\ initcpiocfg/" /etc/calamares/settings.conf
sed -i "s/\ \ \-\ initramfs/#\ \ \-\ initramfs/" /etc/calamares/settings.conf

#Calamares-pkexec
sed -i "s/calamares-pkexec/pkexec\ \/usr\/bin\/calamares/g" /usr/share/applications/calamares.desktop

#Extended globbing by default
echo "shopt -s extglob" >> /etc/profile

#GRUB Plymouth entry
sed -i "s/.*GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash zram.num_devices=1\"/" /etc/default/grub
sed -i "s/.*GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/" /etc/default/grub
sed -i "s/GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/" /etc/calamares/modules/grubcfg.conf

#Root password
echo -e "triggerlinux\ntriggerlinux" | passwd

#Automatic login
systemctl enable gdm.service
sed -i "3a AutomaticLoginEnable=true" /etc/gdm/custom.conf
sed -i "4a AutomaticLogin=root" /etc/gdm/custom.conf

#Customize Dash-to-Panel
echo -e "[org.gnome.shell.extensions.dash-to-panel]" >> /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/org.gnome.shell.extensions.dash-to-panel.gschema.override
echo -e "appicon-margin=3" >> /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/org.gnome.shell.extensions.dash-to-panel.gschema.override
echo -e "hotkeys-overlay-combo='TEMPORARILY'" >> /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/org.gnome.shell.extensions.dash-to-panel.gschema.override
echo -e "panel-size=40" >> /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/org.gnome.shell.extensions.dash-to-panel.gschema.override
echo -e "animate-show-apps=false" >> /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/org.gnome.shell.extensions.dash-to-panel.gschema.override

#Desktop Background
echo -e "[org.gnome.desktop.background:GNOME]" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "picture-options='str/etched'" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "picture-uri='file:///usr/share/backgrounds/gnome/SeaSunset.jpg'" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "primary-color='#ffffff'" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "secondary-color='#000000'" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override

#Lock screen background
echo -e "[org.gnome.desktop.screensaver:GNOME]" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "picture-options='str/etched'" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "picture-uri='file:///usr/share/backgrounds/gnome/SeaSunset.jpg'" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "primary-color='#ffffff'" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "secondary-color='#000000'" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
echo -e "idle-activation-enabled=false" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override

#Enable GNOME Shell extensions by default
echo -e "[org.gnome.shell:GNOME]\nenabled-extensions=['dash-to-panel@jderose9.github.com', 'desktop-icons@csoriano', 'user-theme@gnome-shell-extensions.gcampax.github.com']" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override

#Favorites
echo -e "favorite-apps=['calamares.desktop', 'org.gnome.Evolution.desktop', 'brave-bin.desktop', 'gnome-control-center.desktop', 'rhythmbox.desktop', 'shotwell.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop', 'org.gnome.tweaks.desktop', 'org.gnome.Terminal.desktop', 'kdenlive.desktop']\n" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override

#More window controls than just "Close"
echo -e "[org.gnome.desktop.wm.preferences:GNOME]\nbutton-layout='appmenu:minimize,maximize,close'\n" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override

#Arc Theme + Clock Prefs
echo -e "[org.gnome.desktop.interface:GNOME]\ngtk-theme='Arc'\nicon-theme='Arc'\nclock-show-date=true\nclock-show-seconds=true" >> /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override

#Recompile Schemas
glib-compile-schemas /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas
glib-compile-schemas /usr/share/glib-2.0/schemas

#Don't disadvantage those with slower hardware
sed -i "s/MAKEOPTS/\#MAKEOPTS/" /etc/portage/make.conf
sed -i "s/MAKEOPTS/\#MAKEOPTS/" /etc/genkernel.conf

#Activate Automatic Updater
systemctl enable autoupdate.service
systemctl enable autoupdate.timer

#NetworkManager
systemctl enable systemd-resolved.service
systemctl enable NetworkManager.service

#Ensure that printing works out-of-the-box
systemctl enable cups.service

#AppImage Daemon
mkdir /Applications
wget -O /usr/bin/appimaged https://github.com/AppImage/appimaged/releases/download/continuous/appimaged-x86_64.AppImage
chmod a+x /usr/bin/appimaged
wget -O /lib/systemd/system/appimaged.service https://raw.githubusercontent.com/AppImage/appimaged/master/resources/appimaged.service
systemctl enable appimaged.service

#AppImage Updater
wget -O /usr/bin/AppImageUpdate https://github.com/AppImage/AppImageUpdate/releases/download/continuous/AppImageUpdate-x86_64.AppImage
chmod a+x /usr/bin/AppImageUpdate
wget -O /usr/share/applications/AppImageUpdate.desktop https://raw.githubusercontent.com/AppImage/AppImageUpdate/rewrite/resources/AppImageUpdate.desktop

#AppImageLauncher
wget -O /usr/bin/appimagelauncher-lite https://github.com/TheAssassin/AppImageLauncher/releases/download/continuous/appimagelauncher-lite-2.0.2-travis879-29526eb-x86_64.AppImage
chmod a+x /usr/bin/appimagelauncher-lite
appimagelauncher-lite --appimage-extract
cp squashfs-root/usr/share/applications/appimagelauncher-lite.desktop /usr/share/applications/appimagelauncher-lite.desktop
for i in $(ls /usr/share/icons); do
  if [ ! -d /usr/share/icons/$i/192x192 ]; then
    mkdir -p /usr/share/icons/$i/192x192/apps
  fi
  cp squashfs-root/usr/share/icons/hicolor/192x192/apps/AppImageLauncher.png /usr/share/icons/$i/192x192/apps/AppImageLauncher.png
done
rm -rf squashfs-root

#Install Kdenlive as AppImage
wget -O /Applications/Kdenlive.AppImage https://files.kde.org/kdenlive/release/kdenlive-19.08.2b-x86_64.appimage
chmod a+x /Applications/Kdenlive.AppImage
/Applications/Kdenlive.AppImage --appimage-extract
cp squashfs-root/org.kde.kdenlive.desktop /usr/share/applications/kdenlive.desktop
sed -i "s/Exec\=.*/Exec\=\/Applications\/Kdenlive.AppImage\ \%F/" /usr/share/applications/kdenlive.desktop
for i in $(ls /usr/share/icons); do
  if [ ! -d /usr/share/icons/$i/scalable ]; then
    mkdir -p /usr/share/icons/$i/scalable/apps
  fi
  cp squashfs-root/kdenlive.svg /usr/share/icons/$i/scalable/apps/kdenlive.svg
done
rm -rf squashfs-root

#Needed for emerge --sync to succeed on calamares target system
umount -lf /usr/livecd/db/repos/gentoo && rmdir /usr/livecd/db/repos/gentoo

#Make Brave work when run as any user, including root
sed -i "s/Exec=.*/Exec=\/usr\/bin\/brave-bin\ \-\-no\-sandbox\ \%u/" /usr/share/applications/brave-bin.desktop
