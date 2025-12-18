#!/bin/sh 
echo "STATION1 STATION2 EVNO. STATION1/STATION2"
test "$1" || exit 1
sta1=$1 sta2=$2 evno=$3
rm $evno.$sta1.$sta2.dat
file1="$evno.$sta1.calc"
file2="$evno.$sta2.calc"

cat $file1 |awk '{print $1,$4}' >x
cat $file2 |awk '{print $4}' >xx
paste x xx >xxx
#Here we are dividing two amplitudes
epi1=`cat Sntimenew1.dat |awk '$1=="'$evno'"&& $2=="'$sta1'"'|awk '{print $10}' | sort | uniq`
epi2=`cat Sntimenew1.dat |awk '$1=="'$evno'"&& $2=="'$sta2'"'|awk '{print $10}' | sort | uniq`
cat xxx |awk '{print $1,$2/$3}' >tmp1
cat tmp1|\
while read line
do
fr1=`echo $line | awk '{print $1}'`
#echo $epi1 $epi2
n1=`calc "-0.347*(log10($fr1))^2 + 2.16*log10($fr1) +3.54"`
n2=`calc "-2.69*(log10($fr1))^2 + 10.1*log10($fr1) +20.4"`
n3=`calc "-4.38*(log10($fr1))^2 + 11.7*log10($fr1) + 23.1"`
power1=`calc "$n1*log10(1/$epi1) + $n2"`
power2=`calc "$n1*log10(1/$epi2) +$n2"`
#epratio=`calc "(sqrt($epi1)/sqrt($epi2))"` # for Pg
epratio=`calc "(1/$epi2)^$power2/(1/$epi1)^$power1"`  #for Sn
echo $epratio
# Here we are multiplying amplituderatio and epratio
cat tmp1 |awk '{print $1,$2*'$epratio'}' >tmp2
done
rm tmp3
cat tmp2 |\
while read line
do
amp1=`echo $line |awk '{print $2}'`
amp2=`calc "log($amp1)"`

freq=`echo $line |awk '{print $1}'`
#tmp3 consist frequency and ampltude log multiplied by constant
echo $freq $amp2 >>tmp3
done

Vlg=3.5
 
piercedis=`cat e |awk '$5=="'$evno'"&& $6=="'$sta1'" && $7=="'$sta2'"'|awk '{if ($11=="nan") print $9*100; else print $11}' `
Lgconst=`calc "$Vlg/(pi*$piercedis)"`
 
cat tmp3 |\
while read line
do

 
fr1=`echo $line |awk '{print $1}'`
am1=`echo $line |awk '{print $2}'`
 
frnew1=`calc "log($fr1)"`
ampreduced=`calc "$am1*$Lgconst"`
#amplast=`./calc "log($ampreduced)"`
 
echo $fr1 $ampreduced >>$evno.$sta1.$sta2.dat
done
