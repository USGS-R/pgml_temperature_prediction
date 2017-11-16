#assimilate the discrete and buoy data from UW
library(dplyr)
library(lubridate)
buoy <- read.csv('obs/mendota/partial/mendota_daily_buoy.csv')
#flag code definitions are in the EML format on the UW limno data site
#https://lter.limnology.wisc.edu/data
buoy <- buoy %>% filter(!flag_wtemp %in% c("A11N", "D", "H")) %>% 
  mutate(sampledate = as.Date(sampledate), buoy = TRUE)


discrete <- read.csv('obs/mendota/partial/long_term_ntl.csv')

discrete <- discrete %>% filter(lakeid == "ME") %>% 
  select(year4, daynum, sampledate, depth, wtemp, flagwtemp) %>% 
  mutate(sampledate = as.Date(sampledate), month = month(sampledate),
         buoy = FALSE) %>% rename(flag_wtemp = flagwtemp)
#NOTE: no flagged mendota data, but will want to check for other lakes

combined_df <- bind_rows(buoy, discrete)
saveRDS(object = combined_df, file = 'obs/mendota/partial/mendota_uw.rds')
