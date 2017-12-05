#remeber to load netcdf first when on yeti
library(glmtools)
library(dplyr)
resample <- function(field_file, out_file) {
t <- resample_to_field(nc_file="out/WBIC_805400_optim_1/output.nc", field_file="obs/mendota/mendota_combined.csv",
			method="interp")
t <- mutate(t, DateTime=as.Date(DateTime)) %>% select(Observed_temp, Modeled_temp, DateTime, Depth)
write.csv(t, out_file, row.names = FALSE)
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
