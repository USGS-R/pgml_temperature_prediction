library(dplyr)
parse_mendota_daily_buoy <- function(infile = "1_data_s3/out/mendota_daily_buoy.csv",
                                     outfile = "1_data_s3_cleaned/out/mendota_daily_buoy.rds") {
  raw_file <- data.table::fread(infile)
  #flag code definitions are in the EML format on the UW limno data site
  #https://lter.limnology.wisc.edu/data
  clean <- raw_file %>% filter(!flag_wtemp %in% c("A11N", "D", "H")) %>% 
    rename(DateTime = sampledate, Depth = depth, temp = wtemp) %>% 
    mutate(DateTime = as.Date(DateTime), UWID = "ME") %>% 
    select(DateTime, Depth, temp, UWID)
  saveRDS(object = clean, file = outfile)
  scipiper::s3_put(remote_ind = scipiper::as_ind_file(outfile), 
                   local_source = scipiper::as_ind_file(outfile))
}

parse_long_term_ntl <- function(infile = "1_data_s3/out/long_term_ntl.csv",
                                outfile = "1_data_s3_cleaned/out/long_term_ntl.rds") {
  raw_file <- data.table::fread(infile, select = c("lakeid", "sampledate", 
                                                   "depth", "wtemp"))
  clean <- raw_file %>% rename(UWID = lakeid, DateTime = sampledate, Depth = depth,
                               temp = wtemp) %>% mutate(DateTime = as.Date(DateTime)) 
  saveRDS(object = clean, file = outfile)
  scipiper::s3_put(remote_ind = scipiper::as_ind_file(outfile), 
                   local_source = scipiper::as_ind_file(outfile))
}