#!/bin/bash

git_sources="$(ls /var/db/repos/gentoo/sys-kernel/git-sources | sort -rn | grep -v metadata | grep -v Manifest | head -n1 | cut -d '.' -f1).$(ls /var/db/repos/gentoo/sys-kernel/git-sources | sort -rn | grep -v metadata | grep -v Manifest | head -n1 | cut -d '.' -f2)"

pip install $(pip list --outdated | awk '{ print $1 }') --upgrade
pip install /etc/pip/portage-2.3.78.b-py3-none-any.whl
/usr/lib64/python3.6/site-packages/usr/bin/emerge -av portage
emerge --sync
layman -S
emerge -uDNU --with-bdeps=y @world
emerge =sys-kernel/$git_sources
genkernel --kernel-config=/proc/config.gz all
