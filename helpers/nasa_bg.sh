#!/bin/bash

# check connection
ping -c 3 google.de 2>&1 > /dev/null
ping_check=$?

if [ $ping_check -eq 1 ]; then
    exit 1
fi
RSS_FILE_NAME="lg_image_of_the_day.rss"
wget -q http://www.nasa.gov/rss/lg_image_of_the_day.rss
file $RSS_FILE_NAME | grep gzip 2>&1 > /dev/null
is_not_gzip=$?

if [ $is_not_gzip -eq 0 ]; then
    rss=`zcat $RSS_FILE_NAME`
else
    rss=`cat $RSS_FILE_NAME`
fi

# extract urls and get the newest one
img_url=`echo $rss | grep -o '<enclosure [^>]*>' | grep -o 'http://[^\"]*' | head -1`
img_name=`echo $img_url | grep -o [^/]*\.\w*$`
mkdir -p $HOME/.backgrounds
wget -q -O $HOME/.backgrounds/$img_name $img_url
# set background with feh, and delete the rss file
feh --bg-max $HOME/.backgrounds/$img_name
rm $RSS_FILE_NAME
