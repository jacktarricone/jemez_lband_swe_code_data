# fsca stats
# jack tarricone

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd

# read in fsca rasters
# full
feb_fsca <-rast("./rasters/fsca/landsat_fsca_2-18.tif")
feb_mask <-rast("./rasters/fsca/0218_mask.tif")
mar_fsca <-rast("./rasters/fsca/landsat_fsca_3-05.tif")
mar_mask <-rast("./rasters/fsca/0305_mask.tif")

# no NaN
full <-rast("./rasters/fsca/landsat_fsca_3-05_w0.tif")

# read in vg aoi
vg_aoi <-vect("./vectors/study_area.geojson")

# crop to vg
vg_feb_fsca <-crop(feb_fsca, vg_aoi)
vg_feb_mask <-crop(feb_mask, vg_aoi)
vg_mar_fsca <-crop(mar_fsca, vg_aoi)
vg_mar_mask <-crop(mar_mask, vg_aoi)
vg_full <-crop(full, vg_aoi)

## test plot
# feb
plot(feb_fsca)
plot(feb_mask, add = TRUE, col = "red")
plot(vg_aoi, add = TRUE)

# march
plot(mar_fsca)
plot(mar_mask, add = TRUE, col = "red")

### calculate percent area with no snow for full scene
full_area <-expanse(full, unit = "km")

# feb
feb_snow <-expanse(feb_fsca, unit = "km")
feb_no_snow <-expanse(feb_mask, unit = "km")
feb_perecent_no_snow <-(feb_no_snow/full_area)*100

# mar
mar_snow <-expanse(mar_fsca, unit = "km")
mar_no_snow <-expanse(mar_mask, unit = "km")
mar_perecent_no_snow <-(mar_no_snow/full_area)*100

## for vg aoi only
vg_full_area <-expanse(vg_full, unit = "km")

# feb
vg_feb_snow <-expanse(vg_feb_fsca, unit = "km")
vg_feb_no_snow <-expanse(vg_feb_mask, unit = "km")
vg_feb_perecent_no_snow <-(vg_feb_no_snow/vg_full_area)*100

# mar
vg_mar_snow <-expanse(vg_mar_fsca, unit = "km")
vg_mar_no_snow <-expanse(vg_mar_mask, unit = "km")
vg_mar_perecent_no_snow <-(vg_mar_no_snow/vg_full_area)*100

