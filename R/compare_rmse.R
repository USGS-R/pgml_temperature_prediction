#aggregate the rmses from all model runs to find the lowest
#all written in separate files...
library(data.table)

outDirec <- "mille_lacs_optimize_all_out"
directories <- list.dirs(path = outDirec, recursive=FALSE)
n=length(directories)
naVec <- as.numeric(rep(NA, n))
all_rmse_dt <- data.table(cd=naVec, kw=naVec, coef_mix_shear=naVec, 
			rmse=naVec, rmse_small_train=naVec)
for(i in seq_along(directories)) {
  d <- directories[i]
  rmse_csv <- fread(file.path(d, 'params_with_rmse.csv'), drop  = "X")
  rmse_small_train_csv <- fread(file.path(d, 'params_with_rmse_small_train.csv'), drop = "X")
  rmse_csv$rmse_small_train <- rmse_small_train_csv$rmse
  set(all_rmse_dt, i = i, j= names(all_rmse_dt), value = rmse_csv[1,])
  if(i %% 10 == 0) {print(i)}
}
fwrite(x = all_rmse_dt, file = "mille_lacs_rmse.csv")
#get lowest rmse
min_index <- which.min(all_rmse_dt$rmse)
print(all_rmse_dt[min_index,])


