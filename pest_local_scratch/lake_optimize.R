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
############################
yeti=FALSE
if(grepl(x = Sys.info()["nodename"], pattern = "cr.usgs.gov")) { #are we on yeti?
  .libPaths(libPath)
  yeti=TRUE
}

#folderPath <- paste(stateID, "optim", taskID, sep ="_")
folderPath <- "test"
dir.create(folderPath, recursive = TRUE)

#check that meteo file matches nhd id
#assert_that(grepl(x = get_nml_value(baseNML, arg_name = "meteo_fl"), pattern = nhdID))
run_glm(sim_folder = folderPath)
#TODO: rewrite output to ascii
source('resample.R')
resample(field_file = "/lustre/projects/water/owi/booth-lakes/pgml_temperature_prediction/obs/mendota/mendota_combined.csv", nc_file = "test/output.nc", out_file = "test/temp.csv")
message(paste("finished"))
