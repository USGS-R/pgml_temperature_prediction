#!/bin/bash
#SBATCH --job-name=lakes_evap     # name that you chose
#SBATCH -c 1                   # number of cores per task
#SBATCH -p normal              # the partition you want to use, for this case prod is best
#SBATCH -A cida                 # your account
#SBATCH --time=01:00:00        # time at which the process will be cancelled if unfinished
#SBATCH -o logs/%A_%a.log  # sets output log file to array_job.log
#SBATCH -e logs/%A_%a.err  # sets error log file to array_job.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH --array=1-785          # process IDs 

module load tools/netcdf-4.3.2-gnu

R CMD BATCH --no-restore --no-save lakes_evapOnly_yeti.R logs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.Rlog
