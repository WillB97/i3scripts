#!/bin/sh
# Improved blurlock using ffmpeg for faster lock times

# Don't add a lock screen if one is already running
if pgrep -x i3lock; then exit 0; fi

# get the X canvas size
screensize=( `xdpyinfo | awk '/dimensions/{size=$2; sub("x",":",$2);print size FS $2}'` )
# How much you want to shrink it (multiplies by 1/scale)
scale='10.00'
down_filter="area" # filter used while downscaling the image (see ffmpeg_tests)
up_filter="area" # filter used while scaling the image back up to full-size

ffmpeg -loglevel 0 -y -f x11grab -s ${screensize[0]} -i $DISPLAY -vframes 1 -filter_complex \
   "[0]scale=iw/${scale}:ih/${scale}:flags=$down_filter[v];
    [v]scale=${screensize[1]}:flags=$up_filter" \
   /tmp/screen_locked.png

# Lock
i3lock -i /tmp/screen_locked.png
