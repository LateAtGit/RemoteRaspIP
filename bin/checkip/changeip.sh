#! /bin/bash

#echo $1
#echo $2
#echo $3
#echo $4

#exresult=pippero

changeip_response=$(curl https://nic.ChangeIP.com/nic/update?u=${1}\&p=${2}&ip="$newip"\&hostname=${3}.${4} 2> /dev/null)
