#!/bin/bash
#SBATCH --job-name=ppest_mendota     # name that you chose
#SBATCH -p UV              # the partition you want to use, options are normal, large (>240 cores), and UV
#SBATCH -A cida                 # your account
#SBATCH -o shellLog/slurm-%j.out
#SBATCH --time=01:00:00        # time at which the process will be cancelled if unfinished
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH -n 8

module load beopest/beopest-13.6-intel intel/psxe-2017u2 tools/netcdf-4.3.2-gnu 

CASE_NAME="mendota"

MASTER_TEMPLATE="pMaster"
MASTER_DIR="${MASTER_TEMPLATE}_${SLURM_JOBID}"

WORKER_TEMPLATE="${MASTER_TEMPLATE}"
WORKER_DIR="${LOCAL_SCRATCH}/pWorker"

# This command sets up the worker remote directories. It
# creates a directory for each worker with the worker id 
# appended to the directory name
srun ./setup_workers.sh ${WORKER_TEMPLATE} ${WORKER_DIR}

# Ensure multiple runs are possible and saving off the 
# results of the master
cp -r ${MASTER_TEMPLATE} ${MASTER_DIR}
cd ${MASTER_DIR}

# Execute the run
srun --mpi=pmi2 ppest ${CASE_NAME}.pst /L /M /P1 ${WORKER_DIR}

