# Break the grip of censorship
TriggerLinux is an [Gentoo](https://www.gentoo.org) Linux-based operating system designed with the attacks on conservatives coming from Silicon Valley in mind. We chose Gentoo as the base because the repositories are completely decentralized: there are many mirrors to choose the installation of packages from; as a result, if one mirror decides to censor, it's easy for you, the developer, to fork off of it and maintain your own copy of the mirror, with absolutely no problem whatsoever.

# Features

## Easy installation
TriggerLinux comes with the distribution-agnostic [Calamares](https://calamares.io) installer app. This makes installation far easier than the rather tedious work involved with the upstream Arch installation instructions, to say the least.

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

    tar -C build-chroot-xjvf stage3.amd64-systemd-xxxxxxxx.tar.gz
    sudo chroot build-chroot
    cd root
    git clone https://github.com/realKennyStrawn93/TriggerLinux
    cd TriggerLinux
    emerge --ask app-admin/sudo
    ./autocatalyst.sh
