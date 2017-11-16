#assimilate UW and WQP data

library(dplyr)
library(lubridate)
wqp <- readRDS('obs/mendota/partial/mendota_wqp.rds')
uw <- readRDS('obs/mendota/partial/mendota_uw.rds')

wqp <- wqp %>% mutate(buoy = FALSE, year4 = year(Date), 
                      month = month(Date), daynum = yday(Date)) %>% 
      rename(DateTime=Date)
uw <- uw %>% rename(DateTime=sampledate)
all_data <- bind_rows(wqp, uw) %>% rename(Depth=depth, temp = wtemp)
write.table(x = all_data, file = "obs/mendota/mendota_combined.tsv", sep = "\t",
            row.names = FALSE)
