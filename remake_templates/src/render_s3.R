render_s3 <- function(){
  template <- readLines('remake_templates/s3.template')
  lakes <- read.csv('lib/crosswalks/rawfile_to_id_crosswalk.csv', 
                    stringsAsFactors = FALSE) %>% 
          filter(id != "UWID")
  targets <- lakes$file
  
  targets <- list(targets=targets)
  out <- whisker.render(template = template, data = targets)
  cat(out, file = '1_data_s3.yml')
}

render_s3_clean <- function(){
  template <- readLines('remake_templates/s3_clean.template')
  with_ext <- read.csv('lib/crosswalks/rawfile_to_id_crosswalk.csv', stringsAsFactors = FALSE)$file
  no_ext <- tools::file_path_sans_ext(with_ext)
  targets <- vector("list", length(with_ext))
  for(i in seq_along(with_ext)){
    with_ext_i <- with_ext[i]
    no_ext_i <- no_ext[i]
    targets[i] <- list(list(with_ext = with_ext_i, no_ext = no_ext_i)) 
  }
  targets <- list(targets=targets)
  out <- whisker.render(template = template, data = targets)
  cat(out, file = '1_data_s3_cleaned.yml')
}



