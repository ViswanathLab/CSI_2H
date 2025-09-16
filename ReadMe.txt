Instructions
Step 1: Import your "High resolution anatomical reference image" using file 'LoadT2wHR_RefImage.m' or 'LoadT2wHR_RefImage_pv360.m' depending on your Paravision version (PV6.0.1 or PV360). Run the code after giving the folder number. Output 'RefImage' will be created and be available in the WorkSpace.
Step 2: Import your "2H CSI spectroscopic data" using file 'LoadCSIreconMulti.m'. Run the code after inputing the folder number and Paravision version. Output 'MetImageC' will be created and be available in the WorkSpace.
Step 3: Now that you have the anatomical reference image and the 2H-CSI data as matlab matrixes, you are ready to further process your data (spectra zero fill & apodize, calculate metabolic maps and evaluate SNR) using 'AnalyzeImage_2DCSI_2Hglc.m'. This code allow you to plot the different CSI frames collected as SNR images or the SNR of the sum of all the collected CSIs.

Evaluation of SNR in a Region Of Interest (ROI): use code 'SNRevaluationROI.mat'. Before using this code you should have processed your Bruker data through AnalyzeImage_2DCSI_2Hglc. Required data are: RefImage - anatomical image for reference and localization of region of interest, inim_lac - matrix with the values of lactate in a 8x8.

Files included (Matlab R2023b)
Main files:
LoadT2wHR_RefImage.m
LoadT2wHR_RefImage_pv360.m
LoadCSIreconMulti.m
AnalyzeImage_2DCSI_2Hglc.m
SNRevaluationROI.m
Function file:
readBrukerHeader.m
LoadCSIreconFun.m
LoadCSIreconFun_pv360.m

Note: code is optimized for analyzing 2H-glucose data but can be easilty modified for other 2H labeled compounds.
