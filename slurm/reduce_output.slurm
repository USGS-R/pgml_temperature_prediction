#!/bin/bash
#SBATCH --job-name=reduce_output     # name that you chose
#SBATCH -p normal              # the partition you want to use, for this case prod is best
#SBATCH -A cida                 # your account
#SBATCH -o shellLog/slurm-%A_%a.out
#SBATCH --time=01:00:00        # time at which the process will be cancelled if unfinished
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH --array=1-4261         # process IDs 

offset_task_id=${1}
echo $offset_task_id
if [[ $offset_task_id == "offset_yes" ]]
then
	task_id_adj=$(echo ${SLURM_ARRAY_TASK_ID} + 5000 | bc)
	job_offset=5000
elif [[ $offset_task_id == "offset_no" ]] 
then
	task_id_adj=$(echo ${SLURM_ARRAY_TASK_ID})
else 
	echo "invalid argument: use offset_yes or offset_no"
	exit 1 #terminate with error
fi

dir=$(echo ../out/WBIC_805400_optim_"$task_id_adj")
module load tools/netcdf-4.3.2-gnu
module load tools/nco-4.4.4-gnu
ncks -v z,lon,lat,NS,temp "$dir"/output.nc "$dir"/output_reduced.nc
rm "$dir"/output.nc	
