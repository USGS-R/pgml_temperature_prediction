library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
df <- fread('mendota_train_center.csv')
param_steps <- fread('param_steps_training.csv') 
param_steps_spread <- param_steps %>% mutate(itr = rep(1:(nrow(param_steps)/3), each = 3)) %>% spread(V1, V2) %>% 
  select(-V3, -V4)
min_from_grid <- fread('mendota_train_center_minrmse.csv')
theme <- theme(axis.text.x = element_text(angle = 90, hjust = 1))
plot_cd <- ggplot(df, aes(x = kw, y = coef_mix_shear, fill = rmse)) + 
  geom_tile() + ggtitle(paste("varying cd, winner", min_from_grid$cd)) + 
  facet_wrap(~cd) +
  geom_path(data = select(param_steps_spread, -cd), aes(x = kw, y = mxshr), inherit.aes = FALSE) +
  geom_point(data = min_from_grid, aes(x = kw, y = coef_mix_shear)) + 
  theme

print(plot_cd)

plot_kw <- ggplot(df, aes(x = cd, y = coef_mix_shear, fill = rmse)) + 
  geom_tile() + ggtitle(paste("varying kw, winner", min_from_grid$kw)) + 
  facet_wrap(~kw) + 
  scale_fill_gradient(low = 'red', high = "white") +
  geom_path(data = select(param_steps_spread, -kw), inherit.aes = FALSE, aes(x = cd, y = mxshr)) +
  geom_point(data = select(min_from_grid, -kw), aes(x = cd, y = coef_mix_shear)) + theme +
  geom_point(data= select(param_steps_spread[1,], -kw), inherit.aes=FALSE, aes(x=cd, y=mxshr),  color = "purple")
print(plot_kw)

plot_cms <- ggplot(df, aes(x = cd, y = kw, fill = rmse)) + 
  geom_tile() + ggtitle(paste("varying shear mixing, winner", min_from_grid$coef_mix_shear)) +
  facet_wrap(~coef_mix_shear) + 
  scale_fill_gradient(low = 'green', high = "white") + 
  geom_path(data = select(param_steps_spread, -mxshr), aes(x = cd, y = kw), inherit.aes = FALSE) +
  geom_point(data = min_from_grid, aes(x = cd, y = kw)) + theme
print(plot_cms)

 
