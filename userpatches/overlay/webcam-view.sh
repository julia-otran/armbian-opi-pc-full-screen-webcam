#! /bin/bash

exec >/dev/tty1 2>&1;

echo " ";
echo " ";
echo " ";

echo "Waiting for initialization";

sleep 5;

while :; do
  /bin/camview;
  echo "camview exited! will retry exec...";
  sleep 10;
done;
