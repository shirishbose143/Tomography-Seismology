#!/bin/sh -x
cat info_twostn.dat |\
while read line
do
sta=`echo $line | awk '{print $1}'`
evno=`echo $line | awk '{print $2}'`
begfreq=`echo $line | awk '{print $3}'`
endfreq=`echo $line | awk '{print $4}'`
#freqint=`echo $line | awk '{print $5}'`
./twostn.sh $sta $evno $begfreq/$endfreq/0.01
done