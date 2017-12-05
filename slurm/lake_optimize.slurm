#!/bin/bash
#SBATCH --job-name=mendota2     # name that you chose
#SBATCH -p UV              # the partition you want to use, for this case prod is best
#SBATCH -A cida                 # your account
#SBATCH -o shellLog/slurm-%A_%a.out
#SBATCH --time=04:00:00        # time at which the process will be cancelled if unfinished
#SBATCH --mail-type=ALL
#SBATCH --mail-user=wwatkins@usgs.gov
#SBATCH --export=ALL
#SBATCH --array=4-4261          # process IDs 
#SBATCH -n 1
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
#TODO: pass in offset arg to r script; Now works, just need to add logic
#TODO: be smarter about lake id in file name  do we still need to write to local scratch with less output?
module load tools/netcdf-4.3.2-gnu
mkdir rlogs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}
R CMD BATCH --no-restore --no-save '--args '$1'' R/lake_optimize.R rlogs/${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}/rlog.Rlog 
	
cp -r ${LOCAL_SCRATCH}/WBIC_805400_optim_"$task_id_adj" /lustre/projects/water/owi/booth-lakes/out
sync
