# Break the grip of censorship
Triggerbox is an [Arch Linux](https://www.archlinux.org)-based operating system designed with the attacks on conservatives coming from Silicon Valley in mind. We chose Arch Linux as the base because the repositories are completely decentralized: there are many mirrors to choose the installation of packages from; as a result, if one mirror decides to censor, it's easy for you, the developer, to fork off of it and maintain your own copy of the mirror, with absolutely no problem whatsoever.

# Features

## Easy installation
Triggerbox comes with the distribution-agnostic [Calamares](https://calamares.io) installer app. This makes installation far easier than the rather tedious work involved with the upstream Arch installation instructions, to say the least.

## Decentralization - see introduction

## Out-of-the-box (((Coincidence Detection)))
**Developer's Note:** No, this is not because I personally support the idea that any certain group of people deserves to be completely trolled out of existence; hell, I even wrote [a lengthy blog post on Minds](https://www.minds.com/blog/view/925216309127471104) offering an alternative explanation for the idea behind this. However, censorship of this kind of speech actually hinders the chances of allowing people to actually offer explanations like this, and it only proves the point behind the "echo" symbol all the more. If and when Google decides to un-ban this extension from the Chrome Web Store, then and only then will I unbundle the Firefox version of it, but not until then.

Although this extension is bundled, you're more than welcome to remove it; it's as easy as right-clicking the extension icon. It also only comes with the Firefox version and not any other, so installing another browser other than Firefox (explained below) will hide it. I also included a link to Gab in there, bundled and pinned to the task manager.

## Out-of-the-box Ethereum mining
Triggerbox comes with Claymore bundled, along with OpenCL support for both Nvidia and AMD GPUs. The only thing left to do is configure it by creating a mine.sh script and placing it in /usr/local/claymore; everything else is already done for you.

## Out-of-the-box documents, spreadsheets, and presentations
I was a bit disappointed when Ubuntu decided to unbundle [LibreOffice](https://www.libreoffice.org), since that's exactly what made it so appealing early on. Well, you're in luck: it's bundled with Triggerbox. So you can once again get straight to your office work after system installation without needing to install anything later.

## Out-of-the-box video production
YouTubers, take note: Triggerbox comes with [Kdenlive](https://kdenlive.org) out-of-the-box. So no more tedious post-install configuration in order to start producing YouTube content; everything you need to start in on making everything from short videos all the way to long documentaries is already there when the OS is installed.

If you do decide that burning DVDs is another way to reach people, powerful DVD authoring tool K3b is also preinstalled, making that a breeze as well.

## Easy installation of software
Triggerbox comes with out-of-the-box support for [Snap](http://snapcraft.io) apps, along with the Discover store which makes installation extremely easy. It also includes the "yay" [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) out-of-the-box, which allows you to install, among other things, browsers other than Firefox; for example, `yay -S google-chrome` will allow you to install the stable channel version of Chrome, whereas `yay -S google-chrome-dev` will allow you to install the version from the newer-but-less-stable dev channel. No more manual AUR dependency resolution!

## Perfectly scalable, easy-to-use interface
The custom [KDE](https://www.kde.org) Plasma 5 desktop is laid out the way it is for ease-of-transition reasons. Both major mobile operating systems currently on the market (Android and iOS) have the status icons and clock on the top-right of the screen. Except macOS and some other Linux distributions, however, the same is not true with the position of the clock and status icons in desktop operating systems. Windows places them all on the bottom right, and so does Chrome OS; this makes for a completely inconsistent user experience across devices. We thought, "We can do better."

Hence, the layout that we have. It borrows from the best of both the Windows (menu/icons on bottom-left) and macOS (global menu) user interfaces while simultaneously ensuring that, no matter what device you are using, the status icons, clock, and favorite apps will always remain in the same position relative to the screen.

## Rolling release with silent updates
Triggerbox makes use of a systemd timer to automatically run a system update command silently in the background every 20 minutes, ensuring the system is up to date before Discover has a chance to nag you. The result is that although the system will update frequently in the background, all you have to do is reboot if asked, which is very seldom.

Rolling release is also important because it means that you always get the newest version of both the apps and the system without the need to upgrade to a major new release. Features simply get installed each and every time you install updates to existing software; kind of like Windows 10, but even more frequently.

## Develop without preconfiguring
Triggerbox comes with [Qt Creator](https://doc.qt.io/qtcreator) out of the box. This powerful IDE provides you with all the necessary tools to design, develop, and/or distribute native apps for Triggerbox, which should work both on phones (when I, the lead developer, can get my hands on a developer-mode Android device, which might be as early as next year) and on desktop computers using the same codebase (just compiled for different architectures).

Distribution of your projects is also rather straightforward, as [this fantastic Arch Linux wiki page](https://wiki.archlinux.org/index.php/Creating_packages) explains; because `PKGBUILD` files essentially provide instructions for the makepkg command to run on a target device, this will enable you to very easily and quickly compile your code for different architectures just by running `makepkg -si` on multiple devices and saving the resulting .pkg.tar.xz file from each device. This also makes for fantastic sideloadability; you can simply distribute a systemd timer along with the `PKGBUILD` file for what you are developing that automatically updates said `PKGBUILD` every given number of days (or hours). Again, the beauty of Arch Linux is decentralization; you don't have to rely on repository maintainers making decisions for you if you don't want to.

# Build Instructions (if you already have Arch Linux installed)
The `autobuild.sh` script runs everything else for you. So simply:

    git clone https://github.com/realKennyStrawn93/Triggerbox
    cd Triggerbox
    ./autobuild.sh

It is also possible to pass a version number and a codename to this script as parameters. For example:

    ./autobuild.sh 0.3.2019.01.23.1 alpha1

# Releases
Due to GitHub's 2GB file size limit, all binary (monthly) ISO images are [here](https://mega.nz/#!RI1xXCgK!XbH-hchloLsuaeY6iMnASIB8kVT0_MkX1GMJKBaMnJs)
