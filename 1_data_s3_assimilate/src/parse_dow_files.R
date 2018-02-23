#parse various minnesota state agency data files
parse_MPCA_temp_data_all <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  raw_file <- data.table::fread(infile, colClasses = c(DOW="character"),
                                select = c("SAMPLE_DATE", "START_DEPTH", "DEPTH_UNIT",
                                           "RESULT_NUMERIC", "RESULT_UNIT", "DOW"))
  assert_that(unique(raw_file$RESULT_UNIT) == "deg C")
  #some measurements missing depth unit
  clean <- raw_file %>% filter(DEPTH_UNIT == "m") %>% select(-RESULT_UNIT, -DEPTH_UNIT) %>% 
    mutate(SAMPLE_DATE = as.Date(SAMPLE_DATE, format = "%m/%d/%Y")) %>% 
    rename(DateTime = SAMPLE_DATE, Depth = START_DEPTH, temp = RESULT_NUMERIC)
  saveRDS(object = clean, file = outfile)
  s3_put(remote_ind = outind, local_source = outfile)
}

parse_URL_Temp_Logger_2006_to_2017 <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  tables <- Hmisc::mdb.get(infile)
  #3 tables in database
  df <- tables[['State Waters - 11 feet']]
  #need to add DOW for Red lake, add depth in m, convert to deg C
  #time is stored in a separate column, but it seems to have a date 
  #added starting from 12/30/99?
  #keep noon measurements to downsample
  df_clean <- df %>% mutate(DOW = "04003501", 
                            temp = 5/9*(WaterTempF - 32),
                            Depth = 11/3.28, 
                            DateTime = as.Date(Date, format = "%m/%d/%y"),
                            Time = substr(as.character(Time), 10, 19)) %>% 
    filter(Time == "12:00:00") %>% 
    select(DateTime, Depth, temp, DOW) %>% arrange(DateTime)
  saveRDS(object = df_clean, file = outfile)
  s3_put(remote_ind = outind, local_source =  outfile)
}

parse_MN_fisheries_all_temp_data_Jan2018 <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  raw <- data.table::fread(infile, colClasses = c(DOW="character"))
  #convert to meters depth and deg C temp
  clean <- raw %>% mutate(temp = 5/9*(TEMP_F - 32),
                          Depth = DEPTH_FT/3.28,
                          DateTime = as.Date(SAMPLING_DATE, 
                                             format = "%m/%d/%Y")) %>%  
    select(DateTime, Depth, temp, DOW)
  saveRDS(object = clean, file = outfile)
  s3_put(remote_ind = outind, local_source = outfile)                        
}
