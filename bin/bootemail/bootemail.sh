#! /bin/bash

### BEGIN INIT INFO
# Provides:          bootemail 
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Send and email at boot time
# Description:       Send a status email at boot time.
### END INIT INFO

. /etc/rpi/globals.conf 
basedir=${bindir}/bootemail
hostname=$(hostname)
externalip=$(curl $publicipservice$hostname 2>/dev/null)
internalip=$(hostname -I)

sed -e "s~internalip~$internalip~g" $basedir/bootemail.template | sed -e "s~externalip~$externalip~g" | sed -e "s~hostname~`hostname`~g" | /usr/bin/mail -a "From: $hostname <$fromEmail>" -s "[$hostname] System is up and running" $destEmail 

logger -p local7.info "     System booted up"
logger -p local7.info "     Internal ip: $internalip"
logger -p local7.info "     External ip: $externalip"
