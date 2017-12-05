library(mda.lakes)
library(glmtools)
library(dplyr)
library(tools)
library(assertthat)
# Start the clock!
ptm <- proc.time()

#########################################
libPath <- '/lustre/projects/water/owi/booth-lakes/rLibs'
nhdID <- "nhd_13293262"
stateID <- "WBIC_805400"
param_df <- read.csv('param_search/mendota_params.csv')
obs_file <- 'obs/mendota/training.csv'
base_nml_file <- 'nml/glm2_mendota.nml'
############################
yeti=FALSE
if(grepl(x = Sys.info()["nodename"], pattern = "cr.usgs.gov")) { #are we on yeti?
  .libPaths(libPath)
  yeti=TRUE
}
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

outFolder <- paste(stateID, "optim", taskID, sep ="_")
#folderPath <- file.path("out2", outFolder)
folderPath <- file.path(localScratch, outFolder)
message(folderPath)
dir.create(folderPath, recursive = TRUE)

#TODO: make reusable for different lakes - supply baseNML?
#Could set more things here explicitly, since only using one lake most things won't change
#might speed up populate_base_lake_nml?

#check that meteo file matches nhd id
assert_that(grepl(x = get_nml_value(baseNML, arg_name = "meteo_fl"), pattern = nhdID))

run_glm(sim_folder = folderPath)

message(paste("finished", taskID))
