#!/bin/bash
# H100 machine

cwd=$PWD
lammps=""   ### SET PATH TO LAMMPS DIRECTIORY HERE, e.g. /home/user/myself/lammps
exename=h100_kokkos_gpu

module purge
module load cudatoolkit/12.4
module load openmpi-intel/4.1.6-cuda 
module load ucx/1.16.0
module load gnu/11.2.1
module load intel/21.3.0
module load aue/python/3.12.4
module list 

# May need to set Kokkos default compiler
#NVCC_WRAPPER_DEFAULT_COMPILER="nvc++"
export UCX_CUDA_COPY_ENABLE_FABRIC=no

cd ${lammps}/src
make clean-all

make yes-kokkos
make yes-manybody
make yes-reaxff
make yes-ml-snap

make -j36 ${exename}
cd $cwd

ln -sf ${lammps}/lmp_${exename} .

