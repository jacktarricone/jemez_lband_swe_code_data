# atmosphereic correction for 12-26 pair
# jack tarricone
# january 10th, 2023

library(terra)
library(ggplot2)

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

# look vector geocoded rasters 
lkv_km_raw <-rast("./rasters/lvk/lkv_km.tif")

# bring in coherence raster for masking
cor <-rast("./rasters/uavsar_p3_feb12-26/alamos_35915_20005-003_20013-000_0014d_s01_L090HH_01.cor.grd.tiff")

# create masking raster with smallest possible extent
cor_mask <-cor
lkv_km_crop <-resample(lkv_km_raw, cor_mask)
cor_mask_v2 <-mask(cor_mask, lkv_km_crop, maskvalue=NA)
lkv_masked <-mask(lkv_km_crop, cor_mask_v2, maskvalue=NA)
lkv_masked
plot(lkv_masked, add = TRUE)

##############
### bring in all the insar data 
##############

# unw
unw_raw <-rast("./rasters/uavsar_p3_feb12-26/alamos_35915_20005-003_20013-000_0014d_s01_L090HH_01.unw.grd.tiff")

#########################################
## resample and crop to one size ########
#########################################

unw_masked <-mask(unw_raw, lkv_masked, maskvalue=NA)

#### crop down to largest size possible with all overlapping pixels
# create new rast, set non NA values to 0 for unw
unw_non_na <-unw_masked
values(unw_non_na)[!is.na(unw_non_na[])] = 1
plot(unw_non_na)

# same thing for lkv
lkv_resamp_non_na <-lkv_masked

# crop lkv with unw, this leaves only the cells that exist in both data sets for plotting
lkv_unw_mask <-mask(lkv_resamp_non_na, unw_non_na, maskvalues=NA)

# test plot, looks good
plot(lkv_masked)
plot(unw_masked, add = TRUE)
plot(lkv_unw_mask, add = TRUE)

########################################
## bring in the no snow mask ###########
########################################

# using the snow mask, only analyze pixels that have no snow to check for atmospheric delay
# we do this because we're assuming there is some snow signal combine with atm signal in no pixels
# by doing just these, in theory we're just focusing on the atmospheric portion

### snow mask
snow_mask_raw <-rast("./rasters/fsca/landsat_fsca_2-18.tif")
plot(snow_mask_raw)

# clip edges off no snow mask to make it same size as lkv and unw
sm_v1 <-resample(snow_mask_raw, unw_masked)
snow_mask <-mask(sm_v1, unw_raw, maskvalue = NA)
plot(snow_mask)

#### snow unw and lkv
# snow unw
snow_unw <-mask(unw_masked, snow_mask, maskvalue = NA)
plot(snow_unw)
snow_unw

# snow lkv
snow_lkv <-mask(lkv_unw_mask, snow_unw, maskvalue = NA)
plot(snow_lkv)
snow_lkv

### convert no snow lkv and unw rasters to dataframes, rename data columns
# unw
unw_df <-as.data.frame(snow_unw, xy=TRUE, cells=TRUE, na.rm=TRUE)
colnames(unw_df)[4] <- "unwrapped_phase"
head(unw_df)
hist(unw_df$unwrapped_phase, breaks = 100) #quick hist to check

# lkv
lkv_df <-as.data.frame(snow_lkv, xy=TRUE, cells=TRUE, na.rm=TRUE)
colnames(lkv_df)[4] <- "lkv_km"
head(lkv_df)
hist(lkv_df$lkv_km, breaks = 100) #quick hist to check

# bind last column on for future plot
snow_df <-cbind(unw_df, lkv_df$lkv_km)
colnames(snow_df)[5] <- "lkv_km"
head(snow_df)

# run linear model to plot trend line
lm_fit <-lm(snow_df$unwrapped_phase ~ snow_df$lkv_km)
summary(lm_fit)

# create new df for lm and plotting on graph
head(snow_df)
lm_df <-snow_df[-c(1:3)]
names(lm_df)[1:2] <-c("y","x")
head(lm_df)

# function for running lm, plotting equation and r2 
lm_eqn <- function(df){
  m <- lm(y ~ x, df);
  eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2,
                   list(a = format(unname(coef(m)[1]), digits = 2),
                        b = format(unname(coef(m)[2]), digits = 2),
                        r2 = format(summary(m)$r.squared, digits = 2)))
  as.character(as.expression(eq));
}

# create eq
eq_label <-lm_eqn(lm_df)
print(eq_label)

########################################
########### unw vs lkv #################
########################################

theme_set(theme_classic(12))

p12 <-ggplot(snow_df, aes(lkv_km, unwrapped_phase)) +
  geom_hex(bins = 25) +
  scale_fill_gradient(low = "white", high = "seagreen") +
  geom_smooth(method = "lm", color = "black", se = FALSE) +
  annotate("text", x = 14, y = 4, parse = TRUE,
           label = "italic(y) == \"0.12\" + \"0.14\" %.% italic(x) * \",\" ~ ~italic(r)^2 ~ \"=\" ~ \"0.39\"") +
  ylim(-5,5) + xlim(10,30)+
  labs(#title = "Jemez Radar Path Length vs. Unwrapped Phase 2/12-2/19",
       x = "lkv (km)",
       y = "Unwrapped Phase (radians)")+
  theme(legend.position = c(.85, .30),
        legend.key.size = unit(.5, 'cm'))

print(p12)


### correct unw data using path length and the linear estimation we generated
path_length_correction <-function(unw, lkv){
  return((unw - ((lkv * coef(lm_fit)[[2]]) + coef(lm_fit)[[1]])))
  }

# apply function
unw_corrected <-path_length_correction(unw_masked, lkv_masked)
plot(unw_corrected)

# writeRaster(unw_corrected, "./rasters/atm_corrected_unw/unw_corrected_new_feb12-26.tif")

