#!/bin/bash

for element in $( ls $1 ); do
    if [ "$element" = "home" ]; then
        break;
    fi

    if [ "$element" = "script.sh" ]; then
        continue;
    fi
    echo $element
done