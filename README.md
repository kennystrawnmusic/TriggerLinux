# Break the grip of censorship
TriggerLinux is a [Gentoo](https://www.gentoo.org) Linux-based operating system designed with the attacks on conservatives coming from Silicon Valley in mind. I chose Gentoo as the base because it's source-based: instead of packages, there's ebuilds, which are simply instructions on how to build packages from source. That makes for a highly decentralized build process, which is made even more decentralized through the use of Portage overlays.

# Features

## AppImage Ready
[AppImageUpdate](https://github.com/AppImage/AppImageUpdate), [appimaged](https://github.com/AppImage/appimaged), and the /Applications directory are all installed, enabled, and configured out of the box. This means that any sideloaded apps are updated automatically, no configuring necessary.

## Easy installation
TriggerLinux comes with the distribution-agnostic [Calamares](https://calamares.io) installer app. This makes installation far easier than the rather tedious work involved with the upstream Gentoo installation instructions, to say the least. Also, installation time is greatly reduced ― minutes instead of hours.

## Decentralization - see introduction

## Rolling release with silent updates
TriggerLinux makes use of a systemd timer to automatically run a system update command silently in the background every 20 minutes, ensuring the system is up to date before Discover has a chance to nag you. The result is that although the system will update frequently in the background, all you have to do is reboot if asked, which is very seldom.

Rolling release is also important because it means that you always get the newest version of both the apps and the system without the need to upgrade to a major new release. Features simply get installed each and every time you install updates to existing software; kind of like Windows 10, but even more frequently.

# Build Instructions (if you already have Gentoo installed)
The `autocatalyst.sh` script runs everything else for you. So assuming you already use Gentoo as your main system, simply:

    git clone https://github.com/realKennyStrawn93/TriggerLinux
    cd TriggerLinux
    ./autocatalyst.sh

If you don't use Gentoo, download a [Stage3 tarball](http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-systemd/) and chroot into it first:

    tar -C build-chroot -xjvf stage3.amd64-systemd-xxxxxxxx.tar.gz
    sudo chroot build-chroot
    cd root
    git clone https://github.com/realKennyStrawn93/TriggerLinux
    cd TriggerLinux
    emerge --ask app-admin/sudo
    ./autocatalyst.sh
