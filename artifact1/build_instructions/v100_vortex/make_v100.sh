#!/bin/bash
# V100 machine (IBM Power 9)

cwd=$PWD
lammps=""   ### SET PATH TO LAMMPS DIRECTORY HERE, e.g. /home/user/myself/lammps

module purge
module load cuda/11.1.1
module load gcc/8.3.1
module load fftw/3.3.8

# May need to override NVCC default
#NVCC_WRAPPER_DEFAULT_COMPILER="nvc++"
export UCX_CUDA_COPY_ENABLE_FABRIC=no

#rm -rf lmp_*

cd ${lammps}/src
make clean-all

make yes-kokkos
make yes-manybody
make yes-reaxff
make yes-ml-snap

make -j36 ${lmp_exe}
ln -sf ${lammps}/src/lmp_${exename} .
cd $cwd


