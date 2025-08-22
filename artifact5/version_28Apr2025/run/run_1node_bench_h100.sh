#!/bin/bash

#SBATCH --nodes=1
#SBATCH -p batch,short 
#SBATCH --time=01:00:00
#SBATCH --job-name=h100

export starttime=`date`
lmpdate=4Feb25
lmpexe=lmp_h100_kokkos_gpu
machine=h100

module purge
module load cudatoolkit/12.4
module load openmpi-intel/4.1.6-cuda
module load ucx/1.16.0
module load gnu/11.2.1
module load intel/21.3.0
module list

hn=`hostname`

x=160
y=160
z=160 #320
t=1000
sizestr=16M
lmplog=log.lammps.date=${lmpdate}.model=lj.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off
srun -n 1 -c 128 --cpu_bind=cores -G 1 --gpu-bind=single:1 ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh full neigh/qeq full newton off comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in in.lj.gpu.steps -nocite -log ${lmplog}

x=8
y=16
z=12
t=100
sizestr=512K
lmplog=log.lammps.date=${lmpdate}.model=hns.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off
srun -n 1 -c 128 --cpu_bind=cores -G 1 --gpu-bind=single:1 ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh half neigh/qeq full newton on comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in in.hns.kokkos_gpu.steps -nocite -log ${lmplog} 

x=20
y=40
z=40
t=200
sizestr=64K
lmplog=log.lammps.date=${lmpdate}.model=snap.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off
srun -n 1 -c 128 --cpu_bind=cores -G 1 --gpu-bind=single:1 ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh half neigh/qeq full newton on comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in in.snap.steps -nocite -log ${lmplog} 

