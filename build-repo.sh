#!/bin/bash

cleanup() {
  if [ -d customrepo ]; then
    sudo sed -i /etc/pacman.conf
    sudo sed -i /etc/pacman.conf
    sudo sed -i /etc/pacman.conf
    sudo rm -rf customrepo
  fi
}

compilecalamares() {
  echo "Preparing Repository..."
  if [ ! -d customrepo ]; then
    git clone https://github.com/realKennyStrawn93/triggerbox-overlay customrepo
    #Must start from scratch
    rm -rf customrepo/{LICENSE,README.md,triggerbox-overlay.db.*,x86_64}
  else
    rm -rf customrepo
    git clone https://github.com/realKennyStrawn93/triggerbox-overlay customrepo
    #Must start from scratch
    rm -rf customrepo/{LICENSE,README.md,triggerbox-overlay.db.*,x86_64}
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
  mkdir customrepo/triggerbox-calamares
  echo "Preparing Calamares-build..."
  
  wget -O customrepo/triggerbox-calamares/PKGBUILD http://archmaker.guidedlinux.org/PKGBUILD
  
  #Fix out-of-date calamares dependencies
  sed -i "s/depends.*/depends=('kconfig' 'kcoreaddons' 'kiconthemes' 'ki18n' 'kio' 'solid' 'yaml-cpp' 'kpmcore3' 'mkinitcpio-openswap' 'boost-libs' 'ckbcomp' 'hwinfo' 'qt5-svg' 'polkit-qt5' 'gtk-update-icon-cache' 'pythonqt>=3.2' 'plasma-framework' 'qt5-xmlpatterns' 'kparts' 'qt5-webengine' 'rsync' 'f2fs-tools')/" customrepo/triggerbox-calamares/PKGBUILD
  sed -i "s/makedepends.*/makedepends=('extra-cmake-modules' 'qt5-tools' 'qt5-translations' 'git' 'boost')/" customrepo/triggerbox-calamares/PKGBUILD

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
  sed -i "27a \ \ \ \ cp $(pwd)/{forward,back}.png src/branding/custombranding/" ./customrepo/triggerbox-calamares/PKGBUILD
  currentslide=1
  for f in $FILES
  do
    currentline=$(( $currentslide + 28 ))
    sed -i "${currentline}a\ \ \ \ cp $(pwd)\/$f src\/branding\/custombranding\/" ./customrepo/triggerbox-calamares/PKGBUILD
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
  sed -i "s/DISTRNAME/Triggerbox/" ./customrepo/triggerbox-calamares/PKGBUILD
  sed -i "s/DISTRVERSION/${distroversion}/" ./customrepo/triggerbox-calamares/PKGBUILD
  sed -i "s/archmaker-calamares/triggerbox-calamares/" ./customrepo/triggerbox-calamares/PKGBUILD
  echo "  echo '  ' >> src/branding/custombranding/show.qml" >> slideshowchanges
  echo "  echo '}' >> src/branding/custombranding/show.qml" >> slideshowchanges
  lastline=$(( $currentslide + 27 ))
  sed -i '/mkdir -p build/r slideshowchanges' ./customrepo/triggerbox-calamares/PKGBUILD
  rm slideshowchanges
  cd ./customrepo/triggerbox-calamares
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
  cd triggerbox-calamares
  yes | makepkg -s || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ../
  rm -rf {qt5-styleplugins-git,pythonqt,claymore-miner,triggerbox-calamares}
  cd ../
  echo "triggerbox-calamares" | sudo tee -a ./workingdir/packages.x86_64 > /dev/null
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
  git clone https://github.com/realKennyStrawn93/triggerbox-gab
  cd triggerbox-gab
  yes | makepkg -s --skipinteg || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ..
  git clone https://github.com/realKennyStrawn93/triggerbox-minds
  cd triggerbox-minds
  yes | makepkg -s --skipinteg || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ..
  git clone https://github.com/realKennyStrawn93/triggerbox-parler
  cd triggerbox-parler
  yes | makepkg -s --skipinteg || exit 1
  cp *.pkg.tar.* ../x86_64
  cd ..
  cd x86_64
  #Download a third time. Keeps disappearing from the finished repository.
  wget -O kpmcore3-3.3.0-1-x86_64.pkg.tar.xz https://mirrors.ocf.berkeley.edu/manjaro/stable/community/x86_64/kpmcore3-3.3.0-1-x86_64.pkg.tar.xz
  echo "Adding packages to repository..."
  repo-add triggerbox-overlay.db.tar.gz *.pkg.tar.*
  # Avoid creating symlinks; throws Git off
  unlink triggerbox-overlay.db
  unlink triggerbox-overlay.files
  cat triggerbox-overlay.db.tar.gz > triggerbox-overlay.db
  cat triggerbox-overlay.files.tar.gz > triggerbox-overlay.files
  cd ..
  git add .
  git commit -m "Add new packages"
  git push origin master
  cat /etc/pacman.conf > ./pacman.backup
  echo "[triggerbox-overlay]" | sudo tee --append /etc/pacman.conf > /dev/null
  echo "SigLevel = Never" | sudo tee --append /etc/pacman.conf > /dev/null
  echo "Server = https://raw.github.com/realKennyStrawn93/triggerbox-overlay/master/$(echo '$arch')" | sudo tee --append /etc/pacman.conf > /dev/null
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
  cp ~/.cache/yay/*/*.pkg.tar.* customrepo/x86_64
  cd x86_64
  repo-add -n triggerbox-overlay.db.tar.gz *.pkg.tar.*
  unlink triggerbox-overlay.db
  unlink triggerbox-overlay.files
  cat triggerbox-overlay.db.tar.gz > triggerbox-overlay.db
  cat triggerbox-overlay.files.tar.gz > triggerbox-overlay.files
  cd ..
  git add .
  git commit -m "Add AUR Helper packages"
  git push origin master
}
compilecalamares
compileaurpkgs
setuprepo
setupaurhelper
