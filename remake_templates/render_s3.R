render_s3 <- function(){
  template <- readLines('remake_templates/s3.template')
  targets <- read.csv('lib/crosswalks/rawfile_to_id_crosswalk.csv', stringsAsFactors = FALSE)$file
  
  targets <- list(targets=targets)
  out <- whisker.render(template = template, data = targets)
  cat(out, file = '1_data_s3.yml')
}



