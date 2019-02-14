#!/bin/sh
# Improved blurlock using ffmpeg for faster lock times

# get the X canvas size
screensize=`xdpyinfo | grep -i dimensions: | sed 's/[^0-9]*pixels.*(.*).*//' | sed 's/[^0-9x]*//'`
screensizecolon=`echo $screensize | sed 's/x/:/'`
# How much you want to shrink it (multiplies by 1/scale)
scale='10.00'

# 'nearest neighbor' resize, creates a pixelly thing
# speed: 0.5s
# downscales in nearest neighbor mode, upscales in nearest neighbor

#ffmpeg -loglevel 0 -y -f x11grab -s $screensize -i $DISPLAY -vframes 1 -filter_complex \
#    "[0]scale=iw/$scale:ih/$scale:flags=neighbor[v];
#     [v]scale=$screensizecolon:flags=neighbor" \
#    /tmp/screen_locked.png

# 'nearest neighbor' resize, creates a pixelly thing
# speed: 0.6s
# downscales in bilinear mode, upscales in nearest neighbor

#ffmpeg -loglevel 0 -y -f x11grab -s $screensize -i $DISPLAY -vframes 1 -filter_complex \
#    "[0]scale=iw/$scale:ih/$scale:flags=bilinear[v];
#     [v]scale=$screensizecolon:flags=neighbor" \
#    /tmp/screen_locked.png

# 'area' resize:
# speed: 0.7s
# This one produces a blur using fast_bilinear

ffmpeg -loglevel 0 -y -f x11grab -s $screensize -i $DISPLAY -vframes 1 -filter_complex\
    "[0]scale=iw/$scale:ih/$scale[v];
     [v]scale=$screensizecolon[out]" \
    -map "[out]" -sws_flags fast_bilinear /tmp/screen_locked.png

# prank people
#xinput test-xi2 --root | sed -n '/detail\: 107/{p;q;}' | xargs -I % sh -c 'killall xinput; ffmpeg -f video4linux2 -i /dev/video0 -ss 0:0:0.5 -y -vf "scale=2560:1440"  -frames 1 /tmp/screen_locked.png; killall i3lock; i3lock -i /tmp/screen_locked.png' &

# Lock
i3lock -i /tmp/screen_locked.png
