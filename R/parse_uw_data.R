#assimilate the discrete and buoy data from UW
library(dplyr)
library(lubridate)
buoy <- read.csv('obs/mendota/partial/mendota_daily_buoy.csv')
#flag code definitions are in the EML format on the UW limno data site
#https://lter.limnology.wisc.edu/data
buoy <- buoy %>% filter(!flag_wtemp %in% c("A11N", "D", "H")) %>% 
  mutate(sampledate = as.Date(sampledate), buoy = TRUE) %>% filter(!is.na(wtemp))


discrete <- read.csv('obs/mendota/partial/long_term_ntl.csv')
#deal with duplicates and remove NAs  
discrete <- discrete %>% filter(lakeid == "ME" & !is.na(wtemp)) %>% 
  select(year4, daynum, sampledate, depth, wtemp, flagwtemp) %>% 
  mutate(sampledate = as.Date(sampledate), month = month(sampledate),
         buoy = FALSE) %>% rename(flag_wtemp = flagwtemp) %>% 
  anti_join(buoy, by = c("sampledate", "depth")) #keep buoy data over hand 
#NOTE: no flagged mendota data, but will want to check for other lakes

#remove BOTH pairs of duplicated data
date_depth <- select(discrete, sampledate, depth)
dup_indices <- which(duplicated(date_depth) | duplicated(date_depth, fromLast = TRUE))
discrete <- slice(discrete, -dup_indices)

combined_df <- bind_rows(buoy, discrete)
saveRDS(object = combined_df, file = 'obs/mendota/partial/mendota_uw.rds')
