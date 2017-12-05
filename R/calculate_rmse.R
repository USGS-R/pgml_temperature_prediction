#calculate rmses for existing model runs
#run as a batch job
.libPaths('/lustre/projects/water/owi/booth-lakes/rLibs')
library(glmtools)

calculate_rmse <- function(offset, parent_folder, id, obs_file, out_file) {
	#run model with diff param combos for optimization 
	taskID <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID', 'NA'))# + 5000 #from yeti environment
	if(offset) {
		taskID <- taskID + 5000
	}
	message(taskID)

	outFolder <- paste(id, "optim", taskID, sep ="_")
	folderPath <- file.path(parent_folder, outFolder)

	#read in param_df_used, replace rmse, write to new file
	nc_file <- file.path(folderPath, 'output_reduced.nc')
	temp_rmse <- compare_to_field(nc_file, obs_file, 
				      metric = 'water.temperature', as_value = FALSE, 
				      method = 'interp', precision = 'days')
	param_df_use <- read.csv(file.path(folderPath, 'params_with_rmse.csv'))
	param_df_use$rmse <- temp_rmse
	write.csv(x = param_df_use, file = file.path(folderPath, out_file), row.names = FALSE)
}

