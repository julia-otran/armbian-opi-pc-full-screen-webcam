#! /bin/bash

VIDEO_DEVICE=/dev/video0

exec >/dev/tty1 2>&1;

echo " ";
echo " ";
echo " ";

echo "Waiting for initialization";

sleep 5;

while :; do
  guvcview --resolution=1920x1080 -d "$VIDEO_DEVICE";
  echo "guvcview exited! will retry exec...";
  sleep 10;  
done;
