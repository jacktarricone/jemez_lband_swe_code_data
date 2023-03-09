# jemez_lband_swe_code_data

This is the R and Python code used to conduct the analysis and create the figures for the forthcoming article in The Cryosphere, "Estimating snow accumulation and ablation with L-band InSAR" by Tarricone et al. Further information on the article will be updated upon publication.

Author: Jack Tarricone
Contact: jtarricone@nevada.unr.edu


A user must first unzip the downloaded file and install the libraries needed on top of each script.

The on top of each script, the your working directory need to b

```
# set path to '/jemez_lband_swe_code_data' that was downloaded and unzipped from zenodo
# all other file paths are relative

setwd("path/to/jemez_lband_swe_code_data")
list.files() #pwd
```

## list of scripts
scripts/
	processing/
		atmospheric_correction_feb12-19.R: Atmospherically correct 12-19 February unwrapped phase data
		atmospheric_correction_feb12-26.R: Atmospherically correct 12-26 February unwrapped phase data
		convert_amp_to_db.R:               Convert linear amplitude to decibels
		
		uavsar_data_download.py:		   Download UAVSAR data using uavsar_pytools
