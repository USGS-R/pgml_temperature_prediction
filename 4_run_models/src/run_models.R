setup_model_dir <- function(nhd_id, nml_file) {
  #create model directory, change nml values
  #get things from the global config file
  sim_directory <- file.path('4_run_models/out', nhd_id)
  dir.create(sim_directory, showWarnings = FALSE)
  baseNML <- read_nml(nml_file)
  base_cfg <- yaml::read_yaml('lib/cfg/base_model_config.yml')
  nml_params <- base_cfg$nml_params
  nml_params$meteo_fl <- file.path('../../../2_setup_models/meteo', paste(nhd_id, "driver.csv",
                                                                          sep = "_"))
  for(param in names(nml_params)) {
    baseNML <- set_nml(glm_nml = baseNML, arg_name = param, 
                       arg_val = nml_params[[param]])
  }
  write_nml(baseNML, file.path(sim_directory, "glm2.nml"))
}


run_model <- function(nhd_id) {
  #
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
