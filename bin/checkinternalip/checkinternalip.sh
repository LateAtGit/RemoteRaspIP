#! /bin/bash

. /etc/rpi/globals.conf 
basedir=${bindir}/checkinternalip
confip=$(cat $basedir/checkinternalip.dat)
currip=$(hostname -I)
hostname=$(hostname)
remoteauth=$(curl $remoteconfig/$hostname.rauth 2>/dev/null)

#logger -p local7.info "currip: $currip, confip: $confip, remoteauth: $remoteauth"

if [ "$confip" != "$currip" -a "$remoteauth" == "1" ] ; then
	logger -p local7.info "The internal IP is changed, the new ip is $currip"
	confipstatus=$(nmap -sn $confipr)
	hostnamecheck=$(echo $confipstatus | grep $hostname)
	hostupcheck=$(echo $confipstatus | grep "1 host up")
	if [[ !( "$hostupcheck" != "" && "$hostnamecheck" == "" ) ]] ; then
		sudo /sbin/ifconfig wlan0 down
		sudo /sbin/ifconfig wlan0 $confip up 2> /dev/null
		sleep 30
		ifconfigresult=$(/sbin/ifconfig wlan0)
		ifconfigresult=$(echo $ifconfigresult | sed -e "s/(//g")
                ifconfigresult=$(echo $ifconfigresult | sed -e "s/)//g")	
                sed -e "s~newhomeip~$currip~g" $basedir/checkinternalip.template | sed -e "s~hostname~$hostname~g" | sed -e "s~ifconfigresult~$ifconfigresult~g" | /usr/bin/mail -a "From: $hostname <$fromEmail>" -s "[$hostname] Internal IP has changed" $destEmail 
	else
		scanresult=$(sudo nmap -Pn -O $confip) 
		scanresult=$(echo $scanresult | sed -e "s/(//g")
		scanresult=$(echo $scanresult | sed -e "s/)//g")
                sed -e "s~scanresult~$scanresult~g" $basedir/portscan.template | sed -e "s~hostname~$hostname~g" | /usr/bin/mail -a "From: $hostname <$fromEmail>" -s "[$hostname] Internal IP has changed: Portscan result" $destEmail
		logger -p local7.info "The old internal IP is currently configured to another device: "
		logger -p local7.info "$scanresult"
	fi;
fi;

if [ "$confip" != "$currip" -a "$remoteauth" == "0" ] ; then
        sed -e "s~newhomeip~$currip~g" $basedir/noauth.template | sed -e "s~hostname~$hostname~g" | /usr/bin/mail -a "From: $hostname <$fromEmail>" -s "[$hostname] IP has changed: No authorized to take actions" $destEmail 
fi;
