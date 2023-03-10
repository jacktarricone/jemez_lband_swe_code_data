# jemez_lband_swe_code_data

This is the R and Python code used to conduct the analysis and create the figures for the forthcoming article in The Cryosphere, "Estimating snow accumulation and ablation with L-band InSAR" by Tarricone et al. Further information on the article will be updated upon publication.

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

	create_figures/
		create_fig07: Density plot showing atm delay for snow cover and snow free pixels
		create_fig11: InSAR vs. (a) depth sensors, pits, (b) gpr dSWE
	processing/
		atmospheric_correction_feb12-19.R: Atmospherically correct 12-19 February unwrapped phase data
		atmospheric_correction_feb12-26.R: Atmospherically correct 12-26 February unwrapped phase data
		convert_amp_to_db.R:               Convert linear amplitude to decibels
		swe_inversion_feb12-feb19.R:	   SWE inversion for 12-19 February
		swe_inversion_feb12-feb26.R:	   SWE inversion for 19-26 February
		swe_inversion_feb19-feb26.R:       SWE inversion for 12-26 February
		uavsar_data_download.py:           Download UAVSAR data using uavsar_pytools

