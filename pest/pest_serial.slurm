#!/bin/bash
#SBATCH --job-name=pest_serial     # name that you chose
#SBATCH -p UV              # the partition you want to use, for this case prod is best
#SBATCH -A cida                 # your account
#SBATCH -o shellLog/slurm-%A_%a.out
#SBATCH --time=04:00:00        # time at which the process will be cancelled if unfinished
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH -n 1
cd ${LOCAL_SCRATCH}
cp -r /lustre/projects/water/owi/booth-lakes/pgml_temperature_prediction/pest/* .
module load tools/netcdf-4.3.2-gnu
module load tools/pest-13.5-gnu
pest mendota 
mv ./* /lustre/projects/water/owi/booth-lakes/pgml_temperature_prediction/pest_all_log

