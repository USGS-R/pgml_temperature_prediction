library(dplyr)
library(lubridate)
summarize_evap <- function(evap_df){
  df_posix <- mutate(evap_df, DateTime = as.POSIXct(strptime(x = DateTime, format = "%Y-%m-%dT%H:%M:%S", tz = 'GMT'))) 
  df_tz <- mutate(df_posix, DateTime = with_tz(DateTime, tz = "Etc/GMT+6"), Date = as.Date(DateTime))
  daily_evap <- df_tz %>% group_by(Date) %>% summarize(evap_mm_day = sum(`evaporation(mm/d)`))
  return(daily_evap)
}

#run from inside the "out" directory, where there is a folder for each lake's output
folders <- list.files()
for(f in folders) {
	file <- data.table::fread(file.path(f, paste(f, 'evap.csv', sep = "_")))
	evap_summary <- summarize_evap(file)
  data.table::fwrite(x = evap_summary, file = file.path(f, paste(f, 'evap_daily.csv', sep = "_")))
	message("Done with ", f)
}
