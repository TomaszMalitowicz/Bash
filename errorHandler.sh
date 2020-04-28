#!/bin/bash

cd $1 2>/dev/null
if [ "$?" -eq 0 ]; then
ls -la
else
    echo "Podales zly katalog. Sprawdz swoj wpis."
fi