#!/bin/bash
# Toggle between US intl layout and US dvorak layout

CURRENT_LAYOUT=$(setxkbmap -query | grep layout | awk '{print $2}')
CURRENT_VARIANT=$(setxkbmap -query | grep variant | awk '{print $2}')


if [ $CURRENT_VARIANT = "dvorak" ]
then
    NEW_VARIANT="intl"
else
    NEW_VARIANT="dvorak"
fi

setxkbmap $CURRENT_LAYOUT -variant $NEW_VARIANT

notify-send "Keyboard layout set to $CURRENT_LAYOUT, $NEW_VARIANT"
exit 0
