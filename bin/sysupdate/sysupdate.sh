#! /bin/bash

. /etc/rpi/globals.conf 
basedir=${bindir}/sysupdate
hostname=$(hostname)
timestamp=$(date "+%Y%m%d%H%M%S")
logfile=$basedir/log/$timestamp.log
logfileinline=$basedir/log/inline_$timestamp.log

function isUpgraded () {
  noupgr=$(echo $1 | sed -e "s~.*\(0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.\).*~\1~g")
  if [ "$noupgr" == "0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded." ] ; then
    echo "0"
  else
    echo "1"
  fi;
}

function upgradeMsg () {
  if [ "$1" == "1" ] ; then
    upgrMsg=$(echo $2 | sed -e "s~.*upgraded:\(.*\) [[:digit:]]\+ upgraded.*~\1~g")
  else
    upgrMsg="Nothing"
  fi;
  echo $upgrMsg
}

sudo apt-get update > /dev/null
upgrResult=$(sudo apt-get -y upgrade)
upgraded=$(isUpgraded "$upgrResult")
upgrMsg=$(upgradeMsg "$upgraded" "$upgrResult")


dupgrResult=$(sudo apt-get -y dist-upgrade)
dupgraded=$(isUpgraded "$dupgrResult")
dupgrMsg=$(upgradeMsg "$dupgraded" "$dupgrMsg")

sudo apt-get autoclean > /dev/null
sudo apt-get -y autoremove > /dev/null
sudo apt-get remove > /dev/null
sudo apt-get clean > /dev/null

if [ "$upgraded" == "1" ] || [ "$dupgraded" == "1" ] ; then
  sed -e "s~dupgrMsg~$dupgrMsg~g" $basedir/sysupdate.template | sed -e "s~upgrMsg~$upgrMsg~g" | sed -e "s~hostname~$hostname~g" | /usr/bin/mail -a "From: $hostname <$fromEmail>" -s "[$hostname] System updated" $destEmail
  echo "$upgrResult" > $logfile
  echo "--------------------------------" >> $logfile
  echo "$dupgrResult" >> $logfile 
  echo $upgrResult > $logfileinline
fi;
