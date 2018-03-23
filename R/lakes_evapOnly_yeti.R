.libPaths('/cxfs/projects/usgs/water/owi/booth-lakes/rLibs')
library(mda.lakes)
library(glmtools)
library(dplyr)
library(tools)
library(data.table)


run_lake_evap <- function(task_id_if_NA, glm_output = TRUE) {
#run model for all driver files, save evaporation 

#need to loop over drivers, some kind of cross-ref scheme
taskID <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID', 'NA')) #from yeti environment
if(is.na(taskID)) {
	taskID <- task_id_if_NA
	warning("changing task ID to ", taskID, " based on user arg")
}

message(taskID)

crossWalk <- fread('/cxfs/projects/usgs/water/owi/booth-lakes/siteInputs4_1_list.csv')
rowToUse <- crossWalk[taskID,]
rowToUse$WBIC <- paste("WBIC", rowToUse$WBIC, sep = "_")
nhdID <- rowToUse$NHD

#make sure there is z max available
zmax <- get_zmax(nhdID)
stopifnot(is.finite(zmax))

fileToUse <- file.path("/cxfs/projects/usgs/water/owi/booth-lakes/siteInputs_rain_meters", paste0(rowToUse$WBIC, ".csv"))
message(fileToUse)

localScratch <- Sys.getenv('LOCAL_SCRATCH', unset="out")
folderPath <- file.path(localScratch, rowToUse$WBIC)
message(folderPath)
dir.create(folderPath, recursive = TRUE)
baseNML <- populate_base_lake_nml(site_id = nhdID, driver = fileToUse,
                                  kd = get_kd_avg(nhdID, default.if.null = TRUE)$kd_avg)

#set num layers based on depth
min_thick <- get_nml_value(baseNML, arg_name = "min_layer_thick")                                                                 
max_depth <- get_nml_value(baseNML, arg_name = "lake_depth")
message(max_depth, " max depth")
max_layers <- ceiling((max_depth/min_thick) * 1.1)

baseNML <- set_nml(baseNML, 'max_layers', max_layers)
message(max_layers)

baseNML <- set_nml(baseNML, 'start', '1948-01-01 00:00:00')
baseNML <- set_nml(baseNML, 'stop', '2015-12-31 00:00:00')
baseNML <- set_nml(baseNML, 'nsave', 1)
baseNML <- set_nml(baseNML, 'dt', 3600)
write_nml(baseNML, file.path(folderPath, "glm2.nml"))
run_glm(sim_folder = folderPath, verbose = glm_output)
evap <- get_evaporation(file.path(folderPath, 'output.nc'))
#summarize evap to daily
#currently only used to check num days
#TODO: do time zone conversion here, so summarize_evap script can be folded in 
evap_daily <- evap %>% mutate(date = as.Date(DateTime)) %>% group_by(date) %>% summarize(daily_evap = sum(`evaporation(mm/d)`))

start <- get_nml_value(baseNML, 'start')
end <- get_nml_value(baseNML, 'stop')
expected_days <- as.Date(end) - as.Date(start)

if(nrow(evap_daily) < expected_days) {
	stop("less than 24836 evap values")
}
 
fwrite(x = evap, file = file.path(folderPath, paste(rowToUse$WBIC,'evap.csv', sep = "_")))

message(paste("finished", nhdID))
}
