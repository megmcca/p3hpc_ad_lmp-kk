
# LJ
echo -n "PairComputeLJCut "
grep "PairLJCutKokkos" cupti-lj.out | grep -v "ParallelReduce" | awk ' { x += $7; } END { print x; } '

# ComputeUiLarge
echo -n "ComputeUi "
grep "ComputeUiLarge" cupti-snap.out | grep -v "ParallelReduce" | awk ' { x += $7; } END { print x; } '

# ComputeYi
echo -n "ComputeYi "
grep "ComputeYi" cupti-snap.out | grep -v "With" | grep -v "From" | awk ' { x += $7; } END { print x; } '

# ComputeFusedDeidrjAllLarge
echo -n "ComputeFusedDeidrjAllLarge "
grep "ComputeFusedDeidrjAllLarge" cupti-snap.out | grep -v "ParallelReduce" | awk ' { x += $7; } END { print x; } '

# HNS SpMv
echo -n "SparseMatvec2_Full "
grep "TagQEqSparseMatvec2_Full" cupti-hns.out | grep -v "ParallelReduce" | awk ' { x += $7; } END { print x; } '

# ComputeLjCoulomb
echo -n "ComputeLJCoulomb "
grep "ComputeLJCoulomb" cupti-hns.out | grep -v "ParallelReduce" | awk ' { x += $7; } END { print x; } '

# ComputeH
echo -n "ComputeHFunctor "
grep "ComputeHFunctor" cupti-hns.out | grep -v "ParallelReduce" | awk ' { x += $7; } END { print x; } '

# Build lists preview
echo -n "BuildListsHalfPreview<2> "
grep "TagPairReaxBuildListsHalfPreview" cupti-hns.out | grep -v "ParallelReduce" | awk ' { x += $7; } END { print x; } '
