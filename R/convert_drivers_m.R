#convert driver files to m/day from mm/day
library(dplyr)
library(data.table)


files <- list.files('siteInputs4_1', full.names = TRUE)

for(f in files) {
	file <- fread(f)
	file_m <- mutate(file, Rain = Rain/1000)
	new_path <- file.path('siteInputs_rain_meters', basename(f))
  fwrite(x = file_m, file = new_path)
  print(new_path)
}

