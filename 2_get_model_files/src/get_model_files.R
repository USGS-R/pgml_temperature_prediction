#download driver data and cache the file on s3
#since this is its own file, needs to be its own remake target
#outside of populate_base_lake_nml
get_post_driver_file <- function(outind, nhd) {
  outfile <- as_data_file(outind)
  temp_path <- get_driver_path(nhd)
  file.copy(from = temp_path, to = outfile)
  s3_put(remote_ind = outind, local_source = outfile)
}

get_lake_base_nml <- function(nhd, glm_out) {
  nml <- populate_base_lake_nml(site_id = nhd, 
                                driver = file.path("2_setup_models/meteo",
                                                   paste0(nhd, "_driver.csv")))
  write_nml(glm_nml = nml, file = glm_out)
}