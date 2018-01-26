library(whisker)
library(assertthat)
template <- readLines('remake_templates/s3.template')

raw_files_ind <- grep(pattern = ".ind", x = list.files('1_data_s3/out', full.names = TRUE),
                      value = TRUE)
commands <- rep("s3_get(target_name)", length(raw_files_ind))


target_names <- c("lib/cfg/s3_config.yml", raw_files_ind)
commands <- c("s3_config(config_file=target_name, bucket = I('pgml-temperature-prediction'))",
              commands)
assert_that(length(target_names) == length(commands))
targets <- list()
for(i in seq_along(target_names)) {
  targets[[i]] <- list(name = target_names[i], command = commands[i])
}
targets <- list(targets=targets)
out <- whisker.render(template = template, data = targets)
cat(out, file = '1_data_s3.yml')


