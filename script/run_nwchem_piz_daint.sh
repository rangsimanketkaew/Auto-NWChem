#!/bin/bash -l

#SBATCH --export=ALL
#SBATCH --error=slurm.%J.err
#SBATCH --output=slurm.%J.out
#SBATCH --exclusive
#SBATCH --account=XXXXXXXXXXXXX
#SBATCH --job-name="nwchem_test"
#SBATCH --time=24:00:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --partition=normal
#SBATCH --constraint=mc
#SBATCH --hint=nomultithread

###############################################################
# Execute, for example, the following command to run NWChem job
# sbatch -J INPUT.inp run.sh
###############################################################

EXE="path/to/bin/LINUX64/nwchem"

PROJECT=${SLURM_JOB_NAME}
PROJECT=$(basename $PROJECT .inp)

module swap PrgEnv-cray PrgEnv-intel
module load daint-mc
module add craype-hugepages64M

INP="${PROJECT}.inp"
OUT="${PROJECT}.out"

echo ' --------------------------------------------------------------'
echo ' |        --- RUNNING JOB ---                                 |'
echo ' --------------------------------------------------------------'

echo "${SLURM_NTASK_PER_CORE}"

# stop if maximum number of processes per node is exceeded
if [ ${SLURM_NTASKS_PER_CORE} -eq 1 ]; then
  if [ $((${SLURM_NTASKS_PER_NODE} * ${SLURM_CPUS_PER_TASK})) -gt 36 ]; then
     echo 'Number of processes per node is too large! (STOPPING)'
     exit 1
  fi
else
  if [ $((${SLURM_NTASKS_PER_NODE} * ${SLURM_CPUS_PER_TASK})) -gt 72 ]; then
     echo 'Number of processes per node is too large! (STOPPING)'
     exit 1
  fi
fi

# build SRUN command
srun_options="\
  --exclusive \
  --bcast=/tmp/${USER} \
  --nodes=${SLURM_NNODES} \
  --ntasks=${SLURM_NTASKS} \
  --ntasks-per-node=${SLURM_NTASKS_PER_NODE} \
  --cpus-per-task=${SLURM_CPUS_PER_TASK} \
  --ntasks-per-core=${SLURM_NTASKS_PER_CORE}"

if [ ${SLURM_CPUS_PER_TASK} -gt 1 ]; then
  export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
else
  export OMP_NUM_THREADS=1
fi

srun_command="/usr/bin/time -p srun ${srun_options}"

# print some informations
nnodes=${SLURM_NNODES}
nranks_per_node=${SLURM_NTASKS_PER_NODE}
nranks=$((${nranks_per_node} * ${nnodes}))
nthreads_per_rank=${SLURM_CPUS_PER_TASK}
nthreads=$((${nthreads_per_rank} * ${nranks}))
echo "SRUN-command: ${srun_command}"
echo "JOB-config:   nodes=${nnodes} ranks/nodes=${nranks_per_node} threads/rank=${nthreads_per_rank} total_task=$((${SLURM_NNODES} * ${SLURM_NTASKS_PER_NODE}))"
echo "JOB-total:    nodes=${nnodes} ranks=${nranks} threads=${nthreads}"
echo ""

# run the program
${srun_command} ${EXE} ${INP} > ${OUT}

echo ' --------------------------------------------------------------'
echo ' |        --- DONE ---                                        |'
echo ' --------------------------------------------------------------'

exit 0
