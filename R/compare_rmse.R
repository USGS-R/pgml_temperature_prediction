#aggregate the rmses from all model runs to find the lowest
#all written in separate files...
library(data.table)

outDirec <- "out"
rmseFileName <- "mendota_training_3k_rmse.csv"

directories <- list.dirs(path = outDirec, recursive=FALSE)
n=length(directories)
naVec <- as.numeric(rep(NA, n))
all_rmse_dt <- data.table(cd=naVec, kw=naVec, coef_mix_shear=naVec, 
			rmse=naVec)#, armse_small_train=naVec)
for(i in seq_along(directories)) {
  d <- directories[i]
  rmse_csv <- fread(file.path(d, 'params_with_rmse_3k_train.csv'), drop  = "X")
  #rmse_small_train_csv <- fread(file.path(d, 'params_with_rmse_small_train.csv'), drop = "X")
  #rmse_csv$rmse_small_train <- rmse_small_train_csv$rmse
  set(all_rmse_dt, i = i, j= names(all_rmse_dt), value = rmse_csv[1,])
  if(i %% 10 == 0) {print(i)}
}
fwrite(x = all_rmse_dt, file = rmseFileName)
#get lowest rmse
min_index <- which.min(all_rmse_dt$rmse)
print(all_rmse_dt[min_index,])


