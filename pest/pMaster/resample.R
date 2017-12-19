
#remeber to load netcdf first when on yeti
library(glmtools)
library(dplyr)
resample <- function(field_file, nc_file, out_file) {
t <- resample_to_field(nc_file=nc_file, field_file=field_file,
			method="interp")
t <- mutate(t, DateTime=as.Date(DateTime)) %>% select(Modeled_temp, Observed_temp, DateTime, Depth) %>% filter(!is.na(Modeled_temp))
write.csv(t, out_file, row.names = FALSE)
return(t)
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

