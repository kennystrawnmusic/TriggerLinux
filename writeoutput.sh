#!/usr/bin/sudo /bin/bash
dd if=$1 of=$2 &

while killall -0 dd; do
  killall -USR1 dd
done
