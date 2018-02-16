parse_mendota_daily_buoy <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  raw_file <- data.table::fread(infile)
  #flag code definitions are in the EML format on the UW limno data site
  #https://lter.limnology.wisc.edu/data
  clean <- raw_file %>% filter(!flag_wtemp %in% c("A11N", "D", "H")) %>% 
    rename(DateTime = sampledate, Depth = depth, temp = wtemp) %>% 
    mutate(DateTime = as.Date(DateTime), UWID = "ME") %>% 
    select(DateTime, Depth, temp, UWID)
  saveRDS(object = clean, file = outfile)
  s3_put(remote_ind = outind, local_source = outfile)
}

parse_long_term_ntl <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  raw_file <- data.table::fread(infile, select = c("lakeid", "sampledate", 
                                                   "depth", "wtemp"))
  clean <- raw_file %>% rename(UWID = lakeid, DateTime = sampledate, Depth = depth,
                               temp = wtemp) %>% mutate(DateTime = as.Date(DateTime)) 
  saveRDS(object = clean, file = outfile)
  scipiper::s3_put(outind, local_source = outfile)
}

parse_mendota_temps_long <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  raw_file <- data.table::fread(infile, select = c("sampledate", "depth", "watertemp")) 
  clean <- raw_file %>% mutate(UWID = "ME") %>% rename(DateTime = sampledate, 
                                                       Depth = depth, temp = watertemp) %>% 
              filter(Depth != "MUD") %>% 
    mutate(DateTime = as.Date(DateTime), Depth = as.numeric(Depth))
  saveRDS(object = clean, file = outfile)
  s3_put(outind, local_source = outfile)
}