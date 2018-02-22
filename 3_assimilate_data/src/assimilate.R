#universal temp obs cleaning
clean_universal <- function(df, base_model_cfg, max_depth) {
  cfg <- read_yaml(base_model_cfg)
  df_clean <- df %>% filter(temp < cfg$max_temp & Depth < max_depth & 
                       (DateTime > cfg$start_date & DateTime < cfg$end_date)) %>% 
    filter(!is.na(temp) & !is.na(Depth) & !is.na(DateTime))
  
}


#filter out data for this site from files
#then get WQP data
#do universal cleaning + depth filtering based on lake nml max depth
#dots are cleaned files to look in for this site
assimilate_data <- function(nhd_id, state_src, state_id, wqp_file, ...) {
  cleaned_files <- lapply(c(...), sc_retrieve, remake_file = "1_data_s3_cleaned.yml")
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
  nml <- read_nml(nml_file = file.path("2_setup_models/nml", 
                                       paste0("glm2_", nhd_id, ".nml")))
  max_depth <- get_nml_value(nml, "lake_depth")
  cleaned <- clean_universal(site_data, "lib/cfg/base_model_config.yml",
                             max_depth)
  outfile <- paste0("3_assimilate_data/out/", nhd_id, ".rds")
  saveRDS(object = cleaned, file = outfile)
  s3_put(remote_ind = as_ind_file(outfile), local_source =  outfile) 
}

summarize_assimilated <- function(...){
  files <- lapply(c(...), sc_retrieve, remake_file = "3_assimilate_data.yml")
  #load all the data
  data_list <- lapply(X = files, readRDS)
  all_data <- do.call(what = bind_rows, data_list)
  
  lake_info <- read.csv("lib/crosswalks/lakes_master.csv",
                      stringsAsFactors = FALSE) %>% 
                        mutate(facet_label = paste(Lake, site_id, sep=", "))
  all_data_n_obs <- all_data %>% group_by(nhd_id) %>% 
    count(nhd_id) %>% 
    ungroup() %>% 
    right_join(lake_info, by = c("nhd_id"= "site_id")) %>% 
    mutate(n = ifelse(is.na(n), 0, n)) 
  
  all_data <- all_data %>%
    left_join(all_data_n_obs, by = "nhd_id") %>%
    mutate(facet_label = paste0(facet_label, " (n=", n, ")"))
  
  depth_plot <- ggplot(all_data, aes(x = DateTime, y = Depth)) +
    geom_point(size = 0.7) + scale_y_reverse() +
    facet_wrap( ~ facet_label, ncol=2)
  ggsave(file.path('3_assimilate_data/out/data_summary_plots.pdf'), depth_plot, width = 12, height = 8)
}

