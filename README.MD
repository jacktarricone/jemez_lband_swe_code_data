# jemez_lband_swe_code_data

This is the code (R and Python) and data used to conduct the analysis and create the figures for the forthcoming article in The Cryosphere, "Estimating snow accumulation and ablation with L-band InSAR" by Tarricone et al. Further information on the article will be updated upon publication. Specfifc information about prouduts is located in the Supplemntary Material.

Author: Jack Tarricone \
Contact: jtarricone@nevada.unr.edu

A user must first unzip the downloaded file, install the libraries needed on top of each script, and set working directory to unszip folder.

```
# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative

setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd
```

## List of Scripts
	rasters/
        amplitude/                             UAVSAR amplitude data from 12, 19, and 26 February
        atm_corrected_unw/                     Atmospherically corrected UAVSAR UNW
        dem/                                   Lidar DEM
        dswe/                                  InSAR-derived dSWE data
        fsca/                                  Landsat fSCA from 18 February and 5 March
        gpr/                                   GPR dSWE data
        incidence_angle/                       Inc. Angle and other products
        lvk/                                   LVK raster and component vectors
        no_snow_uncert/                        No fSCA mask dSWE data
        slc/                                   Single Look Complex data
        uavsar_p1_feb12-19/					   12-19 February InSAR
        uavsar_p2_feb19-26/                    19-26 February InSAR
        uavsar_p3_feb12-26/                    12-26 February InSAR
	scripts/	
		create_figures/
			create_fig05:                      Time series of snow depth, temp, wind speed, isolation during the study period
			create_fig07:                      Density plot showing atm delay for snow cover and snow free pixels
			create_fig10_table04:              dSWE histograms and metrics table
			create_fig11:                      InSAR vs. (a) depth sensors, pits, (b) gpr dSWE
		processing/  
			atmospheric_correction_feb12-19.R: Atmospherically correct 12-19 February unwrapped phase data
			atmospheric_correction_feb12-26.R: Atmospherically correct 12-26 February unwrapped phase data
			categorize_aspect_raster.R:        Bin DEM into north and south facing slopes
			convert_amp_to_db.R:               Convert linear amplitude to decibels
			create_lkv_raster.R:               Make geocoded LVK rasters
			create_new_inc.R:                  Make new lidar-derived incidence angle raster
			fsca_stats.R:                      Generate fSCA stats
			geolocate_lvk_jemez.py:	           Geolocate SLC data using uavsar_pytools
			insar_swe_functions.R:             SWE inversion function
			landsat_fsca_processing.R:         Formatting fSCA data
			no_snow_swe_uncert_analysis.R      Calculate no snow SWE change for uncertainty analysis
			swe_inversion_feb12-feb19.R:	   SWE inversion for 12-19 February
			swe_inversion_feb12-feb26.R:	   SWE inversion for 19-26 February
			swe_inversion_feb19-feb26.R:       SWE inversion for 12-26 February
			uavsar_data_download.py:           Download UAVSAR data using uavsar_pytools

