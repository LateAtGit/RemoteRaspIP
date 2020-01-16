#! /bin/bash

#echo $1
#echo $2
#echo $3
#echo $4
#echo $5

changeip_response=$(curl https://nic.ChangeIP.com/nic/update?u=${1}\&p=${2}\&ip=${3}\&hostname=${4}.${5} 2> /dev/null)