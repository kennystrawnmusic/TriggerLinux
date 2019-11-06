subarch: amd64
version_stamp: latest
target: livecd-stage2
rel_type: default
profile: default/linux/amd64/17.1/desktop/gnome/systemd
snapshot: latest
source_subpath: default/livecd-stage1-amd64-installer-latest
portage_confdir: /opt/TriggerLinux/portage
portage_overlay: /var/lib/layman/triggerlinux-overlay

livecd/bootargs: dokeymap dodetect dousb quiet splash zram.num_devices=1 apparmor=1 security=apparmor
livecd/cdtar: /opt/TriggerLinux/livecd-stage2-cdtar.tar.bz2
livecd/fsscript: /opt/TriggerLinux/customize.sh
livecd/fstype: squashfs
livecd/fsops: -comp xz
livecd/gk_mainargs: --plymouth --plymouth-theme=bgrt
livecd/iso: livecd-amd64-installer-latest.iso
livecd/motd: ""
livecd/type: generic-livecd
livecd/volid: TriggerLinux LiveDVD latest
livecd/xsession: gnome
livecd/xdm: gdm

boot/kernel: triggerlinux
boot/kernel/triggerlinux/sources: git-sources
boot/kernel/triggerlinux/config: /opt/TriggerLinux/livecd-stage2.config
boot/kernel/triggerlinux/use: atm png truetype usb
boot/kernel/triggerlinux/packages:
	media-libs/alsa-oss
	media-sound/alsa-utils
	media-sound/pulseaudio
### Masked (~amd64)
#	net-dialup/fcdsl
### Masked (~amd64)
#	net-dialup/fritzcapi
### Masked (~amd64)
#	net-dialup/slmodem
### No longer exists
#	net-misc/br2684ctl
### Masked (~amd64)
#	net-wireless/acx
	net-wireless/hostap-utils
#	net-wireless/ipw3945
#	net-wireless/madwifi-ng-tools
#	net-wireless/rt2500
### Masked (~amd64)
#	net-wireless/rtl8187
	sys-apps/pcmciautils
	sys-kernel/linux-firmware
	sys-fs/ntfs3g
	dev-util/triggerlinux-autobuilder
	=gnome-extra/gnome-software-3.34.1
	x11-drivers/xf86-video-amdgpu

livecd/empty:
	/var/db/repos
	/var/tmp
	/var/empty
	/var/run
	/var/state
	/var/cache/edb/dep
	/tmp
	/root/.ccache
	/usr/share/genkernel/pkg/x86/cpio

livecd/rm:
	/etc/*.old
	/root/.viminfo
	/var/log/*.log
	/usr/share/genkernel/pkg/x86/*.bz2
