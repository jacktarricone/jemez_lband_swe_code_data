# create new incidence angle data from lidar dem and geocoded lvk from SLC data
# jack tarricone

####
# using the function cgrad, from the insol package
# calculate the 3d (x,y,z) unit vector for a valle grande crop of the lidar dem
# then add? not sur yet, to make surface normal vector

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

library(terra)
library(raster)
library(insol) # https://rdrr.io/cran/insol/man/cgrad.html


# notes from meeting with HP October 25th

### creating new incidence angle raster from CZO LiDAR data
# will be used for SWE inversion of UAVSAR data

## steps
# 1.create slope, aspect rasters from filtered DEM
# 2.reproject and resample lidar data products to UAVSAR projection (wsg-84, lat/lon)
# 3.use these resampled products to create new .inc file

# function to calculate "gradient" of LiDAR raster (vector)
# three component vector (easting, northing, 3 component vector)
# calculate dot product and calculate the angle
# dot product of gradient from lidar raster and path length vector (n1*n2+e1*e2+up1*up2)
# cos^-1((n1*n2+e1*e2+up1*up2)/(distance calc through atm for each vector))

# packages in r or python for calculating gradients and surface normals


#########################################################################

# bring in lidar dem with raster not terra
# switched back to using the raster package bc cgrad can injest only rasters not SpatRasters!
# lidar_dem <-raster("/Users/jacktarricone/ch1_jemez_data/jemez_lidar/valles_elev_filt.img")
# plot(lidar_dem, col = terrain.colors(3000)) # test plot
# 
# # crop down
# crop_ext <-extent(359000, 374000, 3965000, 3980000) # set vg UTM extent for raster
# crop_ext_sr <-ext(359000, 374000, 3965000, 3980000) # for spatrast
# lidar_crop <-crop(lidar_dem, crop_ext)
# writeRaster(lidar_crop, "/Users/jacktarricone/ch1_jemez_data/jemez_lidar/jemez_lidar_crop.tif")

# bring in lidar crop
## use raster not rast
lidar_dem <-raster("./rasters/dem/jemez_lidar_crop.tif")
plot(lidar_dem, col = terrain.colors(3000)) # test, good

########
# calculate the gradient in all three dimensions
# this function create a matrix for the x,y,z competent of a unit vector
########

grad_mat <-cgrad(lidar_dem, 1, 1, cArea = FALSE)

# make individual raster layer for each competent
# and geocode back to original crop extent
# switch back to terra
lidar_rast <-rast(lidar_dem)
crop_ext_sr <-ext(359000, 374000, 3965000, 3980000) # for spatrast

## x
x_comp <-rast(grad_mat[,,1], crs = crs(lidar_rast))
ext(x_comp) <-ext(lidar_rast)
plot(x_comp)

## y
y_comp <-rast(grad_mat[,,2], crs = crs(lidar_rast))
ext(y_comp) <-ext(lidar_rast)
plot(y_comp)

## z
z_comp <-rast(grad_mat[,,3], crs = crs(lidar_rast))
ext(z_comp) <-ext(lidar_rast)
plot(z_comp)

rm(grad_mat)

#################################
# bring in look vector data #####
#################################

# read in lvk file we made before
lvk_km <-rast("./rasters/lvk/lkv_km.tif")
lvk_m <-lvk_km*1000
plot(lvk_km)

# lidar latlon
lidar_ll <-project(lidar_crop_spat, crs(lvk_km))
plot(lidar_ll)

# east
radar_east_v1 <-rast("./rasters/lvk/alamos_35915_01_BU_s1_2x8.lkv.y.tif")
radar_east <-resample(radar_east_v1, lvk_m)

# north
radar_north_v1 <-rast("./rasters/lvk/alamos_35915_01_BU_s1_2x8.lkv.x.tif")
radar_north <-resample(radar_north_v1, lvk_m)

# up
radar_up_v1 <-rast("./rasters/lvk/alamos_35915_01_BU_s1_2x8.lkv.z.tif")
radar_up <-resample(radar_up_v1, lvk_m)

######
# resample to uavsar grid
######
# x
x_rs_v1 <-project(x_comp, radar_east, method = "bilinear")
x_rs <-resample(x_rs_v1, radar_east, method = "bilinear")
x_rs
radar_east

# y
y_rs_v1 <-project(y_comp, radar_north, method = "bilinear")
y_rs <-resample(y_rs_v1, radar_north, method = "bilinear")
y_rs
radar_north

# z
z_rs_v1 <-project(z_comp, radar_up, method = "bilinear")
z_rs <-resample(z_rs_v1, radar_up, method = "bilinear")
z_rs
radar_up

### dot product formula
# cos^-1((y_rs*radar_north+x_rs*radar_east+z_rs*radar_up)/(distance calc through atm for each vector))

# calculate surface normal
dot_prod <-(y_rs*radar_north + x_rs*radar_east+ z_rs*radar_up)
plot(dot_prod)

# compute the dot product to get a inc. angle in radians
# make sure to put the negative sign!
## rad
inc_ang_rad <-(acos)(-dot_prod/(lvk_m))
plot(inc_ang_rad)

# deg
inc_ang_deg <-inc_ang_rad*(180/pi)
plot(inc_ang_deg)

## save
# writeRaster(inc_ang_deg, "./rasters/incidence_angle/lidar_inc_deg.tif")
# writeRaster(inc_ang_rad, "./rasters/incidence_angle/lidar_inc_rad.tif")

















