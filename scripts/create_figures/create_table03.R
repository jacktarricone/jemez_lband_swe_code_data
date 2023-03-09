######################
### create table 3 ###
######################

### unwrapped phase and coherence stats
### for all three insar pairs
### jack tarricone

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
setwd("~/ch1_jemez/jemez_lband_swe_code_data")
list.files() #pwd

### feb 12-19

## bring in vallee grand wkt
vg <-vect("./vectors/study_area.geojson")
vg

######
######
# p1 #
######
######

# feb 12-19
p1_hh_cor <-rast("./rasters/uavsar_p1_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090HH_01.cor.grd.tiff")
plot(p1_hh_cor)

## calc # of pixels in scene
p1_total_pixels <-as.numeric(global(p1_hh_cor, fun="notNA"))

## calc # of pixels in study area
hh_cor_study_area <-crop(p1_hh_cor, vg)
hh_cor_study_area
study_area_pixels <-as.numeric(global(hh_cor_study_area, fun="notNA"))

####
## coherence stats
### 

######
# p1 #
######

# hh mean full scene
p1_cor_hh_full_mean <-round(as.numeric(global(p1_hh_cor, mean, na.rm = TRUE)), digits = 2)

# vv mean full scene
p1_cor_vv <-rast("./rasters/uavsar_p1_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090VV_01.cor.grd.tiff")
p1_cor_vv_full_mean <-round(as.numeric(global(p1_cor_vv, mean, na.rm = TRUE)), digits = 2)

# hh mean study area
p1_cor_hh_vg <-crop(p1_hh_cor, vg)
p1_cor_hh_vg_mean <-round(as.numeric(global(p1_cor_hh_vg, mean, na.rm = TRUE)), digits = 2)

# vv mean study area
p1_cor_vv_vg <-crop(p1_cor_vv, vg)
p1_cor_vv_vg_mean <-round(as.numeric(global(p1_cor_vv_vg, mean, na.rm = TRUE)), digits = 2)


###############
## unw stats ##
###############

# hh full scene pixels lost
p1_unw_hh <-rast("./rasters/uavsar_p1_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090HH_01.unw.grd.tiff")
unw_hh_pixels <-as.numeric(global(p1_unw_hh, fun="notNA"))
p1_unw_hh_perc_lost <-round(100-(unw_hh_pixels/p1_total_pixels)*100, digits = 1)

# vv full scene pixels lost
p1_unw_vv <-rast("./rasters/uavsar_p1_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090VV_01.unw.grd.tiff")
unw_vv_pixels <-as.numeric(global(p1_unw_vv, fun="notNA"))
p1_unw_vv_perc_lost <-round(100-(unw_vv_pixels/p1_total_pixels)*100, digits = 1)

# hh
p1_unw_hh_vg <-crop(p1_unw_hh, vg)
p1_unw_hh_vg_pixels <-as.numeric(global(p1_unw_hh_vg, fun="notNA"))
p1_unw_hh_vg_perc_lost_vg <-round(100-(unw_hh_vg_pixels/study_area_pixels)*100, digits = 1)

# vv
p1_unw_vv_vg <-crop(p1_unw_vv, vg)
p1_unw_vv_vg_pixels <-as.numeric(global(p1_unw_vv_vg, fun="notNA"))
p1_unw_vv_vg_perc_lost_vg <-round(100-(p1_unw_vv_vg_pixels/study_area_pixels)*100, digits = 1)








######
######
# p2 #
######
######

# feb 12-19
p2_hh_cor <-rast("./rasters/uavsar_p2_feb19-26/alamos_35915_20008-000_20013-000_0007d_s01_L090HH_01.cor.grd.tiff")

## calc # of pixels in scene
p2_total_pixels <-as.numeric(global(p2_hh_cor, fun="notNA"))

## calc # of pixels in study area
hh_cor_study_area <-crop(p2_hh_cor, vg)
hh_cor_study_area
study_area_pixels <-as.numeric(global(hh_cor_study_area, fun="notNA"))

####################
## coherence stats #
####################

# hh mean full scene
p2_cor_hh_full_mean <-round(as.numeric(global(p2_hh_cor, mean, na.rm = TRUE)), digits = 2)

# vv mean full scene
p2_cor_vv <-rast("./rasters/uavsar_p2_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090VV_01.cor.grd.tiff")
p2_cor_vv_full_mean <-round(as.numeric(global(p2_cor_vv, mean, na.rm = TRUE)), digits = 2)

# hh mean study area
p2_cor_hh_vg <-crop(p2_hh_cor, vg)
p2_cor_hh_vg_mean <-round(as.numeric(global(p2_cor_hh_vg, mean, na.rm = TRUE)), digits = 2)

# vv mean study area
p2_cor_vv_vg <-crop(p2_cor_vv, vg)
p2_cor_vv_vg_mean <-round(as.numeric(global(p2_cor_vv_vg, mean, na.rm = TRUE)), digits = 2)


###############
## unw stats ##
###############

# hh full scene pixels lost
p2_unw_hh <-rast("./rasters/uavsar_p2_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090HH_01.unw.grd.tiff")
unw_hh_pixels <-as.numeric(global(p2_unw_hh, fun="notNA"))
p2_unw_hh_perc_lost <-round(100-(unw_hh_pixels/p2_total_pixels)*100, digits = 1)

# vv full scene pixels lost
p2_unw_vv <-rast("./rasters/uavsar_p2_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090VV_01.unw.grd.tiff")
unw_vv_pixels <-as.numeric(global(p2_unw_vv, fun="notNA"))
p2_unw_vv_perc_lost <-round(100-(unw_vv_pixels/p2_total_pixels)*100, digits = 1)

# hh
p2_unw_hh_vg <-crop(p2_unw_hh, vg)
p2_unw_hh_vg_pixels <-as.numeric(global(p2_unw_hh_vg, fun="notNA"))
p2_unw_hh_vg_perc_lost_vg <-round(100-(unw_hh_vg_pixels/study_area_pixels)*100, digits = 1)

# vv
p2_unw_vv_vg <-crop(p2_unw_vv, vg)
p2_unw_vv_vg_pixels <-as.numeric(global(p2_unw_vv_vg, fun="notNA"))
p2_unw_vv_vg_perc_lost_vg <-round(100-(p2_unw_vv_vg_pixels/study_area_pixels)*100, digits = 1)





# feb 19-26
p2_hh_cor <-rast("./rasters/uavsar_p2_feb19-26/alamos_35915_20008-000_20013-000_0007d_s01_L090HH_01.cor.grd.tiff")
p2_total_pixels <-as.numeric(global(p2_hh_cor, fun="notNA"))






# feb 12-26
p3_hh_cor <-rast("./rasters/uavsar_p3_feb12-26/alamos_35915_20005-003_20013-000_0014d_s01_L090HH_01.cor.grd.tiff")
plot(p3_hh_cor)
p3_total_pixels <-as.numeric(global(p3_hh_cor, fun="notNA"))
