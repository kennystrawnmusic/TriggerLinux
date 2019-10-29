#!/bin/bash

rm -f /root/calamares.desktop
sed -i "7d" /etc/gdm/custom.conf
sed -i "6d" /etc/gdm/custom.conf
systemctl disable cleanup.service
