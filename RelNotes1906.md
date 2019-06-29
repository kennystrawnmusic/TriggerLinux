# Triggerbox 19.06 Release Notes
Although it is rolling release (as is upstream Arch Linux, whose repositories it does still use), Triggerbox still, also like Arch Linux, releases snapshot ISO images for installation. [Download Here](https://mega.nz/#!JEdE2IaT!_f9B-2GCRmJnjTgJFyc7ZZ79zdn2V0blXwqiGjGZ3HQ)

## Feature Changes and Bug Fixes

* Linux Kernel 5.1
* [Jade Application Kit (JAK)](https://github.com/codesardine/Jade-Application-Kit) support
* Gab, Minds, and Parler now all bundled as JAK hybrid apps
* Replaced LibreOffice with [ms-office-online](https://aur.archlinux.org/packages/ms-office-online) JAK hybrid apps in order to reduce ISO image size
* Replaced Firefox with Brave as bundled browser
* Upgraded bundled Claymore miner to version 14.7
* Bundled an XAMPP server installer for easy one-click installation of server software (should come in handy for sites like Gab in particular that keep getting banned by hosting providers for political reasons)
* F2FS support (using bleeding-edge version of GRUB)

## Known Issues

* Ethernet sometimes connects and disconnects repeatedly in an infinite loop
  * **Workaround**:
    1. Disable NetworkManager notifications by clicking on the icon that looks like a bunch of switches on one of the notifications themselves, then uncheck "Device Failed" > "Show a message in a popup", uncheck "Connection Activated" > "Show a message in a popup", and finally uncheck "Connection Deactivated" > "Show a message in a popup"
    1. Disconnect from "Wired Connection 1". "eno1" should then connect automatically.
* Server installer pops up "You must be root" error message
  * **Workaround**:
    1. Press Ctrl-Alt-T to open a terminal window
    1. Type "sudo su" (without the quotes) and press Enter (type your password when prompted)
    1. Type "echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL)" >> /etc/sudoers" (without the outer quotes but **with** the inner quotes) and press Enter
    1. Close the terminal window
    1. Press Alt-F2, type "sudo Desktop/server-install.run", and press Enter
* Gab, Parler, and Minds JAK web apps won't work on live media
  * **Workaround**: Press Alt-F2, type either "gab --no-sandbox", "parler --no-sandbox", or "minds --no-sandbox", and press Enter

If you have any other issues to report, feel free to add them (along with screenshots and logs, among other details) to the [Issues](https://github.com/realKennyStrawn93/Triggerbox/issues) section of this project page. Thanks.
