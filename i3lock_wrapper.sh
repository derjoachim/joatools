#!/bin/bash
# Source: https://www.reddit.com/r/unixporn/comments/3358vu/i3lock_unixpornworthy_lock_screen/
scrot /tmp/screen.png
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png
[[ -f /home/joachim/Pictures/Icons/lock.png ]] && convert /tmp/screen.png /home/joachim/Pictures/Icons/lock.png -gravity center -composite -matte /tmp/screen.png
i3lock -i /tmp/screen.png
