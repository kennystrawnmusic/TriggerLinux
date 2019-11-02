#!/usr/bin/sudo /bin/bash

#Clear terminal window before proceeding
clear

#Need to set extglob because vars depend on it
shopt -s extglob

#Test to see if eix is installed
eix-installed -a >/dev/null; if [ $? -ne 0 ]; then
  echo "Need to install eix to proceed"
  emerge --ask app-portage/eix || exit 1
  isinstalled1="$(eix-installed -a | grep catalyst)"
  isinstalled2="$(eix-installed -a | grep layman)"
else
  #Go straight to defining
  isinstalled1="$(eix-installed -a | grep catalyst)"
  isinstalled2="$(eix-installed -a | grep layman)"
fi

scriptdir=$PWD
tarballdir=/var/tmp/catalyst/builds/default
configfile=/etc/catalyst/catalystrc
fsscript=$scriptdir/customize.sh

stage1spec=$scriptdir/livecd-stage1.spec
stage2spec=$scriptdir/livecd-stage2.spec
kconffile=$scriptdir/livecd-stage2.config
portageconf=$scriptdir/portage

cdtar=$scriptdir/livecd-stage2-cdtar.tar.bz2
url=https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/$(wget -qO - https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/ | grep -Eo "stage3-amd64-systemd-[0-9]{1,}.tar.bz2" | head -n1)
cpucores=$(nproc --all)

tmpbuilddir=/var/tmp/catalyst/tmp/default
livestage1tarball=$tarballdir/livecd-stage1-amd64-installer-latest.tar.bz2
stage1chroot=$tmpbuilddir/livecd-stage1-amd64-installer-latest
stage2chroot=$tmpbuilddir/livecd-stage2-amd64-latest

support=/usr/share/catalyst/targets/support
python_targets=/usr/lib64/python3.6/site-packages/catalyst/targets
catalystrc_ischanged="$(cat /etc/catalyst/catalystrc | grep NINJAFLAGS)"
repo_dir=/var/db/repos/gentoo

sysrepoconfstat="$(stat -c%s /etc/portage/repos.conf/gentoo.conf)"
localrepoconfstat="$(stat -c%s $portageconf/repos.conf/gentoo.conf)"

echo "Welcome to the TriggerLinux Gentoo Edition Catalyst build automator!"

if [ -z $isinstalled1 ]; then
  echo "Installing all required packages"
  emerge --ask dev-util/catalyst app-portage/layman || exit 1
elif [ -z $isinstalled2 ]; then
  echo "Installing overlay manager"
  emerge --ask app-portage/layman || exit 1
fi

echo "Adding necessary overlays"
if [ ! -d /var/lib/layman/triggerlinux-overlay ]; then
  layman -L
  yes | layman -o https://raw.githubusercontent.com/realKennyStrawn93/triggerlinux-overlay/master/triggerlinux-overlay.xml -f -a triggerlinux-overlay
  yes | layman -a brave-overlay
elif [ ! -d /var/lib/layman/snapd ]; then
  layman -L
  yes | layman -a brave-overlay
else
  echo "Overlays already added, skipping"
fi

echo "Downloading necessary stage tarball..."
if [ ! -d $tarballdir ]; then
  mkdir -p $tarballdir
  wget -O $livestage1tarball $url
elif [ ! -f $livestage1tarball ]; then
  wget -O $livestage1tarball $url
else
  echo "Tarball already exists, skipping download"
fi

if [ -z "$catalystrc_ischanged" ]; then
  cat $scriptdir/catalystrc > /etc/catalyst/catalystrc
else
  echo "Skipping catalystrc as it already has the necessary changes"
fi

echo "Generating snapshot"
if [ $sysrepoconfstat -eq $localrepoconfstat ]; then
  emerge --sync && catalyst -s latest || exit 1
else
  cat portage/repos.conf/gentoo.conf > /etc/portage/repos.conf/gentoo.conf && \
  rm -rf $repo_dir && \
  emerge --sync && \
  catalyst -s latest || exit 1
fi

echo "Making necessary specfile changes..."
sed -i "s/portage_confdir.*/portage_confdir: ${portageconf//\//\\/}/g" $stage1spec
sed -i "s/portage_confdir.*/portage_confdir: ${portageconf//\//\\/}/g" $stage2spec
sed -i "s/livecd\/fsscript.*/livecd\/fsscript: ${fsscript//\//\\/}/g" $stage2spec
sed -i "s/livecd\/cdtar.*/livecd\/cdtar: ${cdtar//\//\\/}/g" $stage2spec
sed -i "s/boot\/kernel\/gentoo\/config.*/boot\/kernel\/gentoo\/config: ${kconffile//\//\\/}/g" $stage2spec

echo "Removing hard dependency on openrc/sysvinit from Catalyst Python code..."
sed -i "/app-misc\/livecd-tools/d" $python_targets/livecd_stage1.py

echo "Changing genkernel dependency to genkernel-next"
sed -i "s/genkernel.*/genkernel-next/g" $support/pre-kmerge.sh

echo "Ensuring that the squashed system is itself bootable (no calamares if it isn't)"
sed -i "s/mv/cp/g" $support/bootloader-setup.sh

echo "Ensuring that Plymouth is recognized as a splash option on the live media"
sed -i 's/default_append_line.*/default_append_line="root=\/dev\/ram0 init=\/linuxrc log_buf_len=4M ${cmdline_opts} ${custom_kopts} cdroot quiet splash"/'

build() {
  echo "Building..." && \
  catalyst -f $stage1spec && \
  sed -i "s/.MAKEOPTS=.*/MAKEOPTS=\"-j$cpucores\"/" $stage1chroot/etc/genkernel.conf && \
  sed -i "s/.*PLYMOUTH=.*/PLYMOUTH=\"yes\"/" $stage1chroot/etc/genkernel.conf && \
  sed -i "s/.*PLYMOUTH_THEME=.*/PLYMOUTH_THEME=\"bgrt\"/" $stage1chroot/etc/genkernel.conf && \
  cp -r $scriptdir/calamares-config $stage1chroot/etc/calamares && \
  cp $scriptdir/autoupdate\.{service,timer} $stage1chroot/lib/systemd/system && \
  cp $scriptdir/unmerge-calamares.service $stage1chroot/lib/systemd/system && \
  cp $scriptdir/cleanup.service $stage1chroot/lib/systemd/system && \
  cp $scriptdir/appimagehub.desktop $stage1chroot/usr/share/applications && \
  cat $scriptdir/org.gnome.settings-daemon.plugins.power.gschema.override > $stage1chroot/usr/share/glib-2.0/schemas/org.gnome.settings-daemon.plugins.power.gschema.override && \
  install -m 755 $scriptdir/autoupdate.sh $stage1chroot/usr/bin/autoupdate.sh && \
  install -m 755 $scriptdir/cleanup.sh $stage1chroot/usr/bin/cleanup.sh && \
  install -m 755 $scriptdir/appimagehub $stage1chroot/usr/bin/appimagehub && \
  install -m 755 $scriptdir/imgmerge $stage1chroot/usr/bin/imgmerge && \
  mkdir -p $stage1chroot/etc/pip && \
  cp $scriptdir/*.whl $stage1chroot/etc/pip && \
  catalyst -f $stage2spec
}

if [ -d $stage2chroot ]; then
  echo "Purging Stage 2 caches"
  catalyst -Pf $stage2spec && \
  echo "Purging Stage 1 caches" && \
  catalyst -Pf $stage1spec && \
  build; if [ $? -ne 0 ]; then
    echo "Fixing package.keywords and trying again"
    install -m 755 fix-keywords.sh $stage1chroot/tmp/fix-keywords.sh
    chroot $stage1chroot /tmp/fix-keywords.sh
    build; if [ $? -ne 0 ]; then
      echo "Entering chroot to allow for manual recovery"
      chroot $stage1chroot
      echo "Trying again"
      build
    fi
  fi
elif [ -d $stage1chroot ]; then
  echo "Purging Stage 1 caches"
  catalyst -Pf $stage1spec && \
  build; if [ $? -ne 0 ]; then
    echo "Fixing package.keywords and trying again"
    install -m 755 fix-keywords.sh $stage1chroot/tmp/fix-keywords.sh
    chroot $stage1chroot /tmp/fix-keywords.sh
    build; if [ $? -ne 0 ]; then
      echo "Entering chroot to allow for manual recovery"
      chroot $stage1chroot
      echo "Trying again"
      build
    fi
  fi
else
  build; if [ $? -ne 0 ]; then
    echo "Fixing package.keywords and trying again"
    install -m 755 fix-keywords.sh $stage1chroot/tmp/fix-keywords.sh
    chroot $stage1chroot /tmp/fix-keywords.sh
    build; if [ $? -ne 0 ]; then
      echo "Entering chroot to allow for manual recovery"
      chroot $stage1chroot
      echo "Trying again"
      build
    fi
  fi
fi
