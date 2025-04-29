## LAMMPS source is in /var/tmp/lammps
mkdir -p /var/tmp/lammps/build && \
  cd /var/tmp/lammps/build && \
  export NVCC_WRAPPER_DEFAULT_COMPILER="nvc++"
  cmake -D BUILD_SHARED_LIBS=OFF \
        -D CMAKE_INSTALL_PREFIX=/usr/local/lammps \
        -D LAMMPS_SIZES=bigbig \
        -D Kokkos_ARCH_HOPPER90=ON \
        -D Kokkos_ARCH_BDW=ON \
        -D CMAKE_BUILD_TYPE=Release \
        -D CMAKE_VERBOSE_MAKEFILE=ON \
        -D MPI_C_COMPILER=`which mpicc` \
        -D MPI_CXX_COMPILER=`which mpicxx` \
        -D BUILD_MPI=yes \
        -D FFT_KOKKOS=CUFFT \
        -D CMAKE_CXX_COMPILER=/var/tmp/lammps/lib/kokkos/bin/nvcc_wrapper \
        -D PKG_REAXFF=yes \
        -D PKG_ML-SNAP=yes \
        -D PKG_KOKKOS=yes \
        -D Kokkos_ENABLE_CUDA=yes \
        -D Kokkos_ENABLE_SERIAL=yes \
        -D Kokkos_ENABLE_IMPL_CUDA_MALLOC_ASYNC=OFF \
    /var/tmp/lammps/cmake && \
    cmake --build /var/tmp/lammps/build --target install -- -j

