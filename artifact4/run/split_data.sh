#!/bin/bash

klist="lj snap hns"

for k in $klist; do
txt=sat${k}.txt
rm $txt
while read s; do
 a=`echo $s|cut -d" " -f 6`
 b=`echo $s|cut -d" " -f 8`
 echo "$a $b">> $txt; 
done < sat_bench_${k}.txt

done # klist
