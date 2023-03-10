######################
### create table 3 ###
######################

### unwrapped phase and coherence stats
### for all three insar pairs

# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative
setwd("path/to/jemez_lband_swe_code_data")
setwd("~/ch1_jemez/jemez_lband_swe_code_data")
list.files() #pwd


## bring in vallee grand wkt
vg <-vect("./vectors/study_area.geojson")
vg

######
######
# p1 #
######
######

# bring in cor rast
p1_hh_cor <-rast("./rasters/uavsar_p1_feb12-19/alamos_35915_20005-003_20008-000_0007d_s01_L090HH_01.cor.grd.tiff")
plot(p1_hh_cor)

## calc # of pixels in scene
p1_total_pixels <-as.numeric(global(p1_hh_cor, fun="notNA"))

## calc # of pixels in study area
p1_hh_cor_study_area <-crop(p1_hh_cor, vg)
p1_study_area_pixels <-as.numeric(global(p1_hh_cor_study_area, fun="notNA"))

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
p1_unw_hh_vg_perc_lost_vg <-round(100-(p1_unw_hh_vg_pixels/p1_study_area_pixels)*100, digits = 1)

# vv
p1_unw_vv_vg <-crop(p1_unw_vv, vg)
p1_unw_vv_vg_pixels <-as.numeric(global(p1_unw_vv_vg, fun="notNA"))
p1_unw_vv_vg_perc_lost_vg <-round(100-(p1_unw_vv_vg_pixels/p1_study_area_pixels)*100, digits = 1)








######
######
# p2 #
######
######

p2_hh_cor <-rast("./rasters/uavsar_p2_feb19-26/alamos_35915_20008-000_20013-000_0007d_s01_L090HH_01.cor.grd.tiff")

## calc # of pixels in scene
p2_total_pixels <-as.numeric(global(p2_hh_cor, fun="notNA"))

## calc # of pixels in study area
p2_hh_cor_study_area <-crop(p2_hh_cor, vg)
p2_study_area_pixels <-as.numeric(global(p2_hh_cor_study_area, fun="notNA"))

####################
## coherence stats #
####################

# hh mean full scene
p2_cor_hh_full_mean <-round(as.numeric(global(p2_hh_cor, mean, na.rm = TRUE)), digits = 2)

# vv mean full scene
p2_cor_vv <-rast("./rasters/uavsar_p2_feb19-26/alamos_35915_20008-000_20013-000_0007d_s01_L090VV_01.cor.grd.tiff")
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
p2_unw_hh <-rast("./rasters/uavsar_p2_feb19-26/alamos_35915_20008-000_20013-000_0007d_s01_L090HH_01.unw.grd.tiff")
unw_hh_pixels <-as.numeric(global(p2_unw_hh, fun="notNA"))
p2_unw_hh_perc_lost <-round(100-(unw_hh_pixels/p2_total_pixels)*100, digits = 1)

# vv full scene pixels lost
p2_unw_vv <-rast("./rasters/uavsar_p2_feb19-26/alamos_35915_20008-000_20013-000_0007d_s01_L090VV_01.unw.grd.tiff")
unw_vv_pixels <-as.numeric(global(p2_unw_vv, fun="notNA"))
p2_unw_vv_perc_lost <-round(100-(unw_vv_pixels/p2_total_pixels)*100, digits = 1)

# hh
p2_unw_hh_vg <-crop(p2_unw_hh, vg)
p2_unw_hh_vg_pixels <-as.numeric(global(p2_unw_hh_vg, fun="notNA"))
p2_unw_hh_vg_perc_lost_vg <-round(100-(p2_unw_hh_vg_pixels/p2_study_area_pixels)*100, digits = 1)

# vv
p2_unw_vv_vg <-crop(p2_unw_vv, vg)
p2_unw_vv_vg_pixels <-as.numeric(global(p2_unw_vv_vg, fun="notNA"))
p2_unw_vv_vg_perc_lost_vg <-round(100-(p2_unw_vv_vg_pixels/p2_study_area_pixels)*100, digits = 1)







######
######
# p3 #
######
######

p3_hh_cor <-rast("./rasters/uavsar_p3_feb12-26/alamos_35915_20005-003_20013-000_0014d_s01_L090HH_01.cor.grd.tiff")

## calc # of pixels in scene
p3_total_pixels <-as.numeric(global(p3_hh_cor, fun="notNA"))

## calc # of pixels in study area
p3_hh_cor_study_area <-crop(p3_hh_cor, vg)
p3_study_area_pixels <-as.numeric(global(p3_hh_cor_study_area, fun="notNA"))

####################
## coherence stats #
####################

# hh mean full scene
p3_cor_hh_full_mean <-round(as.numeric(global(p3_hh_cor, mean, na.rm = TRUE)), digits = 2)

# vv mean full scene
p3_cor_vv <-rast("./rasters/uavsar_p3_feb12-26/alamos_35915_20005-003_20013-000_0014d_s01_L090VV_01.cor.grd.tiff")
p3_cor_vv_full_mean <-round(as.numeric(global(p3_cor_vv, mean, na.rm = TRUE)), digits = 2)

# hh mean study area
p3_cor_hh_vg <-crop(p3_hh_cor, vg)
p3_cor_hh_vg_mean <-round(as.numeric(global(p3_cor_hh_vg, mean, na.rm = TRUE)), digits = 2)

# vv mean study area
p3_cor_vv_vg <-crop(p3_cor_vv, vg)
p3_cor_vv_vg_mean <-round(as.numeric(global(p3_cor_vv_vg, mean, na.rm = TRUE)), digits = 2)


###############
## unw stats ##
###############

# hh full scene pixels lost
p3_unw_hh <-rast("./rasters/uavsar_p3_feb12-26/alamos_35915_20005-003_20013-000_0014d_s01_L090HH_01.unw.grd.tiff")
unw_hh_pixels <-as.numeric(global(p3_unw_hh, fun="notNA"))
p3_unw_hh_perc_lost <-round(100-(unw_hh_pixels/p3_total_pixels)*100, digits = 1)

# vv full scene pixels lost
p3_unw_vv <-rast("./rasters/uavsar_p3_feb12-26/alamos_35915_20005-003_20013-000_0014d_s01_L090VV_01.unw.grd.tiff")
unw_vv_pixels <-as.numeric(global(p3_unw_vv, fun="notNA"))
p3_unw_vv_perc_lost <-round(100-(unw_vv_pixels/p3_total_pixels)*100, digits = 1)

# hh
p3_unw_hh_vg <-crop(p3_unw_hh, vg)
p3_unw_hh_vg_pixels <-as.numeric(global(p3_unw_hh_vg, fun="notNA"))
p3_unw_hh_vg_perc_lost_vg <-round(100-(p3_unw_hh_vg_pixels/study_area_pixels)*100, digits = 1)

# vv
p3_unw_vv_vg <-crop(p3_unw_vv, vg)
p3_unw_vv_vg_pixels <-as.numeric(global(p3_unw_vv_vg, fun="notNA"))
p3_unw_vv_vg_perc_lost_vg <-round(100-(p3_unw_vv_vg_pixels/study_area_pixels)*100, digits = 1)



## create dataframe
table02 <-data.frame("name" = c("pair1", "pair1", "pair2", "pair2","pair3", "pair3"),
                         "Polarization" = c("HH","VV","HH","VV","HH","VV"),
                         "FS Mean Coherence" = c(p1_cor_hh_full_mean, p1_cor_vv_vg_mean,
                                                 p2_cor_hh_full_mean, p2_cor_vv_full_mean,
                                                 p3_cor_hh_full_mean, p3_cor_vv_full_mean),
                         "SA Mean Coherence" = c(p1_cor_hh_vg_mean, p2_cor_vv_vg_mean,
                                                 p2_cor_hh_vg_mean, p2_cor_vv_vg_mean,
                                                 p3_cor_hh_vg_mean, p3_cor_vv_vg_mean),
                         "FS UNW Loss" = c(),
                         "SA UNW Loss" = c())

# conver to latex format
table02 %>%
  kbl(caption="Summary Statistics of Financial Well-Being Score by Gender and Education",
      format="latex",
      col.names = c("Pair","Mean","SD","Median","IQR"),
      align="r") %>%
  kable_minimal(full_width = F,  html_font = "Source Sans Pro")




