# jack tarricone
# jemez UAVSAR slc stack data

# converting the binary look vector file (.lkv) from binary into 3 different rasters (easting, northing, elevation)
# converting binary binary lat, lon, elevation file into rasters to base the lvk data off

library(terra)
library(data.table)

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

# set paths
lkv_path <-"./rasters/slc/alamos_35915_01_BU_s1_2x8.lkv"
llh_path <-"./rasters/slc/alamos_35915_01_BU_s1_2x8.llh"

# read in the look vector data
lkv <-readBin(lkv_path, what = "numeric", n = 2^30, size = 4, endian = "little")
lkv_mat <-as.data.frame(lkv)
head(lkv_mat)

# sequence every third number, convert to data matrix with correct number of rows
east <-rast(matrix(lkv_mat[seq(1, nrow(lkv_mat),3),], nrow = 8628, byrow = TRUE))
north <-rast(matrix(lkv_mat[seq(2, nrow(lkv_mat),3),], nrow = 8628, byrow = TRUE))
up <-rast(matrix(lkv_mat[seq(3, nrow(lkv_mat),3),], nrow = 8628, byrow = TRUE))

# read in the lat/lon/ele data
llh <-readBin(llh_path, what = "numeric", n = 2^30, size = 4, endian = "little")
llh_mat <-as.data.frame(llh)
head(llh_mat)

# seqence every third number, convert to data matrix with correct number of rows, convert to raster
lat <-rast(matrix(llh_mat[seq(1, nrow(llh_mat),3),], nrow = 8628, byrow = TRUE))
lon <-rast(matrix(llh_mat[seq(2, nrow(llh_mat),3),], nrow = 8628, byrow = TRUE))
ele <-rast(matrix(llh_mat[seq(3, nrow(llh_mat),3),], nrow = 8628, byrow = TRUE))

# save
makeVRT(east, "./rasters/lvk/east.vrt")
writeRaster(west, "./rasters/lkv/west.tif")
writeRaster(up, "./rasters/lkv/up.tif")