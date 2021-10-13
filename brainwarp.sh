echo "loading filename and optional parameters..."
t1=`jq -r '.t1' config.json`
optional_params=`jq -r '.optional_params' config.json` # currently the only option is null
intense=`jq -r '.intense' config.json` # true, false, or test

echo "loading template..."
template=`jq -r '.template' config.json` # currently the only option is MNI152
prefix=output/t1w_

echo "creating output folder..."
mkdir -p output

echo "warping..."

if [ "$intense" == "false" ]; then
    # less intense
    ANTS 3 -m CC[$t1,$template,1,4] -i 100x100x50 -o $prefix -t SyN[0.25] -r Gauss[3,0]
elif [ "$intense" == "true" ]; then
    # more intense
    ANTS 3 -m CC[$t1,$template,1,4] -i 100x100x100x25 -o $prefix -t SyN[0.25] -r Gauss[3,0]
elif [ "$intense" == "test" ]; then
    # for testing, only iterates 1x1x1
    ANTS 3 -m CC[$t1,$template,1,4] -i 1x1x1 -o $prefix -t SyN[0.25] -r Gauss[3,0]
else
    # error out
    echo "you must choose a value for intense: true, false, test"
    exit 1
fi

echo "registering..."
# creating the registered image
WarpImageMultiTransform 3 $t1 output/t1.nii.gz -R $template output/t1w_Warp.nii.gz output/t1w_Affine.txt

echo "warp complete!"
