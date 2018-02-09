#remeber to load netcdf first when on yeti
library(glmtools)
library(dplyr)
resample <- function(nc_file, field_file, meteo_file) {
t <- resample_to_field(nc_file=nc_file, field_file=field_file,
			method="interp")
t <- mutate(t, DateTime=as.Date(DateTime))
meteo <- data.table::fread(meteo_file) %>% 
	rename(DateTime=time) %>%
	mutate(DateTime=as.Date(DateTime))
#trim to model start/end dates to catch NAs
with_meteo <- left_join(t, meteo, by = "DateTime") %>% filter(DateTime >= "1980-04-01" & DateTime <= "2016-01-01") %>%
		filter(!is.na(Modeled_temp))
return(with_meteo)
}

get_temp_half_meter <- function(nc_file, nml_file) {
	nml <- read_nml(nml_file)
	depth <- get_nml_value(nml, 'lake_depth')
  depths <- seq(0, depth, by = 0.5)
  temps <- get_temp(nc_file, reference='surface', z_out = depths)
  return(temps)
}

#add a logical column to denote training subset
add_training_col <- function(df, starts, ends) {
	assertthat::assert_that(length(starts) == length(ends))
	df$paramSearchTraining <- FALSE
	for(i in seq_along(starts)){
		df <- mutate(df, paramSearchTraining=ifelse(DateTime >= starts[i] & DateTime <= ends[i],
						 	yes=TRUE, no=paramSearchTraining))
	}
	return(df)
}
