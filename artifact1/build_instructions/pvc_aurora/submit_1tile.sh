#!/bin/bash -l

AFFINITY=./set_affinity_gpu.sh

lmpdate=4Apr25
lmpexe="${AFFINITY} /home/knight/projects/McCarthy/lammps/src/lmp_aurora_kokkos"
machine=aurora

######################################## change above as needed

export starttime=`date`
hn=`hostname`
echo hostname: ${hn}
echo aurora kokkos_gpu START ${starttime}
echo "matching ajohans run params for natoms/test"

NUMA=""
NUMA="numactl -m 0-1"

x=160
y=160
z=320
t=1000
sizestr=32M
lmplog=log.lammps.date=${lmpdate}.model=lj.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off
${NUMA} mpiexec -n 1 --cpu-bind list:1 -ppn 1 ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh full neigh/qeq full newton off comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in in.lj.gpu.steps -nocite -log ${lmplog}

x=8
y=16
z=12
t=100
sizestr=512K
lmplog=log.lammps.date=${lmpdate}.model=hns.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off
${NUMA} mpiexec -n 1 --cpu-bind list:1 -ppn 1 ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh half neigh/qeq full newton on comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in in.hns.steps -nocite -log ${lmplog} 

x=20
y=40
z=40
t=200
sizestr=64K
lmplog=log.lammps.date=${lmpdate}.model=snap.machine=${machine}.pkg=kokkos_gpu.kind=node.size=${sizestr}.node=1.mpi=1.gpu=1.mode=off
${NUMA} mpiexec -n 1 --cpu-bind list:1 -ppn 1  ${lmpexe} -sf kk -k on g 1 -pk kokkos neigh half neigh/qeq full newton on comm device pair/only off -v x $x -v y $y -v z $z -v t $t -in in.snap.steps -nocite -log ${lmplog} 


