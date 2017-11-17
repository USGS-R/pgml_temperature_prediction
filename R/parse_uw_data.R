remove_duplicates <- function(df, colNames) {
  #remove both pairs of duplicates from df based on colNames
  df_cols <- select(df, colNames)
  dup_indices <- which(duplicated(df_cols) | duplicated(df_cols, fromLast = TRUE))
  df_nodups <- slice(df, -dup_indices)
  return(df_nodups)
}


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

discrete <- remove_duplicates(discrete, c("sampledate", "depth"))

combined_df <- bind_rows(buoy, discrete)

#long-term from LTER data portal
#there are characters in depth column, but before 1980
long <- read.csv(file = 'obs/mendota/partial/Lake_Mendota_temps_long.csv',
                 stringsAsFactors = FALSE, colClasses = c(sampledate="Date"))
long <- filter(long, sampledate > "1980-01-01") %>% 
  select(-day, -reps, -average, -observer, -ObsTime, -Loc) %>% 
  rename(wtemp=watertemp) %>% mutate(daynum = yday(sampledate), 
                                     buoy=FALSE, depth=as.numeric(depth)) %>% 
  anti_join(combined_df, by = c("sampledate", "depth"))
long_nodups <- remove_duplicates(long, c("sampledate", "depth"))

combined_df <- bind_rows(combined_df, long_nodups)



saveRDS(object = combined_df, file = 'obs/mendota/partial/mendota_uw.rds')