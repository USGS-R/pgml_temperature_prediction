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

fahrenheit_to_celsius <- function(x){ 5/9*(x - 32) } 

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
                            temp = fahrenheit_to_celsius(WaterTempF),
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


#these take hourly measurements - keeping the noon measurements to
#downsample to daily
parse_Cass_lake_emperature_Logger_Database_2008_to_present <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  tables <- Hmisc::mdb.get(infile)
  #two different instruments
  cedar <- tables$`Cedar Island_South (11 ft)` %>% mutate(Depth = 11/3.28)
  knutron <- tables$`Cass Logger near Knutron (27 ft)` %>% 
    mutate(Depth = 27/3.28) %>% rename(WaterTemp=WaterTempF)
  raw <- bind_rows(cedar, knutron) 
  clean <- raw %>% mutate(temp = fahrenheit_to_celsius(WaterTemp),
                          Time = substr(Time, 10,18), 
                          DateTime = as.Date(Date, format = "%m/%d/%y"),
                          DOW = "04003000") %>% 
    filter(Time == "12:00:00") %>% select(DateTime, Depth, temp, DOW)
  saveRDS(object = clean, file = outfile)
  s3_put(remote_ind = outind, local_source = outfile)
}

#Lake of the Woods
parse_LotW_WQ_Gretchen_H <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  raw <- readxl::read_excel(infile)
  clean <- raw %>% filter(!grepl(pattern = "Dates in Red", x = notes) & !is.na(temp.units) & !is.na(temperature)) %>% 
    mutate(DOW = gsub(pattern = "-", replacement = "", x = DOW),
           depth = depth/3.28,
           temp = ifelse(temp.units == "F", yes = fahrenheit_to_celsius(temperature),
                         no = temperature)) %>% rename(Depth = depth, DateTime = Date) %>% 
    select(DateTime, temp, Depth, DOW)
  saveRDS(object = clean, file = outfile)
  s3_put(remote_ind = outind, local_source = outfile)
}

#mille lacs
parse_ML_observed_temperatures <- function(inind, outind) {
  infile <- as_data_file(inind)
  outfile <- as_data_file(outind)
  raw <- data.table::fread(infile)
  clean <- raw %>% mutate(temp = fahrenheit_to_celsius(temp.f),
                          Depth = depth.ft/3.28,
                          DateTime = as.Date(Date, format = "%m/%d/%Y"),
                          DOW = "48000200") %>% select(DateTime, temp, Depth, DOW)
  saveRDS(object = clean, file = outfile)
  s3_put(remote_ind = outind, local_source = outfile)
}
