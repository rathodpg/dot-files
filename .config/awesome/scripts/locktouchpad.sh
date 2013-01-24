#!/bin/bash

a=`xinput list-props 11 | grep "Device Enabled" | awk '{print $4}'`

if [ 0 -eq $a ];then
    /usr/bin/xinput set-prop 11 "Device Enabled" 1
    notify-send "Touchpad enabled"
else
    /usr/bin/xinput set-prop 11 "Device Enabled" 0
    notify-send "Touchpad disabled"
fi
#/usr/bin/xinput set-prop 11 "Device Enabled" 0
