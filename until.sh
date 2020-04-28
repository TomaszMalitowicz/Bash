#!/bin/bash

licznik=20
until [ $licznik -lt 10 ]; do
    echo "Licznik: $licznik"
    (( licznik-- ))
done
echo "bonus: $licznik"