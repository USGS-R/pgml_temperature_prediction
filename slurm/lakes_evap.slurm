#!/bin/bash
#SBATCH --job-name=booth_lakes_evap     # name that you chose
#SBATCH -c 1                   # number of cores per task
#SBATCH -p normal              # the partition you want to use, for this case prod is best
#SBATCH -A cida                 # your account
#SBATCH --time=01:00:00        # time at which the process will be cancelled if unfinished
#SBATCH -o logs/%A_%a.log  # sets output log file to array_job.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH --array=51,148,401,598

module load tools/netcdf-4.3.2-gnu
module load tools/nco-4.4.4-gnu

Rscript --verbose -e  'source("pgml_temperature_prediction/R/lakes_evapOnly_yeti.R"); run_lake_evap(NA)' > logs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.Rlog 2>&1
#reduce size of netcdf output
#get WBIC by line matching task id
lineNumber=$((${SLURM_ARRAY_TASK_ID} + 1))
wbicNum=$(cat siteInputs4_1_list.csv | sed -n "$lineNumber"p | cut -d, -f1)
WBIC=$(echo ${LOCAL_SCRATCH}/"WBIC_"$wbicNum)
ncks -v time,evap,temp $WBIC/output.nc $WBIC/output_reduced.nc
nccopy -k4 -d9 $WBIC/output_reduced.nc $WBIC/output_reduced_deflated.nc
rm $WBIC/output.nc 
rm $WBIC/output_reduced.nc
cp -r $WBIC /cxfs/projects/usgs/water/owi/booth-lakes/out
