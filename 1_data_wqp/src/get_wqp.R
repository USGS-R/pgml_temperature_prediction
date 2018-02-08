munge_temperature <- function(data.in){
  
  max.temp <- 40 # threshold!
  min.temp <- 0
  max.depth <- 260
  
  depth.unit.map <- data.frame(depth.units=c('meters','m','in','ft','feet','cm', 'mm', NA), 
                               depth.convert = c(1,1,0.0254,0.3048,0.3048,0.01, 0.001, NA), 
                               stringsAsFactors = FALSE)
  
  unit.map <- data.frame(units=c("deg C","deg F", NA), 
                         convert = c(1, 1/1.8,NA), 
                         offset = c(0,-32,NA),
                         stringsAsFactors = FALSE)
  
  activity.sites <- group_by(data.in, OrganizationIdentifier) %>% 
    summarize(act.n = sum(!is.na(ActivityDepthHeightMeasure.MeasureValue)), res.n=sum(!is.na((ResultDepthHeightMeasure.MeasureValue)))) %>% 
    mutate(use.depth.code = ifelse(act.n>res.n, 'act','res')) %>% 
    select(OrganizationIdentifier, use.depth.code)
  
  left_join(data.in, activity.sites, by='OrganizationIdentifier') %>% 
    mutate(raw.depth = as.numeric(ifelse(use.depth.code == 'act', ActivityDepthHeightMeasure.MeasureValue, ResultDepthHeightMeasure.MeasureValue)),
           depth.units = ifelse(use.depth.code == 'act', ActivityDepthHeightMeasure.MeasureUnitCode, ResultDepthHeightMeasure.MeasureUnitCode)) %>% 
    rename(Date=ActivityStartDate, raw.value=ResultMeasureValue, units=ResultMeasure.MeasureUnitCode, wqx.id=MonitoringLocationIdentifier) %>% 
    select(Date, raw.value, units, raw.depth, depth.units, wqx.id) %>% 
    left_join(unit.map, by='units') %>% 
    left_join(depth.unit.map, by='depth.units') %>% 
    mutate(wtemp=convert*(raw.value+offset), depth=raw.depth*depth.convert) %>% 
    filter(!is.na(wtemp), !is.na(depth), wtemp <= max.temp, wtemp >= min.temp, depth <= max.depth) %>% 
    select(Date, wqx.id, depth, wtemp)
}


wqp_lookup_retrieve <- function(nhd, outfile) {
  #use existing lookup table from necsc repo
  lookup <- readRDS('lib/crosswalks/wqp_nhdLookup.rds')
  
  lookup_keep <- filter(lookup, id == nhd)
  config <- yaml.load_file('lib/cfg/wqp_config.yml')
  wqp_args <- list(characteristicName=config$characteristicName,
                   startDateLo=config$startDate,
                   startDateHi=config$endDate,
                   siteid=lookup_keep$MonitoringLocationIdentifier)
  wqp_raw <- readWQPdata(wqp_args)
  #watch out — there's some fahrenheit data!
  munged_wqp <- munge_temperature(wqp_raw)
  
  saveRDS(object = munged_wqp, file = outfile)
  s3_put(remote_ind = as_ind_file(outfile), local_source =  as_ind_file(outfile))
}

