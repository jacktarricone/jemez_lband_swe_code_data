# create lvk raster

library(terra)

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd


###########################################################
##### read in look vector new geotiffs from python code ###
###########################################################

# LKV file (.lkv): look vector at the target pointing from the aircraft to the ground, 
# in ENU (east, north, up) components.


# up in meters
east <-rast("./rasters/lvk/alamos_35915_01_BU_s1_2x8.lkv.x.tif")
east
plot(east)

# north in meters
north <-rast("/Users/jacktarricone/ch1_jemez_data/feb12-19_slc/BU/geocoded_north.tif")
north
plot(north)

# east in meters
east <-rast("/Users/jacktarricone/ch1_jemez_data/feb12-19_slc/BU/geocoded_east.tif")
east
plot(east)

# function triangulate distance to plane from up and east rasters
lvk_km_convert <-function(east_rast, up_rast, north_rast){
  
  lvk_m <-((east_rast^2)+(up_rast^2)+(north_rast^2))^.5
  plot(lvk_m)
  lvk_km <-lvk_m/1000
  return(lvk_km)
  
}

# convert
lvk_km <-lvk_km_convert(east,up,north)
values(lvk_km)[values(lvk_km) == 0] = NA
plot(lvk_km)
lvk_km
# writeRaster(lvk_km, "lvk_km_good.tif")