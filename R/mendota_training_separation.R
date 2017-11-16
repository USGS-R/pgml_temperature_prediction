#separate out "training" data
full_data <- read.table('obs/mendota/mendota_combined.tsv', sep = "\t", header = TRUE)
library(dplyr)
#just take middle 60%?  try splitting differently later
cuts <- ceiling(quantile(1:nrow(full_data), c(0.2,0.8)))
training <- slice(full_data, cuts[1]:cuts[2])
test <- slice(full_data, c(1:(cuts[1]-1), (cuts[2]+1):nrow(full_data)))
write.table(x = training, file = "obs/mendota/training.tsv", sep = "\t",
          row.names = FALSE)
write.table(x = test, file = 'obs/mendota/test.tsv', sep = "\t",
          row.names = FALSE)
