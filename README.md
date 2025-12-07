# Neural_pathways_VSTM

This repository contains the code of the paper "Multiple neural pathways to successful visual short-term memory across the lifespan". 

## Overview of content
### Analysis steps and scripts
A description of the analysis steps and the associated scripts

Step 1: Get the behavioral data for each subject - Combine_behavioral_data.m

Step 2: Create the relevant contrast in the GLM for each participant  - Create_contrasts.m

Step 3: Extract the data from each ROI for each participant and decide who to include - Extract_ROI_data.m

Step 4: Identify the modules of brain regions that covary in a similar way across participants & Get the average brain activity per module - Define_modules.m

Step 5: Get GM data for each module and each participant and regress out covariates - get_GM_data.m

Step 6: Get WM data for each module and each participant and regress out covariates - get_WM_data.m

Step 7: Run the LPA and all the statistical tests - LPA.R

Step 8: Compare subgroup characteristics statistically - R_BayesFactor.R

## Associated files 
The ROI atlas used for this paper Craddock_ROIs_JNpaper_reordered.nii 
