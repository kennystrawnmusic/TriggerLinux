# Triggerbox 19.06.1 Release Notes
Although it is rolling release (as is upstream Arch Linux, whose repositories it does still use), Triggerbox still, also like Arch Linux, releases snapshot ISO images for installation. [Download Here](https://mega.nz/#!Vd8GUazQ!i5ssW9PNB4n3TGZ50tzbs_V9PcN4Ve7f3TutAsoQfYA)

## Feature Changes and Bug Fixes

* Linux Kernel 5.1
* [Jade Application Kit (JAK)](https://github.com/codesardine/Jade-Application-Kit) support
* Gab, Minds, and Parler now all bundled as JAK hybrid apps
* Replaced LibreOffice with [ms-office-online](https://aur.archlinux.org/packages/ms-office-online) JAK hybrid apps in order to reduce ISO image size
* Replaced Firefox with Brave as bundled browser
* Upgraded bundled Claymore miner to version 14.7
* Bundled an XAMPP server installer for easy one-click installation of server software (should come in handy for sites like Gab in particular that keep getting banned by hosting providers for political reasons)
* F2FS support (using bleeding-edge version of GRUB)
* Bug Fixes:
  * NetworkManager now uses dhclient instead of dhcpcd, working as intended because of this
  * Server installer now runs using sudo by default
  * Gab, Parler, and Minds now check whether or not you're root (what the live DVD automatically logs into) and, if you are, they run with different command line options that allow them to work

## Known Issues

If you have any other issues to report, feel free to add them (along with screenshots and logs, among other details) to the [Issues](https://github.com/realKennyStrawn93/Triggerbox/issues) section of this project page and I will add them here. Thanks.
