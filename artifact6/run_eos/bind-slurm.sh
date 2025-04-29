#!/bin/bash 

# check for various flags

if [ -z $MACHINE ]
then
  echo "MACHINE unset, exiting..."
  exit
fi

if [ -z $NGPU ]
then
  echo "NGPU unset, exiting..."
  exit
fi

if [ -z $NIB ]
then
  echo "NIB unset, exiting..."
  exit
fi

# This is the list of GPUs we have
export GPUS=(0 1 2 3 4 5 6 7)

  # This is the list of NICs we should use for each GPU
  # e.g., associate GPU0,1 with MLX0, GPU2,3 with MLX1, GPU4,5 with MLX2 and GPU6,7 with MLX3
  NICS=(mlx5_0 mlx5_3 mlx5_4 mlx5_5 mlx5_6 mlx5_9 mlx5_10 mlx5_11)

  # This is the list of CPU cores we should use for each process
  # e.g., 2x56 core CPUs split into 4 threads per process with correct NUMA assignment

  #CPUS=(1-4 5-8 10-13 15-18 21-24 25-28 30-33 35-38)
  CPUS=(0 0 0 0 1 1 1 1)

  # Number of physical CPU cores per GPU
  if [ -z "$OMP_NUM_THREADS" ]
  then
    export OMP_NUM_THREADS=12
  fi

# set the reorder for various numbers of GPUs
if [[ $NGPU -eq 8 ]]
then
  REORDER=(0 1 2 3 4 5 6 7)
  NREORDER=(0 1 2 3 4 5 6 7)
elif [[ $NGPU -eq 4 ]]
then
  if [[ $NIB -eq 4 ]]
  then
    REORDER=(0 2 4 6 1 3 5 7)
    NREORDER=(0 2 4 6 1 3 5 7)
  elif [[ $NIB -eq 2 ]]
  then
    REORDER=(0 1 4 5 2 3 6 7)
    NREORDER=(0 0 4 4 2 2 6 6)
  elif [[ $NIB -eq 1 ]]
  then
    REORDER=(0 1 2 3 4 5 6 7)
    NREORDER=(0 0 0 0 2 2 2 2)
  else
    echo "Invalid number of NICs $NIC , exiting..."
    exit
  fi
elif [[ $NGPU -eq 3 ]]
then
  REORDER=(0 2 4 6 1 3 5 7)
  if [[ $NIB -eq 3 ]]
  then
    NREORDER=(0 2 4 6 1 3 5 7)
  elif [[ $NIB -eq 1 ]]
  then
    NREORDER=(0 0 0 0 7 7 7 7)
  else
    echo "Invalid number of NICs $NIC , exiting..."
    exit
  fi
elif [[ $NGPU -eq 2 ]]
then
  REORDER=(0 4 1 5 2 3 6 7)
  if [[ $NIB -eq 2 ]]
  then
    NREORDER=(0 4 1 5 2 3 6 7)
  elif [[ $NIB -eq 1 ]]
  then
    NREORDER=(0 0 4 5 2 3 6 7)
  else
    echo "Invalid number of NICs $NIC , exiting..."
    exit
  fi
elif [[ $NGPU -eq 1 ]]
then
  REORDER=(0 1 4 5 2 3 6 7)
  if [[ $NIB -eq 1 ]]
  then
    NREORDER=(0 1 4 5 2 3 6 7)
  else
    echo "Invalid number of NICs $NIC , exiting..."
    exit
  fi
else
  echo "Invalid number of GPUs $NGPU , exiting..."
  exit
fi

# this is the order we want the GPUs to be assigned in (e.g. for NVLink connectivity)# now given the REORDER array, we set CUDA_VISIBLE_DEVICES, NIC_REORDER and CPU_REORDER to for this mapping 
export CUDA_VISIBLE_DEVICES="${GPUS[${REORDER[0]}]},${GPUS[${REORDER[1]}]},${GPUS[${REORDER[2]}]},${GPUS[${REORDER[3]}]},${GPUS[${REORDER[4]}]},${GPUS[${REORDER[5]}]},${GPUS[${REORDER[6]}]},${GPUS[${REORDER[7]}]}" 
NIC_REORDER=(${NICS[${NREORDER[0]}]} ${NICS[${NREORDER[1]}]} ${NICS[${NREORDER[2]}]} ${NICS[${NREORDER[3]}]} ${NICS[${NREORDER[4]}]} ${NICS[${NREORDER[5]}]} ${NICS[${NREORDER[6]}]} ${NICS[${NREORDER[7]}]}) 
CPU_REORDER=(${CPUS[${REORDER[0]}]} ${CPUS[${REORDER[1]}]} ${CPUS[${REORDER[2]}]} ${CPUS[${REORDER[3]}]} ${CPUS[${REORDER[4]}]} ${CPUS[${REORDER[5]}]} ${CPUS[${REORDER[6]}]} ${CPUS[${REORDER[7]}]}) 


# Have rank 0 print the list of nodes
if [[ "$SLURM_PROCID" == "0" ]]
then
  echo "***************** ALLOCATED NODE LIST *****************"
  echo " $SLURM_JOB_NODELIST"
  echo "*******************************************************"
fi

# Depending on the value of USE_NSYS, enable profiling on some nodes
PROFILING=0

if [[ "$USE_NSYS" == "ONE_RANK" ]] && [[ "$SLURM_PROCID" == "0" ]]
then
  # only rank 0 profiles
  PROFILING=1
elif [[ "$USE_NSYS" == "ONE_RANK_PER_NODE" ]] && [[ "$SLURM_LOCALID" == "0" ]]
then
  # only one rank per node profiles
  PROFILING=1
elif [[ "$USE_NSYS" == "ALL" ]]
then
  # everyone profiles
  PROFILING=1
elif [[ "$USE_NSYS" != "NO" ]] && [[ "$SLURM_PROCID" == "0" ]]
then
  # if USE_NSYS is unset or has some random value, print a warning
  echo 'FYI: USE_NSYS is unset or has a random value, not profiling. Appropriate values are "NO", "ONE_RANK", "ONE_RANK_PER_NODE", and "ALL"'
fi

if [[ "$USE_NSYS" == "ONE_RANK" ]] || [[ "$USE_NSYS" == "ONE_RANK_PER_NODE" ]]
then
  # Needed to enable profiling only a subset of MPI ranks
  export NSYS_MPI_STORE_TEAMS_PER_RANK=1
fi

NSYSSTR=""
if [[ $PROFILING -eq 1 ]]
then
  NSYSSTR="nsys profile --trace=cuda,nvtx,mpi,ucx --force-overwrite=true --output=trace-lammps-${RUNSTRING}-rank${SLURM_PROCID}-J${SLURM_JOB_ID} "
fi

if [ "$#" -eq 0 ]
then
  APP="$EXE $ARGS"
else
  APP="$@"
fi

lrank=$OMPI_COMM_WORLD_LOCAL_RANK
if [ -z "$lrank" ]
then
  lrank=$SLURM_LOCALID
fi

export UCX_NET_DEVICES="${NIC_REORDER[lrank]}:1"
export NVSHMEM_HCA_LIST="${NIC_REORDER[lrank]}:1"
export OMPI_MCA_btl_openib_if_include=${NIC_REORDER[lrank]}

$NSYSSTR numactl --cpunodebind=${CPU_REORDER[$lrank]} --membind=${CPU_REORDER[$lrank]} $APP


