#!/bin/bash

imgmerge sync
imgmerge install $(ls /Applications | cut -d '.' -f1)
pip install $(pip list --outdated | awk '{ print $1 }') --upgrade
pip install /etc/pip/portage-2.3.78.b-py3-none-any.whl
/usr/lib64/python3.6/site-packages/usr/bin/emerge -av portage
emerge --sync
layman -S
emerge -uDNU --with-bdeps=y @world
emerge sys-kernel/git-sources
genkernel --kernel-config=/proc/config.gz all
