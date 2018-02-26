render_run_models <- function() {
  template <- readLines('remake_templates/run_models.template')
  master_lakes <- read.csv('lib/crosswalks/lakes_master.csv', stringsAsFactors = FALSE)
  unique_nhd <- unique(master_lakes$site_id)
  nhd <- list(nhd = unique_nhd)
  out <- whisker.render(template = template, data = nhd)
  cat(out, file = '4_run_models.yml')
}