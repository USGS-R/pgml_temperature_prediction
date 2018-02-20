render_wqp <- function() {
  master_lakes <- data.table::fread('lib/crosswalks/lakes_master.csv')
  nhd_ids <- unique(master_lakes$site_id)
  
  template <- readLines('remake_templates/wqp.template')
  out <- whisker.render(template = template)
  cat(out, file = '1_data_wqp.yml')
}

