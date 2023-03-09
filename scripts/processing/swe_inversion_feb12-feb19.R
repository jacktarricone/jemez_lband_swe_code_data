# SWE inversion for 12-19 February
# jack tarricone

# import libraries
library(terra)
library(ggplot2)

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

# import corrected unwrapped phase data
unw_raw <-rast("./rasters/atm_corrected_unw/unw_corrected_new_feb12-19.tif")
plot(unw_raw)

# import i_angle raster in RADIANS and resample to unw grid bc of slight extent difference
lidar_inc_raw <-rast("./rasters/incidence_angle/lidar_inc_rad.tif")
lidar_inc_v1 <-resample(lidar_inc_raw, unw_raw)

# set crop extent to study area and crop
study_area <-vect("./vectors/study_area.geojson")
lidar_inc <-crop(lidar_inc_v1, study_area)

# mask and crop unwrapped phase data down to extent on new inc angle raster
unw_crop <-crop(unw_raw, study_area)
unw <-mask(unw_crop, lidar_inc)

# plot results
plot(lidar_inc)
plot(unw)

########################################################
######### converting phase change to SWE ##############
########################################################

# read in pit averages
pit_info <-read.csv("./in_situ/perm_pits.csv")
head(pit_info)

## define static information from pits
# calculate density
mean_density_feb12 <- pit_info$mean_density[1]
mean_density_feb19 <- pit_info$mean_density[2]

# mean density between two flights
mean_density_feb12_19 <-(mean_density_feb12 + mean_density_feb19)/2
mean_density_feb12_19

# dielectric constant k for each date
k_feb12 <- pit_info$mean_k[1]
k_feb19 <- pit_info$mean_k[2]

# mean k between two flights
mean_k_feb12_19 <-(k_feb12+k_feb19)/2
mean_k_feb12_19

#######################
#### swe inversion ####
#######################

# import depth_from_phase function
# translated this from the uavsar_pytools package
devtools::source_url("https://raw.githubusercontent.com/jacktarricone/snowex_uavsar/master/insar_swe_functions.R")

# radar wave length from uavsar annotation file
uavsar_wL <- 23.8403545

# testing
depth_change <-depth_from_phase(delta_phase = unw_snow_mask,
                                inc_angle = lidar_inc,
                                perm = mean_k_feb12_19,
                                wavelength = uavsar_wL)

# test plot
plot(depth_change)
hist(depth_change, breaks = 100)

# convert to SWE change by multipling by density
dswe_raw <-depth_change*(mean_density_feb12_19/1000)
plot(dswe_raw)
hist(dswe_raw, breaks = 100)
# writeRaster(dswe_raw,"./final_swe_change/raw_dswe_feb12_26.tif")


#######################################
### calculating absolute SWE change ###
#######################################

#### using swe change from the pit as "known" change point, which is 0 in this case
# extent around gpr transect
gpr <-ext(-106.5255, -106.521, 35.856, 35.8594)
dswe_crop <-crop(dswe_raw, gpr)
plot(dswe_crop)

# pull out location info into separate df
loc <-data.frame(lat = pit_info$lat[1],
                 lon = pit_info$lon[1])

# plot pit location using terra vector funcitonality
pit_point <-vect(loc, geom = c("lon","lat"), crs = crs(unw))
points(pit_point, cex = 1)

# extract cell number from pit lat/lon point
pit_cell_v1 <-cells(dswe_raw, pit_point)
cell_number <-pit_cell_v1[1,2]
cell_number

# define neighboring cells by number and create a vector
neighbor_cells <-c(adjacent(dswe_raw, cells = cell_number, directions ="8"))

# add original cell back to vector
cell_vector <-c(cell_number, neighbor_cells)

# extract using that vector
nine_cell_dswe <-terra::extract(dswe_raw, cell_vector, xy = TRUE)
nine_cell_dswe

# mean of 9 swe changes around
mean_pit_dswe <-mean(nine_cell_dswe[1:9,3])
mean_pit_dswe

# subtract average swe change value to great absolute swe change
# therefor pixels around the pit will show no swe change
# which is consistent with what was observed on the ground
dswe_abs <-dswe_raw - mean_pit_dswe
plot(dswe_abs)
hist(dswe_abs, breaks = 100)

####################################
###### bring in fsca layers ########
####################################

# fsca
snow_mask <-rast("./rasters/fsca/study_area_02_18_2020_snow_mask.tif")

# masked the unwrapped phase with snow mask
dswe_abs_masked <-mask(dswe_abs, snow_mask, maskvalue = NA)
plot(dswe_abs_masked)
plot(dswe_abs_masked)

# save
# writeRaster(dswe_abs_masked,"./rasters/dswe/dswe_feb12-19.tif")

