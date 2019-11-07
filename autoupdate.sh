#!/bin/bash

kdenlive="https://files.kde.org/kdenlive/release/$(wget -qO - https://files.kde.org/kdenlive/release/ | grep -Eo kdenlive-[0-9][0-9].[0-9][0-9].[0-9][a-z]-x86_64.appimage | sort -rn | head -n1)"

appimagelauncher_base=https://artifacts.assassinate-you.net/artifactory/AppImageLauncher
appimagelauncher_var1=$(wget -qO - https://artifacts.assassinate-you.net/artifactory/AppImageLauncher | grep -Eo "travis-[0-9]{1,}" | sort -rn | head -n1)
appimagelauncher_var2=$(wget -qO - $appimagelauncher_base/$appimagelauncher_var1 | grep appimagelauncher-lite | grep x86_64 | cut -d "\"" -f2)
appimagelauncher=$appimagelauncher_base/$(wget -qO - https://artifacts.assassinate-you.net/artifactory/AppImageLauncher | grep -Eo "travis-[0-9]{1,}" | sort -rn | head -n1)/$appimagelauncher_var2

#AppImage Daemon
current_version=$(appimaged --version)
wget -O /tmp/appimaged https://github.com/AppImage/appimaged/releases/download/continuous/appimaged-x86_64.AppImage
chmod a+x /tmp/appimaged
new_version=$(/tmp/appimaged --version)
if [ "$new_version" == "$current_version" ]; then
  echo "appimaged already up-to-date; cleaning up"
  rm -f /tmp/appimaged
else
  cat /tmp/appimaged > /usr/bin/appimaged
  chmod a+x /usr/bin/appimaged
  wget -O /lib/systemd/system/appimaged.service https://raw.githubusercontent.com/AppImage/appimaged/master/resources/appimaged.service
systemctl enable appimaged.service
  rm -f /tmp/appimaged
fi

#AppImage Updater
current_version=$(AppImageUpdate --version)
wget -O /tmp/AppImageUpdate https://github.com/AppImage/AppImageUpdate/releases/download/continuous/AppImageUpdate-x86_64.AppImage
chmod a+x /tmp/AppImageUpdate
new_version=$(/tmp/AppImageUpdate --version)
if [ "$new_version" == "$current_version" ]; then
  echo "AppImageUpdate already up-to-date; cleaning up"
  rm -f /tmp/AppImageUpdate
else
  cat /tmp/AppImageUpdate > /usr/bin/AppImageUpdate
  chmod a+x /usr/bin/AppImageUpdate
  wget -O /usr/share/applications/AppImageUpdate.desktop https://raw.githubusercontent.com/AppImage/AppImageUpdate/rewrite/resources/AppImageUpdate.desktop
  rm -f /tmp/AppImageUpdate
fi

#AppImageLauncher
current_version=$(appimagelauncher-lite --version)
wget -O /tmp/appimagelauncher-lite $appimagelauncher
chmod a+x /tmp/appimagelauncher-lite
new_version=$(/tmp/appimagelauncher-lite --version)
if [ "$new_version" == "$current_version" ]; then
  echo "AppImageLauncher already up-to-date; cleaning up"
  rm -f /tmp/appimagelauncher-lite
else
  cd /tmp
  cat /tmp/appimagelauncher-lite > /usr/bin/appimagelauncher-lite
  appimagelauncher-lite --appimage-extract
  cp squashfs-root/usr/share/applications/appimagelauncher-lite.desktop /usr/share/applications/appimagelauncher-lite.desktop
  for i in $(ls /usr/share/icons); do
    if [ ! -d /usr/share/icons/$i/192x192 ]; then
      mkdir -p /usr/share/icons/$i/192x192/apps
    fi
    cp squashfs-root/usr/share/icons/hicolor/192x192/apps/AppImageLauncher.png /usr/share/icons/$i/192x192/apps/AppImageLauncher.png
  done
  rm -rf squashfs-root
fi

#Update Kdenlive AppImage
current_version=$(/Applications/Kdenlive.AppImage --version)
wget -O /tmp/Kdenlive.AppImage $kdenlive
new_version=$(/tmp/Kdenlive.AppImage --version)
if [ "$new_version" == "$current_version" ]; then
  echo "Kdenlive already up-to-date; cleaning up"
  rm -f /tmp/Kdenlive.AppImage
else
  cd /tmp
  imgmerge sideload Kdenlive
  rm -f /tmp/Kdenlive.AppImage
  rm -f /org.kde.kdenlive.desktop
fi

#Update LibreOffice AppImage
current_version=$(/Applications/LibreOffice.AppImage --version)
wget -O /tmp/LibreOffice.AppImage https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-fresh.full-x86_64.AppImage
new_version=$(/tmp/LibreOffice.AppImage --version)
if [ "$new_version" == "$current_version" ]; then
  echo "LibreOffice already up-to-date; cleaning up"
  rm -f /tmp/LibreOffice.AppImage
else
  cd /tmp
  imgmerge sideload LibreOffice
  rm -f /tmp/LibreOffice.AppImage
fi

#Packages installed with imgmerge
imgmerge sync
imgmerge install $(ls /Applications | cut -d '.' -f1 | grep -v "Kdenlive" | grep -v "LibreOffice")

#Portage
emerge --sync
layman -S
emerge -uDNU --with-bdeps=y @world
eselect kernel set $(eselect kernel list | sort -Vr | cut -d\] -f1 | cut -d\[ -f2 | head -n1)
zcat /proc/config.gz > /tmp/config
genkernel --kernel-config=/tmp/config all
rm -f /tmp/config
