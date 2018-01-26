#parse various minnesota state agency data files
parse_MPCA_temp_data_all <- function(infile = "1_data_s3/out/MPCA_temp_data_all.tsv",
                         outfile = "1_data_s3_cleaned/out/MPCA_temp_data_all.rds") {
  raw_file <- data.table::fread(infile, colClasses = c(DOW="character"),
                                select = c("SAMPLE_DATE", "START_DEPTH", "DEPTH_UNIT",
                                           "RESULT_NUMERIC", "RESULT_UNIT", "DOW"))
  assert_that(unique(raw_file$RESULT_UNIT) == "deg C")
  #some measurements missing depth unit
  clean <- raw_file %>% filter(DEPTH_UNIT == "m") %>% select(-RESULT_UNIT, -DEPTH_UNIT) %>% 
    mutate(SAMPLE_DATE = as.Date(SAMPLE_DATE, format = "%m/%d/%Y")) %>% 
    rename(DateTime = SAMPLE_DATE, Depth = START_DEPTH, temp = RESULT_NUMERIC)
  saveRDS(object = clean, file = outfile)
  s3_put(remote_ind = as_ind_file(outfile), local_source =  as_ind_file(outfile))
}