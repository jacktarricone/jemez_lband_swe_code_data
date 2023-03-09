# north and south facing slopes categorization
# of lidar raster

library(terra)

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

# bring in aspect rast
aspect <-rast("./rasters/incidence_angle/aspect_uavsar_grd.tif")
plot(aspect)
aspect


# set nouth/south classes
aspect_classes2 <-matrix(c(270,360,1, 0,90,1, # 1 = north
                           90,270,2),          # 2 = south
                           ncol=3, byrow=TRUE)

# classify
directions_ns <-classify(aspect, rcl = aspect_classes2)
plot(directions_ns)
# writeRaster(directions_ns, "./rasters/incidence_angle/ns_aspect.tif")
