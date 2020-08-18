"""
2020.06.10
Andy Revell
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Purpose: script to get iEEG data in batches

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Logic of code:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Input:
  username: first argument. Your iEEG.org username
  password: second argument. Your iEEG.org password

  Reads data on which sub-IDs to download data from in data_raw/iEEG_times/EEG_times.xlsx
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Output:
Saves EEG timeseries in specified output directors
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example:

python3.6 Script_05_tractography.py

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"""

#%%
path = "/mnt"
import os
from os.path import join as ospj
import pandas as pd
import numpy as np
#%% Paths and File names

inputfile_EEG_times = ospj(path, "data_raw/iEEG_times/EEG_times.xlsx")
inputpath_dwi =  ospj(path, "data_processed/imaging")
outputpath_tractography = ospj(path, "data_processed/tractography")
                             
#%%Load Data
data = pd.read_excel(inputfile_EEG_times)    

sub_ID_unique = np.unique(data.RID)

#%%
for i in range(len(sub_ID_unique)):
    #parsing data DataFrame to get iEEG information
    sub_ID = sub_ID_unique[i]
    print("\n\nSub-ID: {0}".format(sub_ID))
    inputfile_dwi =    "sub-{0}_ses-preop3T_dwi-eddyMotionB0Corrected.nii.gz".format(sub_ID) 
    inputfile_dwi_fullpath = os.path.join(inputpath_dwi,"sub-{0}".format(sub_ID), inputfile_dwi)
    input_name = os.path.splitext(os.path.splitext(inputfile_dwi)[0])[0]
    outputpath_tractography_sub_ID = os.path.join(outputpath_tractography, "sub-{0}".format(sub_ID))
    if not (os.path.isdir(outputpath_tractography_sub_ID)): os.mkdir(outputpath_tractography_sub_ID)
    output_src =  os.path.join(outputpath_tractography, "sub-{0}".format(sub_ID), "{0}.src.gz".format(input_name))
    output_fib = "{0}.odf8.f5.bal.012fy.rdi.gqi.1.25.fib.gz".format(output_src)
    output_trk =  os.path.join(outputpath_tractography, "sub-{0}".format(sub_ID), "{0}.trk.gz".format(input_name))
    os.path.exists(output_fib)
    
    if (os.path.exists(output_trk)):
        print("Tractography file already exists: {0}".format(output_trk))
    if not (os.path.exists(output_trk)):#if file already exists, don't run below
        print("Creating Source File in DSI Studio")
        cmd = "dsi_studio --action=src --source={0} --output={1}".format( inputfile_dwi_fullpath, output_src)
        os.system(cmd)
        print("Creating Reconstruction File in DSI Studio")
        cmd = "dsi_studio --action=rec --source={0} --method=4 --param0=1.25".format(output_src)
        os.system(cmd)
        parameter_id = '7C1D393C9A99193FF3B3513Fb803Fcb2041bC84340420Fca01cbaCDCC4C3Ec'
        print("Creating Tractography File in DSI Studio")
        cmd = "dsi_studio --action=trk --source={0} --parameter_id={1} --output={2}".format(output_fib, parameter_id, output_trk)
        os.system(cmd)
       


#%%











