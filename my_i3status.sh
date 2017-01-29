#!/bin/bash

# Prerend i3status with certain other information
# For now, the current keyboard layout will do. Will possibly add more later
# Source: docs.slackware.com/howtos:window_managers:keyboard_layout_in_i3

i3status | while :
do
    read line
    LG=$(setxkbmap -query | awk '/variant/{print $2}')
    if [ $LG == "dvorak" ]
    then
        dat="[{ \"full_text\": \"us_dv\", \"color\":\"#009E00\" },"
    else
        dat="[{ \"full_text\": \"us_intl\", \"color\":\"#C60101\" },"
    fi
    echo "${line/[/$dat}" || exit 1
done

