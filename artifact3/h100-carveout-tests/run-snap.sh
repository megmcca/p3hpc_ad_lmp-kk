
mpirun -np 1 --bind-to core ./lmp  -k on g 1 -sf kk -pk kokkos \
  neigh half neigh/qeq full newton on comm device pair/only off gpu/aware on \
  -v x 80 -v y 80 -v z 80 -v t 200 -in in.snap.steps -nocite -log none

