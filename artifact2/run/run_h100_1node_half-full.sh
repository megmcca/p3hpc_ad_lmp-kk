#!/bin/bash

#SBATCH --nodes=1
#SBATCH -p batch,short 
#SBATCH --time=01:00:00
#SBATCH --job-name=h100

function parse_log(){
	## first arg is lmplog variable
	loop=`grep Loop $1`
	perf=`grep Performance $1`
	seconds=`echo $loop | cut -d " " -f 4`
	natoms=`echo $loop | cut -d " " -f 12`
	tss=`echo $perf | cut -d " " -f 4`
	mass=`echo $perf | cut -d " " -f 6`

	echo $natoms $seconds $tss $mass
}

export starttime=`date`
lmpdate=ad
lmpexe=lmp_h100_kokkos_gpu
machine=h100
model=lj
infile=in.${model}.gpu.steps
txt=neigh_bench_${model}.txt

# copy files from artifact1
benchdir=../../artifact1/bench/* .

module purge
module load cudatoolkit/12.4
module load openmpi-intel/4.1.6-cuda
module load ucx/1.16.0
module load gnu/11.2.1
module load intel/21.3.0
module list

hn=`hostname`

echo h100 kokkos_gpu START ${starttime}

size_arr=( "1K" "2K" "4K" "8K" "16K" "32K" "64K" "128K" "256K" "512K" "1M" "2M" "4M" "8M" "16M" "32M" "64M" "128M" )
dim_arr=( "5 5 10" "5 10 10" "10 10 10" "10 10 20" "10 20 20" "20 20 20" "20 20 40" "20 40 40" "40 40 40" "40 40 80" "40 80 80" "80 80 80" "80 80 160" "80 160 160" "160 160 160" "160 160 320" "160 320 320" "320 320 320" )

count=0
end=12
t=1000
echo "sizestr x y z natoms loop-time timesteps/s Matom*step/s neigh nqeq newt" > $txt
for ((i=${count}; i<${end}; i++)); do

echo $count "${size_arr[$count]}" "${dim_arr[$count]}" 

sizestr="${size_arr[$count]}"
x=`echo "${dim_arr[$count]}" | cut -d " " -f 1`
y=`echo "${dim_arr[$count]}" | cut -d " " -f 2`
z=`echo "${dim_arr[$count]}" | cut -d " " -f 3`
echo $x $y $z $sizestr

neigh=full
nqeq=full
newt=off
lmplog=log.lammps.date=${lmpdate}.model=${model}.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off.neigh=${neigh}.nqeq=${nqeq}.newt=${newt}
mpirun -np 1 --bind-to core  ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh ${neigh} neigh/qeq ${nqeq} newton ${newt} comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in ${infile} -nocite -log ${lmplog}
stats=`parse_log $lmplog`
echo $sizestr $x $y $z $stats $neigh $nqeq $newt >> $txt

neigh=half
nqeq=full
newt=on
lmplog=log.lammps.date=${lmpdate}.model=${model}.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off.neigh=${neigh}.nqeq=${nqeq}.newt=${newt}
mpirun -np 1 --bind-to core  ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh ${neigh} neigh/qeq ${nqeq} newton ${newt} comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in ${infile} -nocite -log ${lmplog}
stats=`parse_log $lmplog`
echo $sizestr $x $y $z $stats $neigh $nqeq $newt >> $txt

neigh=half
nqeq=full
newt=off
lmplog=log.lammps.date=${lmpdate}.model=${model}.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off.neigh=${neigh}.nqeq=${nqeq}.newt=${newt}
mpirun -np 1 --bind-to core ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh ${neigh} neigh/qeq ${nqeq} newton ${newt} comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in ${infile} -nocite -log ${lmplog}
stats=`parse_log $lmplog`
echo $sizestr $x $y $z $stats $neigh $nqeq $newt >> $txt

count=$(( $count + 1 ))

echo ""

done 
