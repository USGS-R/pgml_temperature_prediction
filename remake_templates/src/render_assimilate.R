render_assimilate <- function(){
  template <- readLines('remake_templates/assimilate.template')
  master_table <- readr::read_csv('lib/crosswalks/lakes_master.csv') 
  
  #check if these columns are not NA for this NHD id
  #means we need to check raw files for data
  all_state_data_sources <- yaml::read_yaml('lib/cfg/state_data_sources.yml')$state_data_sources
  
  raw_files <- readr::read_csv('lib/crosswalks/rawfile_to_id_crosswalk.csv')
  
  targets <- list()
  #TODO: need to loop over unique nhd since not a 1:1 map with local ids
  #need to send multiple state ids for each nhd id
  unique_nhd_lakes <- unique(master_table$site_id)
  for(i in seq_along(unique_nhd_lakes)) {
    nhd_id <- unique_nhd_lakes[i]
    matches <- filter(master_table, site_id == nhd_id)
    #see which state data sources need to check
    #remove all NA columns
    state_id_cols <- matches[all_state_data_sources]
    nas_gone <- state_id_cols[,colSums(is.na(state_id_cols)) < nrow(state_id_cols)]
    if(ncol(nas_gone) > 1) {
      stop("Code doesn't deal with a site having data from multiple state agencies yet.
         Looks like you need to do some work :/ ")
    }
    assertthat::assert_that(!is.na(names(nas_gone)))
    state_source <- names(nas_gone)
    state_ids <- nas_gone[[state_source]]
    
    raw_files_to_check <- filter(raw_files, id == state_source)$file %>% 
      file_path_sans_ext(.) %>% paste("rds", sep=".") %>% file.path("1_data_s3_cleaned/out", .)
    file_list_string <- paste(shQuote(paste0(raw_files_to_check, ".ind")), collapse = ",")
    state_ids_string <- paste(shQuote(state_ids), collapse = ",")
    targets[[i]] <- list(nhd = nhd_id, files_collapse = file_list_string, 
                         state_source = state_source, state_id = state_ids_string)
  }
  targets <- list(targets=targets)
  out <- whisker.render(template = template, data = targets)
  cat(out, file = '3_assimilate_data.yml')
}