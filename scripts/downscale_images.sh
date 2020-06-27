#!/bin/bash
# This script downscales all images of the members using imagemagick.
#
# If an image size is larger than 300KB, we downscale it.
# If the image has a resolution higher than 72dpi, we downscale it to 72dpi.
# If the image has a width higher than 400px; we downscale it to a width of 400px
# If the image has a height higher than 400px; we downscale it to a height of 400px
LIMIT=`printf "%09d" 300000`
for IMAGE in `grep -o 'assets/images/.*' _data/committee/members.yml`; do
  size=`convert $IMAGE -print "%B" /dev/null | xargs printf "%09d"`
  if [[ $size > $LIMIT ]]; then
    echo '---------------------------------------'
    convert $IMAGE -print "${IMAGE} %wx%h %xx%y\n" /dev/null
  fi
  while [[ $size > $LIMIT ]]; do
    DPI=`convert $IMAGE -print "%x" /dev/null | xargs printf "%.0f" | xargs printf "%03d"`
    WIDTH=`convert $IMAGE -print "%w" /dev/null | xargs printf "%04d"`
    HEIGHT=`convert $IMAGE -print "%h" /dev/null | xargs printf "%04d"`
    echo "$WIDTH $HEIGHT $DPI"
    if [[ $DPI > 072 ]]; then
      MESSAGE="Decrease resolution"
      convert $IMAGE -density 72 $IMAGE
    elif [[ $WIDTH > 0400 ]]; then
      MESSAGE="Decrease width"
      convert $IMAGE -geometry 400x $IMAGE
    elif [[ $HEIGHT > 0400 ]]; then
      MESSAGE="Decrease height"
      convert $IMAGE -geometry x400 $IMAGE
    fi
    git add $IMAGE
    git commit -m "${MESSAGE} of `basename ${IMAGE}`"
    size=`convert $IMAGE -print "%B" /dev/null | xargs printf "%09d"`
  done
done