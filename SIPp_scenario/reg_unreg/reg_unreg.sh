#!/bin/bash

function help() {
	echo "usage:"
	echo "-f|--file  \"client file csv\""
	echo "-c|--call  \"count of call that want done in -t time\""
	echo "-t|--time  \"duration of time that -c packet send\""
	echo "-m|--total \"total of call you want send in a execution time\""
	echo "-l|--loop  \"show how many want to do this execution\""
 	echo "example:"
	echo "./reg_unreg.sh -f client.csv -c 10  -t 1 -m 100 -l 2 "
	echo " means send 10 packet register_unregister in 1 secend repeat this action for 2 and total of cal is 100"
}

if [ $# -ne 10 ]
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
  *)
  help
  exit 1
  ;;
 esac
shift
done



TIME_OUT=100

TIME=`echo "scale=2 ; $time*1000" | bc`




l=0
while [ $loop  -gt $l ]

do

sudo sipp imsdomain.com -sf register_unregister.xml -inf $inf -i `ifconfig | head -2 | tail -1 | awk '{print $2}'` -p 15060 -r $call -rp $TIME -m $total   -timeout $TIME_OUT -timeout_error -recv_timeout $(($TIME_OUT*1000))  -send_timeout $(($TIME_OUT*1000))   | tee /tmp/salam.log
UNOK=0
unRegister2=0
unRegister1=0
OK=0
Register2=0
Register1=0
#####################################
Register1=`cat /tmp/salam.log |head -28 | tail -16 |awk '{print $4}'|head -1`
Register2=`cat /tmp/salam.log |head -28 | tail -16 |awk '{print $4}' |head -5 |tail -1`
OK=`cat /tmp/salam.log |head -28 | tail -16 |awk '{print $4}' |head -7 |tail -1`


unRegister1=`cat /tmp/salam.log |head -28 | tail -16 |awk '{print $4}' |head -10 |tail -1`
unRegister2=`cat /tmp/salam.log |head -28 | tail -16 |awk '{print $4}' |head -14 |tail -1`
UNOK=`cat /tmp/salam.log |head -28 | tail -16 |awk '{print $4}' |head -16 |tail -1`

CHALLENGE_REGISTER_p=`echo "scale=2 ; $Register2/$Register1*100" |bc`
OK_REGISTER_p=`echo "scale=2 ; $OK/$Register1*100" |bc`
UNREGISTER_p=`echo "scale=2 ; $unRegister1/$Register1*100" |bc`
CHALLENGE_UNREGISTER_p=`echo "scale=2 ; $unRegister2/$Register1*100" |bc`
OK_UNREGISTER_p=`echo "scale=2 ; $UNOK/$Register1*100" |bc`
PERFORMANCE_p=`echo "scale=2 ; $UNOK/$Register1*100" |bc` 


echo $CHALLENGE_REGISTER_p >> /tmp/per
echo $OK_REGISTER_p >> /tmp/per
echo $UNREGISTER_p >> /tmp/per
echo $CHALLENGE_UNREGISTER_p >> /tmp/per
echo $OK_UNREGISTER_p >> /tmp/per


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
repeat=`echo "scale=0 ; $LINE / 5" | bc  `


m=1
l=1
register=0
ok=0
chunregister=0
unregister=0
TOTAL_performance=0

for i in $b
do 
if [ $l -eq 1 ]
 then
  echo "################# $m ###################"
  echo "performance challenge register for $m TH is $i"
  register=`echo "scale=2 ; $register+$i" | bc`
 fi
if [ $l -eq 2 ]
 then
  echo "performance 200 OK register for $m TH is $i"
  ok=`echo "scale=2 ; $ok+$i" | bc`
 fi
if [ $l -eq 3 ]
 then
  echo "performance challenge unregister for $m TH is $i"
  chunregister=`echo "scale=2 ; $chunregister+$i" | bc`
 fi
if [ $l -eq 4 ]
 then
  echo "performance unregister for $m TH is $i"
  unregister=`echo "scale=2 ; $unregister+$i" | bc`
 fi
if [ $l -eq 5 ]
 then 
  echo "performance 200 OK unregister and TOTAL performance for $m TH is $i"
  TOTAL_performance=`echo "scale=2 ; $TOTAL_performance+$i" | bc`
 fi
l=$(($l+1))
if [ $l -gt 5 ]
 then
  l=1
  m=$(($m+1))
 fi
done 

echo ""
echo "#########################################"

echo " total performance for challenge register is `echo "scale=2 ; $register/$repeat" | bc`% "
echo " total performance for 200 OK register `echo "scale=2 ; $ok/$repeat" | bc` "
echo " total performance for challenge unregister is `echo "scale=2 ; $chunregister/$repeat" | bc`% "
echo " total performance for unregister is `echo "scale=2 ; $unregister/$repeat" | bc` "
echo " total performance for 200 OK unregister is `echo "scale=2 ; $TOTAL_performance/$repeat" | bc`% "

if [ -f /tmp/per ]
then
rm -rf /tmp/per
fi
