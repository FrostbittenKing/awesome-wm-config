#!/bin/bash

# check connection
ping -c 3 google.de 2>&1 > /dev/null
ping_check=$?

if [ $ping_check -eq 1 ]; then
    exit 1
fi


APOD_URL="https://apod.nasa.gov"
APOD_HTML_NAME="astropix.html"
RSS_FILE_NAME="apod.rss"
RSS_URL="https://apod.nasa.gov/$RSS_FILE_NAME"
wget -q "$APOD_URL"


html_file_name="index.html"
# extract urls and get the newest one
img_url=$APOD_URL/apod/`grep -o '.*IMG.*' $html_file_name | grep -o '\".*\"' | sed -e 's/\"//g' `
img_name=`echo $img_url | grep -o [^/]*\.\w*$`
mkdir -p $HOME/.backgrounds
wget -q -O $HOME/.backgrounds/$img_name $img_url
# set background with feh, and delete the rss file
feh --bg-max $HOME/.backgrounds/$img_name
rm $html_file_name
