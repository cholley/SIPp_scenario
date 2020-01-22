#!/bin/bash

function help() {
	echo "usage:"
	echo "-f|--file  \"client file csv\""
 	echo "example:"
	echo "./send_call.sh -f client.csv "
	echo " means you recive call that id is in client.csv "
}

if [ $# -ne 2 ]
then
	help
	exit 1

fi

while [ $# -gt 0 ]
do
 case	"$1" in 
  -f)
  inf=$2
  shift
  ;;
  --file)
  inf=$2
  shift
  ;;
  *)
  help
  exit 1
  ;;
 esac
shift
done



TIME_OUT=10000000000000000000


sudo sipp imsdomain.com -sf register.xml -inf $inf -i `ifconfig | head -2 | tail -1 | awk '{print $2}'` -p 55060 -r 1 -rp 1 -m 1   -timeout $TIME_OUT -timeout_error -recv_timeout $(($TIME_OUT*1000))  -send_timeout $(($TIME_OUT*1000))
sudo sipp imsdomain.com -sf responder.xml -inf $inf -i `ifconfig | head -2 | tail -1 | awk '{print $2}'` -p 55060 -timeout $TIME_OUT -timeout_error -recv_timeout $(($TIME_OUT*1000))  -send_timeout $(($TIME_OUT*1000))