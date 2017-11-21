#populate an nml, copy over driver file, save nml for reuse
#speed up mass model runs by not populating the base nml/downloading driver data repeatedly
library(mda.lakes)
library(glmtools)
setup_nml <- function(nhd_id, nml_name) {
  nml <- populate_base_lake_nml(site_id = nhd_id)
  meteo_file_path <- get_nml_value(nml, 'meteo_fl')
  new_meteo_path <- file.path("meteo", paste(nhd_id, 'driver.csv', sep = "_"))
  file.copy(from =meteo_file_path, to = new_meteo_path)
  nml <- set_nml(glm_nml = nml, arg_name = "meteo_fl", arg_val = file.path('../..', new_meteo_path))
  #be smart about setting max layers, to reduce amount of output
  min_thick <- get_nml_value(nml, arg_name = "min_layer_thick")
  max_depth <- get_nml_value(nml, arg_name = "lake_depth")
  max_layers <- ceiling(max_depth/min_thick * 1.1)
  nml <- set_nml(glm_nml = nml, arg_name = "max_layers", arg_val = max_layers)
  write_nml(glm_nml = nml, file = nml_name)
}

#create df of param search space
create_param_df <- function(nml.file, plus.minus.frac, n.steps, file.name) {
  nml <- read_nml(nml_file = nml.file)
  kw <- get_nml_value(nml, arg_name = "Kw")
  cd <- get_nml_value(nml, arg_name = "cd")
  coef_mix_shear <- get_nml_value(nml, arg_name = "coef_mix_shear")
  kw_seq <- get_param_seq(kw, plus.minus.frac, n.steps)
  cd_seq <- get_param_seq(cd, plus.minus.frac, n.steps)
  coef_mix_shear_seq <- get_param_seq(coef_mix_shear, plus.minus.frac, n.steps)
  df <- expand.grid(cd=cd_seq, kw=kw_seq, coef_mix_shear=coef_mix_shear_seq)
  write.csv(df, file = file.name, row.names = FALSE)
}

get_param_seq <- function(param.val, plus.minus.frac, n.steps) {
  seq(from = param.val - plus.minus.frac*param.val, 
      to = param.val + plus.minus.frac*param.val, 
      length.out = n.steps)
}