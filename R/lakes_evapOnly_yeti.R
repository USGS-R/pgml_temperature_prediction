.libPaths('/cxfs/projects/usgs/water/owi/booth-lakes/rLibs')
library(mda.lakes)
library(glmtools)
library(dplyr)
library(tools)
library(data.table)


run_lake_evap <- function(task_id_if_NA) {
#run model for all driver files, save evaporation 

#need to loop over drivers, some kind of cross-ref scheme
taskID <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID', 'NA')) #from yeti environment
if(is.na(taskID)) {
	taskID <- task_id_if_NA
	warning("changing task ID to ", taskID, " based on user arg")
}

message(taskID)

crossWalk <- fread('siteInputs4_1_list.csv')
rowToUse <- crossWalk[taskID,]
rowToUse$WBIC <- paste("WBIC", rowToUse$WBIC, sep = "_")
nhdID <- rowToUse$NHD
fileToUse <- file.path("../../siteInputs4_1", paste0(rowToUse$WBIC, ".csv"))
message(fileToUse)

folderPath <- file.path("out", rowToUse$WBIC)
message(folderPath)
dir.create(folderPath, recursive = TRUE)
baseNML <- populate_base_lake_nml(site_id = nhdID, driver = fileToUse,
                                  kd = get_kd_avg(nhdID, default.if.null = TRUE)$kd_avg)

#set num layers based on depth
min_thick <- get_nml_value(baseNML, arg_name = "min_layer_thick")                                                                 
max_depth <- get_nml_value(baseNML, arg_name = "lake_depth")
message(max_depth, " max depth")
max_layers <- max(ceiling((max_depth/min_thick) * 1.1), 200)

baseNML <- set_nml(baseNML, 'max_layers', max_layers)
message(max_layers)

baseNML <- set_nml(baseNML, 'start', '1948-01-01 00:00:00')
baseNML <- set_nml(baseNML, 'stop', '2015-12-31 00:00:00')
baseNML <- set_nml(baseNML, 'nsave', 1)
baseNML <- set_nml(baseNML, 'dt', 3600)
write_nml(baseNML, file.path(folderPath, "glm2.nml"))
run_glm(sim_folder = folderPath)
evap <- get_evaporation(file.path(folderPath, 'output.nc'))
#TODO: summarize evap to daily
fwrite(x = evap, file = file.path(folderPath, paste(rowToUse$WBIC,'evap.csv', sep = "_")))
#TODO: check if evap exists, isn't empty, has full date range

message(paste("finished", nhdID))
}
