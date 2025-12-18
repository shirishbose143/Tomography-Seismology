#!/bin/sh 

rawdir="<path to sac files>"
direvt=`ls $rawdir`
for dir in $direvt
do
#cat QUALITY/quality.$dir |awk '$2==1||$2==2' |awk -F. '{print $2}'  >x

awk -v b=$dir -F. '{if ($1==b) print $2}' dd>x
evtlat=`sachdr $rawdir/*.BHZ.SAC | grep lat | awk 'NR==2' |awk '{print $2}'`
evtlon=`sachdr $rawdir/*.BHZ.SAC | grep lon | awk 'NR==2' |awk '{print $2}'`

awk '
        {
                A[++c] = $1
        }
        END {
                for ( i = 1; i <= c; i++ )
                {
                        for ( j = 1; j <= c; j++ )
                        {
                            if (j>i)
                            print A[j], A[i]
                        }
                }
        }
' x > $dir-list

cat $dir-list |\
while read line
do
sta1=`echo $line |awk '{print $1}'`
sta2=`echo $line |awk '{print $2}'`
eventdep=`sachdr $rawdir/*$sta1*BHZ.SAC | grep evdp | awk 'NR==1' |awk '{print $3}'`
eventlat=`sachdr $rawdir/*$sta1*BHZ.SAC | grep lat | awk 'NR==1' |awk '{print $3}'`
eventlon=`sachdr $rawdir/*$sta2*BHZ.SAC | grep lon | awk 'NR==1' |awk '{print $3}'`
stalat1=`sachdr $rawdir/*$sta1*BHZ.SAC | grep lat | awk 'NR==1' |awk '{print $3}'`
stalat2=`sachdr $rawdir/*$sta2*BHZ.SAC | grep lat | awk 'NR==1' |awk '{print $3}'`
stalon1=`sachdr $rawdir/*$sta1*BHZ.SAC | grep lon | awk 'NR==1' |awk '{print $3}'`
stalon2=`sachdr $rawdir/*$sta2*BHZ.SAC | grep lon | awk 'NR==1' |awk '{print $3}'`


###############for spherical earth
a=`delta $stalat1 $stalon1 $stalat2 $stalon2 |awk 'NR==1' |awk '{print $3}'`
b=`delta $eventlat $eventlon $stalat1 $stalon1 |awk 'NR==1' |awk '{print $3}'`
c=`delta $eventlat $eventlon $stalat2 $stalon2 |awk 'NR==1' |awk '{print $3}'`
upper=`calc "cosd($a)-cosd($b)*cosd($c)"`
lower=`calc "sind($b)*sind($c)"`
angle=`calc $upper/$lower  #### cosine$angle for the spherical earth`


echo $stalat1 $stalon1 $stalat2 $stalon2 $dir $sta1 $sta2 $eventdep $a $angle >>y

cat y |awk '$10>=0.965926' | awk '$9*111.1>=150' | awk '$8<55' >e

done

done
