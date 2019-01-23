#!/usr/bin/sudo /bin/bash
dd if=output.iso of=$1 &

while killall -0 dd; do
  killall -USR1 dd
done
