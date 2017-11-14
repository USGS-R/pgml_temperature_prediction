library(mda.lakes)
library(glmtools)
library(dplyr)
library(tools)
# Start the clock!
ptm <- proc.time()

#########################################
.libPaths('/lustre/projects/water/owi/booth-lakes/rLibs')
nhdID <- "nhd_2360642"
wbicID <- "DOW_48000200"
param_df <- read.csv('param_df_02.csv')
obs_file <- 'obs_filt.tsv'

############################

taskID <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID', unset=1)) #from yeti environment; set to 1 if doesnt exist (i.e. on a local VM)

#see if an argument was passed in to offset the taskID
suppliedArgs <- commandArgs(trailingOnly=TRUE)
if(length(suppliedArgs) > 0 && suppliedArgs[1] == "offset_yes") {
	taskID <- taskID + 5000
}

#run model with diff param combos for optimization 
message(taskID)
localScratch <- Sys.getenv('LOCAL_SCRATCH', unset="out") #write to diff directory if local

param_df_use <- param_df[taskID,]

outFolder <- paste(wbicID, "optim", taskID, sep ="_")
#folderPath <- file.path("out2", outFolder)
folderPath <- file.path(localScratch, outFolder)
message(folderPath)
dir.create(folderPath, recursive = TRUE)

#TODO: make reusable for different lakes - supply baseNML?
#Could set more things here explicitly, since only using one lake most things won't change
#might speed up populate_base_lake_nml?
baseNML <- read_nml('glm2_mille_lacs.nml')
baseNML <- set_nml(baseNML, 'cd', param_df_use$cd)
baseNML <- set_nml(baseNML, 'Kw', param_df_use$kw)
baseNML <- set_nml(baseNML, 'coef_mix_shear', param_df_use$coef_mix_shear)
baseNML <- set_nml(baseNML, 'start', '1980-04-01 00:00:00')
baseNML <- set_nml(baseNML, 'stop', '2016-10-01 00:00:00')
baseNML <- set_nml(baseNML, 'dt', 3600)
baseNML <- set_nml(baseNML, 'timezone', -6)
baseNML <- set_nml(baseNML, 'nsave', 24)
baseNML <- set_nml(baseNML, 'out_dir', folderPath)

write_nml(baseNML, file.path(folderPath,  "glm2.nml"))
run_glm(sim_folder = folderPath)
#do rmse
nc_file <- file.path(folderPath, 'output.nc')
temp_rmse <- compare_to_field(nc_file, obs_file, 
                              metric = 'water.temperature', as_value = FALSE, 
                              method = 'interp', precision = 'days')
#store it
param_df_use$rmse <- temp_rmse
write.csv(x = param_df_use, file = file.path(folderPath, "params_with_rmse.csv"), row.names = FALSE)
print(proc.time() - ptm) #print time

message(paste("finished", taskID))
