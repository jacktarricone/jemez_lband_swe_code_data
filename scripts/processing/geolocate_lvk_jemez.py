#!/usr/bin/env python
# coding: utf-8

# In[2]:


# geolocate look vector components
# jack tarricone

get_ipython().run_line_magic('matplotlib', 'inline')
import sys
import os
import glob
import numpy as np
from osgeo import gdal
import matplotlib.pyplot as plt
import rasterio as rio
from rasterio.plot import show
from uavsar_pytools.georeference import geolocate_uavsar


# In[3]:


## set function inputs
os.chdir('/Users/jacktarricone/ch1_jemez/jemez_lband_swe_code_data/rasters/')


# In[4]:


# input data
data = './slc/alamos_35915_01_BU_s1_2x8.lkv'

# annotationn file
ann_fp = './slc/alamos_35915_20005_003_200212_L090HH_01_BU.ann'

# saving directory
out_dir = './lvk'

# lat lon heigh file
llh_fp = './slc/alamos_35915_01_BU_s1_2x8.llh'


# In[5]:


##  run funciton, it works, just very slowly
geolocated = geolocate_uavsar(in_fp   = data, 
                              ann_fp  = ann_fp, 
                              out_dir = out_dir, 
                              llh_fp  = llh_fp)

