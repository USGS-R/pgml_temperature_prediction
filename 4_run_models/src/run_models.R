setup_model_dir <- function()





run_model <- function(nhd_id) {
  #create model directory, change nml values
  #get things from the global config file
  sim_directory <- file.path('4_run_models/out', nhd_id)
  dir.create(sim_directory)
  #todo use config params                                                                                                                                                        
  base_cfg <- yaml::read_yaml('lib/cfg/base_model_config.yml')
  baseNML <- read_nml(file.path('2_setup_models/nml',
                                paste0("glm2_", nhd_id, ".nml")))
  baseNML <- set_nml(baseNML, 'start', '1980-04-01 00:00:00')
  baseNML <- set_nml(baseNML, 'stop', '2016-01-01 00:00:00')
  baseNML <- set_nml(baseNML, 'dt', 3600)
  baseNML <- set_nml(baseNML, 'timezone', -6)
  baseNML <- set_nml(baseNML, 'nsave', 24)
  meteo_from_nml <- file.path('../../../2_setup_models/meteo', paste(nhd_id, "driver.csv",
                                                                     sep = "_"))
  baseNML <- set_nml(baseNML, 'meteo_fl', meteo_from_nml)
  write_nml(baseNML, file.path(sim_directory, "glm2.nml"))
  run_glm(sim_folder = sim_directory)
  
  #only accepts ascii files right now
  obs <- readRDS(file.path('3_assimilate_data/out',
                           paste0(nhd_id, '.rds')))
  ascii_field <- file.path(sim_directory, paste0(nhd_id, ".csv"))
  data.table::fwrite(obs, file = ascii_field)
  source('R/resample.R')
  meteo_from_root <- gsub(pattern = "../../../", replacement = "", x = meteo_from_nml)
  nc_path <- file.path(sim_directory, "output.nc")
  resampled <- resample(nc_file = nc_path,
                        field_file = ascii_field, meteo_file = meteo_from_root)
  data.table::fwrite(resampled, file = paste0(nhd_id, "_obs_drivers.csv"))
  
  depth <- get_nml_value(baseNML, "lake_depth")
  temps <- get_temp(file = nc_path, reference = "surface", z_out = seq(0, depth, by = 0.5))
  data.table::fwrite(temps, file = paste0(nhd_id, "_sampled_temps.csv"))
  message("done with ", nhd_id)
}
