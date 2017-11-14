#!/bin/bash
#SBATCH --job-name=calc_rmse     # name that you chose
#SBATCH -p normal              # the partition you want to use, for this case prod is best
#SBATCH -A cida                 # your account
#SBATCH -o shellLog/slurm-%A_%a.out
#SBATCH --time=00:30:00        # time at which the process will be cancelled if unfinished
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH --array=4446,4454,4457,4463        # process IDs 
#SBATCH -n 1


module load tools/netcdf-4.3.2-gnu
mkdir rlogs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
R CMD BATCH --no-restore --no-save calculate_rmse.R rlogs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}/rlog.Rlog

