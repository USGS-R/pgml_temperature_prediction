#assimilate UW and WQP data

library(dplyr)
library(lubridate)
library(assertthat)
wqp <- readRDS('obs/mendota/partial/mendota_wqp.rds')
uw <- readRDS('obs/mendota/partial/mendota_uw.rds')

wqp <- wqp %>% mutate(buoy = FALSE, year4 = year(Date), 
                      month = month(Date), daynum = yday(Date)) %>% 
      rename(DateTime=Date)
uw <- uw %>% rename(DateTime=sampledate)
#deal with overlapping measurements 
#keep UW measurements since more data from there
wqp <- anti_join(wqp, uw, by = c("DateTime", "depth"))

all_data <- bind_rows(wqp, uw) %>% rename(Depth=depth, temp = wtemp)
assert_that(anyDuplicated(all_data[,c("DateTime", "Depth")]) == 0)
write.csv(x = all_data, file = "obs/mendota/mendota_combined.csv",
            row.names = FALSE)
