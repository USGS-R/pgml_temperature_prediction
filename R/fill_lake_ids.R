fill_nhd_ids <- function(df) {
  na_rows <- is.na(df$site_id)
  #first, try to fill them from the lookup tables
  #they must have some ID though...
  #just dealing with DOW lakes for now
  assertthat::assert_that(all(!is.na(df$DOW[na_rows])))
  dow_lookup <- readRDS('obs/nhd2dow.rds')
  joined <- left_join(df, dow_lookup, by = "DOW", suffix = c("", ".y")) 
  df$site_id[na_rows] <- joined$site_id.y[na_rows] 
  return(df) 
}