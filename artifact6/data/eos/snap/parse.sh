mkdir -p parsed
for g in 4 8
do
  for c in 16K 64K 256K 1M
  do
    echo "" > parsed/snap-${c}-${g}gpus.dat
    for n in 1 2 4 8 16 32 64 128
    do
      awk -v g="$g" '/Loop time/ {natoms=$12; nprocs=$6; nnodes=nprocs/g} /Performance/ {speed=$6; perf=speed*natoms/nnodes/1e6; print nnodes " " natoms " " speed " " perf;}' \
        bench-snap-${c}-${n}node-${g}gpu-${g}ib-J*out
    done >> parsed/snap-${c}-${g}gpus.dat
  done
done

