
aggregate_all_data <- function(outind, ...){
  files <- lapply(c(...), sc_retrieve, remake_file = "3_regroup_data.yml")
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
  
  saveRDS(object = all_data, file = as_data_file(outind))
  s3_put(remote_ind = outind, local_source =  as_data_file(outind)) 
}

data_summary_plots <- function(inind, outfile) {
  data_file <- sc_retrieve(inind, remake_file = "3_regroup_data.yml")
  all_data <- readRDS(data_file)
  depth_plot <- ggplot(all_data, aes(x = DateTime, y = Depth)) +
    geom_point(size = 0.7) + scale_y_reverse() +
    facet_wrap( ~ facet_label, ncol=2)
  ggsave(filename = outfile, plot = depth_plot, width = 12, height = 8)
}

data_summary_csv <- function(inind, outfile) {
  data_file <- sc_retrieve(inind, remake_file = "3_regroup_data.yml")
  all_data <- readRDS(data_file)
  summary <- all_data %>% group_by(nhd_id) %>% summarise(name = unique(Lake), nobs = n(), 
                                                         start = min(DateTime),
                                                         end = max(DateTime))
  write.csv(x = summary, file = outfile, row.names = FALSE)
}
