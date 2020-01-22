#!/bin/bash

function help() {
	echo "usage:"
	echo "-f|--file  \"client file csv\""
	echo "-c|--call  \"count of call that want done in -t time\""
	echo "-t|--time  \"duration of time that -c packet send\""
	echo "-m|--total \"total of call you want send in a execution time\""
	echo "-l|--loop  \"show how many want to do this execution\""
	echo "-s|--service \"set client you want call him\""
 	echo "example:"
	echo "./send_call.sh -f client.csv -c 10  -t 1 -m 100 -l 2 -s norouzzadegan"
	echo " means send 10 call to norouzzadegan in 1 secend repeat this action for 2 and total of cal is 100"
}

if [ $# -ne 12 ]
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
  --cal)
  call=$2
  shift
  ;;
  -c)
  call=$2
  shift
  ;;
  --time)
  time=$2
  shift
  ;;
  -t)
  time=$2
  shift
  ;;
  -m)
  total=$2
  shift
  ;;
  --total)
  total=$2
  shift
  ;;
  -l)
  loop=$2
  shift
  ;;
  --loop)
  loop=$2
  shift
  ;;
  -s)
  SERVICE=$2
  shift
  ;;
  --service)
  SERVICE=$2
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

TIME=`echo "scale=2 ; $time*1000" | bc`




l=0
while [ $loop  -gt $l ]

do

sudo sipp imsdomain.com -sf register.xml -inf $inf -i `ifconfig | head -2 | tail -1 | awk '{print $2}'` -p 15060 -r 10 -rp 1 -m $total   -timeout $TIME_OUT -timeout_error -recv_timeout $(($TIME_OUT*1000))  -send_timeout $(($TIME_OUT*1000))
sudo sipp imsdomain.com -sf call.xml -inf $inf -i `ifconfig | head -2 | tail -1 | awk '{print $2}'` -p 15060 -r $call -rp $TIME -m $total  -s $SERVICE -timeout $TIME_OUT -timeout_error -recv_timeout $(($TIME_OUT*1000))  -send_timeout $(($TIME_OUT*1000))  | tee /tmp/salam.log




INVITE=`cat /tmp/salam.log |head -23 | tail -11 | awk '{print $3}' |head -1`
RINGING=`cat /tmp/salam.log |head -23 | tail -11 | awk '{print $3}' |head -3 |tail -1`
OKringing=`cat /tmp/salam.log |head -23 | tail -11 | awk '{print $3}' |head -6 |tail -1`
OKbye=`cat /tmp/salam.log |head -23 | tail -11 | awk '{print $3}' |head -11 |tail -1`

RINGING_p=`echo "scale=2 ; ($RINGING/$INVITE)*100" |bc`
OKringing_p=`echo "scale=2 ; ($OKringing/$INVITE)*100" |bc`
OKbye_p=`echo "scale=2 ; ($OKbye/$INVITE)*100" |bc`


UNOK=0
unRegister2=0
unRegister1=0
OK=0
Register2=0
Register1=0
#####################################


echo $RINGING_p >> /tmp/per
echo $OKringing_p >> /tmp/per
echo $OKbye_p >> /tmp/per



if [ -f /tmp/salam.log ]
then
rm -rf /tmp/salam.log
fi

sleep 5
l=$(($l+1))
done

n=0
b=`cat /tmp/per`

LINE=`cat /tmp/per | wc -l`
repeat=`echo "scale=0 ; $LINE / 3" | bc  `


m=1
l=1
ringing=0
ok_ring=0
okbye=0
TOTAL_performance=0

for i in $b
do 
if [ $l -eq 1 ]
 then
  echo "################# $m ###################"
  echo "performance challenge register for $m TH is $i"
  ringing=`echo "scale=2 ; $ringing+$i" | bc`
 fi
if [ $l -eq 2 ]
 then
  echo "performance 200 OK register for $m TH is $i"
  ok_ring=`echo "scale=2 ; $ok_ring+$i" | bc`
 fi
if [ $l -eq 3 ]
 then
  echo "performance challenge unregister for $m TH is $i"
  okbye=`echo "scale=2 ; $okbye+$i" | bc`
 fi

l=$(($l+1))
if [ $l -gt 3 ]
 then
  l=1
  m=$(($m+1))
 fi
done 

echo ""
echo "#########################################"

echo " total performance for Ringing is `echo "scale=2 ; $ringing/$repeat" | bc`% "
echo " total performance for 200 OK after ringing is `echo "scale=2 ; $ok_ring/$repeat" | bc` "
echo " total performance for 200 ok after bye is `echo "scale=2 ; $okbye/$repeat" | bc`% "


if [ -f /tmp/per ]
then
rm -rf /tmp/per
fi

