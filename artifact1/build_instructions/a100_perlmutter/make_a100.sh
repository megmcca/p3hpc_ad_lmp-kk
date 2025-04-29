#!/bin/bash

cwd=$PWD
lammps=../../artifact1/lammps
exename=a100_kokkos_gpu

# Perlmutter defaults as of April 4th, 2025
# $ module list
# Currently Loaded Modules:
#   1) craype-x86-milan                                5) PrgEnv-gnu/8.5.0      9) craype/2.7.32           13) cudatoolkit/12.4       17) darshan/default
#   2) libfabric/1.20.1                                6) cray-dsmml/0.3.0     10) gcc-native/13.2         14) craype-accel-nvidia80
#   3) craype-network-ofi                              7) cray-libsci/24.07.0  11) perftools-base/24.07.0  15) gpu/1.0
#   4) xpmem/2.9.6-1.1_20240510205610__g087dc11fc19d   8) cray-mpich/8.1.30    12) cpe/24.07               16) sqs/2.0

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

