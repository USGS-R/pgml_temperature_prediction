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
