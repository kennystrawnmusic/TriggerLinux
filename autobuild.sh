#!/bin/bash
if [ "$EUID" = 0 ]; then
  echo "Please don't run this script as root!"
  exit
fi
distroversion=""
distrocodename=""
echo "Welcome to the generation script for Triggerbox"
echo "==========="
if [ "$1" != "" ]; then
  distroversion="$1"
  distrocodename="$2"
else
  echo -n "Please enter the current version of Triggerbox > "
  read distroversion
  echo -n "Please enter the current codename of Triggerbox > "
  read distrocodename
fi
createdir() {
  sudo mkdir workingdir
  sudo cp -r config/* workingdir
  sudo mkdir -p workingdir/airootfs/usr/share/plymouth/themes/
}
copypackages() {
  sudo cp -f ./packages ./workingdir/packages.x86_64
}
copyskel() {
  sudo mkdir -p ./workingdir/airootfs/etc/fonts
  sudo cp -r skeldata ./workingdir/airootfs/etc/skel
  sudo bash -c 'echo -e "PROMPT=\"%n@%m:%~%# \"" >> ./workingdir/airootfs/etc/skel/.zshrc'
  sudo cp fonts.conf workingdir/airootfs/etc/skel/.config/fontconfig
  sudo cp fonts.conf workingdir/airootfs/etc/fonts/local.conf
  sudo ln -s /usr/lib/systemd/system/sddm-plymouth.service ./workingdir/airootfs/etc/systemd/system/display-manager.service
  sudo cp -f ./customize_airootfs.sh ./workingdir/airootfs/root/customize_airootfs.sh
  sudo cp -r triggerbox-breeze ./workingdir/airootfs/usr/share/plymouth/themes/
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
  mkdir customrepo/i686
  mkdir customrepo/triggerbox-calamares
  echo "Preparing Calamares-build..."
  curl http://archmaker.guidedlinux.org/PKGBUILD > customrepo/triggerbox-calamares/PKGBUILD
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
  makepkg -s
  cp *.pkg.tar.* ../x86_64
  cd ../
  echo "Building calamares..."
  cd triggerbox-calamares
  makepkg -s
  cp *.pkg.tar.* ../x86_64
  cd ../
  rm -rf qt5-styleplugins-git triggerbox-calamares
  cd ../
  echo "triggerbox-calamares" | sudo tee -a ./workingdir/packages.x86_64 > /dev/null
}

#Unfortunately there are dependencies of calamares in the AUR or I wouldn't have to run this
compileaurpkgs() {
  mkdir customrepo/custompkgs
  repopath="$(readlink -f .)"
  buildingpath="$(readlink -f ./customrepo/custompkgs)"
  while IFS='' read -r currentpkg || [[ -n "$currentpkg" ]]; do
    cd customrepo/custompkgs
    curl $currentpkg > ./currentpkg.tar.gz
    tar xf currentpkg.tar.gz
    rm currentpkg.tar.gz
    for d in * ; do
      cd "$d"
    done
    makepkg -si
    cp *.pkg.tar.* ../../x86_64
    #work around dependency problems
    repo-add customrepo.db.tar.gz *.pkg.tar.*
    echo "[customrepo]" | sudo tee --append ./workingdir/pacman.conf > /dev/null
    echo "SigLevel = Never" | sudo tee --append ./workingdir/pacman.conf > /dev/null
    echo "Server = file://$(pwd)/customrepo/$(echo '$arch')" | sudo tee --append ./workingdir/pacman.conf > /dev/null
    sudo pacman -Syyuu
    cat /etc/pacman.conf > ./pacman.backup
    echo "[customrepo]" | sudo tee --append /etc/pacman.conf > /dev/null
    echo "SigLevel = Never" | sudo tee --append /etc/pacman.conf > /dev/null
    echo "Server = file://$(pwd)/customrepo/$(echo '$arch')" | sudo tee --append /etc/pacman.conf > /dev/null
    sudo pacman -Syyuu
    cd $buildingpath
    for d in */ ; do
      rm -rf "$d"
    done
    cd $repopath
  done < "aurpackages"
  rm -rf customrepo/custompkgs
  unset repopath buildingpath
}
buildtheiso() {
  sudo rm -rf ./workingdir/airootfs/etc/systemd/system/getty*
  cd workingdir
  sudo ./build.sh -v
  cd ../
}
cleanup() {
  echo "Cleaning up..."
  cat ./pacman.backup | sudo tee /etc/pacman.conf > /dev/null
  sudo pacman -Syyuu
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
  cp ./workingdir/out/*.iso ./output.iso
  echo "Removing archiso directory..."
  sudo rm -rf workingdir
}
createdir
copypackages
copyskel
createlsbrelease
compilecalamares
compileaurpkgs
#setuprepo
buildtheiso
cleanup
