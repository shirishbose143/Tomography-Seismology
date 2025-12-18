#!/bin/sh
cat info_makespecnew.dat |\
while read line
do
sta1=`echo $line | awk '{print $2}'`
sta2=`echo $line | awk '{print $3}'`
event=`echo $line | awk '{print $1}'`
./makespecnew_tectonics.sh $sta1 $sta2 $event
done
