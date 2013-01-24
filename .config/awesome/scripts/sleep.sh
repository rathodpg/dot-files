#!/bin/bash

logger "Sleep pressed just now"
/usr/bin/xlock &
sudo /usr/sbin/pm-suspend
