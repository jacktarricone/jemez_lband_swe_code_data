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
lidar_crop_spat <-rast(lidar_dem)
crop_ext_sr <-ext(359000, 374000, 3965000, 3980000) # for spatrast

## x
x_comp <-rast(grad_mat[,,1], crs = crs(lidar_dem))
ext(x_comp) <-ext(crop_ext_sr)
plot(x_comp)

## y
y_comp <-rast(grad_mat[,,2], crs = crs(lidar_dem))
ext(y_comp) <-ext(crop_ext_sr)
plot(y_comp)

## z
z_comp <-rast(grad_mat[,,3], crs = crs(lidar_dem))
ext(z_comp) <-ext(crop_ext_sr)
plot(z_comp)

#################################
# bring in look vector data #####
#################################

# read in lvk file we made before
lvk_km <-rast("./rasters/lvk/lkv_km.tif")
lvk_m <-lvk_km*1000
plot(lvk_km)

# east
radar_east_raw <-rast("./rasters/lvk/alamos_35915_01_BU_s1_2x8.lkv.y.tif")
plot(radar_east_raw)

# north
radar_north_raw <-rast("./rasters/lvk/alamos_35915_01_BU_s1_2x8.lkv.x.tif")
plot(radar_north_raw)

# up
radar_up_raw <-rast("./rasters/lvk/alamos_35915_01_BU_s1_2x8.lkv.y.tif")
plot(radar_up_raw)


######
# resample surface vector components up to 5.6m
######
x_rs <-resample(x_comp, lvk_m, method = "bilinear")
y_rs <-resample(y_comp, lvk_m, method = "bilinear")
z_rs <-resample(z_comp, lvk_m, method = "bilinear")


# cos^-1((y_rs*radar_north+x_rs*radar_east+z_rs*radar_up)/(distance calc through atm for each vector))

# calculate surface normal
dot_prod <-(y_rs*radar_north + x_rs*radar_east + z_rs*radar_up)
plot(dot_prod)

# compute the dot product to get a inc. angle in radians
# make sure to put the negative sign!
inc_ang_rad <-(acos)(-dot_prod/(lvk_km*1000))
plot(inc_ang_rad)
inc_ang_deg <-inc_ang_rad*(180/pi)
plot(inc_ang_deg)

writeRaster(inc_ang_deg, "/Users/jacktarricone/ch1_jemez_data/gpr_rasters_ryan/lidar_inc_deg.tif")
writeRaster(inc_ang_rad, "/Users/jacktarricone/ch1_jemez_data/gpr_rasters_ryan/lidar_inc_rad.tif")

















