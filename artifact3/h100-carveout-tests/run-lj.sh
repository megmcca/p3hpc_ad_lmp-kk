
mpirun -np 1 --bind-to core ./lmp -k on g 1 -sf kk -pk kokkos \
  neigh full neigh/qeq full newton off comm device pair/only off gpu/aware on \
  -v x 40 -v y 80 -v z 80 -v t 1000 -in in.lj.gpu.steps -nocite -log none
