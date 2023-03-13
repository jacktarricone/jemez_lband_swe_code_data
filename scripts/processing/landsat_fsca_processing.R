# format fsca data, make dsca and masks, and resample dswe to 30m
# jack tarricone

library(terra)
library(sf)

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

# uavsar swath extent shapefile
uavsar_shp <-vect("./vectors/jpl_dem_extent.shp")

# feb 18th 2020
# bringg in raw fSCA feb 18th data downloaded from landsat web portal
fsca_0218_raw_v1 <-rast("./rasters/fsca/LC08_CU_010012_20200218_20200227_C01_V01_SNOW.tif")
fsca_0218_raw_v2 <-fsca_0218_raw_v1/10 # correct [%] scale
plot(fsca_0218_raw_v2)

# reproj, format, save
values(fsca_0218_raw_v2)[values(fsca_0218_raw_v2) == 0] = NA # if above 0 then NA
feb_reproj <-project(fsca_0218_raw_v2, "EPSG:4326") # project
feb_reproj_v2 <-mask(feb_reproj, uavsar_shp) # mask
feb_reproj_v3 <-crop(feb_reproj_v2, ext(uavsar_shp)) # crop ext
feb_reproj_v3
plot(feb_reproj_v3)
# writeRaster(reproj_v3, "./rasters/fsca/landsat_fsca_2-18.tif")

# make no pixel mask for 2/18
fsca_0218_raw_v3 <-subst(fsca_0218_raw_v2,0,-999) # sub -999 for 0
values(fsca_0218_raw_v3)[values(fsca_0218_raw_v3) > 0] = NA # if above 0 then NA
mask_v1 <-project(fsca_0218_raw_v3, "EPSG:4326") # project
mask_v2 <-mask(mask_v1, uavsar_shp) # mask
mask_v3 <-crop(mask_v2, ext(uavsar_shp)) # crop ext
plot(mask_v3)
values(mask_v3)[values(mask_v3) < -999] = -999 # if above 0 then NA
plot(mask_v3)
# writeRaster(mask_v3, "./rasters/fsca/0218_mask.tif")


########################
#### march 5th 2020 ####
########################

# bring in raw fSCA 5 March
fsca_0305_raw_v1 <-rast("./rasters/fsca/LC08_CU_010012_20200305_20200316_C01_V01_SNOW.tif")
fsca_0305_raw_v2 <-fsca_0305_raw_v1/10 # correct [%] scale
plot(fsca_0305_raw_v2)

# reproj, format, save with 0 instead of NaN
test <-project(fsca_0305_raw_v2, "EPSG:4326") # project
test_v1 <-mask(test, uavsar_shp) # mask
test_v2 <-crop(test_v1, ext(uavsar_shp)) # crop ext
test_v2
plot(test_v2)
# writeRaster(test_v2, "./rasters/fsca/landsat_fsca_3-05_w0.tif")

# reproj, format, save
values(fsca_0305_raw_v2)[values(fsca_0305_raw_v2) == 0] = NA # if above 0 then NA
test <-project(fsca_0305_raw_v2, "EPSG:4326") # project
test_v1 <-mask(test, uavsar_shp) # mask
test_v2 <-crop(test_v1, ext(uavsar_shp)) # crop ext
test_v2
plot(test_v2)
# writeRaster(test_v2, "./rasters/fsca/landsat_fsca_3-05.tif")

# make no pixel mask for 5 march
fsca_0305_raw_v12 <-fsca_0305_raw_v1/10 # correct [%] scale
fsca_0305_raw_v3 <-subst(fsca_0305_raw_v12,0,-999) # sub -999 for 0
values(fsca_0305_raw_v3)[values(fsca_0305_raw_v3) > 0] = NA # if above 0 then NA
plot(fsca_0305_raw_v3)
mar_mask_v1 <-project(fsca_0305_raw_v3, "EPSG:4326") # project
mar_mask_v2 <-mask(mar_mask_v1, uavsar_shp) # mask
mar_mask_v3 <-crop(mar_mask_v2, ext(uavsar_shp)) # crop ext
plot(mar_mask_v3)
# writeRaster(mar_mask_v3, "./rasters/fsca/0305_mask.tif")

# create delta fsca product
dfsca <-fsca_0305_raw_v2 - fsca_0218_raw_v2
plot(dfsca)

# reproject to lat/lon
dfsca <-project(dfsca, "EPSG:4326")
dsca_m <-mask(dfsca, uavsar_shp) # mask
dfsca_cm <-crop(dsca_m, ext(uavsar_shp)) # crop ext
plot(dfsca_cm)
# writeRaster(dfsca_cm, "./rasters/fsca/dfsca_uavsar.tif")

# bring in DEM
dswe <-rast("./rasters/dswe/dswe_feb19-26.tif")
dswe
plot(dswe)

# crop to extent of SWE data
dfsca_crop <-crop(dfsca, ext(dswe))
plot(dfsca_crop)

# resample SWE data up to 30m landsat
dswe_30m <-resample(dswe, dfsca_crop, method = "bilinear")
dswe_30m
plot(dswe_30m)
# writeRaster(dswe_30m, "./rasters/fsca/dswe_30m.tif")
