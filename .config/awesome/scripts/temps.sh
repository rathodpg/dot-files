#!/bin/bash

while [ 1 ];do
    sleep 15
    echo "tempwidget.text = \"$(~/.showtemp.sh)\"" | awesome-client
done
