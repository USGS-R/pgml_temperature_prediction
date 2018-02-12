#!/bin/bash
#SBATCH --job-name=calc_rmse_ml     # name that you chose
#SBATCH -p normal             # the partition you want to use, for this case prod is best
#SBATCH -A cida                 # your account
#SBATCH -o shellLog/slurm-%A_%a.out
#SBATCH --time=02:00:00        # time at which the process will be cancelled if unfinished
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH --array=2397-5000
#SBATCH -n 1

module load tools/netcdf-4.3.2-gnu
#TODO: pass in offset arg - don't want to hard code things in script - cant use script w diff args while job is running
#would be easier if scripts were functions... don't need goofy arg parsing
#and switch to Rscript -e
mkdir rlogs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
Rscript --verbose -e 'source("R/calculate_rmse.R"); calculate_rmse(offset=FALSE, "../mille_lacs_optimize_all_out", "DOW_48000200", "../mille_lacs_large_training_obs.csv", "params_with_rmse_large_train.csv")' > rlogs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}/rlog.Rlog 2>%1

