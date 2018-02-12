#compare number of observations with what got matched up 
#by resample_to_field
#i.e. did teh model dry out early?
model_stats <- data.frame()
#check number of obs and date range
lakes_master <- readr::read_csv('lib/crosswalks/lakes_master.csv')
for(lake in unique(lakes_master$site_id)){
  #resampled to obs
  resampled_path <- file.path('~/Desktop/models', paste(lake, "obs_drivers.csv",
                                           sep = '_'))
  resampled_df <- readr::read_csv(resampled_path)
  full_obs <- readRDS(file.path('3_assimilate_data/out', 
                                paste0(lake, ".rds")))
  model_stats_lake <- data.frame(lake = lake, nobs_full = nrow(full_obs),
                                 nobs_model = nrow(resampled_df),
                                 start_full = min(full_obs$DateTime),
                                 start_model = min(resampled_df$DateTime),
                                 end_full = max(full_obs$DateTime),
                                 end_model = max(resampled_df$DateTime),
                                 stringsAsFactors = FALSE) %>% 
    mutate(percent_obs_lost = (1 - nobs_model/nobs_full)*100)
  model_stats <- bind_rows(model_stats, model_stats_lake)
  
  #missing obs
  missing <- anti_join(full_obs, resampled_df, by = c("DateTime", "Depth"))
  View(missing)
  readline(prompt="Press [enter] to continue")
}

#anti join two dfs by depth and date 