render_setup_models <- function(){
  template <- readLines('remake_templates/setup_models.template')
  master_lakes <- data.table::fread('lib/crosswalks/lakes_master.csv')
  unique_nhd <- unique(master_lakes$site_id)
  nhd <- list(nhd = iteratelist(unique_nhd, name = "nhd", value = ""))
  out <- whisker.render(template = template, data = nhd)
  cat(out, file = '2_setup_models.yml')
}