#create nmls, driver files for DOW large lakes
library(data.table)
library(dplyr)
library(purrr)
dow_lakes <- fread('Large_lakes_DOW_nhd.csv') %>% filter(site_id != "") %>% 
  mutate(Lake=gsub(pattern = " ",replacement = "", x = Lake))
source('R/get_lake_base_nml.R')
map(dow_lakes$site_id, setup_nml)
