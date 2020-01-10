#! /bin/bash

function showUsage() {
  echo "Usage: $0 hostname"
  echo "hostname: the new hostname for this raspberry"
  exit -1;
}

if [ "$1" == "" ] ; then
  showUsage;
fi;

raspiname=$1

echo $raspiname > /etc/hostname
sed -i -e "s~raspix~$raspiname~g" /etc/hosts
git config --global user.name "$raspiname"
echo "127.0.0.1" >  /home/pi/bin/checkip/checkip.dat
hostname -I > /home/pi/bin/checkinternalip/checkinternalip.dat
