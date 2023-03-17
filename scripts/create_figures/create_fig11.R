# in situ snow depth vs. insar swe
# jack tarricone

library(terra)
library(ggplot2)
library(cowplot)
library(dplyr)
library(sf)
library(Metrics)

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

# set custom plot theme
theme_classic <-function(base_size = 11, base_family = "",
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

#######
## bring in swe change rasters masked for same pixels "sp"
rast_list <-list.files("./rasters/dswe/sp", 
                       pattern = ".tif",
                       full.names = TRUE)

# read in list at raster stack
stack <-rast(rast_list)
sources(stack) # check paths
stack
plot(stack[[1]])

# bring in swe change data
depth_change_csv <-read.csv("./in_situ/insitu_depth_change_v2.csv")
sensor_locations <-vect(depth_change_csv, geom = c("x","y"), crs = crs(stack))
plot(sensor_locations)
sensor_locations$name

# bring snow depth sensor locations shapefile for cropping
loc_raw <-vect("./vectors/pingers_location_new.shp")
locations <-project(loc_raw, crs(stack))
locations
values(locations)

# bring in BA it change data
pits_raw <-read.csv("./in_situ/pits_swe_change.csv")
pits_location <-vect(ba_raw, geom = c("x","y"), crs = crs(stack))
plot(pits_location, add = TRUE, col = 'red')
pits_location

# crop swe change stack, just for visualization purposes
ext(sensor_locations) # get extent
shp_ext <-ext(-106.5323, -106.5318, 35.8884, 35.889) # make a bit bigger for plotting
stack_crop <-terra::crop(stack, shp_ext)
plot(stack_crop[[3]])
points(sensor_locations, cex = 1)
points(pits_location, col = 'red')

# rasters from orginal stack
feb12_19 <-stack[[1]]
feb12_26 <-stack[[3]]
feb19_26 <-stack[[4]]

###########################
### compare insitu depth change to insar swe change
###########################

# check names and numbers
O2_1 <-terra::extract(feb12_19, sensor_locations[1],  cells = TRUE, xy = TRUE, method = 'bilinear')
E1_3 <-terra::extract(feb12_19, sensor_locations[2],  cells = TRUE, xy = TRUE, method = 'bilinear')
O1_4 <-terra::extract(feb12_19, sensor_locations[3],  cells = TRUE, xy = TRUE, method = 'bilinear')
O3_6 <-terra::extract(feb12_19, sensor_locations[4],  cells = TRUE, xy = TRUE, method = 'bilinear')
C2_7 <-terra::extract(feb12_19, sensor_locations[5],  cells = TRUE, xy = TRUE, method = 'bilinear')
E3_9 <-terra::extract(feb12_19, sensor_locations[6],  cells = TRUE, xy = TRUE, method = 'bilinear')
VG_met <-terra::extract(feb12_19, sensor_locations[7],  cells = TRUE, xy = TRUE, method = 'bilinear')

#### czo sensors
## feb 12-19
feb12_19_dswe <-terra::extract(feb12_19, sensor_locations,  cells = TRUE, xy = TRUE, method = 'bilinear')
feb12_19_dswe <-cbind(depth_change_csv$name,depth_change_csv$number, feb12_19_dswe)
feb12_19_dswe
colnames(feb12_19_dswe)[c(1,2,4)] <-c("name","number", "insar_feb12_19_dswe")
feb12_19_dswe

## feb 19-26
feb19_26_dswe <-terra::extract(feb19_26, sensor_locations,  cells = TRUE, xy = TRUE, method = 'bilinear')
feb19_26_dswe <-cbind(depth_change_csv$name,depth_change_csv$number, feb19_26_dswe )
colnames(feb19_26_dswe)[c(1,2,4)] <-c("name","number","insar_feb19_26_dswe")
feb19_26_dswe

## feb 12-26
feb12_26_dswe <-terra::extract(feb12_26, sensor_locations,  cells = TRUE, xy = TRUE, method = 'bilinear')
feb12_26_dswe <-cbind(depth_change_csv$name,depth_change_csv$number, feb12_26_dswe )
colnames(feb12_26_dswe)[c(1,2,4)] <-c("name","number","insar_feb12_26_dswe")
feb12_26_dswe

#### pits
## feb 12-19
pits_feb12_19_dswe <-terra::extract(feb12_19, pits_location,  cells = TRUE, xy = TRUE, method = 'bilinear')
colnames(pits_feb12_19_dswe)[2] <-"insar_feb12_19_dswe"
pits_feb12_19_dswe

## feb 19-26
pits_feb19_26_dswe <-terra::extract(feb19_26, pits_location,  cells = TRUE, xy = TRUE, method = 'bilinear')
colnames(pits_feb19_26_dswe)[2] <-"insar_feb19_26_dswe"
pits_feb19_26_dswe

## feb 12-26
pits_feb12_26_dswe <-terra::extract(feb12_26, pits_location,  cells = TRUE, xy = TRUE, method = 'bilinear')
colnames(pits_feb12_26_dswe)[2] <-"insar_feb12_26_dswe"
pits_feb12_26_dswe

# rbind pits data to insar change csvs
pits_dswe <-cbind(pits_raw, pits_feb12_19_dswe$insar_feb12_19_dswe, 
                pits_feb19_26_dswe$insar_feb19_26_dswe, pits_feb12_26_dswe$insar_feb12_26_dswe)

pits_dswe

# rename binded colums
names(pits_dswe)[7:9] <-c("insar_feb12_19_dswe","insar_feb19_26_dswe","insar_feb12_26_dswe")
pits_dswe

# create new df
depth_change_csv_v2 <-cbind(depth_change_csv, feb12_19_dswe$insar_feb12_19_dswe, feb19_26_dswe$insar_feb19_26_dswe,
                      feb12_26_dswe$insar_feb12_26_dswe)

depth_change_csv_v2


# rename binded colums
names(depth_change_csv_v2)[8:10] <-c("insar_feb12_19_dswe","insar_feb19_26_dswe","insar_feb12_26_dswe")
depth_change_csv_v2

###################
#### convert depth to SWE for noah's depth sensors
##################

swe_df <-depth_change_csv_v2

# new snow density, taking from interval board measurements 
new_snow_density <- .24

# for the second pair 
swe_df$feb19_26_dswe <-swe_df$feb19_26*.24
swe_df

# read in pit data
pit_info <-read.csv("./in_situ/perm_pits.csv")
pit_info

# calc bulk density, doesn't vary much
# this value will be used for the first pair because there was no new snow
bulk_density <-mean(pit_info$mean_density[6:7])/1000

# calc SWE change
swe_df$feb12_19_dswe <-swe_df$feb12_19*bulk_density
swe_df$feb12_26_dswe <-swe_df$feb12_26*bulk_density
swe_df

### add error term two swe calc
# 10% uncertainty density
# 1 cm uncertainty depth
swe_df$feb12_19_dswe_error <-abs(swe_df$feb12_19_dswe)-abs((-1+swe_df$feb12_19)*(bulk_density+(bulk_density*.1)))
swe_df$feb19_26_dswe_error <-abs(swe_df$feb19_26_dswe)-abs((1+swe_df$feb19_26)*(.24+(.24*.1)))
swe_df$feb12_26_dswe_error <-abs(swe_df$feb12_26_dswe)-abs((-1+swe_df$feb12_26)*(bulk_density+(bulk_density*.1)))
swe_df

#write.csv(sensor_csv_v2, "/Users/jacktarricone/ch1_jemez_data/climate_station_data/noah/insitu_insar_swe_change.csv")

#############################################
#### format df for plotting and analysis ####
#############################################

first <-rep(names(swe_df[5]), length = nrow(swe_df)) 
second <-rep(names(swe_df[6]), length = nrow(swe_df)) 
third <-rep(names(swe_df[7]), length = nrow(swe_df))
date <-c(first, second, third) # make vector
date

# repeat meta data
meta <-rbind(swe_df[1:4],swe_df[1:4],swe_df[1:4])

# bind date vector
add_date <-cbind(meta, date)
add_date

# make swe data column in proper order
insar_dswe <-c(swe_df$insar_feb12_19_dswe,
               swe_df$insar_feb19_26_dswe,
               swe_df$insar_feb12_26_dswe)

# make insitu column
insitu_dswe <-c(swe_df$feb12_19_dswe,
                swe_df$feb19_26_dswe,
                swe_df$feb12_26_dswe)

# error column
insitu_error<-c(swe_df$feb12_19_dswe_error,
                swe_df$feb19_26_dswe_error,
                swe_df$feb12_26_dswe_error)

# bind together
plotting_df <-cbind(add_date,insar_dswe,insitu_dswe,insitu_error)
plotting_df
# write.csv(plotting_df, "/Users/jacktarricone/ch1_jemez_data/climate_station_data/noah/insitu_insar_swe_change_plotting_df.csv")

######################
#### pits formatting ###
######################

# meta data
pits_meta <-rbind(pits_dswe[1:3],pits_dswe[1:3],pits_dswe[1:3])

# format pits dataframe for plotting
date_pits <-c(names(pits_dswe[4]), names(pits_dswe[5]), names(pits_dswe[6])) # make vector

# bind
add_data_pits <-cbind(date_pits,pits_meta)

# make swe data column in proper order
pits_insar_dswe <-c(pits_dswe$insar_feb12_19_dswe,
                    pits_dswe$insar_feb19_26_dswe,
                    pits_dswe$insar_feb12_26_dswe)

# make insitu column
pits_insitu_dswe <-c(pits_dswe$feb12_19,
                     pits_dswe$feb19_26,
                     pits_dswe$feb12_26)

# bind together
pits_plotting_df <-cbind(add_data_pits,pits_insar_dswe,pits_insitu_dswe)
pits_plotting_df


#####################
##### build plot ####
#####################

## new plot
my_colors <-c('darkgreen', 'plum', 'goldenrod')

# create new df for lm and plotting on graph
lm_df <-plotting_df[-c(1:5)]
lm_df

# add ba pit data 
ba_dat <-cbind(ba_plotting_df[-c(1:4)], rep(NA,3))
colnames(ba_dat) <-colnames(lm_df) 
ba_dat

# bbind
lm_df_v2 <-rbind(lm_df, ba_dat)
lm_df_v2
names(lm_df_v2)[1:2] <-c("y","x") # y = insar, x = insitu

# test
cor(lm_df_v2$y, lm_df_v2$x)
hmmt <-lm(lm_df_v2$y ~ lm_df_v2$x)
summary(hmmt)

# stats
# function for running lm, plotting equation and r2 
lm_eqn <- function(df){
  m <- lm(y ~ x, df);
  eq <- substitute(bold(y == a + b %.% x*","~~r^2~"="~r2),
                   list(a = format(unname(coef(m)[1]), digits = 2),
                        b = format(unname(coef(m)[2]), digits = 2),
                        r2 = format(summary(m)$r.squared, digits = 2)))
  as.character(as.expression(eq));
}



# plot
p <-ggplot(plotting_df, aes(x = insitu_dswe, y = insar_dswe)) +
  geom_abline(intercept = 0, slope = 1, linetype = 2) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_errorbar(aes(y= insar_dswe, xmin=insitu_dswe-abs(insitu_error), xmax=insitu_dswe+abs(insitu_error)), 
                 width=0.1, colour = 'black', alpha=0.4, size=.5) +
  geom_point(aes(color = date)) +  
  scale_y_continuous(limits = c(-10,10),breaks = c(seq(-10,10,2)),expand = (c(0,0))) +
  scale_x_continuous(limits = c(-10,10),breaks = c(seq(-10,10,2)),expand = (c(0,0))) +
  ylab(Delta~"SWE InSAR (cm)") + xlab(Delta~"SWE In Situ (cm)") +
  scale_color_manual(name = "InSAR Pair",
                     values = my_colors,
                     breaks = c('feb12_19', 'feb19_26', 'feb12_26'),
                     labels = c('Feb. 12-19', 'Feb. 19-26', 'Feb. 12-26'))+
  scale_fill_discrete(breaks=c('B', 'C', 'A'))  +
  theme_classic(15) +
  theme(panel.border = element_rect(colour = "black", fill=NA, linewidth =1)) +
  theme(legend.position = c(.80,.20))

p2 <- p + geom_point(data = ba_plotting_df, aes(x = ba_insitu_dswe, y = ba_insar_dswe), 
                     color = my_colors, shape = 8, size = 4)  

print(p2)


# create stats and make text labesl
rmse <-round(rmse(lm_df_v2$x, lm_df_v2$y), digits = 2)
mae <-round(mae(lm_df_v2$x, lm_df_v2$y), digits = 2)
rmse_lab <-paste0("RMSE = ",rmse," cm")
mae_lab <-paste0("MAE = ",mae," cm") 

# add labels
insitu <- p2 + geom_label(x = -4.5, y = 5.5, label = lm_eqn(lm_df_v2), parse = TRUE, label.size = NA, fontface = "bold") +
           geom_label(x = -4.5, y = 6.8, label = rmse_lab, label.size = NA, fontface = "bold") +
           geom_label(x = -4.5, y = 8.1, label = mae_lab, label.size = NA, fontface = "bold") 

print(insitu)

# save image, doesnt like back slahes in the name bc it's a file path... idk
# ggsave("./plots/in_situ_insar_fig12_BA.pdf",
#         width = 5, 
#         height = 5,
#         units = "in",
#         dpi = 500)

######################################
######################################
############### gpr ##################
######################################
######################################


#######
#######
## read in swe change data
dswe <-rast("./rasters/dswe/sp/dswe_feb12-26_sp.tif") # 
dswe_cm <-rast("./rasters/dswe/sp/dswe_feb12-26_cm.tif") # 
dswe
dswe_cm

# bring in 2/12-2/26 gpr data
gpr_feb26_minus_feb12_v1 <-rast("./rasters/gpr/feb26_minus_Feb12_bias_corrected1.tif")
gpr_feb26_minus_feb12 <-gpr_feb26_minus_feb12_v1/10 # convert to cm from mm
plot(gpr_feb26_minus_feb12)
hist(gpr_feb26_minus_feb12, breaks = 50)
#global(gpr_feb26_minus_feb12,mean,na.rm=T)

# resample gpr to same grid as unw, crop ext
dswe_crop <-crop(dswe, ext(gpr_feb26_minus_feb12)) # crop
dswe_cm_crop <-crop(dswe_cm, ext(gpr_feb26_minus_feb12)) # crop
gpr_feb26_minus_feb12 # check
dswe_crop # check
dswe_cm_crop # check

# test plot
plot(dswe_crop)
plot(dswe_cm_crop)
plot(gpr_feb26_minus_feb12, add = TRUE, col = "red")

# mask unw data with gpr
dswe_crop_mask <-mask(dswe_crop, gpr_feb26_minus_feb12, maskvalue = NA)
dswe_cm_crop_mask_v1 <-mask(dswe_cm_crop, gpr_feb26_minus_feb12, maskvalue = NA)
dswe_cm_crop_mask <-mask(dswe_cm_crop_mask_v1, dswe_crop_mask, maskvalue = NA)
f26_m_12_mask <-mask(gpr_feb26_minus_feb12, dswe_crop_mask, maskvalue = NA)

# plot only pixels that have data for both gpr and unw
plot(dswe_crop_mask)
plot(dswe_cm_crop_mask)
plot(f26_m_12_mask, add = TRUE, col = hcl.colors(12, "Berlin"))

# convert raster to dataframe
df <-as.data.frame(dswe_crop_mask, xy = TRUE, cells = TRUE, na.rm = TRUE)
cm_df <-as.data.frame(dswe_cm_crop_mask, xy = TRUE, cells = TRUE, na.rm = TRUE)
gpr_df <-as.data.frame(f26_m_12_mask, xy = TRUE, cells = TRUE, na.rm = TRUE)
head(gpr_df)
head(cm_df)

# gpr n pixels over o
number <-filter(gpr_df, feb26_minus_Feb12_bias_corrected1 > 0)
percent <-(nrow(number)/nrow(gpr_df))*100
percent

# bind the data frames
plotting_df_gpr <-cbind(df, cm_df[,4] ,gpr_df[,4])
head(plotting_df_gpr)
colnames(plotting_df_gpr)[4] <- "dswe_insar_isce" # rename col 4
colnames(plotting_df_gpr)[5] <- "dswe_insar_cm" # rename col 5
colnames(plotting_df_gpr)[6] <- "dswe_gpr" # rename col 6
head(plotting_df_gpr)

# quick hists
hist(plotting_df_gpr$dswe_gpr, breaks = 20)
hist(plotting_df_gpr$dswe_insar_isce, breaks = 20)
hist(plotting_df_gpr$dswe_insar_cm, breaks = 20)

####
# plotting
####

gpr <-ggplot(plotting_df_gpr, aes(y = dswe_insar_isce, x = dswe_gpr)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_abline(intercept = 0, slope = 1, linetype = 2) +
  scale_y_continuous(limits = c(-10,10),breaks = c(seq(-10,10,2)),expand = (c(0,0))) +
  scale_x_continuous(limits = c(-10,10),breaks = c(seq(-10,10,2)),expand = (c(0,0))) +
  geom_point(aes(color = "isce"), alpha = .5, size = 1) +
  scale_color_manual(name = "InSAR Pair",
                     values = c('isce' = 'goldenrod'),
                     labels = c('12-26 Feb.'))+
  labs(x = Delta~"SWE GPR (cm)",
       y = Delta~"SWE InSAR (cm)")+
  theme_classic(15) +
  theme(panel.border = element_rect(colour = "black", fill=NA, size = 1)) +
  theme(legend.position = c(.80,.15))

plot(gpr)

# create stats and make text labesl
rmse_v2 <-round(rmse(plotting_df_gpr$dswe_gpr, plotting_df_gpr$dswe_insar_isce), digits = 2)
mae_v2 <-round(mae(plotting_df_gpr$dswe_gpr, plotting_df_gpr$dswe_insar_isce), digits = 2)
rmse_lab_v2 <-paste0("RMSE = ",rmse_v2," cm")
mae_lab_v2 <-paste0("MAE = ",mae_v2," cm") 

# make gpr lm df
lm_df_gpr <-plotting_df_gpr[-c(1:3,5)]
head(lm_df_gpr)
names(lm_df_gpr)[1:2] <-c("y","x") # y = insar, x = gpr

# test lm
cor(lm_df_gpr$y, lm_df_gpr$x)
gpr_lm <-lm(lm_df_gpr$y ~ lm_df_gpr$x)
summary(gpr_lm)

# add labels
gpr_v2 <- gpr + geom_label(x = -4.5, y = 5.5, label = lm_eqn(lm_df_gpr), parse = TRUE, label.size = NA, fontface = "bold") +
  geom_label(x = -4.5, y = 6.8, label = rmse_lab_v2, label.size = NA, fontface = "bold") +
  geom_label(x = -4.5, y = 8.1, label = mae_lab_v2, label.size = NA, fontface = "bold") 

plot(gpr_v2)

# stack with cow plot
plot_grid(insitu, gpr_v2,
          labels = c("(a)","(b)"),
          align = "v", 
          nrow = 2, 
          rel_heights = c(1/2, 1/2))

# save
# ggsave("./plots/fig11.pdf",
#        width = 5,
#        height = 9,
#        units = "in",
#        dpi = 500)

