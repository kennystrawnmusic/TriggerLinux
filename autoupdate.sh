#!/bin/bash

git_sources="$(ls /var/db/repos/gentoo/sys-kernel/git-sources | sort -rn | grep -v metadata | grep -v Manifest | head -n1 | cut -d '.' -f1).$(ls /var/db/repos/gentoo/sys-kernel/git-sources | sort -rn | grep -v metadata | grep -v Manifest | head -n1 | cut -d '.' -f2)"

emerge --sync
emerge -uDU --changed-deps --with-bdeps=y @world
emerge =sys-kernel/$git_sources
genkernel --kernel-config=/proc/config.gz all
