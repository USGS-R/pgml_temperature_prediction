#!/bin/bash
#SBATCH --job-name=booth_lakes_evap     # name that you chose
#SBATCH -c 1                   # number of cores per task
#SBATCH -p UV              # the partition you want to use, for this case prod is best
#SBATCH -A cida                 # your account
#SBATCH --time=1:00:00        # time at which the process will be cancelled if unfinished
#SBATCH -o logs/%A_%a.log  # sets output log file to array_job.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH --array=118,119,142,159,216,224,22,241,270,273,275,294,296,303,316,358,367,377,400,408,431,450,462,463,482,493,501,575,598,606,625,642,681,685,699,704,70,727,72,744,764,777,783,814,817,81,822,831,837,870,886,896,934%20          # process IDs 

module load tools/netcdf-4.3.2-gnu
module load tools/nco-4.4.4-gnu

Rscript --verbose -e  'source("pgml_temperature_prediction/R/lakes_evapOnly_yeti.R"); run_lake_evap(NA)' > logs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.Rlog 2>&1
#reduce size of netcdf output
#get WBIC by line matching task id
lineNumber=$((${SLURM_ARRAY_TASK_ID} + 1))
wbicNum=$(cat siteInputs4_1_list.csv | sed -n "$lineNumber"p | cut -d, -f1)
WBIC=$(echo ${LOCAL_SCRATCH}/"WBIC_"$wbicNum)
ncks -v time,evap,temp $WBIC/output.nc $WBIC/output_reduced.nc
rm $WBIC/output.nc 
cp -r $WBIC /cxfs/projects/usgs/water/owi/booth-lakes/out
