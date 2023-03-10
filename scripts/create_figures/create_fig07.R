# jack tarricone
# create figure 7: # atmospheric delay for snow cover and snow free
# 12 - 19 February

library(terra)
library(ggplot2)
library(cowplot)

# set custom theme
theme_classic <- function(base_size = 11, base_family = "",
                          base_line_size = base_size / 22,
                          base_rect_size = base_size / 22) {
  theme_bw(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size,
    base_rect_size = base_rect_size
  ) %+replace%
    theme(
      # no background and no grid
      panel.border     = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      
      # show axes
      # axis.line      = element_line(colour = "black", linewidth = rel(1)),
      
      # match legend key to panel.background
      legend.key       = element_blank(),
      
      # simple, black and white strips
      strip.background = element_rect(fill = "white", colour = "black", linewidth = rel(2)),
      # NB: size is 1 but clipped, it looks like the 0.5 of the axes
      
      complete = TRUE
    )
}

theme_set(theme_classic(14))


# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

# path length raster 
lkv_km <-rast("./rasters/lvk/lkv_km.tif")
lkv_km
plot(lkv_km)

##############
### bring in all the insar data 
##############

# unw
unw_raw <-rast("./rasters/uavsar_p1_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090HH_01.unw.grd.tiff")
unw_raw
plot(unw_raw)

# cor
cor <-rast("./rasters/uavsar_p1_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090HH_01.cor.grd.tiff")
cor
plot(cor)


#########################################
## resample and crop to one size ########
#########################################

# resample look vector to unwrapped phase
lkv_resamp <-resample(lkv_km, unw_raw, method = "bilinear")
lkv_resamp
ext(lkv_resamp) <-ext(unw_raw) # set extent as same as unw
lkv_resamp

# test plot
plot(unw_raw)
plot(lkv_resamp, add = TRUE)

#### crop down to largest size possible with all overlapping pixels
# create new rast, set non NA values to 0 for unw
unw_non_na <-unw_raw
values(unw_non_na)[!is.na(unw_non_na[])] = 1
plot(unw_non_na)

# same thing for lkv
lkv_resamp_non_na <-lkv_resamp
values(lkv_resamp_non_na)[!is.na(lkv_resamp_non_na[])] = 1
plot(lkv_resamp_non_na)

# crop lkv with unw, this leaves only the cells that exist in both data sets for plotting
lkv_crop1 <-terra::mask(lkv_resamp_non_na, unw_non_na, maskvalues=NA)
lkv_unw_mask <-terra::mask(unw_non_na, lkv_crop1, maskvalues=NA)

# test plot, looks good
plot(lkv_resamp)
plot(unw_raw, add = TRUE)
plot(lkv_unw_mask, add = TRUE)

# mask both unw and lkv with the mask
unw_masked <-terra::mask(unw_raw, lkv_unw_mask, maskvalues=NA)
lkv_masked <-terra::mask(lkv_resamp, lkv_unw_mask, maskvalues=NA)

# plot -- looks good
plot(unw_masked)
plot(lkv_masked, add = TRUE)


########################################
## bring in the no snow mask ###########
########################################

fsca <-rast("./rasters/fsca/landsat_fsca_2-18.tif")
plot(fsca)

# clip edges off no snow mask to make it same size as lkv and unw
clipped_nsm <-mask(fsca, unw_masked, maskvalue = NA)
plot(clipped_nsm, add = TRUE)

###### mask for snow cover
# snow unw
snow_unw <-mask(unw_masked, clipped_nsm, maskvalue = NA)
plot(snow_unw)

# snow lkv
snow_lkv <-mask(lkv_resamp, clipped_nsm, maskvalue = NA)
plot(snow_lkv)

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
cor(snow_df$unwrapped_phase, snow_df$lkv_km)

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

## plot 
p12 <-ggplot(snow_df, aes(lkv_km, unwrapped_phase)) +
  geom_bin_2d(bins = 40) +
  scale_fill_gradient(low = "white", high = "darkseagreen") +
  geom_smooth(method = "lm", color = "black", se = FALSE) +
  annotate("text", x = 14, y = 4, parse = TRUE,
          label = "italic(y) == \"-4.3\" + \"0.26\" %.% italic(x) * \",\" ~ ~italic(r)^2 ~ \"=\" ~ \"0.81\"") +
  ylim(-5,5) + xlim(10,30)+
  labs(y = "Unwrapped Phase (radians)")+
  theme(panel.border = element_rect(colour = "black", fill=NA, linewidth = 1),
        legend.position = c(.85, .30),
        legend.key.size = unit(.5, 'cm'),
        axis.title.x=element_blank())

print(p12)

#############################################
############ for NO snow  pixels ########
#############################################

# create snow snow mask
no_snow <-fsca
values(no_snow)[is.na(no_snow[])] = -999
values(no_snow)[values(no_snow) > 0] = 1
no_snow_crop <-mask(no_snow, cor, maskvalue = NA)
plot(no_snow_crop)

# clip edges off no snow mask to make it same size as lkv and unw
clipped_nsm_v2 <-mask(no_snow_crop, unw_masked, maskvalue = NA)
plot(clipped_nsm_v2)

# no snow unw
no_snow_unw <-mask(unw_masked, clipped_nsm_v2, maskvalue = 1)
plot(no_snow_unw)

# no snow lkv
no_snow_lkv <-mask(lkv_masked, clipped_nsm_v2, maskvalue = 1)
plot(no_snow_lkv)

### convert no snow lkv and unw rasters to dataframes, rename data columns
# unw
no_unw_df <-as.data.frame(no_snow_unw, xy=TRUE, cells=TRUE, na.rm=TRUE)
colnames(no_unw_df)[4] <- "unwrapped_phase"
head(no_unw_df)
hist(no_unw_df$unwrapped_phase, breaks = 100) #quick hist to check

# lkv
no_lkv_df <-as.data.frame(no_snow_lkv, xy=TRUE, cells=TRUE, na.rm=TRUE)
colnames(no_lkv_df)[4] <- "lkv_km"
head(no_lkv_df)
hist(no_lkv_df$lkv_km, breaks = 100) #quick hist to check

# bind last column on for future plot
no_snow_df <-cbind(no_unw_df, no_lkv_df$lkv_km)
colnames(no_snow_df)[5] <- "lkv_km"
head(no_snow_df)

# run linear model to plot trend line
lm_fit_v2 <-lm(no_snow_df$unwrapped_phase ~ no_snow_df$lkv_km)
summary(lm_fit_v2)

# create new df for lm and plotting on graph
head(no_snow_df)
lm_df_v2 <-no_snow_df[-c(1:3)]
names(lm_df_v2)[1:2] <-c("y","x")
head(lm_df_v2)

# create eq
eq_label_v2 <-lm_eqn(lm_df_v2)
print(eq_label_v2)


########################################
########### no snow unw vs lkv #########
########################################

p13 <-ggplot(no_snow_df, aes(lkv_km, unwrapped_phase)) +
  geom_bin_2d(bins = 40) +
  scale_fill_gradient(low = "white", high = "darkorchid4") +
  geom_smooth(method = "lm", color = "black", se = FALSE) +
  annotate("text", x = 14, y = 4, parse = TRUE,
           label = "italic(y) == \"-4.5\" + \"0.26\" %.% italic(x) * \",\" ~ ~italic(r)^2 ~ \"=\" ~ \"0.81\"") +
  ylim(-5,5) + xlim(10,30)+
  labs(#title = "Jemez Radar Path Length vs. Unwrapped Phase 2/12-2/19",
    x = "LKV (km)",
    y = "Unwrapped Phase (radians)")+
  theme(panel.border = element_rect(colour = "black", fill=NA, size = 1),
        legend.position = c(.85, .30),
        legend.key.size = unit(.5, 'cm'))

print(p13)


# combine
figure <-plot_grid(p12, p13, 
                   labels = c("(a)", "(b)"),
                   align = "v",
                   nrow = 2,
                   vjust = 2.2,
                   hjust = -4,
                   rel_heights = c(.48, .52))

plot(figure)

# # save
ggsave(figure,
       file = "./plots/fig07.pdf",
       width = 6,
       height = 7,
       dpi = 500)