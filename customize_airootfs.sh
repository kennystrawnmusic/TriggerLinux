#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root

#inject XAMPP installer into system
wget -O /opt/server-install.run https://www.apachefriends.org/xampp-files/7.3.6/xampp-linux-x64-7.3.6-2-installer.run
chmod a+x /opt/server-install.run

#shell script wrapper to allow ordinary users to install
echo -e "\x23\x21/usr/bin/sudo /bin/bash\n/opt/server-install.run" > /usr/bin/server-install.sh
chmod a+x /usr/bin/server-install.sh

#Override default dhcp client to (hopefully) resolve NetworkManager endless restarts issue
echo -e "[main]\ndhcp=dhclient" > /etc/NetworkManager/conf.d/dhcp.conf

cp -aT /etc/skel/ /root/
cp /root/calamares.desktop /root/Desktop/

#make certain that the plasma configuration files are copied properly
cat /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc > /root/.config/plasma-org.kde.plasma.desktop-appletsrc
cat /etc/skel/.config/plasmashellrc > /root/.config/plasmashellrc

#root's home cannot be visible to anyone but root
chmod 700 /root

if [ -d /etc/ssh ]; then
  sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
fi

#Change archiso hostname to resolve branding issues
echo "triggerbox" > /etc/hostname

#Only uncomment American servers (for now)
sed -i "/United States$/{n;s/#Server/Server/;}" /etc/pacman.d/mirrorlist

#work around lack of keys on live media due to installer bug mentioned in line 87
sed -i "s/SigLevel.*/SigLevel = Optional TrustAll/" /etc/pacman.d/mirrorlist

sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

#Enable core services
systemctl enable pacman-init.service choose-mirror.service NetworkManager.service

#Boot to GUI by default
systemctl set-default graphical.target

#Make sure plymouth is instantly added to mkinitcpio hooks and Intel graphics are working correctly
sed -i "s/.*MODULES.*/MODULES=(intel_agp i915)/" /etc/mkinitcpio.conf
sed -i "s/.*HOOKS.*/HOOKS=(base udev plymouth autodetect modconf block filesystems keyboard fsck)/" /etc/mkinitcpio.conf

#Create temporary user for installation of AUR packages using AUR helper to avoid dependency problems
if ! id tempuser; then
  useradd -k /etc/skel -md /home/tempuser -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -c "Live System User" tempuser
else
  userdel -rf tempuser
  useradd -k /etc/skel -md /home/tempuser -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -c "Live System User" tempuser
fi
echo "tempuser ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

#Remove custom repo
sed -i "$ d" /etc/pacman.conf
sed -i "$ d" /etc/pacman.conf
sed -i "$ d" /etc/pacman.conf

#required for yay to work inside the chroot
pacman-key --init
pacman-key --populate archlinux

#work around package signature bug
su tempuser -c "gpg --recv-keys FE0784117FBCE11D F5675605C74E02CF EAAF29B42A678C20 EC94D18F7F05997E"
su tempuser -c "gpg --recv-keys EC94D18F7F05997E"

#Install certain packages using AUR helper to work around integrity failures
su tempuser -c "yes | yay -Syu --devel yay-git plymouth-git snapd-glib-git snapd-git discover-snap ocs-url opencl-amd grub-git jade-application-kit-git pyside2 brave-bin ms-office-online"

systemctl enable autoupdate.service autoupdate.timer

#Autologin to root account upon live image boot
echo -e "[Users]\nHideUsers=\nMaximumUid=65000\nMinimumUid=0\nRememberLastUser=true" > /etc/sddm.conf
mkdir /etc/sddm.conf.d
echo -e "[Autologin]\nUser=root\nSession=plasma.desktop" > /etc/sddm.conf.d/autologin.conf

#Configure grub to enable splash boot by default
sed -i "s/.*GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/" /etc/default/grub
sed -i "s/.*GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash loglevel=0 rd.udev.log-priority=3 vt.global_cursor_default=0 sysrq_always_enabled=1\"/" /etc/default/grub

#retarget logo.png symlink before changing theme to work around failure of splash screen to appear
unlink /usr/share/plymouth/themes/triggerbox-breeze/logo.png
ln -s /usr/share/plymouth/themes/triggerbox-breeze/logo_full_blue.png /usr/share/plymouth/themes/triggerbox-breeze/logo.png

#self-explanatory
plymouth-set-default-theme -R triggerbox-breeze

#Delete pacman-key directory to work around bug in which calamares tries to create directory that already exists
rm -rf /etc/pacman.d/gnupg

#Install AMDGPU fan controller
wget -O /usr/bin/amdgpu-pro-fans https://raw.githubusercontent.com/DominiLux/amdgpu-pro-fans/master/amdgpu-pro-fans.sh
chmod a+x /usr/bin/amdgpu-pro-fans

#Auto-update needs to be fixed
sed -i "s/ExecStart\=\/usr\/bin\/nice -n 19 \/usr\/bin\/pacman -Syuwq --noconfirm/ExecStart\=\/usr\/bin\/pacman  --noconfirm -Syuq/g" /lib/systemd/system/autoupdate.service

#Customize GRUB to remove last vestiges of Arch branding
sed -i "s/GRUB_DISTRIBUTOR=\"Arch\"/GRUB_DISTRIBUTOR=\"Triggerbox\"/" /etc/default/grub
sed -i "s/OS=\"\${GRUB_DISTRIBUTOR} Linux\"/OS=\"\${GRUB_DISTRIBUTOR}\"/" /etc/grub.d/10_linux

#Create JAK webapp for Gab
wget -O /usr/share/icons/breeze/apps/48/gab.png https://gab.com/assets/icon/apple-touch-icon.png

#Create /usr/share/icons/breeze/apps/scalable if it doesn't exist
if [ ! -d /usr/share/icons/breeze/apps/scalable ]; then
  mkdir /usr/share/icons/breeze/apps/scalable
fi

#Create JAK webapp for Minds
wget -O /usr/share/icons/breeze/apps/scalable/minds.svg https://cdn-assets.minds.com/front/dist/en/assets/logos/bulb.svg

#Create JAK webapp for Parler
wget -O /usr/share/icons/breeze/apps/48/parler.jpg https://images.parler.com/a078092e6e2df507bfd12db4710e8621_128

#Add desktop shortcuts for Gab, Minds, and Parler for all users
cp /usr/share/applications/{gab,minds,parler}.desktop /root/Desktop/
cp /usr/share/applications/{gab,minds,parler}.desktop /etc/skel/Desktop/

#Delete temporary user
userdel -rf tempuser
