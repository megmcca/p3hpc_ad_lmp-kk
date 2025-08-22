
mpirun -np 1 --bind-to core ./lmp -k on g 1 -sf kk -pk kokkos \
  neigh half neigh/qeq full newton on comm device pair/only off gpu/aware on \
  -v x 16 -v y 16 -v z 12 -v t 100 -in in.hns.kokkos_gpu.steps -nocite -log none

