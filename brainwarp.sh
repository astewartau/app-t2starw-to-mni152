#!/bin/sh

set -e

echo "[INFO] Loading parameters from config.json..."
t2starw=`jq -r '.t2starw' config.json`
optional_params=`jq -r '.optional_params' config.json` # currently the only option is null
intense=`jq -r '.intense' config.json` # true, false, or test
template=`jq -r '.template' config.json` # currently the only option is MNI152
segmentation=`jq -r '.segmentation' config.json` # MNI segmentation to bring into T2*-weighted space
prefix=output/MNI-to-T2starw_

echo "[INFO] Creating output folder..."
mkdir -p output

echo "[INFO] Registering MNI template to T2*-weighted image..."

if [ "$intense" = "false" ]; then
    # less intense
    ANTS 3 -m CC[$t2starw,$template,1,4] -i 100x100x50 -o $prefix -t SyN[0.5] -r Gauss[3,0] --do-rigid TRUE
elif [ "$intense" = "true" ]; then
    # more intense
    ANTS 3 -m CC[$t2starw,$template,1,4] -i 100x100x100x25 -o $prefix -t SyN[0.5] -r Gauss[3,0] --do-rigid TRUE
elif [ "$intense" = "test" ]; then
    # for testing, only iterates 1x1x1
    ANTS 3 -m CC[$t2starw,$template,1,4] -i 1x1x1 -o $prefix -t SyN[0.25] -r Gauss[3,0]
else
    # error out
    echo "[ERROR] You must choose a value for intense: true, false, test"
    exit 1
fi

echo "[INFO] Applying transform to MNI segmentations..."
WarpImageMultiTransform 3 $segmentation output/segmentation_in_T2starw.nii.gz -R $t2starw ${prefix}Warp.nii.gz ${prefix}Affine.txt --use-NN

echo "[INFO] Moving output..."
mkdir -p parcellation
mv output/segmentation_in_T2starw.nii.gz parcellation/parc.nii.gz
mv template/label.json parcellation/label.json

echo "[INFO] Warp complete!"

