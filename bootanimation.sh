#!/bin/bash
# 
# Create bootanimation.zip for teyes car audio cc2 and spro
# based on youtube-to-bootanimation.sh - Download & create Android boot animations from YouTube videos
# author: Jared Rummler <jared@jrummyapps.com>
#

# Replace URL with any YouTube link
#url="https://www.youtube.com/watch?v=Ynm6Vgyzah4"
# Set the frames per second for the boot animation
fps=30
# where the bootanimation will be created


tmp="`pwd`/temp"
out=$1

# delete the directory if it currently exists
rm -rf $tmp

# create the directory
mkdir -p $tmp

# Use youtube-dl to download the video
# https://github.com/rg3/youtube-dl
#youtube-dl -o $out $url

# Make the directory for the frames to be extracted to
mkdir -p $tmp/part0

# Use ffmpeg to extract frames from the video
# https://trac.ffmpeg.org/wiki/UbuntuCompilationGuide

ffmpeg -i "$out" -vf scale=1024:600 -preset slow -crf 18 "$tmp/output.mp4"


ffmpeg -i "$tmp/output.mp4" -qscale:v 2  $tmp/part0/00%05d.jpg

# Use ImageMagick to get the width and height of the first image
# http://www.imagemagick.org/
size=`identify -format '%w %h' $tmp/part0/0000001.jpg`

# Create the desc.txt file
echo "$size $fps" > $tmp/desc.txt
echo "p 1 0 part0" >> $tmp/desc.txt

# Create the bootanimation
cd $tmp
zip -0r bootanimation part0 desc.txt

# Remove the downloaded video
#rm $out

# Remove desc.txt
rm $tmp/desc.txt

# Create a GIF of the bootanimation
# fps = 1/(delay in seconds) = 100/(delay ticks)
delay=`echo "scale=2; 100/${fps}" | bc`
echo "Creating animated GIF..."
convert -delay $delay -loop 0 $tmp/part0/*.jpg -resize 300x -layers optimize $tmp/animation.gif

# Remove the folder with the images
echo "Cleaning up..."
rm -rf $tmp/part0

echo "Finished! Your boot animation is at $tmp/bootanimation.zip"
