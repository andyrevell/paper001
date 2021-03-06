
#!/bin/bash

# The user will specify the main path and the patient ID folder
# an example of an ID could be HUP138
# The user must also specify the type of mag field of MRI imaging (3T or 7T)
#source /opt/fsl-6.0.1/etc/fslconf/fsl.sh
export MAIN_DIR=$1
export PROCESSED_DIR=$2
export templatePath=$3
export ID=$4
export session=$5

input=$MAIN_DIR/sub-${ID}/ses-${session}
tmp=$PROCESSED_DIR/sub-${ID}/imaging/dwi/tmp
mkdir -p $tmp
name=sub-${ID}_ses-${session}

#Example inputs
#MAIN_DIR=/gdrive/public/DATA/Human_Data/BIDS; ID=RID0194; session=preop3T; templatePath=/gdrive/public/TOOLS/atlases_and_templates/templates
#sh dwi_motionEddyAndDistortionCorrection_AS.sh /gdrive/public/DATA/Human_Data/BIDS RID0194 preop3T /gdrive/public/TOOLS/atlases_and_templates/templates        #Dont include this: /MNI152_T1_1mm_brain.nii.gz
#new exaple shell input from singularity container: (as of 4/25/2020)
#ALEX, RUN THIS:
# sh dwi_motionEddyAndDistortionCorrection_AS.sh /gdrive/public/DATA/Human_Data/BIDS_new /gdrive/public/DATA/Human_Data/BIDS_processed_data /gdrive/public/TOOLS/atlases_and_templates/templates RID0529 preop3T

#Brain Extract 
echo "brain extracting T1"
# Use FSL Bet function with options to generate a binary brain mask for T1
# Also use the option -f to set a fractional intensity threshold of 0.35
# FSL defaults to a frac intensity of 0.5. smaller gives larger brain estimate
bet $input/anat/${name}_acq-3D_T1w.nii $tmp/${name}_T1w_brainExtracted.nii -m -f 0.35
# Brain Extract the DWI image
echo "brain extracting DWI"
# devise a loop to pull out the b=0 images and average them 
# This is necessary to have a 3D template for later registrations to the DWI space
i=0
for line in $(cat $input/dwi/${name}_dwi.bval)
do 	
	if [ $line -lt 10 ]
	then	
		#echo $line
		#echo $i
		fslroi $input/dwi/${name}_dwi.nii $tmp/b0_$i.nii $i 1
	fi
	i=$((i+1))
done
# merge the Bo images back together and then take their averages
fslmerge -t $tmp/B0mergedAll $tmp/b0_*
fslmaths $tmp/B0mergedAll -Tmean $tmp/B0average
# brain extract the b=o DWI state
bet $tmp/B0average $tmp/${name}_dwi_brainExtracted -m -f 0.35
# Brain Extract the magnitude of B0 also using bet function in fsl
echo "brain extracting magnitude image"
bet $input/fmap/${name}_magnitude1.nii $tmp/${name}_magnitude1_brainExtracted.nii -m -f 0.35
# Correct noisey edges of the image 
echo "eroding brain extracted magnitude image"
fslmaths $tmp/${name}_magnitude1_brainExtracted.nii -ero $tmp/${name}_magnitude1_brainExtracted_eroded.nii
# Prepare the field map 
echo "fsl_prepare_fieldmap \n\n\n"
# Argument 2.46 is difference in echo times used within the fieldmap acquisition
fsl_prepare_fieldmap SIEMENS $input/fmap/${name}_phasediff.nii $tmp/${name}_magnitude1_brainExtracted.nii $tmp/${name}_fmap_rads.nii.gz 2.46


# add eddy and motion correction before registration
# First step is reading in the json file to extract relevant information 
echo "reading json file"
json=$input/dwi/${name}_dwi.json
# pull out the phase encoding direction in a format that is required for eddy correction 
echo -e"getting phase encoding direction"
PED=$(sed -ne 's/.*PhaseEncodingDirection": "//gp' $json | cut -c 1-2)
echo PED is $PED
if [ $PED = "i" ];then
   PE_vector="1 0 0"
   pedirDir="x"
elif [ $PED = "j" ];then
   PE_vector="0 1 0"
   pedirDir="y"
elif [ $PED = "k" ];then
   PE_vector="0 0 1"
   pedirDir="z"   
elif [ $PED = "i-" ];then
   PE_vector="-1 0 0"
   pedirDir="-x"
elif [ $PED = "j-" ];then
   PE_vector="0 -1 0"
   pedirDir="-y"
elif [ $PED = "k-" ];then
   PE_vector="0 0 -1"
   pedirDir="-z"
else
   echo "Unknown Phase Encoding Direction"
fi

echo pedirDir: ${pedirDir}
#Create index for eddy to know which acquisition parameters apply to which volumes                                                      
echo "creating index.txt"
volume_length=$(awk '{print NF}' $input/dwi/${name}_dwi.bval | sort -nu | tail -n 1) #finds how many volumes there are                    

indx=""
echo $indx> $tmp/index.txt
for i in $( seq 1 $volume_length )
do
    sed -i '$ s/$/1 /' $tmp/index.txt
    #echo $i
done
#cat $tmp/index.txt

#echo $indx
#echo $indx> $tmp/index.txt
#cat $tmp/index.txt
# Also pull out the echospacing for use in epi registration 
echo "getting echo spacing \n\n\n"
ES=$(sed -ne 's/.*EffectiveEchoSpacing": //gp' $json | rev | cut -c 2- | rev)
# get the inverse of the PEbandwidthperpixel.
PE_value=$(sed -ne 's/.*BandwidthPerPixelPhaseEncode": //gp' $json | rev | cut -c 2- | rev)
PE_value=$(echo "1/ $PE_value" | bc -l)
# Now we need to recreate the --acqp file needed for Eddy Correction 
echo $PE_vector 0$PE_value> $tmp/acqparams.txt
# here we can now perform the Eddy Correction. First we will try using eddy openmp (NoGPU)
#imain=$3T_P26_multishell.nii
#bvec=$3T_P26_multishell.bvec
#bval=$3T_P26_multishell.bval 
echo "Performing eddy correction"
eddy_openmp --imain=$input/dwi/${name}_dwi.nii --mask=$tmp/${name}_dwi_brainExtracted \
 --acqp=$tmp/acqparams.txt --index=$tmp/index.txt --bvecs=$input/dwi/${name}_dwi.bvec --bvals=$input/dwi/${name}_dwi.bval --repol --out=$tmp/${name}_dwi_eddy_corrected.nii --verbose

 
# Perform Linear (flirt) registration of Template to T1 space 
echo "Performing registration of Template to T1 Space"
flirt -in $templatePath/MNI152_T1_1mm_brain.nii.gz -ref $tmp/${name}_T1w_brainExtracted.nii -dof 12 -out $tmp/TemplateToT1space.nii.gz -omat $tmp/TemplateToT1.mat  
# Perform epi registration of DWI to T1 space  
fslroi $tmp/${name}_dwi_eddy_corrected.nii.gz $tmp/${name}_dwi_eddy_correction_first_vol_for_epi_reg 0 1 #epi_reg is much faster (and only works in FSL version 6.0+) with a single 3D volume rather than the whole 4D image of the diffusion imaging
echo "Performing epi registration"
epi_reg --epi=$tmp/${name}_dwi_eddy_correction_first_vol_for_epi_reg.nii --t1=$input/anat/${name}_acq-3D_T1w.nii \
--t1brain=$tmp/${name}_T1w_brainExtracted.nii --fmap=$tmp/${name}_fmap_rads.nii.gz \
--fmapmag=$input/fmap/${name}_magnitude1.nii \
--fmapmagbrain=$tmp/${name}_magnitude1_brainExtracted_eroded.nii \
--echospacing=$ES --pedir=$pedirDir --out=$tmp/${name}_dwi_epireg.nii \
-v --noclean

echo "Applying epir_reg warp to entire DWI image"
#We get a warp image output from epireg of the first volume. Now we want to apply that warp to the entire 4D image, using applywarp. 
applywarp --ref=$input/anat/${name}_acq-3D_T1w.nii --in=$tmp/${name}_dwi_eddy_corrected.nii.gz --warp=$tmp/${name}_dwi_epireg_warp.nii.gz --out=$tmp/${name}_dwi_applywarp -v

echo "Transforming T1 to DWI space"
#Epireg tranforms the DWI to T1 space. For tractography purposes, we want to do reconstruction in the native DWI space, so we use the inverse matrix (_inv.mat) from epi_reg to put the the DWI back into DWI space
flirt -ref $tmp/${name}_dwi_brainExtracted.nii -in $tmp/${name}_dwi_applywarp.nii -applyxfm -init $tmp/${name}_dwi_epireg_inv.mat -out $tmp/${name}_dwi-eddyMotionB0Corrected.nii.gz
cp $tmp/${name}_dwi-eddyMotionB0Corrected.nii.gz $tmp/../${name}_dwi-eddyMotionB0Corrected.nii.gz

#copying bvecs and bvals to same output folder (dsi_studio needs these files in the same directory to work)
cp $input/dwi/${name}_dwi.bvec $tmp/../${name}_dwi-eddyMotionB0Corrected.bvec
cp $input/dwi/${name}_dwi.bval $tmp/../${name}_dwi-eddyMotionB0Corrected.bval






###echo "Transforming AAL to DWI space"
# Perfrom the transformation of the AAL atlas to the DWI space
# This is two part-- transform the AAL to T1 space then from T1 to DWI space 
###convert_xfm -omat $tmp/AALtoDWI.mat -concat $tmp/dwi/${name}_dwi_epireg_T1toDWI.mat $tmp/TemplateToT1.mat
# check for missing args later, use nearest nieghbors algorithm to do this 
###flirt -ref $tmp/${name}_dwi_brainExtracted.nii -in $templatePath/AAL600.nii -applyxfm -init $tmp/AALtoDWI.mat -interp nearestneighbour -out $tmp/AAL600toDWIspace.nii
echo "Done!"
# Perform Linear (flirt) registration of T1 to the DWI space
###echo "Performing registration of T1 to DWI space"
###flirt -in $tmp/${name}_T1w_brainExtracted.nii -ref $tmp/${name}_dwi_brainExtracted.nii -applyxfm -init $tmp/dwi/${name}_dwi_epireg_T1toDWI.mat -out $tmp/${name}_T1wToDWI.nii.gz   













