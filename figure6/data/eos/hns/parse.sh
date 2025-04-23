mkdir -p parsed
for g in 4 8
do
  for c in 256K 1M 4M 16M
  do
    echo "" > parsed/reaxff-${c}-${g}gpus.dat
    for n in 1 2 4 8 16 32 64 128
    do
      awk -v g="$g" '/Loop time/ {natoms=$12; nprocs=$6; nnodes=nprocs/g} /Performance/ {speed=$6; perf=speed*natoms/nnodes/1e6; print nnodes " " natoms " " speed " " perf;}' \
        bench-reaxff-${c}-${n}node-${g}gpu-${g}ib-J*out
    done >> parsed/reaxff-${c}-${g}gpus.dat
  done
done

