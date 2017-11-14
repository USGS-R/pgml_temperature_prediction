#calculate rmses for existing model runs
#run as a batch job
.libPaths('/lustre/projects/water/owi/booth-lakes/rLibs')
library(glmtools)
#run model with diff param combos for optimization 
taskID <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID', 'NA'))# + 5000 #from yeti environment
message(taskID)

wbicID <- "DOW_48000200"
outFolder <- paste(wbicID, "optim", taskID, sep ="_")
folderPath <- file.path("out", outFolder)

#read in param_df_used, replace rmse, write to new file
obs_file <- 'obs_small_training.tsv'
nc_file <- file.path(folderPath, 'output.nc')
temp_rmse <- compare_to_field(nc_file, obs_file, 
                              metric = 'water.temperature', as_value = FALSE, 
                              method = 'interp', precision = 'days')
param_df_use <- read.csv(file.path(folderPath, 'params_with_rmse.csv'))
param_df_use$rmse <- temp_rmse
write.csv(x = param_df_use, file = file.path(folderPath, "params_with_rmse_small_train.csv"), row.names = FALSE)


