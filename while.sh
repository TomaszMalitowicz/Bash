#!/bin/bash

licznik=0
while [ $licznik -lt 10 ]; do
    echo "Licznik: $licznik"
    (( licznik++ ))
done
echo "bonus: $licznik"