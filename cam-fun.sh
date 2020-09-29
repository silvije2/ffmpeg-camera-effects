#!/bin/bash

input=/dev/video0
output=/dev/video2

########################################################################
trap 'echo "Hey hacker, press enter for menu!"; ' 1 2 15 20

module=`lsmod | grep -c ^v4l2loopback`
if [ "$module" == "0" ]; then 
    echo -e "You need to load v4l2loopback kernel module first!\n sudo modprobe v4l2loopback\nIf you don't have it installed try:\n sudo apt-get install v4l2loopback-dkms"
    exit;
fi

function pixelate_motion {
    ffmpeg -loglevel quiet -f v4l2 -i $input \
    -filter_complex "\
    scale=848x480,format=rgb24,split=3[v1][v2][v3];
    [v2]scale=iw/10:-1,
    scale=848x480:flags=neighbor[v4];
    [v1]format=gray,
    scale=iw/4:-1,
    tblend=all_mode=difference,
    smartblur=2:lt=0,
    eq=brightness=1:contrast=3,
    maskfun=low=8:high=9:fill=255:sum=255,
    smartblur=1:lt=-30,
    floodfill=x=0:y=0:s0=0:d0=128,
    geq=lum_expr='if(eq(p(X\,Y)\,128)\,0\,255)',
    erosion,
    erosion,
    scale=848x480,
    format=rgb24[mask];
    [v3][v4][mask]maskedmerge,format=rgb24,scale=848x480
    " -pix_fmt yuv420p -f v4l2 $output
}

function pixelate_background {
    ffmpeg -loglevel quiet -f v4l2 -i $input \
    -filter_complex "\
    scale=848x480,format=rgb24,split=3[v1][v2][v3];
    [v2]scale=iw/10:-1,
    scale=848x480:flags=neighbor[v4];
    [v1]format=gray,
    scale=iw/4:-1,
    tblend=all_mode=difference,
    smartblur=2:lt=0,
    eq=brightness=1:contrast=3,
    maskfun=low=8:high=9:fill=255:sum=255,
    smartblur=1:lt=-30,
    floodfill=x=0:y=0:s0=0:d0=128,
    geq=lum_expr='if(eq(p(X\,Y)\,128)\,0\,255)',
    erosion,
    erosion,
    negate,
    scale=848x480,
    format=rgb24[mask];
    [v3][v4][mask]maskedmerge,format=rgb24,scale=848x480
    " -pix_fmt yuv420p -f v4l2 $output
}


PS3='Choose an effect: '
options=("Pixelate motion" "Pixelate background" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Pixelate motion")
            echo "Moving objects will be pixelated! Press Ctrl-C to stop effect."
            pixelate_motion
            ;;
        "Pixelate background")
            echo "Background (still) objects will be pixelated! Press Ctrl-C to stop effect."
            pixelate_background
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option: $REPLY";;
    esac
done

