#create nmls, driver files for DOW large lakes
library(data.table)
library(dplyr)
library(purrr)
library(lubridate)
master_lakes <- fread('lib/crosswalks/lakes_master.csv', colClasses = c(DOW="character"))
source('R/get_lake_base_nml.R')
map(master_lakes$site_id, setup_nml)

#munge data 
full_df <- fread('obs/MPCA_temp_data_all', colClasses = c(DOW="character")) 
full_df_clean <- full_df %>% filter(DOW %in% dow_lakes$DOW) %>% 
  left_join(dow_lakes, by = "DOW") %>% select(SAMPLE_DATE, START_DEPTH, DEPTH_UNIT,
                                              RESULT_NUMERIC, RESULT_UNIT, DOW, site_id) %>% 
  mutate(SAMPLE_DATE = as.Date(SAMPLE_DATE, format = "%m/%d/%Y"))  
renamed <- full_df_clean %>% rename(DateTime = SAMPLE_DATE, temp = RESULT_NUMERIC, Depth = START_DEPTH) %>% 
  filter(!(temp == 0 & month(DateTime) > 4 & month(DateTime) < 11))

#write out separate files for each NHD?  get WQP first!


#accessing S3 example
library(aws.s3)
library(aws.signature)
use_credentials()
s3sync(files="test", bucket = "pgml-temperature-prediction")
