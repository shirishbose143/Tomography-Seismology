#!/bin/sh -x
echo STATION EVENTNO BEGFREQ/ENDFREQ/INTERVAL
test "$1" || exit 1
sta=$1 evno=$2 freq=$3
rm $evno.$sta.calc
file1="$evno.$sta.ASC"

begfreq=`echo $freq |awk -F/ '{print $1}'`
endfreq=`echo $freq |awk -F/ '{print $2}'`
freqintv=`echo $freq |awk -F/ '{print $3}'`
echo $file1
#echo $begfreq $endfreq $freqintv

tnpfreq=`calc "int(($endfreq-$begfreq)/$freqintv)"`
i=-1
while [ $i -lt $tnpfreq ]
do
num=`echo $i|awk '{print ++n*dt+t0}' dt=$freqintv t0=$begfreq n=$i`
echo $num
# average +-0.3
numminus=`calc "$num-0.3"`
numplus=`calc "$num+0.3"`
#doing processing------------
cat $file1 |awk 'NR>1{print $1,$2}'|awk '$1>='$numminus'&&$1<='$numplus'' >x
ampcoda=`cat x | awk '{print $2}' | awk '{sum+=$i} END {print sum/NR }'`

cat $file1 |awk 'NR>1{print $1,$3}'|awk '$1>='$numminus'&&$1<='$numplus'' >xx
ampsig=`cat xx | awk '{print $2}' | awk '{sum+=$i} END {print sum/NR }'`
echo $ampsig
echo $num $ampcoda $ampsig |awk '{printf "%5.2f%20.4f%20.4f%20.4f",$1,$2,$3,$3/$2}'>>$evno.$sta.calc
echo >>$evno.$sta.calc

i=`echo $i+1 |bc`
done

