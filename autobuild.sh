#!/bin/bash
if [ "$EUID" = 0 ]; then
  echo "Please don't run this script as root!"
  exit
fi
basedistroversion="$(date +%Y.%m.%d)"
distroversion=""
distrocodename=""
echo "Welcome to the generation script for Triggerbox"
echo "==========="
if [ "$1" != "" ]; then
  distroversion="$1"
  distrocodename="$2"
else
  distroversion="${basedistroversion:2:5}"
  distrocodename="monthly-stable-$(uname -m)"
fi

cleanup_failure() {
  if [ -d workingdir ]; then
    sudo rm -rf {workingdir,customrepo}
  elif [ -d customrepo ]; then
    sudo rm -rf {workingdir,customrepo}
  fi
}

createdir() {
  yes | sudo pacman -Scc #prevent AUR package signature errors
  sudo mkdir workingdir
  sudo cp -r config/* workingdir
  sudo mkdir -p workingdir/airootfs/usr/share/plymouth/themes/
  sudo mkdir -p workingdir/airootfs/usr/share/applications
}
copypackages() {
  sudo cp -f ./packages ./workingdir/packages.x86_64
}
copyskel() {
  sudo mkdir -p ./workingdir/airootfs/etc/fonts
  if [ ! -d skeldata/Desktop ]; then
    mkdir -p skeldata/{Desktop,Documents,Downloads,Pictures,Videos}
  fi
  sudo cp -r skeldata ./workingdir/airootfs/etc/skel
  sudo bash -c 'echo -e "PROMPT=\"%n@%m:%~%# \"" >> ./workingdir/airootfs/etc/skel/.zshrc'
  sudo cp fonts.conf workingdir/airootfs/etc/skel/.config/fontconfig
  sudo cp fonts.conf workingdir/airootfs/etc/fonts/local.conf
  sudo ln -s /usr/lib/systemd/system/sddm-plymouth.service ./workingdir/airootfs/etc/systemd/system/display-manager.service
  sudo cp -f ./customize_airootfs.sh ./workingdir/airootfs/root/customize_airootfs.sh
  sudo cp -r triggerbox-breeze ./workingdir/airootfs/usr/share/plymouth/themes/
  if [ ! -d workingdir/airootfs/usr/lib/systemd/system ]; then
    sudo mkdir -p workingdir/airootfs/usr/lib/systemd/system
  fi
  sudo cp autoupdate.{service,timer} ./workingdir/airootfs/lib/systemd/system/
  sudo mkdir ./workingdir/airootfs/usr/bin
  sudo cp {minds,gab,parler} ./workingdir/airootfs/usr/bin
  sudo cp {minds,gab,parler}.desktop ./workingdir/airootfs/usr/share/applications
}
createlsbrelease() {
  echo "lsb-release" | sudo tee --append ./workingdir/packages.x86_64 > /dev/null
  echo "DISTRIB_ID=Triggerbox" | sudo tee ./workingdir/airootfs/etc/lsb-release > /dev/null
  echo 'DISTRIB_DESCRIPTION="Break the grip of censorship"' | sudo tee --append ./workingdir/airootfs/etc/lsb-release > /dev/null
  echo "DISTRIB_RELEASE=$distroversion" | sudo tee --append ./workingdir/airootfs/etc/lsb-release > /dev/null
  echo "DISTRIB_CODENAME=$distrocodename" | sudo tee --append ./workingdir/airootfs/etc/lsb-release > /dev/null
}
compilecalamares() {
  echo "Preparing Repository..."
  mkdir customrepo
  mkdir customrepo/x86_64
  #check if already installed before attempting to sideload Manjaro-specific calamares dependency
  pacman -Qi kpmcore3 > /dev/null
  if [ $? -eq 1 ]; then
    #Calamares dependency found in Manjaro repos only
    wget -O customrepo/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz https://mirrors.ocf.berkeley.edu/manjaro/stable/community/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz
    sudo pacman --noconfirm -U customrepo/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz
  fi
  mkdir customrepo/i686
  mkdir customrepo/triggerbox-calamares
  echo "Preparing Calamares-build..."
  
  wget -O customrepo/triggerbox-calamares/PKGBUILD http://archmaker.guidedlinux.org/PKGBUILD
  
  #Fix out-of-date calamares dependencies
  sed -i "s/depends.*/depends=('kconfig' 'kcoreaddons' 'kiconthemes' 'ki18n' 'kio' 'solid' 'yaml-cpp' 'kpmcore3' 'mkinitcpio-openswap' 'boost-libs' 'ckbcomp' 'hwinfo' 'qt5-svg' 'polkit-qt5' 'gtk-update-icon-cache' 'pythonqt>=3.2' 'plasma-framework' 'qt5-xmlpatterns' 'kparts' 'qt5-webengine')/" customrepo/triggerbox-calamares/PKGBUILD
  sed -i "s/makedepends.*/makedepends=('extra-cmake-modules' 'qt5-tools' 'qt5-translations' 'git' 'boost')/" customrepo/triggerbox-calamares/PKGBUILD

  echo "    echo '    ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '    BackButton {' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        width: 50' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        height: 50' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        source: \"back.png\"' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '    }' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '    ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '    ForwardButton {' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        width: 50' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        height: 50' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        source: \"forward.png\"' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '    }' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '    ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  FILES="calamaresslides/*"
  sed -i "27a \ \ \ \ cp $(pwd)/{forward,back}.png src/branding/custombranding/" ./customrepo/triggerbox-calamares/PKGBUILD
  currentslide=1
  for f in $FILES
  do
  currentline=$(( $currentslide + 28 ))
  sed -i "${currentline}a\ \ \ \ cp $(pwd)\/$f src\/branding\/custombranding\/" ./customrepo/triggerbox-calamares/PKGBUILD
  echo "    echo '    Slide {' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        Image {' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '            id: background${currentslide}' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '            source: \"${f##*/}\"' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '            width: 800; height: 440' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '            fillMode: Image.PreserveAspectFit' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '            anchors.centerIn: parent' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '        }' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '    }' >> src/branding/custombranding/show.qml" >> slideshowchanges
  currentslide=$(( $currentslide + 1 ))
  done
  sed -i "s/DISTRNAME/Triggerbox/" ./customrepo/triggerbox-calamares/PKGBUILD
  sed -i "s/DISTRVERSION/${distroversion}/" ./customrepo/triggerbox-calamares/PKGBUILD
  sed -i "s/archmaker-calamares/triggerbox-calamares/" ./customrepo/triggerbox-calamares/PKGBUILD
  echo "    echo '    ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "    echo '}' >> src/branding/custombranding/show.qml" >> slideshowchanges
  lastline=$(( $currentslide + 27 ))
  sed -i '/mkdir -p build/r slideshowchanges' ./customrepo/triggerbox-calamares/PKGBUILD
  rm slideshowchanges
  cd ./customrepo/triggerbox-calamares
  makepkg --printsrcinfo > .SRCINFO
  cd ../
  echo "Building qt5-styleplugins-git..."
  git clone https://aur.archlinux.org/qt5-styleplugins-git
  cd qt5-styleplugins-git
  yes | makepkg -si
  cp *.pkg.tar.* ../x86_64
  cd ../
  echo "Building calamares..."
  cd triggerbox-calamares
  yes | makepkg -s || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ../
  rm -rf qt5-styleplugins-git triggerbox-calamares
  cd ../
  echo "triggerbox-calamares" | sudo tee -a ./workingdir/packages.x86_64 > /dev/null
}

#Unfortunately there are dependencies of calamares in the AUR or I wouldn't have to run this
compileaurpkgs() {
  yes | sudo pacman -Scc #prevent package signature errors, part 2
  mkdir customrepo/custompkgs
  #must download Manjaro-specific package again in order for it to be used inside build chroot
  wget -O customrepo/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz https://mirrors.ocf.berkeley.edu/manjaro/stable/community/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz
  repopath="$(readlink -f .)"
  buildingpath="$(readlink -f ./customrepo/custompkgs)"
  while IFS='' read -r currentpkg || [[ -n "$currentpkg" ]]; do
    cd customrepo/custompkgs
    if [ ! -z $currentpkg ]; then
      wget -O currentpkg.tar.gz $currentpkg
    fi
    tar xf currentpkg.tar.gz
    rm currentpkg.tar.gz
    for d in * ; do
      cd "$d"
    done
    if [ ! -z $currentpkg ]; then
      yes | makepkg -s || exit 1
    fi
    cp *.pkg.tar.* ../../x86_64
    cd $buildingpath
    for d in */ ; do
      rm -rf "$d"
    done
    cd $repopath
  done < "aurpackages"
  rm -rf customrepo/custompkgs
  unset repopath buildingpath
}

setuprepo() {
  cd customrepo/x86_64
  echo "Adding packages to repository..."
  repo-add customrepo.db.tar.gz *.pkg.tar.*
  cd ../..
  echo "[customrepo]" | sudo tee --append ./workingdir/pacman.conf > /dev/null
  echo "SigLevel = Never" | sudo tee --append ./workingdir/pacman.conf > /dev/null
  echo "Server = file://$(pwd)/customrepo/$(echo '$arch')" | sudo tee --append ./workingdir/pacman.conf > /dev/null
  sudo pacman --noconfirm -Syyuu || exit 1
  cat /etc/pacman.conf > ./pacman.backup
  echo "[customrepo]" | sudo tee --append /etc/pacman.conf > /dev/null
  echo "SigLevel = Never" | sudo tee --append /etc/pacman.conf > /dev/null
  echo "Server = file://$(pwd)/customrepo/$(echo '$arch')" | sudo tee --append /etc/pacman.conf > /dev/null
  sudo pacman --noconfirm -Syyuu || exit 1
}
buildtheiso() {
  sudo rm -rf ./workingdir/airootfs/etc/systemd/system/getty*
  cd workingdir
  sudo ./build.sh -v || exit 1
  cd ../
}
cleanup() {
  echo "Cleaning up..."
  cat ./pacman.backup | sudo tee /etc/pacman.conf > /dev/null
  sudo pacman --noconfirm -Syyuu
  rm ./pacman.backup
  sudo rm -rf /var/cache/pacman/pkg/triggerbox-calamares*
  sudo rm -rf /var/cache/pacman/pkg/qt5-styleplugins-git*
  finalfiles=""
  while IFS='' read -r currentpkg || [[ -n "$currentpkg" ]]; do
    finalfiles="$finalfiles /var/cache/pacman/pkg/$(cut -d'.' -f1 <<<"${currentpkg##*/}")*"
  done < "aurpackages"
  echo "Deleting files $finalfiles..."
  sudo rm -rf $finalfiles
  rm -rf ./customrepo
  echo "Saving iso file..."
  cp ./workingdir/out/*.iso ./triggerbox-$distroversion-$(uname -m).iso
  echo "Removing archiso directory..."
  sudo rm -rf workingdir
}
cleanup_failure
createdir
copypackages
copyskel
createlsbrelease
compilecalamares
compileaurpkgs
setuprepo
buildtheiso
cleanup
