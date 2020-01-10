#! /bin/bash

. /etc/rpi/globals.conf 
basedir=${bindir}/systatus
hostname=$(hostname)
oldstatus=$(cat $basedir/systatus.dat)
newstatus=$(curl $remoteconfig/$hostname.status 2>/dev/null)

if [[ "$oldstatus" != "$newstatus" && "$newstatus" =~ ^[0-9]+$ ]] ; then
        sed -e "s~oldstatus~$oldstatus~g" $basedir/systatus.template | sed -e "s~newstatus~$newstatus~g" | sed -e "s~hostname~$hostname~g" | /usr/bin/mail -a "From: $hostname <$fromEmail>" -s "[$hostname] The system is going to reboot" $destEmail 
	logger -p local7.info "Remote status indicator changed from $oldstatus to $newstatus. Restarting the system..." 
	echo $newstatus > $basedir/systatus.dat
	sudo init 6
fi;
