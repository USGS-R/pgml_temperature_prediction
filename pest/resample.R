#remeber to load netcdf first when on yeti
library(glmtools)
library(dplyr)
resample <- function() {
t <- resample_to_field(nc_file="output.nc", field_file="../../pgml_temperature_prediction/obs/mille_lacs/obs_only.tsv",
			method="interp")
t <- mutate(t, DateTime=as.Date(DateTime))
meteo <- data.table::fread('../../pgml_temperature_prediction/meteo/nhd_13293262_driver.csv') %>% 
	rename(DateTime=time) %>%
	mutate(DateTime=as.Date(DateTime))
#trim to model start/end dates to catch NAs
with_meteo <- left_join(t, meteo, by = "DateTime") %>% filter(DateTime >= "1980-04-01" & DateTime <= "2016-01-01") %>%
		filter(!is.na(Modeled_temp))
return(with_meteo)
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
