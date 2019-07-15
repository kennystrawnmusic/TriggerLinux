#!/bin/bash

cleanup() {
  if [ -d customrepo ]; then
    sudo rm -rf customrepo
  fi
}

compilecalamares() {
  echo "Preparing Repository..."
  if [ ! -d customrepo ]; then
    git clone https://github.com/realKennyStrawn93/triggerlinux-overlay customrepo
    #Must start from scratch
    rm -rf customrepo/{LICENSE,README.md,triggerlinux-overlay.db.*,x86_64}
  else
    rm -rf customrepo
    git clone https://github.com/realKennyStrawn93/triggerlinux-overlay customrepo
    #Must start from scratch
    rm -rf customrepo/{LICENSE,README.md,triggerlinux-overlay.db.*,x86_64}
  fi
  mkdir customrepo/claymore-miner
  cp claymore-PKGBUILD customrepo/claymore-miner/PKGBUILD
  mkdir customrepo/x86_64
  #check if already installed before attempting to sideload Manjaro-specific calamares dependency
  wget -O customrepo/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz https://mirrors.ocf.berkeley.edu/manjaro/stable/community/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz
  pacman -Qi kpmcore3 > /dev/null
  if [ $? -eq 1 ]; then
    #Calamares dependency found in Manjaro repos only
    sudo pacman --noconfirm -U customrepo/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz
  fi
  mkdir customrepo/i686
  mkdir customrepo/triggerlinux-calamares
  echo "Preparing Calamares-build..."
  
  wget -O customrepo/triggerlinux-calamares/PKGBUILD http://archmaker.guidedlinux.org/PKGBUILD
  
  #Fix out-of-date calamares dependencies
  sed -i "s/depends.*/depends=('kconfig' 'kcoreaddons' 'kiconthemes' 'ki18n' 'kio' 'solid' 'yaml-cpp' 'kpmcore3' 'mkinitcpio-openswap' 'boost-libs' 'ckbcomp' 'hwinfo' 'qt5-svg' 'polkit-qt5' 'gtk-update-icon-cache' 'pythonqt>=3.2' 'plasma-framework' 'qt5-xmlpatterns' 'kparts' 'qt5-webengine' 'rsync' 'f2fs-tools')/" customrepo/triggerlinux-calamares/PKGBUILD
  sed -i "s/makedepends.*/makedepends=('extra-cmake-modules' 'qt5-tools' 'qt5-translations' 'git' 'boost')/" customrepo/triggerlinux-calamares/PKGBUILD

  echo "  echo '  ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '  BackButton {' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '    width: 50' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '    height: 50' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '    source: \"back.png\"' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '  }' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '  ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '  ForwardButton {' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '   width: 50' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '   height: 50' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '    source: \"forward.png\"' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '  }' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '  ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  FILES="calamaresslides/*"
  sed -i "27a \ \ \ \ cp $(pwd)/{forward,back}.png src/branding/custombranding/" ./customrepo/triggerlinux-calamares/PKGBUILD
  currentslide=1
  for f in $FILES
  do
    currentline=$(( $currentslide + 28 ))
    sed -i "${currentline}a\ \ \ \ cp $(pwd)\/$f src\/branding\/custombranding\/" ./customrepo/triggerlinux-calamares/PKGBUILD
    echo "  echo '  Slide {' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '    ' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '    Image {' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '     id: background${currentslide}' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '      source: \"${f##*/}\"' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '      width: 800; height: 440' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '      fillMode: Image.PreserveAspectFit' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '      anchors.centerIn: parent' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '    }' >> src/branding/custombranding/show.qml" >> slideshowchanges
    echo "  echo '  }' >> src/branding/custombranding/show.qml" >> slideshowchanges
    currentslide=$(( $currentslide + 1 ))
  done
  sed -i "s/DISTRNAME/TriggerLinux/" ./customrepo/triggerlinux-calamares/PKGBUILD
  sed -i "s/DISTRVERSION/${distroversion}/" ./customrepo/triggerlinux-calamares/PKGBUILD
  sed -i "s/archmaker-calamares/triggerlinux-calamares/" ./customrepo/triggerlinux-calamares/PKGBUILD
  echo "  echo '  ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '}' >> src/branding/custombranding/show.qml" >> slideshowchanges
  lastline=$(( $currentslide + 27 ))
  sed -i '/mkdir -p build/r slideshowchanges' ./customrepo/triggerlinux-calamares/PKGBUILD
  rm slideshowchanges
  cd ./customrepo/triggerlinux-calamares
  makepkg --printsrcinfo > .SRCINFO
  cd ../
  echo "Building qt5-styleplugins-git..."
  git clone https://aur.archlinux.org/qt5-styleplugins-git
  cd qt5-styleplugins-git
  yes | makepkg -si || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ../
  echo "Building pythonqt..."
  git clone https://aur.archlinux.org/pythonqt.git
  cd pythonqt
  yes | makepkg -si || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ../
  echo "Building claymore-miner"
  cd claymore-miner
  yes | makepkg -s --skipinteg || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ../
  echo "Building calamares..."
  cd triggerlinux-calamares
  yes | makepkg -s || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ../
  rm -rf {qt5-styleplugins-git,pythonqt,claymore-miner,triggerlinux-calamares}
  cd ../
  echo "triggerlinux-calamares" | sudo tee -a ./workingdir/packages.x86_64 > /dev/null
}
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
  cd customrepo
  git clone https://github.com/realKennyStrawn93/triggerlinux-gab
  cd triggerlinux-gab
  yes | makepkg -s --skipinteg || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ..
  git clone https://github.com/realKennyStrawn93/triggerlinux-minds
  cd triggerlinux-minds
  yes | makepkg -s --skipinteg || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ..
  git clone https://github.com/realKennyStrawn93/triggerlinux-parler
  cd triggerlinux-parler
  yes | makepkg -s --skipinteg || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ..
  git clone https://github.com/realKennyStrawn93/triggerlinux-touch-detect-kwin
  cd triggerlinux-touch-detect-kwin
  yes | makepkg -si || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ..
  git clone https://github.com/realKennyStrawn93/triggerlinux-touch-disable-appmenu
  cd triggerlinux-touch-disable-appmenu
  yes | makepkg -si || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ..
  git clone https://github.com/realKennyStrawn93/triggerlinux-touch-maximize-all
  cd triggerlinux-touch-maximize-all
  yes | makepkg -si || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ../x86_64
  #Download a third time. Keeps disappearing from the finished repository.
  wget -O kpmcore3-3.3.0-1-x86_64.pkg.tar.xz https://mirrors.ocf.berkeley.edu/manjaro/stable/community/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz
  echo "Adding packages to repository..."
  repo-add triggerlinux-overlay.db.tar.gz *.pkg.tar.*
  # Avoid creating symlinks; throws Git off
  unlink triggerlinux-overlay.db
  unlink triggerlinux-overlay.files
  cat triggerlinux-overlay.db.tar.gz > triggerlinux-overlay.db
  cat triggerlinux-overlay.files.tar.gz > triggerlinux-overlay.files
  cd ..
  git add .
  git commit -m "Add new packages"
  git push origin master
  cat /etc/pacman.conf > ./pacman.backup
  sudo pacman --noconfirm -Syyuu || exit 1
}

setupaurhelper() {
  #Check if yay is installed before proceeding
  pacman -Qi yay > /dev/null
  if [ $? -eq 1 ]; then
    pacman -S yay
  fi
  #Must ensure that all helpered AUR packages have local copies before proceeding
  yes | yay -Syu --devel yay-git plymouth-git snapd-glib-git snapd-git discover-snap ocs-url opencl-amd grub-git jade-application-kit-git pyside2 brave-bin ms-office-online
  cp ~/.cache/yay/*/*.pkg.tar.* x86_64
  cd x86_64
  repo-add -n triggerlinux-overlay.db.tar.gz *.pkg.tar.*
  unlink triggerlinux-overlay.db
  unlink triggerlinux-overlay.files
  cat triggerlinux-overlay.db.tar.gz > triggerlinux-overlay.db
  cat triggerlinux-overlay.files.tar.gz > triggerlinux-overlay.files
  cd ..
  git add .
  git commit -m "Add AUR Helper packages"
  git push origin master
}
cleanup
compilecalamares
compileaurpkgs
setuprepo
setupaurhelper
