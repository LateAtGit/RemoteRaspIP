#! /bin/bash

. /etc/rpi/globals.conf 
basedir=${bindir}/checkip
wrongipfile=$basedir/checkiptries.log
oldip=$(cat $basedir/checkip.dat)
hostname=$(hostname)
newip=$(curl $publicipservice$hostname 2>> /dev/null)

if [ ! -f $basedir/$dynipservice.sh ] ; then
  echo DynDns Provider $dynipservice not supported
  exit 1
fi;

#. $basedir/$dynipservice.sh $dynipusername $dynippassword $hostname $dynipdomain
#echo exresult = $exresult

if [ "$oldip" != "$newip" -a "$newip" != "" ] ; then
  . $basedir/$dynipservice.sh $dynipusername $dynippassword $hostname $dynipdomain 2> /dev/null
  sed -e "s~newhomeip~$newip~g" $basedir/checkip.template | sed -e "s~changeipstatus~$changeip_response~g" | sed -e "s~hostname~$hostname~g" | /usr/bin/mail -a "From: $hostname <$fromEmail>" -s "[$hostname] IP has changed" $destEmail 
  logger -p local7.info "Public ip is changed from $oldip to $newip"
  echo "$newip" > $basedir/checkip.dat
fi;

if [ "$newip" == "" ] ; then
  if [ -a $wrongipfile ] ; then	
    wrongipcount=$(cat $wrongipfile)
  else
    wrongipcount=0
  fi;
  wrongipcount=$((wrongipcount + 1))
  echo $wrongipcount > $wrongipfile 
  logger -p local7.info "A wrong ip was received: $wrongipcount try"
  if [[ $wrongipcount -ge 5 ]] ; then
     #logger -p local7.info "A wrong ip was received: sending mail"
     sed -e "s~hostname~$hostname~g" $basedir/checkip.wrong.template | sed -e "s~wrongipcount~$wrongipcount~g" | /usr/bin/mail -a "From: $hostname <$fromEmail>" -s "[$hostname] Wrong IP" $destEmail 
  fi;
  modulocount=$((wrongipcount % 18))
  if [[ $modulocount == 0 ]] ; then
    logger -p local7.info "I've been getting a wrong ip for $wrongipcount times, trying to restart network interface"
    sudo ifconfig wlan0 down
    sudo ifconfig wlan0 up
    sleep 45 
    testip=$(curl $publicipservice$hostname 2>> /dev/null)
    if [ "$testip" == "" ] ; then
      logger -p local7.info "Network is still unavailable, trying to reboot"
      sudo init 6
    else
      logger -p local7.info "Networking is back"
      echo 0 > $wrongipfile
    fi;
  fi;
else
  echo 0 > $wrongipfile
fi;
