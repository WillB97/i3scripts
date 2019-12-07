#!/bin/bash

# get the X canvas size
screensize=( `xdpyinfo | awk '/dimensions/{size=$2; sub("x",":",$2);print size FS $2}'` )
# How much you want to shrink it (multiplies by 1/scale)
scale='10.00'

filters=( "fast_bilinear" "bilinear" "bicubic" "experimental"
"neighbor" "area" "bicublin" "gauss" "sinc" "lanczos" "spline" )

echo "${screensize[0]}"

sleep 5

if ! [ -d /tmp/screen ]; then 
    mkdir /tmp/screen 
fi

(time (import -window root /tmp/screen/screenshot.png  # take screenshot
convert /tmp/screen/screenshot.png -blur 0x5 /tmp/screen/blurlock.png; # blur it
rm /tmp/screen/screenshot.png)) 2>&1 |
awk '/real/{print "Blurlock style " $2}'

for infilt in "${filters[@]}"; do
    outfilt="$infilt"
    file_name=${infilt}.png
    # for outfilt in "${filters[@]}"; do
        # file_name=${infilt}_${outfilt}.png
        (time ffmpeg -loglevel 0 -y -f x11grab -s ${screensize[0]} \
            -i $DISPLAY -vframes 1 -filter_complex "
            [0]scale=iw/${scale}:ih/${scale}:flags=${infilt}[v];
            [v]scale=${screensize[1]}:flags=${outfilt}" /tmp/screen/${file_name}) 2>&1|
        awk -v IN="$infilt" -v OUT="$outfilt" '/real/{print IN FS $2}' # '/real/{print IN " -> " OUT FS $2}'
    # done
done

notify-send "Test complete"