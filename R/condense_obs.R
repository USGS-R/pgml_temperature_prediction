#thin observations for PEST to fit to
library(data.table)
library(lubridate)
library(dplyr)

df <- fread('obs/processed/nhd_13293262/training.csv') %>% 
  mutate(DateTime = as.Date(DateTime), week = week(DateTime)) 

#just find dates, then filter again 
dates_keep_weekly <- df %>% group_by(year4, week) %>% arrange(DateTime) %>% 
  filter(row_number()==1) %>% select(DateTime)
dates_keep_2months <- dates_keep_weekly %>%
  mutate(month=month(DateTime)) %>% 
  group_by(year4, month) %>% filter(month %% 2 != 0 & row_number() == 1)

shallow <- filter(df, Depth <= 8 & DateTime %in% dates_keep_weekly$DateTime)
deeper <- filter(df, Depth > 8 & DateTime %in% dates_keep_2months$DateTime)

condensed <- bind_rows(shallow, deeper) %>% arrange(DateTime, Depth)
fwrite(x = condensed, file = "obs/processed/nhd_13293262/pest_condensed.csv")
