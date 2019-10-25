#!/bin/bash

keyword_dir=/etc/portage/package.keywords
use_dir=/etc/portage/package.use

echo ">=sys-kernel/git-sources-5.4_rc1 ~amd64" > $keyword_dir/git-sources
echo ">=gnome-extra/gnome-software-3.30.6 ~amd64" > $keyword_dir/gnome-software
echo ">=x11-themes/arc-theme-20190330 ~amd64" > $keyword_dir/arc-theme
echo "=sys-boot/plymouth-9999 **" > $keyword_dir/plymouth
echo "=sys-boot/grub-9999 **" > $keyword_dir/grub
echo ">=x11-libs/libdrm-2.4.99 libkms" > $use_dir/libdrm
