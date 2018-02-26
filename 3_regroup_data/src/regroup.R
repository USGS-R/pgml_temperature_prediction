#universal temp obs cleaning
clean_universal <- function(df, base_model_cfg, max_depth) {
  cfg <- read_yaml(base_model_cfg)
  df_clean <- df %>% filter(temp < cfg$max_temp & Depth < max_depth & 
                       (DateTime > as.Date(cfg$nml_params$start) & DateTime < as.Date(cfg$nml_params$stop))) %>% 
    filter(!is.na(temp) & !is.na(Depth) & !is.na(DateTime))
  return(df_clean)
}

#filter out data for this site from files
#then get WQP data
#do universal cleaning + depth filtering based on lake nml max depth
#dots are cleaned files to look in for this site
regroup_data <- function(nhd_id, state_src, state_id, wqp_file, nml, ...) {
  cleaned_files <- lapply(c(...), sc_retrieve, remake_file = "1_data_s3_assimilate.yml")
  wqp_file <- sc_retrieve(wqp_file, remake_file = "1_data_wqp.yml")
  site_data <- data.frame()
  for(f in cleaned_files) {
    whole_cleaned_file <- readRDS(f)
    filtered <- filter_(whole_cleaned_file, paste(state_src, "%in% state_id"))
    site_data <- bind_rows(site_data, filtered)
  }
  wqp_data <- readRDS(wqp_file)
  wqp_data <- rename(wqp_data, DateTime = Date, temp = wtemp, 
                     Depth = depth)
  #deal with duplicates; keep the non-WQP value
  site_data <- distinct(bind_rows(site_data, wqp_data), DateTime, Depth, 
                        .keep_all = TRUE) %>% mutate(nhd_id = nhd_id)
  #TODO: distinct is missing some?  manually remove what anyDuplicated catches?
  #try a data.table function?
  
  while( anyDuplicated(site_data[c("DateTime", "Depth")]) != 0){
    duplicate <- anyDuplicated(site_data[c("DateTime", "Depth")])
    site_data <- slice(site_data, -duplicate) 
  }
  assert_that(anyDuplicated(site_data[c("DateTime", "Depth")]) == 0)
  
  #get max depth for cleaning
  nml <- read_nml(nml)
  max_depth <- get_nml_value(nml, "lake_depth")
  cleaned <- clean_universal(site_data, "lib/cfg/base_model_config.yml",
                             max_depth)
  outfile <- paste0("3_regroup_data/out/", nhd_id, ".rds")
  saveRDS(object = cleaned, file = outfile)
  s3_put(remote_ind = as_ind_file(outfile), local_source =  outfile) 
}
