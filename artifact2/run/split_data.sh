#!/bin/bash

while read s; do if [[ $s == *"on on"* ]]; then a=`echo $s|cut -d" " -f 5`;b=`echo $s|cut -d" " -f 8` ; echo $a $b >> neigh_h100_thread_on-on.txt; fi; done < thread_bench_lj.txt

while read s; do if [[ $s == *"on off"* ]]; then a=`echo $s|cut -d" " -f 5`;b=`echo $s|cut -d" " -f 8` ; echo $a $b >> neigh_h100_thread_on-off.txt; fi; done < thread_bench_lj.txt 

 while read s; do if [[ $s == *"off off"* ]]; then a=`echo $s|cut -d" " -f 5`;b=`echo $s|cut -d" " -f 8` ; echo $a $b >> neigh_h100_thread_off-off.txt; fi; done < thread_bench_lj.txt

while read s; do if [[ $s == *"off on"* ]]; then a=`echo $s|cut -d" " -f 5`;b=`echo $s|cut -d" " -f 8` ; echo $a $b >> neigh_h100_thread_off-on.txt; fi; done < thread_bench_lj.txt


